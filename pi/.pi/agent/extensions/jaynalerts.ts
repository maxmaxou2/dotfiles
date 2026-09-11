// jaynalerts Pi integration — managed by `jaynalerts init --pi`

type ExtensionContext = {
	cwd: string;
};

type UiPromptStartEvent = {
	kind: "select" | "confirm" | "input" | "editor" | "custom";
	title?: string;
};

type ExecResult = {
	code: number;
	stderr: string;
};

export type PiExtensionApi = {
	on(
		event: "agent_settled",
		handler: (
			event: { type: "agent_settled" },
			ctx: ExtensionContext,
		) => Promise<void>,
	): void;
	on(
		event: "ui_prompt_start",
		handler: (
			event: UiPromptStartEvent,
			ctx: ExtensionContext,
		) => Promise<void>,
	): void;
	exec(
		command: string,
		args: string[],
		options?: { timeout?: number; cwd?: string },
	): Promise<ExecResult>;
};

const HOOK_TIMEOUT_MS = 10_000;

export default function JaynAlertsExtension(pi: PiExtensionApi): void {
	pi.on("agent_settled", async (_event, ctx) => {
		await runHook(pi, "on-agent-settled", ctx.cwd);
	});

	pi.on("ui_prompt_start", async (event, ctx) => {
		await runHook(
			pi,
			"on-ui-prompt",
			ctx.cwd,
			promptMessage(event.title, event.kind),
		);
	});
}

async function runHook(
	pi: PiExtensionApi,
	event: "on-agent-settled" | "on-ui-prompt",
	cwd: string,
	message?: string,
): Promise<void> {
	const args = ["pi-hook", event, "--cwd", cwd];
	if (message !== undefined) {
		args.push("--message", message);
	}

	try {
		const result = await pi.exec("jaynalerts", args, {
			cwd,
			timeout: HOOK_TIMEOUT_MS,
		});
		if (result.code !== 0) {
			warn(result.stderr.trim() || `hook exited with code ${result.code}`);
		}
	} catch (error) {
		warn(errorMessage(error));
	}
}

function promptMessage(
	title: string | undefined,
	kind: UiPromptStartEvent["kind"],
): string {
	const trimmed = title?.trim();
	if (trimmed) {
		return trimmed;
	}

	return kind === "confirm" || kind === "select"
		? "Approval required"
		: "Action required";
}

function warn(message: string): void {
	console.warn(`jaynalerts: Pi extension failed: ${message}`);
}

function errorMessage(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}
