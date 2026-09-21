// budget-guard — keep a small-model session inside a context and cost budget.
//
// Context: auto-compaction (settings.json `compaction.modelOverrides`) fires
// at contextWindow − reserveTokens. This extension warns the model a little
// earlier so the summary lands on a committed, compiling tree, not mid-edit.
//
// Cost: past `maxCost` the model is told to stop and write its state note;
// tool calls are refused from then on, and after a few refusals the run is
// terminated. `PI_BUDGET_MAX_COST` overrides the cap for one run.
//
// Models not listed in BUDGETS are left alone.

import type {
	ExtensionAPI,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";

type Budget = { softTokens: number; hardTokens: number; maxCost: number };

// `hardTokens` must equal contextWindow − reserveTokens for that model.
const BUDGETS: Record<string, Budget> = {
	"opencode-go/glm-5.3-flash": { softTokens: 80_000, hardTokens: 100_000, maxCost: 1.0 },
};

const REFUSALS_BEFORE_TERMINATE = 3;

export default function BudgetGuard(pi: ExtensionAPI): void {
	let warned = false;
	let spent = 0;
	let capped = false;
	let refusals = 0;

	pi.on("session_start", async (_event, ctx) => {
		warned = false;
		capped = false;
		refusals = 0;
		spent = spentSoFar(ctx);
		showStatus(ctx, undefined);
	});

	pi.on("session_compact", async (_event, ctx) => {
		warned = false;
		showStatus(ctx, undefined);
	});

	pi.on("turn_end", async (event, ctx) => {
		const budget = budgetFor(ctx);
		if (!budget) return;
		if (event.message.role === "assistant") {
			spent += event.message.usage?.cost?.total ?? 0;
		}
		const tokens = ctx.getContextUsage()?.tokens ?? null;
		showStatus(ctx, `ctx ${k(tokens ?? 0)}/${k(budget.hardTokens)} · $${spent.toFixed(2)}/$${budget.maxCost.toFixed(2)}`);

		if (!capped && spent >= budget.maxCost) {
			capped = true;
			steer(pi, costText(spent, budget));
			notify(ctx, `Cost cap $${budget.maxCost.toFixed(2)} reached ($${spent.toFixed(2)}); refusing further tool calls`);
			return;
		}
		if (!warned && tokens !== null && tokens >= budget.softTokens) {
			warned = true;
			steer(pi, contextText(tokens, budget));
			notify(ctx, `Context ${k(tokens)}: soft budget reached, steering to a clean stop`);
		}
	});

	pi.on("tool_call", async (_event, _ctx) => {
		if (!capped) return;
		refusals += 1;
		return {
			block: true,
			reason: "Cost cap reached. Reply with your state note; no more tool calls.",
			terminate: refusals > REFUSALS_BEFORE_TERMINATE,
		};
	});

	pi.registerCommand("budget", {
		description: "Show context and cost against this model's budget",
		handler: async (_args, ctx) => {
			const budget = budgetFor(ctx);
			const tokens = ctx.getContextUsage()?.tokens ?? 0;
			const model = `${ctx.model?.provider}/${ctx.model?.id}`;
			ctx.ui.notify(
				budget
					? `${model}: ctx ${k(tokens)} (soft ${k(budget.softTokens)}, compaction ${k(budget.hardTokens)}), spent $${spent.toFixed(3)} of $${budget.maxCost.toFixed(2)}`
					: `${model}: no budget configured`,
				"info",
			);
		},
	});
}

function budgetFor(ctx: ExtensionContext): Budget | undefined {
	const model = ctx.model;
	const budget = model ? BUDGETS[`${model.provider}/${model.id}`] : undefined;
	const override = Number(process.env.PI_BUDGET_MAX_COST);
	return budget && override > 0 ? { ...budget, maxCost: override } : budget;
}

function spentSoFar(ctx: ExtensionContext): number {
	let total = 0;
	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type === "message" && entry.message.role === "assistant") {
			total += entry.message.usage?.cost?.total ?? 0;
		}
	}
	return total;
}

function steer(pi: ExtensionAPI, content: string): void {
	pi.sendMessage(
		{ customType: "budget-guard", content, display: true },
		{ deliverAs: "steer" },
	);
}

function contextText(tokens: number, budget: Budget): string {
	return [
		`Context budget: ${k(tokens)} of ${k(budget.hardTokens)} tokens used. This session is compacted automatically at ${k(budget.hardTokens)}; only a summary of the work so far survives it.`,
		"Before that happens:",
		"1. Finish the edit in progress. Do not open new files or start the next item.",
		"2. `cargo check`; if green, commit what you have (requirement ids in the subject).",
		"3. End your reply with a state note: files touched, what compiles, what is red, the exact next command.",
	].join("\n");
}

function costText(spent: number, budget: Budget): string {
	return [
		`Cost cap reached: $${spent.toFixed(2)} of $${budget.maxCost.toFixed(2)}. Tool calls are refused from now on.`,
		"Reply now with a state note: files touched, what compiles, what is red, the exact next command. Nothing else.",
	].join("\n");
}

// ctx.ui is inert in print mode (`pi -p`); steer messages still work.
function showStatus(ctx: ExtensionContext, text: string | undefined): void {
	if (ctx.hasUI) ctx.ui.setStatus("budget", text);
}

function notify(ctx: ExtensionContext, text: string): void {
	if (ctx.hasUI) ctx.ui.notify(text, "warning");
}

function k(n: number): string {
	return `${Math.round(n / 1000)}k`;
}
