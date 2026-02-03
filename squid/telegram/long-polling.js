// index.js (Node 20+ recommended)
const TOKEN = process.env.TELEGRAM_TOKEN;

console.log("[boot] starting telegram long-poll bot...");

if (!TOKEN) {
  console.error("[boot] TELEGRAM_TOKEN is not set");
  process.exit(1);
}

process.on("exit", (code) => console.log("[exit] code:", code));
process.on("uncaughtException", (e) => console.error("[uncaughtException]", e));
process.on("unhandledRejection", (e) => console.error("[unhandledRejection]", e));

let offset = 0;

async function api(method, payload = {}) {
  const url = `https://api.telegram.org/bot${TOKEN}/${method}`;
  const r = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(payload),
  });

  const j = await r.json().catch(() => null);
  if (!j || !j.ok) {
    throw new Error(`${method} failed: ${r.status} ${JSON.stringify(j)}`);
  }
  return j.result;
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function main() {
  // Prove token works
  const me = await api("getMe");
  console.log(`[boot] authenticated as @${me.username} (id=${me.id})`);

  console.log("[poll] entering loop...");
  while (true) {
    try {
      const updates = await api("getUpdates", {
        offset,
        timeout: 30,
        allowed_updates: ["message", "edited_message"],
      });

      if (updates.length === 0) {
        // Normal: long poll timed out with no updates
        continue;
      }

      for (const u of updates) {
        offset = u.update_id + 1;

        const msg = u.message || u.edited_message;
        const text = msg?.text || "";
        const chatId = msg?.chat?.id;

        console.log('MSG:',msg)

        if (!chatId || !text.startsWith("/")) continue;

        const first = text.trim().split(/\s+/)[0];
        const command = first.split("@")[0];
        const args = text.trim().slice(first.length).trim();

        const reply = args
          ? `You sent command: ${command}\nArgs: ${args}`
          : `You sent command: ${command}`;

        await api("sendMessage", { chat_id: chatId, text: reply });
      }
    } catch (e) {
      console.error("[poll] error:", e?.message || e);
      // Back off so we don’t spin if network/token is bad
      await sleep(1500);
    }
  }
}

main().catch((e) => {
  console.error("[fatal]", e);
  process.exit(1);
});
