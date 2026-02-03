Persistent data lives under the state dir, default ~/.openclaw (or legacy ~/.clawdbot / ~/.moltbot / ~/.moldbot if those exist). You can override it with OPENCLAW_STATE_DIR (or legacy CLAWDBOT_STATE_DIR). The state dir is explicitly documented as the place for mutable data like sessions, logs, and caches. See paths.ts.

Key persistent locations:

Config: openclaw.json (or OPENCLAW_CONFIG_PATH). paths.ts.
Credentials: ~/.openclaw/credentials/ (or OPENCLAW_OAUTH_DIR). paths.ts.
Sessions (transcripts + metadata): ~/.openclaw/agents/<agentId>/sessions/ with sessions.json and *.jsonl transcripts. paths.ts.
Workspace is separate: ~/.openclaw/workspace by default, but not where persistent state like credentials/sessions lives. agent-workspace.md.


It persists Markdown memory files on disk and uses semantic search over those files to recall past facts.

How it works in this repo:

Source of truth = workspace Markdown. Memory is stored in MEMORY.md (long-term) and YYYY-MM-DD.md (daily logs) inside the agent workspace. The model only “remembers” what gets written to disk. See memory.md.
Memory recall = tools + vector index. The memory_search and memory_get tools read those Markdown files and retrieve relevant snippets. See memory-tool.ts and memory.md.
Embeddings + SQLite index. A per‑agent SQLite index is built over memory files; default path is <agentId>.sqlite. See memory-search.ts and memory.md.
Automatic “memory flush” before compaction. When a session nears compaction, the system prompts the model to write any durable notes to disk so they persist. See memory.md.

How semantic search works (end‑to‑end)

Inputs: Markdown memory files only

MEMORY.md and YYYY-MM-DD.md in the workspace.
Optional extra Markdown paths via config.
See memory.md and memory-search.ts.
Chunking:

Memory files are chunked to ~400 tokens with ~80‑token overlap.
Defaults in memory-search.ts (see DEFAULT_CHUNK_TOKENS, DEFAULT_CHUNK_OVERLAP).
Embeddings:

Provider is auto by default, resolves to local, openai, or gemini depending on config and available keys.
Remote embeddings require provider API keys.
See provider selection and config in memory.md and memory-search.ts.
Index storage (SQLite):

Per‑agent SQLite store: <agentId>.sqlite by default.
Configurable via agents.defaults.memorySearch.store.path with {agentId} token support.
See memory-search.ts and memory.md.
Query: hybrid semantic + keyword search

Hybrid mode combines vector similarity + BM25 keyword relevance.
Returns snippets (not full files) with path + line range.
See memory.md and memory-search.ts.
Embeddings details

Default models:
OpenAI: text-embedding-3-small
Gemini: gemini-embedding-001
See memory-search.ts.
Batch embedding is supported for OpenAI/Gemini, with concurrency + polling controls.
See memory.md.
SQLite + vector search specifics

The memory index uses SQLite and can use sqlite-vec when available for vector search acceleration.
See memory.md.
Indexing is per‑agent and tracks provider/model/config so it can reindex when those change.
See memory.md.
Where to look next (most relevant files)

memory.md
memory-search.ts
memory-tool.ts
memory-schema.ts (SQLite schema)

Here’s the concrete trace for default memory (memory-core), from user message → retrieval → SQLite:

Plugin provides memory tools

The default memory slot is memory-core. slots.ts
The memory-core plugin registers memory_search and memory_get tools.
index.ts
Tool list assembled for the agent

Core tools are built in createOpenClawTools, then plugin tools are appended via resolvePluginTools.
openclaw-tools.ts, tools.ts
System prompt tells the model to use memory tools

The prompt includes a Memory Recall section when memory_search/memory_get are available.
system-prompt.ts
The prompt is built with the final tool list.
system-prompt.ts
Model calls memory_search

Tool implementation reads query, resolves agent ID, and gets a MemoryIndexManager.
memory-tool.ts, search-manager.ts
Memory index manager does semantic search

Handles sync, embedding, hybrid search (vector + BM25), and returns snippets.
manager.ts
SQLite storage & search

Schema includes meta, files, chunks, embedding_cache, and optional FTS table.
memory-schema.ts
Vector search uses SQLite (with sqlite-vec if available) and falls back to in‑process cosine similarity if vector extension isn’t available.
manager-search.ts, manager.ts
Model optionally calls memory_get

Reads specific lines from MEMORY.md / *.md (or extra configured paths).
memory-tool.ts, manager.ts
That’s the “RAG” loop: tool‑driven retrieval → snippet injection → model response. Nothing is “trained”; it’s file‑backed memory plus semantic retrieval.