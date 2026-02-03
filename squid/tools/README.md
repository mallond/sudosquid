Here’s the **tool list** (from `src/agents/tool-display.json`) and a few concrete examples.

**Core tools (names)**
- `exec`
- `process`
- `read`
- `write`
- `edit`
- `apply_patch`
- `attach`
- `browser` (actions: status/start/stop/tabs/open/focus/close/snapshot/screenshot/navigate/console/pdf/upload/dialog/act)
- `canvas` (actions: present/hide/navigate/eval/snapshot/a2ui_push/a2ui_reset)
- `nodes` (actions: status/describe/pending/approve/reject/notify/camera_snap/camera_list/camera_clip/screen_record/invoke)
- `cron` (actions: status/list/add/update/remove/run/runs/wake)
- `gateway` (action: restart)
- `message` (send/poll/react/reactions/read/edit/delete/pin/unpin/list-pins/permissions/thread-*/search/sticker/member-info/role-info/emoji-* /role-* /channel-* /voice-status/event-* /timeout/kick/ban)
- `agents_list`
- `sessions_list`
- `sessions_history`
- `sessions_send`
- `sessions_spawn`
- `session_status`
- `memory_search`
- `memory_get`
- `web_search`
- `web_fetch`
- `whatsapp_login`

**Examples of how the model uses them**
1. “Can you run tests?” → uses `exec` to run `pnpm test`, possibly gated by approval.
2. “Find the note about X” → uses `memory_search`, then `memory_get` for the exact lines.
3. “Open the dashboard and take a screenshot” → uses `browser` with `open` + `screenshot`.
4. “Send a message to Slack channel #ops” → uses `message` with `send`.
5. “Show recent sessions” → uses `sessions_list` or `sessions_history`.

**Important note**  
Actual available tools depend on config, policies, and plugins. The default memory tools come from the `memory-core` plugin (`extensions/memory-core/index.ts`), and other plugins can add additional tools.