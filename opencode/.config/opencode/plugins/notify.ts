import type { Plugin } from "@opencode-ai/plugin";

export const NotifyPlugin: Plugin = async ({ $, client }) => {
  let lastNotify = 0;
  const notify = async (message: string) => {
    const now = Date.now();
    if (now - lastNotify < 1000) return;
    lastNotify = now;
    await $`terminal-notifier -title 'OpenCode' -message ${message} -sound default`;
  };

  return {
    event: async ({ event }) => {
      // Root session went idle — needs your input
      if (event.type === "session.idle") {
        const session = await client.session.get({
          path: { id: event.properties.sessionID },
        });
        if (session.data?.parentID) return; // skip subagents
        await notify("Agent requires input");
        return;
      }

      // Tool needs permission to run
      if (event.type === "permission.updated") {
        await notify("Permission required");
        return;
      }

      // Agent is asking a question with options
      if (event.type === "question.asked") {
        await notify("Question waiting");
        return;
      }
    },
  };
};
