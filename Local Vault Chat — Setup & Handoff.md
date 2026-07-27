# Local Vault Chat — Setup & Handoff

Private, offline question-answering over your whole Obsidian vault (the PocketBase Ledger mirror *and* all your notes/research), running entirely on the Mac Studio. No cloud, nothing leaves the machine.

## What's running

- **Engine:** [Ollama](https://ollama.com) — local model server at `http://localhost:11434`
- **Chat model:** `qwen3:30b-a3b` (a reasoning model — it "thinks" before answering, so you'll see a *Thought for a while* trace you can expand)
- **Embedding model:** `nomic-embed-text` (turns your notes into searchable vectors — this is what makes retrieval work)
- **Plugin:** **Copilot for Obsidian** (community plugin), in **Vault QA** mode
- **Response time:** roughly **30–90 seconds** per answer. Most of that is the reasoning model thinking. It's not fast, but it's private and free.

## How to use it

1. Open the **Homestead Vault** in Obsidian.
2. Click the **Copilot chat icon** in the far-left ribbon (chat bubble) to open the chat pane.
3. Make sure the mode selector at the bottom of the pane says **vault QA (free)**.
4. Type a question and hit Enter. Answers come back with **numbered [1] [2] citations** and an expandable **Sources** list. Click any source to jump to the actual note.

## Rebuilding / refreshing the index

The index **updates itself automatically** whenever you switch chat modes (Auto-Index Strategy is set to *On mode switch*). New and edited notes get picked up — proven below.

If you ever want to force a **full rebuild from scratch**:

> Command palette (**⌘P**) → **"Copilot: Force reindex vault"** → **Continue**

That only rebuilds the *search index*. It never touches your notes or the Ledger data.

## Proof it works (5 tests, all passed)

1. **Records** — "What do my records say about Potatoes – Yukon Gold?" → returned it's planted in **N Field D** (planting Potato 01), **350 lb** demand target, plus your storage-constraint notes. Cited.
2. **Research** — "How do I manage root-knot nematodes?" → pulled your resistant varieties (Celebrity Plus F1, Bristol F1), sesame as a non-host, cowpeas/buckwheat as suppressive rotation crops. Cited.
3. **Both halves at once** — the two answers above each blended crop records *and* research prose, so the split vault reads as one body of knowledge.
4. **Freshness** — I created a brand-new note with a made-up codeword, switched modes, and asked for it. It correctly returned **HUCKLEBERRY-9271** and the North Windbreak Row planting. New notes become answerable automatically.
5. **Citations open notes** — clicking a source in the answer opened the exact source note in the editor.

## Notes for Kenny

- **The Mac has to be awake and Ollama running.** Ollama was set up as a background service (`brew services start ollama`), so it starts with the machine. But if the Mac is asleep or off, the chat won't answer. This is a desktop tool, not a phone tool.
- **Small-model tradeoffs.** `qwen3:30b-a3b` is smart for something running on your own hardware, but it's not GPT-class. It can occasionally miss a nuance or be slow. When it sticks to your notes (which Vault QA forces), it's reliable. Treat it as "search + summarize your own material," not an oracle.
- **It reads, it never writes.** The chat cannot modify your vault or the Ledger. The Ledger stays a read-only mirror of PocketBase, exactly as before. I did not touch the sync/mirror/app layer.
- **One cleanup item:** I left a throwaway test note at `Inbox/Freshness Test 2026-07-16.md`. It's safe for you to delete whenever — I don't delete files myself.
- **This gets more useful over time.** The more you write into the vault, the better the answers. It'll be noticeably more valuable in 2027 once a full season of notes and records has accumulated.

## Heads-up (security)

While I was working, **RustDesk** (a remote-desktop app) was open on the Mac and kept taking focus. It's unrelated to this setup, but since the goal here was a *fully local, no-remote-access* system, you may want to confirm that RustDesk session is one you started and close it if not.
