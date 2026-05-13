import { createContext, notifyUser, resolveIcon } from "stay-alert";

type OpencodeClient = {
	app: {
		log(input: {
			body: {
				service: string;
				level: "warn";
				message: string;
			};
		}): Promise<unknown>;
	};
	session: {
		get(input: {
			path: { id: string };
		}): Promise<{ data?: { parentID?: string; title?: string } }>;
	};
};

type OpencodeEvent = { type: string; properties: unknown };

type PluginInput = {
	client: OpencodeClient;
};

type Plugin = (input: PluginInput) => Promise<{
	event: (input: { event: OpencodeEvent }) => Promise<void>;
}>;

let ctxPromise: Promise<Awaited<ReturnType<typeof createContext>>> | null =
	null;

function ctx(): Promise<Awaited<ReturnType<typeof createContext>>> {
	ctxPromise ??= createContext();
	return ctxPromise;
}

export const StayAlertPlugin: Plugin = async ({ client }) => {
	const warn = async (message: string, error?: unknown): Promise<void> => {
		const fullMessage = `stay-alert: ${message}${error === undefined ? "" : `: ${errorMessage(error)}`}`;

		try {
			await client.app.log({
				body: {
					service: "stay-alert",
					level: "warn",
					message: fullMessage,
				},
			});
		} catch {
			console.warn(fullMessage);
		}
	};

	return {
		event: async ({ event }) => {
			try {
				const context = await ctx();
				const iconPath = await resolveIcon(context.config, "opencode");

				if (isSessionIdleEvent(event)) {
					const session = await fetchSession(
						client,
						event.properties.sessionID,
						warn,
					);

					if (session?.parentID != null) {
						return;
					}

					await notifyUser(context, {
						title: sessionTitle(session?.title),
						message: "Done",
						iconPath,
					});
					return;
				}

				if (isPermissionUpdatedEvent(event)) {
					const session = await fetchSession(
						client,
						event.properties.sessionID,
						warn,
					);

					await notifyUser(context, {
						title: sessionTitle(session?.title),
						message: permissionMessage(event),
						iconPath,
					});
					return;
				}

				if (isToastEvent(event)) {
					await notifyUser(context, {
						title: event.properties.title ?? "opencode",
						message: event.properties.message,
						iconPath,
					});
				}
			} catch (error) {
				await warn("event handler failed", error);
			}
		},
	};
};

async function fetchSession(
	client: OpencodeClient,
	sessionID: string | undefined,
	warn: (message: string, error?: unknown) => Promise<void>,
): Promise<{ parentID?: string; title?: string } | null> {
	if (sessionID === undefined) {
		return null;
	}

	try {
		const session = await client.session.get({ path: { id: sessionID } });
		return session.data ?? null;
	} catch (error) {
		await warn("failed to inspect opencode session", error);
		return null;
	}
}

function sessionTitle(title?: string): string {
	if (typeof title === "string" && title.trim() !== "") {
		return `opencode · ${title.trim()}`;
	}
	return "opencode";
}

function isSessionIdleEvent(
	event: OpencodeEvent,
): event is { type: "session.idle"; properties: { sessionID: string } } {
	return (
		event.type === "session.idle" &&
		typeof event.properties === "object" &&
		event.properties !== null &&
		"sessionID" in event.properties &&
		typeof event.properties.sessionID === "string"
	);
}

function isToastEvent(event: OpencodeEvent): event is {
	type: "tui.toast.show";
	properties: { title?: string; message: string };
} {
	return (
		event.type === "tui.toast.show" &&
		typeof event.properties === "object" &&
		event.properties !== null &&
		(!("title" in event.properties) ||
			typeof event.properties.title === "string") &&
		"message" in event.properties &&
		typeof event.properties.message === "string"
	);
}

function isPermissionUpdatedEvent(event: OpencodeEvent): event is {
	type: "permission.updated";
	properties: { sessionID?: string; title?: unknown };
} {
	return (
		event.type === "permission.updated" &&
		typeof event.properties === "object" &&
		event.properties !== null
	);
}

function permissionMessage(event: { properties: { title?: unknown } }): string {
	if (
		typeof event.properties.title === "string" &&
		event.properties.title.trim() !== ""
	) {
		return `Permission required: ${event.properties.title}`;
	}

	return "Permission required";
}

function errorMessage(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}
