import { createContext, notifyUser } from "stay-alert";

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
		}): Promise<{ data?: { parentID?: string } }>;
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
				if (isSessionIdleEvent(event)) {
					if (
						await isSubagentSession(client, event.properties.sessionID, warn)
					) {
						return;
					}

					await notifyUser(await ctx(), {
						title: "opencode",
						message: "Done",
					});
					return;
				}

				if (isPermissionUpdatedEvent(event)) {
					await notifyUser(await ctx(), {
						title: "opencode",
						message: permissionMessage(event),
					});
					return;
				}

				if (isQuestionAskedEvent(event)) {
					if (
						await isSubagentSession(client, event.properties.sessionID, warn)
					) {
						return;
					}

					await notifyUser(await ctx(), {
						title: "opencode",
						message: "Question",
					});
					return;
				}

				if (isToastEvent(event)) {
					await notifyUser(await ctx(), {
						title: event.properties.title ?? "opencode",
						message: event.properties.message,
					});
				}
			} catch (error) {
				await warn("event handler failed", error);
			}
		},
	};
};

async function isSubagentSession(
	client: OpencodeClient,
	sessionID: string,
	warn: (message: string, error?: unknown) => Promise<void>,
): Promise<boolean> {
	try {
		const session = await client.session.get({ path: { id: sessionID } });
		return session.data?.parentID != null;
	} catch (error) {
		await warn("failed to inspect opencode session", error);
		return false;
	}
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
	properties: { title?: unknown };
} {
	return (
		event.type === "permission.updated" &&
		typeof event.properties === "object" &&
		event.properties !== null
	);
}

function isQuestionAskedEvent(event: OpencodeEvent): event is {
	type: "question.asked";
	properties: { sessionID: string };
} {
	return (
		event.type === "question.asked" &&
		typeof event.properties === "object" &&
		event.properties !== null &&
		"sessionID" in event.properties &&
		typeof event.properties.sessionID === "string"
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
