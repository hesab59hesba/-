# agents_workflow.md — Master/Subagent Orchestration Blueprint

A generic, reusable workflow for driving **continuous, multi-iteration work on any repository**
(any language, any build system) using an orchestration model:

- a **master** agent that plans, scopes, dispatches, verifies, and reports, and
- one or more **worker sub-agents** that implement and verify discrete units of work.

The goal is work that keeps moving forward with **minimal conflicts, verified results at
every step, and a human in the loop who is never surprised.**

---

## 1. Roles and responsibilities

### Master (orchestrator)

| Responsibility | Details |
|---|---|
| **Maintain context** | Keep an *anchored summary* of the whole effort (objective, key constraints, what is done / in progress / blocked, next move, relevant files). Refresh it every iteration so the session can always be resumed. |
| **Plan and decompose** | Break the objective into phases and discrete items. Put them in a todo list. Assign each item an owner. |
| **Scope file ownership** | Decide *exactly which files each sub-agent may touch* before anything runs (see §4). This is the single most important conflict-avoidance tool. |
| **Dispatch** | Write detailed prompts (see §6 template). Give each agent its constraints, its file list, the exact verify commands, and what to report back. |
| **Verify combined state** | After every phase, do a clean full build + full test + lint from scratch, because agents may edit overlapping or dependent files. |
| **Report** | Summarize what was done each iteration, ask before continuing to the next phase, and surface risks/limitations honestly. |
| **Recover** | When an agent's change breaks something, investigate, then either fix it yourself (small) or spawn a fix agent (larger). Never paper over a failure. |

### Worker sub-agents

- Do **only** their assigned task, touching **only** their owned files.
- Verify their own work with the commands the master gave them.
- Report back exactly what they changed, their verification output, and anything surprising.

### Human (user)

- Approves phase transitions.
- Provides project-specific constraints (targets, toolchains, standards).

---

## 2. Core principles

1. **The master delegates, it does not do.** All file edits go through sub-agents (or the
   master only for micro-fixes, clearly reported). This keeps the master's context small and
   each unit of work independently verifiable.
2. **One source of truth.** Requirements live in a committed document (e.g. an
   `architecture_analysis.md` / `plan.md`) that the master and every agent reference. Never
   re-derive requirements from memory.
3. **Report each iteration before continuing.** No silent long stretches of work. The human
   always sees a progress report and explicitly approves the next phase.
4. **File ownership is a contract.** An agent may only edit files it owns. Enforced in the
   prompt and audited by the master via `git status`/`git diff` at boundaries.
5. **Every change is verified by its author, and the whole by the master.** No claim of
   "it works" without running the actual commands.
6. **Preserve user-provided commands verbatim.** If the user gives a lint/test command, use
   it exactly as given.
7. **Follow repository conventions.** Read neighboring code before editing. Match naming,
   structure, and tooling. Never assume a library exists — check the manifest/build files.

---

## 3. The continuous-work loop

```
┌──────────────────────────────────────────────────────────────────┐
│ 0. INIT        explore repo; find build/test/lint commands;      │
│                 record conventions (AGENTS.md or summary)         │
└───────────────────────────────┬──────────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────────┐
│ 1. PLAN        read source-of-truth doc; produce phase list;     │
│                 estimate; write todo list                         │
└───────────────────────────────┬──────────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────────┐
│ 2. SCOPE       build FILE OWNERSHIP MATRIX; split shared files   │
│                 across sequential waves; decide build dirs        │
└───────────────────────────────┬──────────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────────┐
│ 3. DISPATCH    launch wave (parallel where disjoint, sequential  │
│                 otherwise) with full prompts (template §6)        │
└───────────────────────────────┬──────────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────────┐
│ 4. VERIFY      master: clean rebuild + full tests + lint;        │
│                 audit git status/diff against ownership matrix    │
└───────────────────────────────┬──────────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────────┐
│ 5. REPORT      per-iteration report; surface surprises/bugs;     │
│                 ask to proceed                                     │
└───────────────────────────────┬──────────────────────────────────┘
                                ▼
                 approved? ──no──▶ refine plan, back to 2/1
                    │ yes
                    ▼
            next phase (back to 2), else DONE
```

Every phase ends with a **verification artifact**: exact test counts, build status, lint
status. Never start a phase with a dirty, unverified previous phase.

---

## 4. File ownership and conflict avoidance

Concurrent agents on the same files = merge nightmares. Prevent it up front.

### 4.1 Build the ownership matrix

Before dispatching a phase, list every file the phase will touch and assign exactly one owner:

| File | Agent | Wave | Why grouped |
|---|---|---|---|
| `src/foo.c`, `src/foo.h` | A | 1 | module self-contained |
| `src/bar.c`, `src/bar.h` | B | 1 | module self-contained |
| `CMakeLists.txt`, `.github/workflows/ci.yml` | C | 2 | shared build/CI plumbing |
| `docs/*.md` | D | 1 | no code conflicts |

Rules:

- **One owner per file per wave.** If two items must touch the same file, put them in
  different waves (sequential), or merge them into one agent.
- **Group "shared plumbing" together** (build system, CI workflows, umbrella headers,
  package manifests). These are conflict magnets — give all of them to a single agent, or
  sequence them.
- **Doc-only and test-only agents are free** to run in parallel with code agents (unless
  they edit shared manifests).
- **Test files** that are added to a build (e.g. need a new entry in `CMakeLists.txt` /
  `Makefile` / `package.json`): either the test agent owns the manifest edit too, or the
  manifest owner runs in a later wave and includes the new file. Prefer: the agent that
  creates the file also registers it (then a later manifest agent must preserve it — flag
  it in the prompt).

### 4.2 Parallelism with separate build directories

When parallel agents both need to build/run tests, give each its **own build dir**
(`build-a`, `build-b`, …) and its own temp dirs, so they never race on artifacts:

```
rm -rf build-a && cmake -S . -B build-a ... && cmake --build build-a -j && ctest --test-dir build-a
```

The master always does the final canonical verification in the default `build/` after all
agents in the wave have finished.

### 4.3 Auditing

At each phase boundary the master runs `git status --short` and `git diff --stat` and
cross-checks against the ownership matrix. Any file touched by the "wrong" agent is a
process failure — revert and re-scope.

---

## 5. Verification standards

- **Author verification (per agent):** the exact commands the master supplied, with real
  output captured. Report *counts* (e.g. "167 passed, 0 failed, 1 skipped, 168 total"),
  not just "passes".
- **Combined verification (master, per phase):**
  1. `rm -rf <build>` then configure, build, and run the full test suite from scratch
     (catches stale-artifact illusions and cross-agent integration breaks).
  2. Run the repo's lint/typecheck/format commands.
  3. If a static-analysis or sanitizer build is part of the toolchain, run it (or
     explicitly document why the local environment cannot — e.g. ASAN in a restricted
     container — and note that CI covers it).
- **Never assume a green test suite.** Re-run after the *final* combined state, not from
  individual agent reports.
- **Always build the real deliverable artifact.** If the project produces a runnable or
  shippable artifact (APK, AAR, iOS app, CLI binary, package, Docker image, …), the
  master's verification MUST include building it — not just unit tests. The artifact is
  the final proof that tests, native libs, resources, and packaging all work together
  (e.g. an APK that actually contains `libcgame.so` for every target ABI). Record the
  exact artifact path and inspect its contents (e.g. `unzip -l` for an APK, `otool`/`nm`
  for a binary, `docker build` for an image). Cross-compiled targets (Android/iOS) should
  be validated locally if the toolchain exists on the machine; otherwise document that CI
  covers it.
- **Environment limitations are documented, not ignored.** If a tool cannot run locally,
  say so and point at the CI job that does. If a tool *can* run locally (NDK, emulator,
  device), use it — don't defer to CI what you can verify here.

---

## 6. Sub-agent prompt template

Reuse this structure verbatim. A good prompt is a complete work order.

```markdown
You are working in <repo path> (<language>/<framework>). Your task: <task, item ref>.

WHAT TO DO:
1. Read first: <the files to read to learn conventions — adjacent modules, build files,
   test framework, existing patterns>. Do not guess.
2. <precise, ordered implementation steps; reference exact files/line numbers where
   possible; specify API shape, naming, and behavior requirements.>
3. Keep changes minimal and idiomatic. Match existing style (indentation, naming, no
   comments unless the codebase comments).

YOU OWN ONLY THESE FILES: <exact list>.
DO NOT touch: <explicit forbidden files — shared manifests, CI, other modules>. 
If a needed change would require touching a file you don't own, STOP and report that
instead of editing it.

VERIFY (required), from <workdir>:
   <exact commands, e.g. rm -rf build-x && cmake ... && build && test>
   All must pass. Report exact pass/fail/skip/total counts.

REPORT BACK:
   - files changed/created and a short summary of each
   - the exact verification output summary
   - anything surprising / any limitation you hit
   - anything that would require touching a file outside your ownership
```

**Prompt-writing rules:**

- **Be explicit about ownership** (the file list + a "DO NOT touch" list). Agents
  otherwise overreach into shared files.
- **Give real commands, not descriptions.** Exact flags, exact dirs, exact env.
- **State the baseline.** "Expected ~166 tests passing; if you add tests it becomes N."
- **Ask for the surprising stuff.** "Report anything that differs from what a reasonable
  reader would expect" surfaces latent bugs (this is how real UAF bugs get found).
- **Scout new territory with an `explore` agent** before planning changes to code you've
  never read — cheap, focused, and keeps the master's context small.
---

## 7. Progress tracking and state management

- **Todo list (master):** one entry per discrete item, with status. Exactly one item
  `in_progress` at a time. Update in real time.
- **Anchored summary (master):** a running document/note containing:
  - *Objective* — the end goal.
  - *Important details* — build constraints, toolchain facts, design decisions, baseline
    test counts, environment limitations.
  - *Work state* — Completed / Active / Blocked, with concrete facts and file paths.
  - *Next move* — the immediate action.
  - *Relevant files* — map of file → role.
  Rebuild it at each iteration. This makes the whole effort resumable even after context
  resets, and lets a new session (or a reviewer) pick up instantly.
- **Iteration reports to the user:** short, table-driven, honest about caveats. End with a
  clear question ("Continue to Phase N?").

---

## 8. Risk handling

| Risk | Mitigation |
|---|---|
| Concurrent edits to the same file | Ownership matrix + sequential waves for shared files (§4). |
| Agent overreaches its file list | Enforce in prompt; audit via `git status`/`git diff`; revert. |
| Agent reports success but combined state is broken | Master always does an independent clean rebuild + full test run after every phase. |
| Latent bug found mid-flight (UAF, double-free, dead code) | Treat as a defect: verify it in the code, spawn a fix agent with its own build dir, add a regression test. |
| Environment cannot run a tool (ASAN, NDK, macOS) | Document it; rely on the CI job; keep `continue-on-error` only where genuinely necessary and say why. |
| Requirement ambiguity | Ask the user (or the plan doc) before guessing. Never silently pick a direction that could be wrong. |
| Third-party files trip strict flags (stb, vendored code) | Scope flags per target, or use `-isystem`/SYSTEM include dirs; verify before enabling a hard gate. |
| Pre-existing failures block a new gate | Scope the gate to what it *can* enforce; report the pre-existing issue separately; never silently disable the gate. |

---

## 9. Best practices checklist (apply to every phase)

- [ ] Source-of-truth plan doc read/updated before starting the phase.
- [ ] File ownership matrix produced; shared files assigned to a single agent or sequenced.
- [ ] Todo list updated (one item in progress).
- [ ] Every dispatched agent got: exact ownership list, exact verify commands, report format.
- [ ] Parallel agents use disjoint build dirs.
- [ ] Master ran a clean combined build + full tests + lint after the phase.
- [ ] Deliverable artifact built and inspected (APK/AAR/binary/package/image): path recorded, contents checked for the expected native libs/components.
- [ ] `git status`/`git diff` audited against the ownership matrix.
- [ ] Iteration report delivered: what changed, verification counts, caveats, next-step question.
- [ ] Anchored summary updated.
- [ ] Nothing committed unless the user explicitly asked.

---

## 10. Applying this to a brand-new repo (quickstart)

1. **Init:** list the tree; read the readme, `AGENTS.md` (create if asked), build files
   (`CMakeLists.txt`, `Makefile`, `package.json`, `Cargo.toml`, …); identify the single
   "run everything" commands (build, test, lint, typecheck). Record them.
2. **Baseline:** get a green build + green tests + clean lint on the untouched repo. This
   is the contract every phase must not regress.
3. **Plan:** write (or use existing) the requirements doc; decompose into phases and items;
   assign owners.
4. **Loop:** run §3 for each phase, stopping to report at every iteration.

The same loop scales down to a single-phase task (one agent, one verify, one report) and
up to a multi-week programme with many parallel waves — the invariants (ownership,
verification, reporting) are identical at every size.
```
