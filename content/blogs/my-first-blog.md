---
title: "A Map of Autonomous Research Projects"
date: 2026-07-17
draft: false
summary: "A practical map of the emerging AI systems that generate hypotheses, run experiments, search for algorithms, and audit research artifacts—and why verification remains the central challenge."
---

“Autonomous research” is no longer one thing. It now covers systems that generate a draft paper from code experiments, agents that search a hypothesis space with scientists, evolutionary loops that optimize programs against an objective, and platforms that connect robotic labs to AI planning. The interesting question is not whether an agent can produce research-shaped output. It is what part of the research process it can *reliably close*.

The recent survey [*What’s Missing in Autonomous Research?*](https://www.researchgate.net/profile/Haizhao-Yang/publication/406952713_What's_Missing_in_Autonomous_Research_A_Systematization_of_SystemsBenchmarks_and_Verification/links/6a2ecd0aab2754591109f2ba/Whats-Missing-in-Autonomous-Research-A-Systematization-of-Systems-Benchmarks-and-Verification.pdf) is a helpful map. It reviews 56 public systems through June 2026 and separates their feedback loops, verifier gates, workflow control, persistent artifacts, domain evidence, and lifecycle coverage. That framing avoids a common mistake: treating fluent prose or a completed PDF as evidence that a system has done science autonomously.

<!--more-->

## 1. Paper-production pipelines

The most visible family turns a computational research task into a mini paper factory. [The AI Scientist](https://github.com/SakanaAI/AI-Scientist) proposes ideas within a template, edits and runs code, analyzes results, writes a manuscript, and asks an LLM to review it. **Agent Laboratory** follows a staged workflow for research and paper generation. **AI Scientist v2** adds tree search and separate critique loops for figures and manuscripts.

These are important demonstrations of workflow breadth: a system can carry an idea through experiment-like computation to a submission-shaped artifact. But the evidence is largely in computer-science and machine-learning settings, and the review stage often advises revision rather than having authority to stop an unsupported claim from being released. They are better thought of as ambitious research-production pipelines than independent scientists.

## 2. Hypothesis engines and biology-facing agents

Some systems focus on the earlier, more exploratory part of research. Google’s [AI co-scientist](https://research.google/blog/accelerating-scientific-breakthroughs-with-an-ai-co-scientist/) is a multi-agent partner that generates, debates, ranks, and evolves hypotheses and research proposals around a scientist-specified goal. Its intended role is collaborative: it expands and organizes the space of candidate explanations rather than replacing scientific judgment.

[Robin](https://www.futurehouse.org/research/demonstrating-end-to-end-scientific-discovery-with-robin-a-multi-agent-system), from FutureHouse, pushes further into biology. It links hypothesis generation, experimental strategy, data analysis, and follow-up insight generation, with reported wet-lab validation. The survey also highlights domain-focused systems such as **A-Lab** and **Qumus** in materials science, where synthesis, characterization, or device measurements can provide valuable physical readouts.

This family is promising because real experimental signals are much harder to fake than a polished narrative. Still, an assay or device measurement validates a particular local claim; it does not by itself settle novelty, causal interpretation, limitations, or whether the whole paper should be trusted.

## 3. Objective-driven discovery loops

Another powerful pattern is to make research progress legible as an objective. [AlphaEvolve](https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/) uses Gemini models to propose and improve programs, while automated evaluators score candidates and guide evolutionary search. In this setting, an incorrect program can fail a test and be rejected automatically. **CORAL**, **AutoSOTA**, and related systems extend the same idea to code and ML optimization with hidden graders, repositories, run logs, or executable scores.

These projects show the current sweet spot for autonomy: tasks with an externally checkable target. A verifier can strongly establish that code runs, a score improves, or a constraint is satisfied. It cannot automatically establish that the resulting explanation is the most meaningful scientific one.

## 4. Evidence, auditing, and the road to a release gate

The newest work increasingly treats research artifacts—not only agents—as the product. **Kosmos** maintains an evidence-linked research world model; **AutoResearchClaw**, **ScientistOne**, **ARIS**, and **NORA** add structured records, paper-integrity checks, publication-oriented workflows, or partial claim gates. **EviBound** and **SEVerA** are narrower verifier infrastructures that make runs or formal contracts more inspectable.

This direction matters. A research system needs more than a memory of its own previous text: it needs durable links among claims, code, datasets, figures, logs, citations, and negative results. However, the survey’s main result is sobering: none of the reviewed public systems demonstrated a verifier that could block release of a full manuscript on the basis of complete scientific evidence. Traceability brings evidence closer to a paper; it does not confer authority to decide that the paper is sound.

## 5. Benchmarks are part of the story

Projects such as **MLE-Bench**, **PaperBench**, **MLR-Bench**, **SoundnessBench**, and **SPOT** are not autonomous scientists, but they are essential infrastructure. They test whether agents can reproduce work, optimize against an external scorer, follow a research-like process, or detect unsupported claims and known paper errors. Their results make clear why polished outputs are a weak proxy for reliability: agents can fabricate results after failed execution, and model-based reviewers often miss low-soundness proposals or planted errors.

## What to watch next

The landscape is moving from “can an agent produce a paper?” toward “what evidence can make an agent stop?” The most credible near-term systems will combine: a well-scoped objective or experimental readout; persistent, replayable evidence; independent checks with real blocking power; and a clearly recorded role for human domain experts.

That is a more useful standard than a claim of fully autonomous science. Today’s systems can already accelerate search, implementation, and analysis. The open challenge is turning those capabilities into a research process that can defend its own conclusions.

## Further reading

- [Ren et al., *What’s Missing in Autonomous Research?*](https://www.researchgate.net/profile/Haizhao-Yang/publication/406952713_What's_Missing_in_Autonomous_Research_A_Systematization_of_SystemsBenchmarks_and_Verification/links/6a2ecd0aab2754591109f2ba/Whats-Missing-in-Autonomous-Research-A-Systematization-of-Systems-Benchmarks-and-Verification.pdf)
- [The AI Scientist repository](https://github.com/SakanaAI/AI-Scientist)
- [Google AI co-scientist](https://research.google/blog/accelerating-scientific-breakthroughs-with-an-ai-co-scientist/)
- [FutureHouse Robin](https://www.futurehouse.org/research/demonstrating-end-to-end-scientific-discovery-with-robin-a-multi-agent-system)
- [Google DeepMind AlphaEvolve](https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/)
