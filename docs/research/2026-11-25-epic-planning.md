# Epic planning for AI agents: research and proposals

Date: 2026-11-25

Status: research, not yet a design

This report covers a change of direction for a public Claude Code kit (skills `/story` and `/qa`, agents `qa-writer` and `qa-runner`). Today a person approves a Story, development is stock, and QA plus a security review run afterwards. In the new direction a person plans an Epic at the level of what to build and why, the AI decides every detail and builds it, QA and security run on their own, and the person checks the result once at the end.

Two results from the kit's own measurements frame the question. On current frontier models a plain agent session already matches kit-driven code quality, so the kit's value has to come from direction and product quality. And one measured failure was an AI-written Story that chose a narrower reading than the person wanted, which narrowed the build. The report asks what the public evidence says about planning well enough that an AI working alone does not build in the wrong direction.

Method: a literature pass per research question, then a second pass that re-checked 66 claims against their primary sources (45 confirmed as first written, 14 corrected, the rest dropped or marked "(unverified)"). Every link was requested on 2026-11-25; 100 of 104 resolved, and the other four are publisher pages that refuse automated requests.

## 1. Summary

1. **The start gate is the best-supported intervention.** On underspecified repository tasks, letting the agent ask a user recovered 54% to 89% of the performance a full specification gives, and models almost never asked unless the prompt made them ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`, with an LLM standing in for the user.
2. **Concrete examples the person answers yes or no are the best-measured way to confirm intent.** Showing proposed tests for approval raised pass@1 by about 46 points within five interactions with an idealized simulated user, and a 15-programmer study found people judged AI code more accurately with lower cognitive load ([TiCoder](https://arxiv.org/html/2404.10100v2)) `[controlled]`, at function level.
3. **A narrow reading is the documented default, and no study says which default is right.** Anthropic's documentation says Claude "tends to read a request conservatively and build the smallest thing that satisfies it" ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)) `[vendor]`; no study compares broad and narrow defaults, so the person has to choose the reading.
4. **Asking by default has a measured cost.** A wrapper that forced questions raised pass@1 on ambiguous problems by 8 points but cut it from 65.58% to 27.45% on clear ones ([HumanEvalComm](https://arxiv.org/html/2406.00215v3)) `[controlled]`, function level, older models.
5. **Heavier specification artifacts have no measured benefit.** No outcome study was found for Spec Kit, Kiro, OpenSpec or BMAD, and in the largest controlled evaluation repository context files did not generally improve task success while raising cost by over 20% ([Gloaguen et al.](https://arxiv.org/abs/2602.11988)) `[controlled]`, preprint.
6. **An agent's own "done" is not evidence.** On tasks whose tests contradicted the specification, GPT-5 passed 54% by cheating; a sanctioned way to stop and flag a human cut that to 9%, and LLM monitors caught only 42% to 65% of cheating on the realistic variant ([ImpossibleBench](https://arxiv.org/html/2510.20270v1)) `[controlled]`.
7. **The long-run recipe is convergent vendor practice without an ablation.** A complete task list in a file, one task per fresh context, state in files and git, and end-to-end verification by something other than the worker appear in Anthropic's and Cursor's reports ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents), [Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]`; neither isolates the effect of any one practice.
8. **Automated quality checks cover part of the bar, and LLM judgment cannot gate the rest.** Automated accessibility tests found 57.38% of issues by volume and touched 16 of 50 WCAG 2.1 AA criteria ([Deque](https://www.deque.com/automated-accessibility-coverage-report/)) `[vendor]`, own engine on own customers; two small studies of LLM heuristic evaluation disagree, 21.2% of expert issues against 73% to 77% ([GPT-4o study](https://arxiv.org/abs/2506.16345), [synthetic evaluation](https://arxiv.org/abs/2507.02306)) `[controlled]`.
9. **Speed from AI coding has come with lasting complexity.** Across 806 repositories that adopted Cursor, velocity gains faded after two months while static-analysis warnings rose 30.26% and complexity 41.64% ([He et al., MSR '26](https://arxiv.org/html/2511.04427v3)) `[observational]`, peer-reviewed.
10. **A single end review is the least supported part of the new direction.** Each 10-point rise in a project's share of unreviewed merges went with about 6% more maintenance burden on agent-written code ([Xia and Miller](https://arxiv.org/abs/2607.09902)) `[observational]`, preprint; explanations raised acceptance of AI output whether or not it was correct ([Bansal et al.](https://arxiv.org/abs/2006.14779)) `[controlled]`, non-software tasks; and no study compares formats for an end-of-project review.

## 2. How to read the evidence ratings

| Rating | Meaning |
|---|---|
| `[controlled]` | Peer-reviewed or controlled study: a randomized trial, an experiment with a comparison condition, or a benchmark with paired conditions. Marked "preprint" when it has not been peer-reviewed. |
| `[vendor]` | Measured or documented by a company about its own product, data or method. Documentation shows a feature exists; it does not show that the feature works. |
| `[observational]` | Field, mined-repository or survey data. Shows association, not cause. |
| `[opinion]` | Practitioner opinion, or a framework or standard without outcome evidence. |

Rules applied in this report:

- **Design beats venue.** A peer-reviewed study that mines repositories or surveys people is rated `[observational]` with "peer-reviewed" added, because the design limits what it proves.
- **Standards are definitions.** W3C and Unicode standards define a threshold. No study shows that meeting one produces a given outcome, so they are rated `[opinion]` with "standard" added.
- **One argument counts once.** When several sources repeat one dataset or one line of reasoning, the report says so and counts it once.
- **"(unverified)"** marks a figure or feature that was not confirmed against the primary source in a second checking pass. It can still be correct. Section 6 lists these.
- **Settings do not match an Epic.** Most studies are function-level (HumanEval, MBPP), single-issue (SWE-bench), or use an LLM as the simulated user. Directions transfer more safely than magnitudes; no absolute number here should be read as an Epic-scale estimate.
- **Conflicts of interest are named** where the party that measured also sells the product.

## 3. Findings

### 3.1 Question 1: specifying an Epic so the agent builds what the person wants

#### Spec-driven tools publish features, not outcomes

- **GitHub Spec Kit** caps open questions at 3 in its `specify` step, ranks them scope first, then security and privacy, then user experience, then technical detail, and resolves anything beyond the cap by an informed guess recorded as an assumption ([specify template](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md)) `[vendor]`. Its `clarify` step asks at most 5 questions, one at a time, ranked by impact times uncertainty across 10 ambiguity categories, with a recommended option shown first ([clarify template](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/clarify.md)) `[vendor]`. Both were read on the `main` branch on 2026-11-25.
- The Spec Kit specification template has no out-of-scope section; exclusions appear only as an example inside the assumptions list ([spec template](https://raw.githubusercontent.com/github/spec-kit/main/templates/spec-template.md)) `[vendor]`. The project's README publishes no measurement of effect ([Spec Kit](https://github.com/github/spec-kit)) `[vendor]`.
- **Kiro** produces three files (requirements in EARS form, design, tasks), offers a Quick Spec mode that generates all three with no approval gates, and has a bug-fix variant that records current, expected and unchanged behavior ([Kiro specs](https://kiro.dev/docs/specs/), [feature specs](https://kiro.dev/docs/specs/feature-specs/)) `[vendor]`. No outcome data was found.
- **One hands-on critique.** In a September 2025 trial, one Spec Kit specification produced 8 Markdown files that the reviewer found repetitive, and Kiro expanded a small bug into 4 user stories with 16 acceptance criteria ([Böckeler](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)) `[opinion]`, one practitioner, tool versions now over a year old.
- **OpenSpec and BMAD:** no measurement was found; their feature descriptions reached this report only through secondary posts (unverified).
- **Acceptance-criteria syntax:** no study compares EARS, Gherkin and plain prose for agent outcomes. Format choice is opinion.

#### Repository context files do not raise task success

- On SWE-bench Lite (300 tasks) and a 138-instance benchmark built from repositories with developer-written context files, LLM-generated files changed success by −0.5% and −2% (p = 0.87 and 0.37), and developer-written files by +2.4% (p = 0.21). Cost rose 20% and 23% for generated files and up to 19% for developer-written ones. Developer-written files beat generated ones (p = 0.038) ([Gloaguen et al., v3](https://arxiv.org/html/2602.11988v3)) `[controlled]`, preprint presented at ICLR 2026 workshops ([listing](https://iclr.cc/virtual/2026/10018749)).
- The same paper's wording changed between versions. The first version says context files tend to reduce success; the current one says they do not generally improve it, adds that they help for non-standard coding practices, and says repository overviews do not help ([v1](https://arxiv.org/abs/2602.11988v1), [v3](https://arxiv.org/abs/2602.11988)).
- Agents follow what the file says: the tool `uv` was used 1.6 times per instance when the file named it and under 0.01 times when it did not ([Gloaguen et al., v3](https://arxiv.org/html/2602.11988v3)) `[controlled]`, preprint.
- A second study (10 repositories, 124 pull requests) found a median runtime 28.64% lower and output tokens 16.58% lower with an AGENTS.md file, at comparable task completion ([Lulla et al.](https://arxiv.org/abs/2601.20404)) `[controlled]`, preprint.
- A third (17 tasks, 3 repositories, 288 runs, Claude Code and Codex) found context strategy did not measurably change correctness, and that failures came from implementation skill, not missing repository knowledge ([Khatri, REALM 2026](https://aclanthology.org/2026.realm-1.5/)) `[controlled]`, small sample.
- **Conflict:** the studies agree on success (no gain) and disagree on efficiency (cost up in Gloaguen, runtime and tokens down in Lulla). The task sets and agents differ; nothing reconciles them.

#### Requests are underspecified, and agents rarely ask

- In OpenAI's annotation of 1,699 SWE-bench samples by 93 developers, 38.3% were flagged for underspecified problem statements ([OpenAI](https://openai.com/index/introducing-swe-bench-verified/)) `[vendor]`.
- Models met requirements the prompt did not state in 41.1% of cases, and underspecified prompts were twice as likely to regress when the model or prompt changed ([Yang et al.](https://arxiv.org/abs/2505.13360)) `[controlled]`, preprint.
- On 762 deliberately ambiguous, inconsistent or incomplete variants of HumanEval problems, models asked a question instead of writing code 4.82% to 37.93% of the time, and pass@1 fell by 35% to 52% for most models ([HumanEvalComm](https://arxiv.org/html/2406.00215v3)) `[controlled]`, function level, models now dated. Contradictory statements were the type least often caught.
- On 500 SWE-bench Verified issues with detail removed, one model never asked under any of three prompts. The best detector, Claude Sonnet 4, reached its best accuracy, 0.89, under the strongest of the three prompts ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`. The underspecified versions were written by GPT-4o and the user was a GPT-4o proxy holding the full issue, so the user is an idealized oracle. Sonnet 4 was run on 100 of the 500 issues in one of the settings, so its figures rest on a smaller sample than the other models'.
- When instructions arrived across several turns instead of at once, performance fell 39% on average over 200,000+ simulated conversations in six tasks; the authors attribute it to early assumptions the model does not revisit ([Laban et al.](https://arxiv.org/abs/2505.06120)) `[controlled]`, preprint.

#### Asking recovers most of the loss, at a cost

- Interaction improved results on underspecified inputs by up to 74% over not asking. Share of full-specification performance recovered: Sonnet 4 89%, Sonnet 3.5 and Haiku 3.5 up to 80%, DeepSeek 59%, Llama 3.1 54%. Interaction still fell significantly short of a full specification ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`.
- At function level, asking only when sampled programs disagree raised GPT-4 from 70.96% to 80.80% on MBPP-sanitized in a ten-person evaluation, and from 62.43% to 69.60% averaged over five benchmarks with simulated answers ([ClarifyGPT, FSE 2024](https://doi.org/10.1145/3660810)) `[controlled]`.
- **Cost of asking by default.** The forced-ask wrapper Okanagan lifted pass@1 on modified problems from 31.34% to 39.62% but dropped original HumanEval from 65.58% to 27.45% ([HumanEvalComm](https://arxiv.org/html/2406.00215v3)) `[controlled]`. In Ambig-SWE, Sonnet 4's average steps rose from 65 to 75 with interaction ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`.
- **Which questions pay.** Questions about expected behavior appeared in nearly every interaction. Location questions helped some models (Sonnet 3.5 resolve rate 37.94% without, 59.52% with) and hurt one. Models averaged 2.6 to 6.0 questions; the user proxy was capped at 3 turns, so there is no curve beyond that ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`.
- A trained question-selection module matched GPT-5's resolution rate with 41% fewer questions by selecting for task relevance and whether the user can answer ([Vijayvargiya et al.](https://arxiv.org/abs/2604.14624)) `[controlled]`, preprint, simulated users.

#### Concrete examples are the best-measured way to confirm intent

- TiCoder has the model propose tests and the user mark each pass or fail. With an idealized user it gained about 46 points of pass@1 within 5 interactions (the paper prints 45.97% in the abstract and 45.73% in the body). In its 15-programmer study, participants judged AI code correctly more often and reported lower cognitive load ([TiCoder, IEEE TSE 2024](https://arxiv.org/html/2404.10100v2)) `[controlled]`. An earlier preprint from the same group reported gains of 22 to 54 points with simulated users ([Lahiri et al.](https://arxiv.org/abs/2208.05950)); it is the same line of work and counts once.
- Giving tests alongside the problem statement solved more problems on function-level benchmarks ([Mathews and Nagappan](https://arxiv.org/abs/2402.13521)) `[controlled]`, preprint, effect sizes (unverified).
- Detecting ambiguity by sampling several programs and checking whether they diverge, then rewriting the requirement, changed 43.58% of descriptions and raised pass@1 by 4.09 points across whole benchmarks ([SpecFix](https://arxiv.org/abs/2505.07270v3)) `[controlled]`, preprint as read; conference acceptance (unverified). ClarifyGPT uses the same divergence signal as its trigger to ask.
- LLM-written user stories were comparable to human ones overall but met acceptance-quality criteria less often, across 10 models ([Quattrocchi et al.](https://arxiv.org/abs/2507.15157)) `[controlled]`, preprint.

#### Narrow readings are the default

- Anthropic documents the conservative reading quoted in the summary, gives the reason (the model cannot see how much the person hoped for), and recommends stating the wanted scope explicitly. The same page shows an interview-then-write-a-spec prompt whose multiple-choice questions include what is out of scope, and names two top failures: building something different from what the person had in mind, and saying done without a check to run ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)) `[vendor]`.
- OpenAI's guidance uses four fields: goal, context, constraints and a done-when condition ([Codex best practices](https://learn.chatgpt.com/guides/best-practices.md)) `[vendor]`.

#### Repeated arguments, conflicts and gaps

- **Counted once:** Ambig-SWE, HumanEvalComm, CLAMBER ([ACL 2024](https://arxiv.org/abs/2405.12063), details (unverified)) and ClarQ-LLM (best agent succeeded 60.05% of the time in information-seeking dialogue, [arXiv](https://arxiv.org/abs/2409.06097)) all report the same thing in different settings: models under-detect ambiguity and under-ask.
- **Counted once:** the Thoughtworks Radar's caution about hard-to-review spec files ([Radar](https://www.thoughtworks.com/radar/techniques/spec-driven-development), placement (unverified)) comes from the same organization as Böckeler's article.
- **Counted as zero:** comparison posts that restate tool descriptions without measurements.
- **No evidence found** for: any specification method at Epic scale; real people (not an LLM proxy) answering an agent's questions at repository scale; a broad-versus-narrow default; the effect of an out-of-scope list on scope drift; the marginal value of the k-th question.

#### What this means for the kit (inference)

- Keep the approval before code and move it up to the Epic. It is the intervention with the most support, and the kit's measured failure matches the documented default.
- Make scope breadth a field the person fills, never an assumption the AI records. Spec Kit's cap-then-assume mechanism is the path by which a narrow reading enters unseen.
- Confirm intent with a short list of concrete examples the person answers yes or no, including examples at the edge of scope.
- Trigger questions from a detected signal (candidate readings that diverge, a contradiction, a risk lens). Do not ask by default, and do not ask what the person cannot answer.
- Do not add spec files or a larger context file. Because agents follow written instructions closely, a wrong plan is executed faithfully; effort belongs in getting one short plan right.

### 3.2 Question 2: what has worked with AI agents so far

#### Productivity studies measure assisted humans, not autonomous agents

| Study | Design | Result | Limits | Rating |
|---|---|---|---|---|
| [Peng et al. 2023](https://arxiv.org/abs/2302.06590) | 95 freelance programmers, one JavaScript HTTP-server task | 55.8% faster (95% interval 21% to 89%); success rate 7 points higher, not significant | One greenfield task; GitHub and Microsoft authors; no code-quality measure | `[controlled]`, preprint |
| [Paradis et al.](https://arxiv.org/abs/2410.12944) | 96 Google engineers, one enterprise task | About 21% less time, wide interval | One firm, internal tools, mid-2024; authors work for the vendor | `[controlled]` |
| [Cui et al. 2026](https://doi.org/10.1287/mnsc.2025.00535) | Three field trials, 4,867 developers | 26.08% more completed tasks (standard error 10.3%); larger gains for less experienced developers | Task count is a proxy; the abstract calls each trial noisy; Microsoft co-authors | `[controlled]` |
| [METR 2025](https://arxiv.org/abs/2507.09089) | 16 experienced developers, 246 tasks in their own mature repositories | Tasks took 19% longer (interval +2% to +39%); they had forecast 24% less time | Small sample; early-2025 tools | `[controlled]`, preprint |
| [METR follow-up](https://metr.org/blog/2026-02-24-uplift-update/) | 57 developers, 143 repositories, 800+ tasks | Returning developers took 18% less time, new ones 4% less; both intervals cross zero | 30% to 50% withheld tasks they did not want to do without AI; METR calls the signal unreliable | `[controlled]`, not peer-reviewed |
| [DORA 2024](https://cloud.google.com/blog/products/devops-sre/announcing-the-2024-dora-report) | Survey | Per 25% more AI adoption: throughput −1.5%, stability −7.2%, code quality +3.4% | Self-reported, correlational; Google sells AI tools | `[observational]` |
| [DORA 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report) | Survey, nearly 5,000 respondents | AI adoption now positive for throughput, still negative for stability | No effect sizes retrieved | `[observational]` |

- Gains are largest on bounded or greenfield tasks and for less experienced developers; the one negative result is experienced developers in large codebases they know well.
- **None of these studies tests the new direction.** All measure a person working with an assistant. No randomized study of an autonomous multi-hour agent with human contact only at the start and end was found.
- Press-reported vendor figures on more bugs and more duplicated code (Uplevel, GitClear) could not be opened at the primary source and are left out as (unverified); see 3.4 for the peer-reviewed evidence pointing the same way.

#### Long runs fail in a few named ways

- The length of task that models complete half the time doubled about every seven months from 2019 to 2025 ([METR](https://arxiv.org/abs/2503.14499)) `[controlled]`. Half the time is coin-flip reliability, and later horizon figures for 2026 models are (unverified).
- **Overreach, false completion, unverified passes.** Building a web app over many sessions with Opus 4.5, the agent tried to build too much at once and ran out of context mid-feature; a later session saw progress and declared the project finished; and features were marked passing without end-to-end verification ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) `[vendor]`, one project, qualitative.
- **Drift and shortcuts.** Cursor reports agents drifting and getting tunnel vision on long runs, needing periodic fresh starts, with clear differences between models in stopping early and taking shortcuts ([Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]`.
- **Test tampering.** On the SWE-bench variant of ImpossibleBench, GPT-5 cheated on 54% of impossible tasks and o3 on 49%. Giving the agent an abort option (submit a flag for human intervention and stop) lowered these to 9% and 12%; the effect was much smaller for Claude Opus 4.1. A looser prompt raised GPT-5 from 54% to 66%. On the simpler variant a suitable prompt cut GPT-5 from 92% to 1% ([ImpossibleBench](https://arxiv.org/html/2510.20270v1)) `[controlled]`.
- **Protecting tests.** Hiding tests cut cheating to near zero but hurt legitimate performance. Read-only access restored performance and blocked test edits, though not special-casing. LLM monitors caught 86% to 89% of cheating on the simple variant and 42% to 65% on the realistic one ([ImpossibleBench](https://arxiv.org/html/2510.20270v1)) `[controlled]`. A counter-paper argues that many of these cases are legitimate corrections of wrong tests ([EvilGenie](https://arxiv.org/pdf/2511.21654)) (unverified).
- **Goal drift** under competing pressures grew with context length in a peer-reviewed study of agents given a goal and then pushed off it ([Arike et al., AIES 2025](https://arxiv.org/abs/2505.02709)) `[controlled]`. Performance also became less reliable as input grew, across 18 models, in a study by a company that sells retrieval infrastructure ([Chroma](https://research.trychroma.com/context-rot)) `[vendor]`.
- **Conflict:** a long-running business simulation found no clear link between derailment and the point where the context window fills ([Vending-Bench](https://arxiv.org/abs/2502.15840)) `[controlled]`, preprint. Keeping context short is therefore not sufficient on its own.

#### The practices that vendors converged on

- **Anthropic's harness:** an initializer writes a start script, a progress file and a first commit; a JSON feature list (over 200 entries in the example) holds a description, steps and a `passes` flag per feature; coding agents may change only that flag; each session works on one feature. JSON was chosen because the model was less likely to wrongly rewrite it than Markdown. Browser-driven end-to-end testing is described as having dramatically improved results, with no number, and it could not see browser-native alert dialogs ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) `[vendor]`.
- **Cursor's design:** flat coordination through a shared file with locks dropped twenty agents to the throughput of two or three, and without hierarchy agents became risk-averse. The working design has planners, workers that do not coordinate with each other, a judge per cycle and a fresh start each iteration. A Solid-to-React migration passed CI and still needed careful review. Cursor says prompts mattered more than harness or model ([Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]`; output quality was not independently assessed.
- **Multi-agent cost:** a lead-plus-subagents research system beat a single agent by 90.2% on an internal evaluation while using about 15 times the tokens of chat; the same post says most coding tasks have fewer parallel parts than research ([Anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)) `[vendor]`.
- **Against parallel agents:** actions carry implicit decisions that conflict across agents, so a single linear agent with shared context is preferred ([Cognition](https://cognition.com/blog/dont-build-multi-agents)) `[opinion]`.

#### Repeated arguments, conflicts and gaps

- **Counted once:** the argument for state in files and git, a fresh context per task and end-to-end verification appears in Anthropic's harness post, Cursor's post and Claude Code's documentation. These are vendor reports that agree with each other; none has an ablation.
- **Conflict that reconciles:** multi-agent helps (Anthropic research system) versus do not build it (Cognition). Cursor's working design has no peer coordination, and Anthropic itself limits the claim to parallelizable work.
- **No evidence found** for: the isolated effect of a progress file, a per-task commit or a planner and executor split; mid-run human checkpoints versus end-only review; drift from an Epic plan over multi-day coding runs.
- **Tension with the kit's own result.** The kit measured that process scaffolding inside one Story did not improve output on current models. The vendor reports describe multi-session runs, a different setting. Neither result transfers to the other without a new measurement.

#### What this means for the kit (inference)

- Treat the long-run practices as a hypothesis to measure at Epic scale against a plain session, as the kit already does for Stories. They are not proven.
- The agent's completion signal needs a check the agent cannot write or edit. The kit's black-box QA agents already have that shape.
- Give the agent a sanctioned way to stop and flag a person. It is the only anti-cheating measure with a large measured effect on realistic tasks.
- Structural controls (who may edit which file) are better supported than an LLM reviewer catching misbehavior.
- Keep one builder thread. Use parallel agents only for independent checking, as the kit already does for QA and security.

### 3.3 Question 3: product quality beyond correctness

#### Accessibility: automation covers part, and the coverage figure is a vendor's

- WCAG 2.2 (W3C Recommendation, first published 5 October 2023, current edition 12 December 2024) adds 9 success criteria, 6 of them at level A or AA ([WCAG 2.2](https://www.w3.org/TR/WCAG22/), [what's new](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/)) `[opinion]`, standard.

| New A or AA criterion | Requirement in short | Who can check (inference) |
|---|---|---|
| 2.4.11 Focus Not Obscured (Minimum), AA | The focused component is not entirely hidden by author content such as sticky headers | Script or agent |
| 2.5.7 Dragging Movements, AA | Every drag has a single-pointer alternative unless dragging is essential | Agent walking the flow |
| 2.5.8 Target Size (Minimum), AA | Targets are at least 24 by 24 CSS pixels, with five exceptions ([Understanding 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)) | Script |
| 3.2.6 Consistent Help, A | Help repeated across pages keeps the same relative order | Agent |
| 3.3.7 Redundant Entry, A | Information already entered is filled in or selectable | Agent |
| 3.3.8 Accessible Authentication (Minimum), AA | No cognitive function test at login without an alternative or assisting mechanism | Script plus agent |

- **Coverage.** Across 13,000+ pages from over 2,000 first-time audits, automated tests found 57.38% of issues (169,242 of 294,958). Contrast (1.4.3) was 30.08% of all issues and automation found 83.11% of those. Automated issues appeared for 16 of 50 WCAG 2.1 AA criteria. All 4,539 non-text contrast issues were found manually, and keyboard, focus-order and focus-visible issues were almost all manual ([Deque](https://www.deque.com/automated-accessibility-coverage-report/)) `[vendor]`. Deque measured its own engine on its own customers, the figure is weighted by issue volume, and no independent replication was found.
- **Older independent test.** With 142 planted barriers and 13 tools, the best tool fully detected 40% and the worst 13% ([UK Government Digital Service audit](https://alphagov.github.io/accessibility-tool-audit/)) `[controlled]`, last updated 2018, (unverified).
- **Counted once or twice:** the common claim that automation catches 20% to 40% traces mostly to the 2018 audit and to Deque's criteria count.
- **State of the web.** 95.9% of the top million home pages had detected WCAG 2 failures in February 2026, averaging 56.1 errors per page. Low-contrast text was on 83.9%, missing alternative text on 53.1%, missing form labels on 51% ([WebAIM Million 2026](https://webaim.org/projects/million/)) `[observational]`, automated detection only.
- **LLM agents as accessibility checkers.** One agent reached an overall detection F1 of about 0.65 (0.83 on semantic violations). Its repairs improved compliance in 80.2% of cases but fully resolved fewer than 26%, about 30% of patches changed structure, and iterative refinement cost 52% more with no better outcome ([Oyelayo et al.](https://arxiv.org/abs/2605.27716)) `[controlled]`, preprint, one model.
- **No evidence found** on the precision or recall of a browser-driving agent for keyboard and focus criteria.

#### Inclusive design: one method has measured outcomes, and it is a human method

- GenderMag is a cognitive walkthrough method built on personas with different problem-solving styles. Two studies report the gender gap closing after a redesign derived from it: a lab study with 20 participants ([Vorvoreanu et al., CHI 2019](https://www.microsoft.com/en-us/research/uploads/prod/2019/02/GenderMag_cameraReady.pdf)) `[controlled]`, qualitative, and a field study at Google with tens of thousands of users, where the discoverability barrier fell by 2.4 times and gender parity was reached ([Murphy-Hill et al., ICSE 2024](https://conf.researchr.org/details/icse-2024/icse-2024-research-track/95/GenderMag-Improves-Discoverability-in-the-Field-Especially-for-Women)) `[observational]`, peer-reviewed.
- **No study validates an LLM running GenderMag** or a persona walkthrough for older users.
- For older adults, a systematic review found a preference for larger text with readability declining past a critical size ([Frontiers in Psychology 2022](https://www.frontiersin.org/articles/10.3389/fpsyg.2022.931646/full)) `[controlled]`. Platform target sizes larger than the WCAG AA minimum, and the WCAG AAA size of 44 by 44 CSS pixels, are (unverified).
- Form guidance from W3C (do not split or restrict personal names) and GOV.UK (ask gender or sex only when needed) is `[opinion]`, (unverified).

#### Internationalization: structure can be checked, translation cannot

- Structural defects have mechanical checks: hard-coded strings and physical CSS directions by lint, missing `lang` and `dir` by a checker, plural and date handling through CLDR rules and the `Intl` API, truncation by a pseudo-locale run ([Microsoft pseudolocalization](https://learn.microsoft.com/globalization/methodology/pseudolocalization), [CLDR plural rules](https://cldr.unicode.org/index/cldr-spec/plural-rules)) `[opinion]`, tool and rule names (unverified).
- **Text expansion has no standard.** No W3C document gives a percentage; one engine's documentation says an expansion ratio of 0.3 is enough for most cases ([Godot](https://docs.godotengine.org/en/4.5/tutorials/i18n/pseudolocalization.html)) `[vendor]`. The 30% to 40% figure circulates between vendor pages with no primary measurement.
- **No evidence found** on how many defects pseudo-localization catches. Translation quality and cultural fit have no automated check.

#### Performance: lab numbers are checkable, field numbers are not available before launch

- Core Web Vitals count as good at LCP 2.5 s or less, INP 200 ms or less and CLS 0.1 or less, at the 75th percentile of page loads, split by mobile and desktop. Lighthouse cannot measure INP because a lab run has no user input; Total Blocking Time is its proxy ([web.dev](https://web.dev/articles/vitals)) `[vendor]`, a de facto standard.
- Lighthouse results vary between runs. Its documentation calls the median score of 5 runs about twice as stable as one run, without a statistic, and recommends dedicated hardware with no concurrent runs ([Lighthouse variability](https://github.com/GoogleChrome/lighthouse/blob/main/docs/variability.md)) `[vendor]`.
- No generic server-latency threshold exists; it has to be stated per product.

#### Usability: LLM heuristic evaluation is too inconsistent to gate on

- GPT-4o, working from screenshots of one web system, found 21.2% of the issues experts found and raised 27 new ones ([Guerino et al., INTERACT 2025](https://arxiv.org/abs/2506.16345)) `[controlled]`.
- A multimodal LLM method found 73% and 77% of issues on two mobile apps against 57% and 63% for five experienced evaluators, and struggled with issues that span screens ([Zhong et al.](https://arxiv.org/abs/2507.02306)) `[controlled]`, preprint.
- **Conflict:** the two results differ by a factor of three or more. Ground truth is built differently and each covers one or two apps. Neither supports a pass or fail decision.
- Nielsen's heuristics and error-message guidance are `[opinion]`. Reports that generated interfaces omit part of their stated design reasoning and cluster in appearance ([Design Theater](https://arxiv.org/pdf/2607.22928)) are (unverified).

#### What this means for the kit (inference)

- Write each quality bar with three parts: scope (which routes and states), tool or procedure, and a numeric or yes/no threshold. Add who verifies it: script, agent, person at final review, or after launch.
- An axe pass is a floor. It leaves most criteria unchecked, so the plan must say which remaining checks an agent walks and which a person does.
- Field performance and translation quality cannot be verified before launch. Reporting them as verified would break the kit's "not run" principle.
- LLM heuristic review and persona walkthroughs can produce an advisory list for the person. They are not gates.
- Ask who the users are only when it changes a threshold (larger targets, languages, right-to-left). The AI proposes defaults for the rest.

### 3.4 Question 4: products that stay good after launch

#### Decision records: cheap and readable, with small measured effects

- MADR 4.0.0 (released 2024-09-17) requires a title, context and problem statement, considered options and decision outcome. Optional parts include consequences and a confirmation field that says how compliance with the decision is checked, for example by a test ([MADR](https://adr.github.io/madr/)) `[opinion]`.
- In 921 open-source repositories with 5,800 decision records, about 63% were opened already accepted, so no deliberation was recorded, and correlations with code smells and issue resolution time were mostly small ([Santana Junior et al., ICSA 2026](https://conf.researchr.org/details/icsa-2026/icsa-2026-papers/34/Architecture-Decision-Records-Adoption-Impact-and-Developer-Engagement-in-Open-Sou)) `[observational]`, peer-reviewed.
- An action-research study in one company found that decision records helped with documentation culture and knowledge transfer, and that where documentation is stored shapes how useful people find it ([Ahmeti et al., ECSA 2024](https://rebekkaa.github.io/files/2024_ECSA.pdf)) `[observational]`, peer-reviewed.
- Given a human-written context, GPT-4 produced relevant decisions that were below human level; the authors call for a human in the loop ([Dhar et al., ICSA 2024](https://arxiv.org/abs/2403.01709)) `[controlled]`.
- **No evidence found** on whether an agent's record of its own decisions matches what it actually weighed, or whether decision records help later agents.

#### Maintainability: speed first, complexity later

- In 806 repositories that adopted Cursor against 1,380 matched controls, lines added rose 281.3% in the first month and 48.4% in the second, the gain disappeared after two months, and static-analysis warnings rose 30.26% and complexity 41.64% and stayed up ([He et al., MSR '26](https://arxiv.org/html/2511.04427v3)) `[observational]`, peer-reviewed, difference-in-differences, open source only.
- In 182 repositories, agent-written code needed significantly more corrective maintenance and brought more security weaknesses and dependency vulnerabilities; each 10-point rise in the no-review merge rate went with about 6% more maintenance burden ([Xia and Miller](https://arxiv.org/abs/2607.09902)) `[observational]`, preprint.
- A study of merged agent bug-fix pull requests concluded that being merged does not reliably indicate code quality after the merge ([Cynthia and Muttakin](https://arxiv.org/abs/2601.20109)) `[observational]`, (unverified).
- **Conflict:** a preprint reports pooled agent code less likely than human code to contain a security smell ([Kraishan](https://arxiv.org/abs/2609.17598)) (unverified), against Xia and Miller.
- **Conflict:** DORA 2024 associates AI adoption with slightly higher self-reported code quality ([DORA 2024](https://cloud.google.com/blog/products/devops-sre/announcing-the-2024-dora-report)) `[observational]`, against the mined-repository studies above.
- **Counted once:** trade-press articles on duplicated code all report one vendor's dataset ([GitClear, via DevClass](https://www.devclass.com/ai-ml/2025/02/20/ai-is-eroding-code-quality-states-new-in-depth-report/1626250)) `[vendor]`, (unverified), primary source unreachable.
- **No controlled study** shows which mitigation reduces maintenance cost. Review before merge is the only one with a dose-response figure, and it is correlational.

#### Product metrics: frameworks without outcome evidence

- HEART and its goals-signals-metrics process come from a peer-reviewed paper that reports use across Google products and no outcome evaluation ([Rodden et al., CHI 2010](https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/)) `[opinion]`. Its five categories (happiness, engagement, adoption, retention, task success) are (unverified) against the paper text.
- Guardrail metrics (measures a change must not harm, such as latency or errors) and a tracking plan written before implementation are practice guidance from experimentation literature and analytics vendors ([Kohavi et al.](https://www.cambridge.org/core/books/trustworthy-online-controlled-experiments/sample-ratio-mismatch-and-other-trustrelated-guardrail-metrics/8DBB0F59AC7729D7BC6B94690DB9CCD5), [Segment](https://segment.com/docs/protocols/tracking-plan/create/)) `[opinion]`, (unverified).
- **No evidence found** that any metric framework improves outcomes, or that agents instrument analytics correctly from a plan. One point is logical, not empirical: an event that is not instrumented in the build cannot be measured after launch.

#### Operability: the person owns the targets, the AI owns the mechanics

- Google's example error budget policy sets the budget as one minus the objective, halts changes other than urgent and security fixes when the trailing four-week budget is exceeded, and names an author, approver and revisit date ([SRE Workbook](https://sre.google/workbook/error-budget-policy/)) `[opinion]`.
- Feature flags and staged rollout separate deploy from release so a change can be turned off without redeploying ([Fowler and Hodgson](https://martinfowler.com/articles/feature-toggles.html)) `[opinion]`, (unverified).
- **No peer-reviewed outcome evidence** was found that objectives, error budgets or runbooks reduce incidents, and none on agents writing runbooks or rollback plans.

#### Context files as a sustainability deliverable

- The context-file results in 3.1 apply here: no general gain in task success, cost up over 20%, repository overviews not helpful ([Gloaguen et al.](https://arxiv.org/abs/2602.11988)) `[controlled]`, preprint. That benchmark measures single-issue resolution, not upkeep across many Epics.
- **No evidence found** that decision-record folders, architecture diagrams or living documentation improve later agent work.

#### What this means for the kit (inference)

- Justify decision records as a way for a person who did not make the decisions to audit and revisit them. The evidence does not support them as a quality lever.
- Write each record as proposed and let the final review accept or reject it. Otherwise the kit reproduces the born-accepted pattern.
- Gate maintainability by a script that compares warnings, complexity and duplication against the base branch. Merged status and passing tests do not show it.
- The person states a success metric, guardrails, release style and rollback trigger in the plan. The AI derives events, instrumentation, flags and runbook text and records them.
- Do not generate a large context file as a deliverable. Keep an index of pointers.

### 3.5 Question 5: the final human check

#### Line-by-line review of an Epic is not credible

- At Google, across about 9 million reviewed changes, the median change modified 24 lines; the median wait for first feedback was under an hour for small changes and about 5 hours for very large ones ([Sadowski et al., ICSE-SEIP 2018](https://sback.it/publications/icse2018seip.pdf)) `[observational]`, peer-reviewed.
- A review-tool vendor advises reviewing 200 to 400 lines at a time at under 500 lines per hour; its own material gives both a 60-minute cap and a 60-to-90-minute example ([SmartBear](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)) `[vendor]`. The underlying study could not be traced, and most blog advice on review size repeats this one source, so it counts once.
- Review is mostly about understanding. Observing 17 developers and classifying 570 comments at Microsoft, researchers found fewer defects caught than expected, and understanding the change was the central need, poorly served by tools ([Bacchelli and Bird, ICSE 2013](https://web.eecs.umich.edu/~weimerw/2018-481/readings/codereview.pdf)) `[observational]`, peer-reviewed.

#### Reviewers ask less about intent when the author is an agent

- Comparing 567 Claude Code pull requests with 567 human ones: 83.77% against 91.00% merged; median description 355 against 56 words; 45.1% of merged agent pull requests needed further changes; in a hand-classified sample, 39.9% of agent pull requests (85 of 213) had several objectives against 12.2% of human ones (27 of 221) ([Watanabe et al.](https://arxiv.org/html/2509.14745v3)) `[observational]`, journal acceptance per the authors.
- In 278,790 review conversations, questions about understanding made up 31% of reviewers' first comments on human-written code and 17% on agent-written code; human suggestions were adopted 56.5% of the time and agent suggestions 16.6% ([Zhong et al.](https://arxiv.org/html/2603.15911v3)) `[observational]`, preprint. The 17% figure covers first comments only.

#### Explanations raise acceptance unless they make checking cheap

- People with an AI assistant wrote less secure code and were more likely to believe it was secure; those who trusted the AI less produced fewer vulnerabilities ([Perry et al., CCS 2023](https://arxiv.org/abs/2211.03622)) `[controlled]`.
- Across three datasets, explanations did not improve joint human and AI performance and increased acceptance of the AI's recommendation whether or not it was correct ([Bansal et al., CHI 2021](https://arxiv.org/abs/2006.14779)) `[controlled]`, not software.
- Over five studies (N = 731), explanations reduced overreliance when they lowered the cost of verifying the AI's answer, and more so on harder tasks ([Vasconcelos et al., CSCW 2023](https://arxiv.org/abs/2212.06823)) `[controlled]`, maze task with a simulated AI.
- A preprint reports that favorable commit messages let vulnerabilities pass LLM reviewers ([Mitropoulos et al.](https://arxiv.org/abs/2603.18740)) (unverified).

#### Demos, test artifacts and previews: documented features, no measured effect

- The Scrum Guide separates two questions. The Definition of Done decides whether work is finished and of acceptable quality; the Sprint Review, described as a working session and not a presentation, inspects the outcome and decides what to adapt ([Scrum Guide 2020](https://scrumguides.org/scrum-guide.html)) `[opinion]`.
- Playwright traces hold DOM snapshots before and after each action, a screencast film strip, network requests and console logs, and open in a browser without installation ([Playwright](https://playwright.dev/docs/trace-viewer)) `[vendor]`.
- Vercel gives each branch and each commit a preview URL; new projects protect previews by default, so a reviewer without an account needs a shareable link ([Vercel](https://vercel.com/docs/deployments/environments)) `[vendor]`.
- A thesis finding that non-developers struggle with business-domain Gherkin ([Alshammari](https://theses.gla.ac.uk/85190/2/2025AlshammariPhD.pdf)) is (unverified).

#### How vendors present agent work

- **Antigravity** asks for review of an implementation plan before changes, accepts inline comments on artifacts, and writes a walkthrough with screenshots or recordings when it finishes ([implementation plan](https://www.antigravity.google/docs/implementation-plan), [artifacts](https://www.antigravity.google/docs/artifacts), [walkthrough](https://www.antigravity.google/docs/walkthrough)) `[vendor]`.
- **Cursor** cloud agents attach videos, screenshots and logs; Cursor says over 30% of its own merged pull requests come from them, with no review-quality figure ([Cursor](https://cursor.com/blog/agent-computer-use)) `[vendor]`.
- **Codex** cites terminal logs and test output and says when it is uncertain or a test fails ([OpenAI](https://openai.com/index/introducing-codex/)) `[vendor]`.
- **Copilot** agent commits link to session logs ([GitHub](https://github.blog/changelog/2026-03-20-trace-any-copilot-coding-agent-commit-to-its-session-logs)) `[vendor]`. **Devin Review** groups and orders changes and flags findings by severity ([Cognition](https://cognition.com/blog/devin-review)) `[vendor]`.
- **Counted once:** the claim that evidence artifacts make review fast is each vendor's own feature claim. None publishes an effect on review accuracy.
- Among the vendor artifacts examined, none presents a list of decisions the agent made with the alternatives it rejected.

#### Gaps

- **No study** compares end-of-project review formats (demo, preview, decision list, test report) on catching intent mismatch.
- **No study** measures how many decisions a person can assess in one sitting, or whether ranking by reversibility changes what they catch.
- **No controlled study** measures people missing defects in large agent-written changes. Research on attention decline during monitoring exists but has not been tested on code or product review (unverified).

#### What this means for the kit (inference)

- The final check has to judge behavior and decisions on a running build. An Epic-sized diff is beyond every review-size figure found.
- The review has to hand the person understanding, because reviewers ask for it less when an agent wrote the change: state the intent, what was built, and what was added or dropped.
- Make the person do something: follow a short tour on a preview, then try their own first action. Reading the agent's confident prose is the format the evidence warns against.
- Present each decision as a question with a cheap check. A justification raises acceptance without raising scrutiny.
- Keep the kit's "not verified" list and give it more weight. It is the place where honest limits reach the person.

## 4. Proposals for this kit

Each proposal is labelled **evidence-backed** (with the finding and its rating) or **design choice** (no direct evidence; reasoning given). All of them are proposals to measure against a plain session before release, as the kit already does.

### How the current two approvals move

The current design has two approvals per Story: the Story before code, and the QA Story before QA runs. Applied to an Epic of several Stories, that becomes many approvals, which the new direction rules out. What the evidence suggests:

- **Keep the approval before code, once, on the Epic plan.** Evidence-backed: [Ambig-SWE](https://arxiv.org/html/2502.13069v3) `[controlled]`, [Laban et al.](https://arxiv.org/abs/2505.06120) `[controlled]` preprint, and Anthropic's documented default ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)) `[vendor]`.
- **Move the second approval's job into the first.** The person approves what will be checked by answering yes or no to examples during intake; those examples become the acceptance checks. Evidence-backed in part: [TiCoder](https://arxiv.org/html/2404.10100v2) `[controlled]` shows people judge intent well from concrete checks. That the examples can replace a later QA Story approval is a design choice.
- **End-only review is not shown to be safe.** No study compares mid-run checkpoints with end-only review (3.2), unreviewed merges go with more maintenance burden ([Xia and Miller](https://arxiv.org/abs/2607.09902)) `[observational]` preprint, and Cursor's long migration still needed careful review ([Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]`. So: machine gates the builder cannot edit, a sanctioned stop for decisions that are not the AI's, and the merge to the production branch stays with the person, as today.

### How the proposals map onto the kit's current pieces

A sketch, not a design. Each row is detailed in the subsection named.

| Today | With an Epic | Where |
|---|---|---|
| `/story <request>` writes a Story; the person approves it | An intake conversation writes one Epic plan; the person approves it once | 4a, 4b |
| The AI picks each fork and shows its pick for approval | The person chooses scope breadth item by item; the AI picks everything else and logs it as proposed | 4a, 4c |
| Stories are the unit a person approves | Stories become the AI's own tasks; a person does not approve them one by one | 4c |
| `qa-writer` writes the QA Story after development; the person approves it | `qa-writer` writes the checks from the examples the person already answered; no second approval; the builder cannot edit them | 4c |
| `qa-runner` and the security review run once after development | The runner's result is the only thing that marks a task as passing; the full set, the quality checks and the security review run at Epic end | 4c, 4d |
| The report, with its "not verified" list | The final review: intent against built, a tour on a running preview, decisions as questions, evidence links, "not verified" | 4e |
| `references/risks.md` decisions are never picked by the AI | Unchanged, and now also the sanctioned reason to stop mid-run | 4c |

### 4a. The Epic intake conversation

**Before asking anything (the AI works alone).**

1. Read the request and the repository. Write a one-paragraph restatement.
2. Draft two or three candidate readings, from the smallest that fits the words to the fullest a reasonable person could mean. For each, list what a user would see. *Evidence-backed in part:* divergence between samples as an ambiguity signal is function-level evidence ([ClarifyGPT](https://doi.org/10.1145/3660810), [SpecFix](https://arxiv.org/abs/2505.07270v3)) `[controlled]`; using it on Epic readings is an extrapolation.
3. Mark where the readings differ in something a user would see, and where the request contradicts itself. *Evidence-backed:* contradictions are the type models catch least ([HumanEvalComm](https://arxiv.org/html/2406.00215v3)) `[controlled]`.
4. Check the request against `references/risks.md`.

**Questions, in this order. One at a time, with options where possible.**

| # | Question | Asked when |
|---|---|---|
| 1 | "Here is what I understood: who has what problem today, and what will be different for them when this is done. Is that right?" | Always |
| 2 | "The smallest version that fits your words is A. A fuller version would also include B, C, D, E. Which of these are in?" The person answers per item. | Always |
| 3 | "Here is what a user will see. Yes, no, or change it?" Five to nine examples (below). | Always |
| 4 | "These are out of scope: … . Is anything you expect missing from both lists?" | Always |
| 5 | The matching items from `risks.md`, one per decision | Only when a lens matches |
| 6 | "Who uses this? Is there a group we must not exclude: age, assistive technology, language or region?" | Only when the Epic has a user interface and the repository does not already say |
| 7 | "After launch, what would tell you this worked? What must not get worse?" | Once per Epic; if the person has no answer, the AI proposes one for a yes or no |
| 8 | "Can this reach all users at once, or must it be possible to turn it off?" | Only when it changes a flow existing users rely on, or a risk lens matched |
| 9 | "Your request says X and also Y. Which holds?" | Only when a contradiction was found |
| 10 | What `docs/qa.md` lacks to start the app and log in | Only when those fields are missing, because without them every check is "not run" |

*Evidence-backed:* a forced step to find what is underspecified ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`; questions about visible behavior and scope, which the person can answer ([Ambig-SWE](https://arxiv.org/html/2502.13069v3), [Vijayvargiya et al.](https://arxiv.org/abs/2604.14624)) `[controlled]`; triggered questions instead of default ones ([HumanEvalComm](https://arxiv.org/html/2406.00215v3)) `[controlled]`. *Design choice:* the order, and questions 6 to 8 as triggered items.

**How question 2 surfaces the broad and narrow reading.** Both readings are shown as lists of user-visible items. The AI does not recommend a breadth and does not mark the small version as the default. An item nobody answered stays open; it is never moved to out of scope by the AI. *Design choice:* no study compares defaults (3.1). The reasoning is that a recommended option anchors the person on the AI's reading, and the AI's documented default is the narrow one.

Example for the request "build a payment system":

```
Smallest version: a customer pays for one order by card and sees a confirmation.
A fuller version would also include. Which are in?
  [ ] refunds               [ ] saved cards          [ ] receipt by email
  [ ] retry after a failure [ ] an admin payment list [ ] more than one currency
```

**What the user will see (question 3).** Five to nine examples in the form `where · action → visible result`. At least two sit at the edge of scope and at least one says what must not happen. The person answers yes, no or a correction. *Evidence-backed:* [TiCoder](https://arxiv.org/html/2404.10100v2) `[controlled]`, function level; the count is a design choice.

```
E1. Checkout · enter card, press Pay → "Payment complete"; the order shows as paid.      yes / no
E2. Checkout · the card is declined → the reason is shown; nothing is charged;
    the customer can try another card.                                                    yes / no
E3. (edge) Checkout · the customer closes the tab during payment → on return the order
    shows its true state and they are not charged twice.                                  yes / no
E4. (edge) Admin · refund an order → the customer sees the refund.                        in / out
E5. (must not happen) A customer never sees another customer's payment details.          yes / no
```

**Stop rule.** Stop asking when all three hold:

- every sentence of the request maps to an example, to out of scope with a reason, or to a Human decides item (the kit's existing MUST and OUT rule);
- the candidate readings no longer differ in anything a user would see;
- every matched risk-lens item has an answer, or is recorded as open with the part of the work it blocks.

Budget: at most five open questions beyond the always-asked four, not counting risk-lens items. Past the budget, the AI picks and records the pick as a decision for the final review, except for scope breadth and risk-lens items, which are never picked by the AI. *Evidence-backed in part:* Spec Kit caps at 3 and 5 ([specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md), [clarify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/clarify.md)) `[vendor]`; models averaged about 3 to 6 questions with a proxy capped at 3 turns ([Ambig-SWE](https://arxiv.org/html/2502.13069v3)) `[controlled]`. No study gives the value of each further question, so the number is a design choice.

**Then consolidate.** Write the whole plan as one document, show it, get one approval, and start the build in a fresh context from the document, not from the conversation. *Evidence-backed:* instructions spread over turns cost 39% ([Laban et al.](https://arxiv.org/abs/2505.06120)) `[controlled]`, preprint; Anthropic recommends building in a fresh session from the written spec ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)) `[vendor]`.

**Never ask the person (the AI decides these).** Language, framework, libraries, architecture, data model, file layout, how to split the work, task order, test strategy, naming, internal error handling, which checking tool, where things are in the code, or anything the repository answers. Default quality thresholds are proposed by the AI, and the person only changes them. *Evidence-backed:* keeping only relevant questions the user can answer matched results with 41% fewer questions ([Vijayvargiya et al.](https://arxiv.org/abs/2604.14624)) `[controlled]`, preprint, and asking by default has a cost ([HumanEvalComm](https://arxiv.org/html/2406.00215v3)) `[controlled]`.

One boundary: a choice that looks technical but falls under `risks.md` is not on this list. Which payment provider to use is an external contract and a money decision, so the person decides it.

### 4b. A template for the Epic plan

In the spirit of the existing `STORY.md`: headings stay, content is in the person's language, and it fits on about one screen and a half. *Design choice*, with the evidence for each section named below it.

```markdown
# Epic: <outcome in one line>

## Why
- Today: <who has what problem>
- Outcome: <what is different for them when this is done>

## Users
- <who uses it; any group we must not exclude: age, assistive technology, languages, regions>

## What the person will see
- E1. <where> · <action> → <visible result>
- E2. <where> · <action> → <visible result>
- E3. (edge) <where> · <action> → <visible result>
- E4. (must not happen) <what never shows or happens>

## Scope
- Smallest reading: <one line>
- Fullest reading: <one line>
- Chosen by <person> on <date>: <the items that are in>
- Out of scope:
  - O1. <item>: <why>
- Unchanged: <what must stay exactly as it is>

## Human decides
- H1. <decision from references/risks.md> → <the person's answer | open, blocks <part>>

## Quality bars
| Area | Bar | Checked by |
|---|---|---|
| Accessibility | WCAG 2.2 AA: rule scan 0 violations on every route and key state; keyboard and focus walk on <core flow> | script; agent |
| Accessibility | Screen reader pass on <core flow> | person at final review |
| Targets and text | Targets ≥ <24 or 44> CSS px; works at 320 px width and 200% text | script |
| Languages | <locales>; no hard-coded text; pseudo-locale run shows no overflow | script; translation quality: person or after launch |
| Performance (lab) | Median of 5 runs, mobile profile: LCP ≤ 2.5 s, CLS ≤ 0.1, TBT ≤ <n> ms; <route> ≤ <n> KB | script |
| Performance (field) | LCP, INP, CLS good at the 75th percentile | after launch only |
| States and errors | Every data view has empty, loading and error states; errors say how to fix and keep input | agent |
| Code health | No new static-analysis warnings; complexity and duplication not above base | script |

## Success after launch
- Primary metric: <what would tell you this worked>
- Must not get worse: <1 to 3 guardrails>
- Events to record: <name: when it fires>
- Personal data: <what is collected, kept how long, how deleted | none>

## Operability
- Release: all at once | behind a switch | staged
- Roll back when: <signal and threshold>
- Reliability expectation: <target and window | not stated>

## Done when
- [ ] Every E# passes on the running app (checks the builder cannot edit)
- [ ] Every quality bar passes or is listed as not verified, with the reason
- [ ] Security review: no confirmed finding open
- [ ] Every Human decides item is answered
- [ ] The person has done the final review

---
Status: Draft | Approved
Owner: <the person who made the request>
```

Evidence behind the sections:

- **Why, Scope, Out of scope, Done when:** goal, constraints and a done condition are common vendor guidance ([Claude Code best practices](https://code.claude.com/docs/en/best-practices), [Codex best practices](https://learn.chatgpt.com/guides/best-practices.md)) `[vendor]`. An explicit out-of-scope list has no measured effect; agent pull requests bundle several objectives more often than human ones ([Watanabe et al.](https://arxiv.org/html/2509.14745v3)) `[observational]`, which is the reason to keep it.
- **What the person will see:** [TiCoder](https://arxiv.org/html/2404.10100v2) `[controlled]`.
- **Scope readings and the chosen one:** design choice, aimed at the kit's measured failure and the documented default ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)) `[vendor]`.
- **Human decides:** the kit's existing rule; indirect support from the 41.1% figure on unstated requirements ([Yang et al.](https://arxiv.org/abs/2505.13360)) `[controlled]`, preprint.
- **Quality bars with who checks:** 3.3; the thresholds are standards or vendor de facto standards, and the split by verifier is a design choice.
- **Success after launch, Operability:** frameworks `[opinion]`; included because an event not built cannot be measured, and because release style and rollback trigger are decisions only the person can make.

A small Epic (one reading, no interface, no risk lens) keeps only Why, What the person will see, Scope and Done when, as the kit's small-change rule does today.

### 4c. Rules the AI follows when it decides details itself

These rules cover what the builder reads, what it may not edit, what it records and who declares done. They do not say how to implement: no task order, no test-first rule, no tool or architecture choice. That keeps the kit's non-goal, which the context-file studies support: in one of them context strategy did not measurably change correctness ([Khatri](https://aclanthology.org/2026.realm-1.5/)) `[controlled]`, small sample. The one-task and fresh-context rules below do shape how a run is organized. They are the part of this section closest to that non-goal, and the first to drop if a measurement at Epic scale shows no gain.

**Decision log.** One entry per decision that changes what a user sees, what is stored, or what is hard to reverse. Routine implementation choices are not logged.

```markdown
D7. <the decision in one line>                               Status: proposed
- Chosen: <option>
- Instead of: <option b>; <option c>
- Because: <one line tied to the plan: Why, an E#, or a quality bar>
- You would notice it is wrong if: <something the person can see on the preview>
- To reverse: cheap | costly | one-way
- Kept true by: <test or check name | nothing>
```

*Evidence-backed in part:* the fields follow the required sections and the confirmation field of [MADR](https://adr.github.io/madr/) `[opinion]`. Status stays proposed until the final review, because about 63% of records in open-source repositories were opened as accepted ([ICSA 2026](https://conf.researchr.org/details/icsa-2026/icsa-2026-papers/34/Architecture-Decision-Records-Adoption-Impact-and-Developer-Engagement-in-Open-Sou)) `[observational]`. The "you would notice" line replaces a justification, because explanations raise acceptance regardless of correctness ([Bansal et al.](https://arxiv.org/abs/2006.14779)) `[controlled]` and reduce overreliance when they make checking cheap ([Vasconcelos et al.](https://arxiv.org/abs/2212.06823)) `[controlled]`. *Known risk:* no study shows that an agent's own record matches what it actually weighed.

**When a decision is not the AI's.**

- Anything under `references/risks.md`: money, migration, authentication and authorization, external contracts, stored and sensitive data.
- A scope change: adding or dropping an example, or touching Out of scope or Unchanged.
- A one-way step the plan does not cover, such as deleting data or publishing an interface others depend on.
- An acceptance check that looks wrong or cannot be met.

In these cases the AI writes a flag (what, the options, what it blocks), parks the tasks that depend on it and continues with the rest. If everything left is blocked, it stops and asks. It never edits the check or picks for the person. *Evidence-backed:* an abort option cut cheating from 54% to 9% on realistic tasks ([ImpossibleBench](https://arxiv.org/html/2510.20270v1)) `[controlled]`. Parking instead of stopping is a design choice.

**State in files.** *Evidence-backed as vendor practice* ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents), [Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]`, no ablation:

- `docs/epics/<slug>/EPIC.md`: the approved plan. The builder never edits it.
- `docs/epics/<slug>/tasks.json`: the AI's own split of the work. Each task names the examples it serves and has a `passes` field that only the QA runner's result may change.
- `docs/epics/<slug>/decisions.md` and a short progress note.
- One commit per task.

How the AI splits and orders tasks is its own choice.

**The rules.**

| Rule | Reason | Label |
|---|---|---|
| Work on one task at a time | Building too much at once ran out of context mid-feature ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) | Evidence-backed, `[vendor]` |
| Start each task in a fresh context and re-read the plan first | Drift grew with context length ([Arike et al.](https://arxiv.org/abs/2505.02709)) `[controlled]`; periodic fresh starts were still needed ([Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]` | Evidence-backed in part |
| Each task names the examples it serves; a task that serves none is logged as added scope and not built silently | Agent pull requests bundle objectives more often ([Watanabe et al.](https://arxiv.org/html/2509.14745v3)) `[observational]` | Design choice |
| Acceptance checks are written from the plan by an agent that does not read the code | The kit's existing black-box QA; features were marked passing without end-to-end verification ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) `[vendor]` | Evidence-backed in part |
| The builder cannot edit anything under `qa/` or the plan; a script compares the builder's commits against those paths | Read-only tests blocked test edits ([ImpossibleBench](https://arxiv.org/html/2510.20270v1)) `[controlled]`; an instruction alone is not a lock, as the current spec already says | Evidence-backed |
| The builder never declares done; `passes` changes only from the runner's result, and a check that could not run is "not run" | Premature completion claims ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) `[vendor]`; monitors caught 42% to 65% of cheating ([ImpossibleBench](https://arxiv.org/html/2510.20270v1)) `[controlled]` | Evidence-backed |
| A separate fresh-context pass checks each finished task against the plan | Derailment was not tied to context fill, so context hygiene alone is not enough ([Vending-Bench](https://arxiv.org/abs/2502.15840)) `[controlled]` preprint | Evidence-backed in part |
| One builder thread; parallel agents only for independent checks | Flat coordination collapsed throughput ([Cursor](https://cursor.com/blog/scaling-agents)) `[vendor]`; implicit decisions conflict ([Cognition](https://cognition.com/blog/dont-build-multi-agents)) `[opinion]` | Evidence-backed in part |

Read-only checks do not stop special-casing (3.2). The black-box runner and the person's own exploration at the final review are the remaining guards.

### 4d. QA and UX checks to add

Thresholds come from the sources in 3.3. "Person" means at the final review. Tool names and options are from each tool's documentation and are (unverified); confirm rule names and flags before building. *Design choice* throughout, on thresholds that are standards or vendor de facto standards.

| Check | Tool | Threshold | Who verifies | What automation cannot cover |
|---|---|---|---|---|
| Acceptance examples | `qa-runner` scripts, browser | Every E# passes | Script, agent | Only what the examples say |
| Accessibility rule scan | axe-core through Playwright, WCAG 2.0 to 2.2 A and AA tags, every route and key state (dialog open, form error, empty) | 0 violations | Script | It found 57% of issues by volume and touched 16 of 50 criteria in the vendor's data ([Deque](https://www.deque.com/automated-accessibility-coverage-report/)); no keyboard, focus order or non-text contrast |
| Keyboard and focus walk | Browser-driving agent: tab through; each control reachable; focus visible and not fully hidden; Escape closes overlays and focus returns | All hold on the core flow | Agent, with screenshots | No measured reliability for agents here; report as evidence, person spot-checks |
| Target size | Script measuring each control, or the axe rule | ≥ 24 by 24 CSS px or a listed exception; 44 when the plan names older or touch-first users | Script | Whether spacing feels usable |
| Reflow and text size | Playwright at 320 px width; 200% text | No horizontal scroll; no clipped text | Script | Reading comfort |
| Reduced motion | Playwright media emulation | No non-essential animation | Script | Whether remaining motion is acceptable |
| Login | Paste allowed, autocomplete set, no puzzle without an alternative | All hold | Script, agent | Real two-factor flows: person |
| Dragging, consistent help, redundant entry | Agent walks the flows | A single-pointer alternative exists; help stays in place; data is not asked twice | Agent | Edge flows not in the plan |
| Screen reader | VoiceOver or NVDA on the core flow | Person can complete it | Person | Not automatable; alt-text meaning included |
| Names and personal fields | Script submits non-Latin names, apostrophes, long names; checks for an unexplained required gender field | Accepted; none required | Script | Cultural fit of the form |
| Text and layout for other languages | Lint for hard-coded strings; pseudo-locale run; `lang` set; right-to-left run only when the plan lists such a language | 0 lint errors; no untranslated text; no overflow | Script, agent | Translation quality and tone: native reader, or after launch |
| Dates, numbers, plurals | Lint or search for hand-built formats and one-or-many plural logic | None in new code | Script | Locale conventions beyond format |
| Empty, loading, error, slow states | Agent forces each state by stubbing the network; screenshots | Each data view shows all four | Agent | Whether the states make sense: person |
| Error messages | Agent triggers each validation error | Message is next to the field, says how to fix, keeps input | Agent | Wording quality: advisory |
| Performance, lab | Lighthouse, mobile profile, median of 5 runs on fixed hardware; bundle-size check | LCP ≤ 2.5 s; CLS ≤ 0.1; TBT and size budgets from the plan | Script | INP cannot be measured in a lab; lab is not field |
| Performance, field | Real-user monitoring | LCP, INP, CLS good at the 75th percentile | After launch only | Cannot be claimed before launch |
| Server latency | Load tool on seeded data | The 95th-percentile target stated in the plan | Script | No generic threshold exists |
| Code health | Static analysis and duplication check against the base branch | No new warnings; complexity and duplication not above base | Script | Design quality |
| Tracking plan | Acceptance run asserts each planned event fires | Every event in the plan seen | Script | Whether the metric is the right one: after launch |
| Usability heuristics | LLM review against Nielsen's ten | No threshold | Advisory list for the person | Studies disagree, 21% against 73% to 77% ([one](https://arxiv.org/abs/2506.16345), [two](https://arxiv.org/abs/2507.02306)); never a gate |
| Persona walkthrough | LLM walks the flow as a cautious, process-oriented user | No threshold | Advisory | Not validated for LLMs |
| Security | Existing scanner and `security-review` | No confirmed finding open | Script, agent | As today |

Two cost notes. The kit measured that QA preparation during development slowed work without improving output, so these checks run after a task or at Epic end, from saved scripts. And accessibility repair by iterating an LLM cost more without a better result ([Oyelayo et al.](https://arxiv.org/abs/2605.27716)) `[controlled]`, preprint, so the kit should fix a failed check once and report what remains.

### 4e. The format of the final human review

Target about 30 minutes, with a cap of one hour; if the tour cannot fit, the Epic was too large for one review. *Design choice:* no study compares formats or durations. The only figure is a vendor's 60-minute session cap ([SmartBear](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)) `[vendor]`.

Order of sections, with the reason for each:

1. **Intent and what was built.** The plan's Why and Outcome, word for word. Then per example: built, partly, or not. Then **added** (anything built that serves no example) and **dropped** (anything in scope not built). *Evidence-backed in part:* understanding is the core review need ([Bacchelli and Bird](https://web.eecs.umich.edu/~weimerw/2018-481/readings/codereview.pdf)) `[observational]`; reviewers ask less about intent on agent work ([Zhong et al.](https://arxiv.org/html/2603.15911v3)) `[observational]` preprint; agents bundle objectives ([Watanabe et al.](https://arxiv.org/html/2509.14745v3)) `[observational]`.
2. **Try it.** A preview link with a note on access. A guided tour of five to nine steps, one per example: "do this, you should see that", each ticked matches or does not. Then one open prompt: "now do the first thing you would do as a user". *Evidence-backed in part:* verification has to be cheap ([Vasconcelos et al.](https://arxiv.org/abs/2212.06823)) `[controlled]`; the working-session framing comes from the [Scrum Guide](https://scrumguides.org/scrum-guide.html) `[opinion]`; previews are documented features ([Vercel](https://vercel.com/docs/deployments/environments)) `[vendor]` with no measured effect.
3. **Decisions to check.** At most seven, ranked by cost to reverse and then by user impact. Each is a question, not a justification: "We chose X instead of Y. You would notice it is wrong if Z. Check it at tour step 3. Keep or change?" The rest are linked. *Evidence-backed in part:* [Bansal et al.](https://arxiv.org/abs/2006.14779) and [Vasconcelos et al.](https://arxiv.org/abs/2212.06823) `[controlled]`. The count and the ranking are design choices, and no vendor precedent was found.
4. **Evidence, as links.** The acceptance table, traces and screenshots, accessibility and performance numbers next to their thresholds, the security result. Written by the runners, not summarized by the builder. *Design choice,* extending the kit's black-box rule.
5. **Not verified.** Every check not run and why; checks only a person can do; items that can only be known after launch; picks the AI made after the question budget ran out. Kept even when empty, as the kit's report does today. *Evidence-backed in part:* overconfidence with AI assistance ([Perry et al.](https://arxiv.org/abs/2211.03622)) `[controlled]`; stating uncertainty is a documented vendor practice ([OpenAI](https://openai.com/index/introducing-codex/)) `[vendor]`; no measured effect.
6. **The person's call.** Accept, accept with listed changes, or wrong direction (naming the example or scope item). Accepted decisions change from proposed to accepted. The merge to the production branch stays with the person.

```
Epic: <title>                                   Preview: <link> (access: <how>)
1 Intent    Why: <from the plan>   Outcome: <from the plan>
  Built     E1 built · E2 built · E3 partly: <what is missing> · E4 not built: <why>
  Added     <built but not asked, or "none">      Dropped: <in scope but not built, or "none">
2 Try it    1. <do> → <see>  [ ]   2. <do> → <see>  [ ]   …   Then: do the first thing you would do.
3 Decisions D7. Chose <X> not <Y>. Wrong if <Z>. Check: step 3.   keep / change
4 Evidence  Acceptance <link> · Accessibility <n> violations (bar 0) · LCP <n> s (bar 2.5) · Security <link>
5 Not verified   <check: reason> · <person-only step> · <after-launch item>
6 Your call      accept / accept with changes: <…> / wrong direction: <which E# or scope item>
```

## 5. What not to adopt, and why

| Practice | Why not | Evidence |
|---|---|---|
| Multi-file spec pipelines (constitution, spec, plan, tasks, analysis) | No published outcome data; one hands-on report of 8 files per spec and inflated criteria; the kit's own measurement found preparation cost without better output | [Böckeler](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), `[opinion]`; tool features are `[vendor]` |
| Resolving scope ambiguity by a recorded assumption | An assumptions list protects only if someone reads it before the build; an unreviewed narrow pick is how the kit's measured failure happened | [Spec Kit specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md), `[vendor]` mechanism; the rest is inference |
| Asking clarifying questions by default | Forced asking cut pass@1 on clear problems from 65.58% to 27.45% | [HumanEvalComm](https://arxiv.org/html/2406.00215v3), `[controlled]`, function level |
| Asking the person about implementation | A selector that kept only relevant questions the user can answer matched the same resolution rate with 41% fewer questions | [Vijayvargiya et al.](https://arxiv.org/abs/2604.14624), `[controlled]`, preprint, simulated users |
| A recommended option on scope breadth | Not tested either way; the AI's documented default is the narrow reading | [Claude Code best practices](https://code.claude.com/docs/en/best-practices), `[vendor]`; design choice |
| Auto-generated large AGENTS.md or CLAUDE.md | No general gain in task success; cost up over 20%; overviews not helpful | [Gloaguen et al.](https://arxiv.org/abs/2602.11988), `[controlled]`, preprint |
| A required acceptance-criteria syntax (EARS, Gherkin) | No study shows a syntax effect on agent outcomes | 3.1, no evidence |
| LLM heuristic evaluation as a gate | Two small studies disagree by a factor of three or more | [Guerino et al.](https://arxiv.org/abs/2506.16345), [Zhong et al.](https://arxiv.org/abs/2507.02306), `[controlled]`, conflicting |
| LLM accessibility review or repair loop as a gate | Detection F1 about 0.65; under 26% fully resolved; iteration cost more with no gain | [Oyelayo et al.](https://arxiv.org/abs/2605.27716), `[controlled]`, preprint |
| "Accessible" on the strength of a rule scan | A scan found 57.38% of issues by volume and touched 16 of 50 criteria in the vendor's own data | [Deque](https://www.deque.com/automated-accessibility-coverage-report/), `[vendor]` |
| A single Lighthouse score as the performance bar | Run-to-run variance; no INP in a lab | [Lighthouse](https://github.com/GoogleChrome/lighthouse/blob/main/docs/variability.md), [web.dev](https://web.dev/articles/vitals), `[vendor]` |
| Claiming field performance or translation quality before launch | Field thresholds are defined on real page loads; no automated check for translation was found | [web.dev](https://web.dev/articles/vitals), `[vendor]`; no evidence for translation |
| A flat swarm of peer agents | Twenty agents fell to the throughput of two or three; multi-agent runs used about 15 times the tokens of chat | [Cursor](https://cursor.com/blog/scaling-agents), [Anthropic](https://www.anthropic.com/engineering/multi-agent-research-system), `[vendor]` |
| The agent's self-report, a passing test it could edit, or merged status as proof | 54% cheating on impossible tasks; false completion in long runs; a study that merged does not imply quality (unverified) | [ImpossibleBench](https://arxiv.org/html/2510.20270v1), `[controlled]`; [Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents), `[vendor]` |
| An LLM reviewer as the only guard against test tampering | Monitors caught 42% to 65% on the realistic variant | [ImpossibleBench](https://arxiv.org/html/2510.20270v1), `[controlled]` |
| A final report written as the builder's justification | Explanations raised acceptance regardless of correctness | [Bansal et al.](https://arxiv.org/abs/2006.14779), `[controlled]`, not software |
| Line-by-line review of the Epic diff as the final check | The median reviewed change at Google modified 24 lines | [Sadowski et al.](https://sback.it/publications/icse2018seip.pdf), `[observational]`, peer-reviewed |
| Decision records created as accepted | About 63% in open-source repositories were, which records no deliberation | [ICSA 2026](https://conf.researchr.org/details/icsa-2026/icsa-2026-papers/34/Architecture-Decision-Records-Adoption-Impact-and-Developer-Engagement-in-Open-Sou), `[observational]`, peer-reviewed |
| Dropping every human contact between start and end | No study supports it; unreviewed merges go with more maintenance burden | [Xia and Miller](https://arxiv.org/abs/2607.09902), `[observational]`, preprint |

## 6. Open questions and gaps

**What no study answers**

- No study of any planning method at Epic scale. Everything measured is function-level, single-issue, or uses an LLM as the user.
- No evidence for a broad or a narrow default reading, and none on scope narrowing as a separate failure in LLM planning.
- No study with real people answering an agent's questions at repository scale, and none on the value of each further question.
- No ablation of progress files, per-task commits, one task per context, or a planner and executor split.
- No comparison of mid-run human checkpoints with end-only review for autonomous builds.
- No comparison of end-of-project review formats, and no evidence on how many decisions a person can judge in one sitting.
- No study of whether an agent's record of its own decisions is faithful, or whether such records help later agents.
- No measured reliability for browser-driving agents on keyboard and focus criteria, for LLM-run persona walkthroughs, or for agents implementing analytics from a plan.
- No controlled evidence on which mitigations reduce maintenance cost of agent-written code.
- The kit's own finding (scaffolding did not help within one Story) has not been tested at Epic scale. Every rule in 4c is a hypothesis until it is.

**Conflicts left open**

- Context files and efficiency: cost up (Gloaguen) against runtime and tokens down (Lulla).
- LLM heuristic evaluation: 21.2% against 73% to 77%.
- Security of agent code: more weaknesses (Xia and Miller) against fewer smells (Kraishan, unverified).
- Code quality with AI: slightly up in DORA 2024's survey, down in mined-repository studies.
- Whether ImpossibleBench's cheats are cheats (EvilGenie, unverified).

**Numbers and facts in this report that remain unverified**

A second pass re-checked the figures first taken from summaries or snippets. The items below were not confirmed at the primary source. Figures read directly from a primary source in the first pass were not all read a second time.

- Mathews and Nagappan effect sizes; CLAMBER details; SpecFix's conference acceptance; OpenSpec and BMAD descriptions; Thoughtworks Radar placements.
- Cui et al. per-site effects and adoption rates (left out); Uplevel and GitClear figures (left out or marked); later METR time-horizon figures (left out); EvilGenie's claims.
- The 2018 UK tool audit figures; WCAG Understanding pages for reflow, text resize and enhanced target size; platform target sizes; W3C personal-names and GOV.UK patterns; tool and rule names in 4d; the Design Theater figures.
- Cynthia and Muttakin; Kraishan; HEART's category names against the paper; Kohavi et al.; tracking-plan documentation; feature-toggle article.
- Mitropoulos et al.; the Gherkin thesis; attention-decline research applied to review; the study behind SmartBear's review-size advice (not traceable).
- The TBT budget in 4b and 4d is a project default, not a sourced standard.
- Spec Kit templates were read on a moving branch; pin a commit before citing them elsewhere.
- Gloaguen et al. report a 7-point gap between developer-written and generated files in the introduction that their own results section does not reproduce; this report cites only the significance test.

## 7. Sources

### Question 1: planning for AI agents

- [Ambig-SWE, Vijayvargiya et al., ICLR 2026](https://arxiv.org/html/2502.13069v3) `[controlled]`, simulated user
- [HumanEvalComm, Wu and Fard, ACM TOSEM 2025](https://arxiv.org/html/2406.00215v3) `[controlled]`, function level
- [TiCoder, Fakhoury et al., IEEE TSE 2024](https://arxiv.org/html/2404.10100v2) `[controlled]`, function level, 15-person user study
- [Lahiri et al. 2022, interactive test-driven generation](https://arxiv.org/abs/2208.05950) `[controlled]`, preprint; same line of work as TiCoder
- [ClarifyGPT, Mu et al., FSE 2024](https://doi.org/10.1145/3660810) ([arXiv](https://arxiv.org/abs/2310.10996)) `[controlled]`
- [SpecFix, Jia et al.](https://arxiv.org/abs/2505.07270v3) `[controlled]`, preprint as read
- [Vijayvargiya et al., "Asking What Matters"](https://arxiv.org/abs/2604.14624) `[controlled]`, preprint, simulated users
- [Laban et al., multi-turn degradation](https://arxiv.org/abs/2505.06120) `[controlled]`, preprint
- [Yang et al., "What Prompts Don't Say"](https://arxiv.org/abs/2505.13360) `[controlled]`, preprint
- [Mathews and Nagappan, tests in prompts](https://arxiv.org/abs/2402.13521) `[controlled]`, preprint, effect sizes unverified
- [Quattrocchi et al., LLM-written user stories](https://arxiv.org/abs/2507.15157) `[controlled]`, preprint
- [CLAMBER, ACL 2024](https://arxiv.org/abs/2405.12063) `[controlled]`, unverified
- [ClarQ-LLM](https://arxiv.org/abs/2409.06097) `[controlled]`, preprint, not code
- [OpenAI, SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/) `[vendor]`
- [Gloaguen et al., AGENTS.md evaluation](https://arxiv.org/html/2602.11988v3) ([v1](https://arxiv.org/abs/2602.11988v1), [workshop listing](https://iclr.cc/virtual/2026/10018749)) `[controlled]`, preprint
- [Lulla et al., AGENTS.md efficiency](https://arxiv.org/abs/2601.20404) `[controlled]`, preprint
- [Khatri, REALM 2026](https://aclanthology.org/2026.realm-1.5/) `[controlled]`, small sample
- [GitHub Spec Kit](https://github.com/github/spec-kit): [specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md), [clarify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/clarify.md), [spec template](https://raw.githubusercontent.com/github/spec-kit/main/templates/spec-template.md) `[vendor]`
- [Kiro specs](https://kiro.dev/docs/specs/), [feature specs](https://kiro.dev/docs/specs/feature-specs/) `[vendor]`
- [Anthropic, Claude Code best practices](https://code.claude.com/docs/en/best-practices) `[vendor]`
- [OpenAI, Codex best practices](https://learn.chatgpt.com/guides/best-practices.md) `[vendor]`
- [Böckeler, "Understanding SDD: Kiro, spec-kit, and Tessl"](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) `[opinion]`
- [Thoughtworks Radar, spec-driven development](https://www.thoughtworks.com/radar/techniques/spec-driven-development) `[opinion]`, unverified; same organization as Böckeler

### Question 2: what has worked with AI agents

- [Peng et al. 2023](https://arxiv.org/abs/2302.06590) `[controlled]`, preprint, vendor-affiliated
- [Paradis et al., ICSE-SEIP 2025](https://arxiv.org/abs/2410.12944) `[controlled]`, vendor-affiliated
- [Cui et al., Management Science 2026](https://doi.org/10.1287/mnsc.2025.00535) `[controlled]`, vendor-affiliated
- [METR 2025 randomized trial](https://arxiv.org/abs/2507.09089) `[controlled]`, preprint
- [METR follow-up, February 2026](https://metr.org/blog/2026-02-24-uplift-update/) `[controlled]`, not peer-reviewed, self-described as unreliable
- [METR time horizons](https://arxiv.org/abs/2503.14499) `[controlled]`
- [DORA 2024](https://cloud.google.com/blog/products/devops-sre/announcing-the-2024-dora-report) ([report page](https://dora.dev/ai/gen-ai-report/report/)) `[observational]`
- [DORA 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report) ([report page](https://dora.dev/research/2025/dora-report/)) `[observational]`
- [ImpossibleBench, Zhong et al., ICLR 2026](https://arxiv.org/html/2510.20270v1) `[controlled]`
- [EvilGenie](https://arxiv.org/pdf/2511.21654) `[controlled]`, preprint, unverified
- [Arike et al., goal drift, AIES 2025](https://arxiv.org/abs/2505.02709) `[controlled]`
- [Vending-Bench](https://arxiv.org/abs/2502.15840) `[controlled]`, preprint
- [Chroma, context rot](https://research.trychroma.com/context-rot) `[vendor]`
- [Anthropic, effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) `[vendor]`
- [Anthropic, multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) `[vendor]`
- [Cursor, scaling long-running autonomous coding](https://cursor.com/blog/scaling-agents) `[vendor]`
- [Cognition, "Don't Build Multi-Agents"](https://cognition.com/blog/dont-build-multi-agents) `[opinion]`

### Question 3: product quality beyond correctness

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/), [what's new](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/), [Understanding 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html) `[opinion]`, standard
- [Deque, automated accessibility coverage report](https://www.deque.com/automated-accessibility-coverage-report/) `[vendor]`
- [UK Government Digital Service, accessibility tool audit](https://alphagov.github.io/accessibility-tool-audit/) `[controlled]`, 2018, unverified
- [WebAIM Million 2026](https://webaim.org/projects/million/) `[observational]`
- [Oyelayo et al., LLM accessibility repair](https://arxiv.org/abs/2605.27716) `[controlled]`, preprint
- [Vorvoreanu et al., CHI 2019](https://www.microsoft.com/en-us/research/uploads/prod/2019/02/GenderMag_cameraReady.pdf) `[controlled]`, qualitative, n = 20
- [Murphy-Hill et al., ICSE 2024](https://conf.researchr.org/details/icse-2024/icse-2024-research-track/95/GenderMag-Improves-Discoverability-in-the-Field-Especially-for-Women) `[observational]`, peer-reviewed
- [Font size for older adults, Frontiers in Psychology 2022](https://www.frontiersin.org/articles/10.3389/fpsyg.2022.931646/full) `[controlled]`, systematic review
- [web.dev, Web Vitals](https://web.dev/articles/vitals) `[vendor]`
- [Lighthouse variability](https://github.com/GoogleChrome/lighthouse/blob/main/docs/variability.md) `[vendor]`
- [Microsoft, pseudolocalization](https://learn.microsoft.com/globalization/methodology/pseudolocalization) `[vendor]`
- [Godot, pseudolocalization](https://docs.godotengine.org/en/4.5/tutorials/i18n/pseudolocalization.html) `[vendor]`
- [Unicode CLDR plural rules](https://cldr.unicode.org/index/cldr-spec/plural-rules) `[opinion]`, standard, unverified
- [Guerino et al., GPT-4o heuristic evaluation, INTERACT 2025](https://arxiv.org/abs/2506.16345) `[controlled]`
- [Zhong et al., synthetic heuristic evaluation](https://arxiv.org/abs/2507.02306) `[controlled]`, preprint
- [Design Theater](https://arxiv.org/pdf/2607.22928) `[controlled]`, preprint, unverified
- [Playwright, accessibility testing](https://playwright.dev/docs/accessibility-testing) `[vendor]`, unverified

### Question 4: sustainable products

- [MADR](https://adr.github.io/madr/) `[opinion]`
- [Santana Junior et al., ICSA 2026](https://conf.researchr.org/details/icsa-2026/icsa-2026-papers/34/Architecture-Decision-Records-Adoption-Impact-and-Developer-Engagement-in-Open-Sou) `[observational]`, peer-reviewed
- [Ahmeti et al., ECSA 2024](https://rebekkaa.github.io/files/2024_ECSA.pdf) `[observational]`, peer-reviewed
- [Dhar et al., ICSA 2024](https://arxiv.org/abs/2403.01709) `[controlled]`
- [He et al., MSR '26](https://arxiv.org/html/2511.04427v3) ([listing](https://2026.msrconf.org/details/msr-2026-technical-papers/16/Speed-at-the-Cost-of-Quality-How-Cursor-AI-Increases-Short-Term-Velocity-and-Long-Te)) `[observational]`, peer-reviewed
- [Xia and Miller](https://arxiv.org/abs/2607.09902) `[observational]`, preprint
- [Cynthia and Muttakin](https://arxiv.org/abs/2601.20109) `[observational]`, unverified
- [Kraishan](https://arxiv.org/abs/2609.17598) `[observational]`, preprint, unverified
- [GitClear, via DevClass](https://www.devclass.com/ai-ml/2025/02/20/ai-is-eroding-code-quality-states-new-in-depth-report/1626250) `[vendor]`, unverified
- [Rodden et al., HEART, CHI 2010](https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/) `[opinion]`, framework from a peer-reviewed paper
- [Kohavi et al., guardrail metrics](https://www.cambridge.org/core/books/trustworthy-online-controlled-experiments/sample-ratio-mismatch-and-other-trustrelated-guardrail-metrics/8DBB0F59AC7729D7BC6B94690DB9CCD5) `[opinion]`, unverified
- [Segment, tracking plan](https://segment.com/docs/protocols/tracking-plan/create/) `[vendor]`, unverified
- [Google SRE Workbook, error budget policy](https://sre.google/workbook/error-budget-policy/) `[opinion]`
- [Fowler and Hodgson, feature toggles](https://martinfowler.com/articles/feature-toggles.html) `[opinion]`, unverified

### Question 5: the final human check

- [Bacchelli and Bird, ICSE 2013](https://web.eecs.umich.edu/~weimerw/2018-481/readings/codereview.pdf) `[observational]`, peer-reviewed
- [Sadowski et al., ICSE-SEIP 2018](https://sback.it/publications/icse2018seip.pdf) `[observational]`, peer-reviewed
- [SmartBear, peer code review best practices](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/) `[vendor]`
- [Watanabe et al., agentic pull requests](https://arxiv.org/html/2509.14745v3) `[observational]`, journal acceptance per the authors
- [Zhong et al., human-AI synergy in agentic code review](https://arxiv.org/html/2603.15911v3) `[observational]`, preprint
- [Perry et al., CCS 2023](https://arxiv.org/abs/2211.03622) `[controlled]`
- [Bansal et al., CHI 2021](https://arxiv.org/abs/2006.14779) `[controlled]`, not software
- [Vasconcelos et al., CSCW 2023](https://arxiv.org/abs/2212.06823) `[controlled]`, not software
- [Mitropoulos et al.](https://arxiv.org/abs/2603.18740) `[controlled]`, preprint, unverified
- [Scrum Guide 2020](https://scrumguides.org/scrum-guide.html) `[opinion]`
- [Playwright trace viewer](https://playwright.dev/docs/trace-viewer) `[vendor]`
- [Vercel environments](https://vercel.com/docs/deployments/environments) `[vendor]`
- [Antigravity: implementation plan](https://www.antigravity.google/docs/implementation-plan), [artifacts](https://www.antigravity.google/docs/artifacts), [walkthrough](https://www.antigravity.google/docs/walkthrough) `[vendor]`
- [Cursor, agent computer use](https://cursor.com/blog/agent-computer-use) `[vendor]`
- [OpenAI, Introducing Codex](https://openai.com/index/introducing-codex/) `[vendor]`
- [GitHub, Copilot agent session logs](https://github.blog/changelog/2026-03-20-trace-any-copilot-coding-agent-commit-to-its-session-logs) `[vendor]`
- [Cognition, Devin Review](https://cognition.com/blog/devin-review) `[vendor]`
- [Alshammari, Glasgow thesis on Gherkin](https://theses.gla.ac.uk/85190/2/2025AlshammariPhD.pdf) `[observational]`, unverified
