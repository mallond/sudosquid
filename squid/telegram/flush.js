const TOKEN = process.env.TELEGRAM_TOKEN;
if (!TOKEN) throw new Error("Set TELEGRAM_TOKEN");

async function api(method, payload = {}) {
  const r = await fetch(`https://api.telegram.org/bot${TOKEN}/${method}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(payload),
  });
  const j = await r.json();
  if (!j.ok) throw new Error(`${method} failed: ${j.description}`);
  return j.result;
}

const updates = await api("getUpdates", { offset: 0, timeout: 0, limit: 100 });
if (updates.length) {
  const last = updates[updates.length - 1].update_id;
  await api("getUpdates", { offset: last + 1, timeout: 0 });
  console.log(`Flushed. Set offset to ${last + 1}`);
} else {
  console.log("No backlog to flush.");
}
