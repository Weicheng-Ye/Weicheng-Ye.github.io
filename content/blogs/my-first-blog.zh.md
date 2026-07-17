---
title: "自动化科研项目概览"
date: 2026-07-17
draft: false
summary: "梳理能够生成假设、运行实验、探索算法与审计科研产物的 AI 系统，并说明为什么验证仍是核心难题。"
---

“自动化科研”早已不是单一方向。它既包括从代码实验生成论文初稿的系统，也包括与科学家共同探索假设空间的智能体、按目标函数优化程序的演化循环，以及将 AI 规划与机器人实验室相连的平台。关键不在于智能体能否产出看似科研的内容，而在于它能够*可靠地完成*科研流程中的哪一环。

近期综述论文 [*What’s Missing in Autonomous Research?*](https://www.researchgate.net/profile/Haizhao-Yang/publication/406952713_What's_Missing_in_Autonomous_Research_A_Systematization_of_SystemsBenchmarks_and_Verification/links/6a2ecd0aab2754591109f2ba/Whats-Missing-in-Autonomous-Research-A-Systematization-of-Systems-Benchmarks-and-Verification.pdf) 提供了一个很有帮助的框架。该文梳理了截至 2026 年 6 月公开的 56 个系统，分别考察它们的反馈循环、验证关卡、工作流控制、持久化产物、领域证据和生命周期覆盖范围。这个框架提醒我们，不应把流畅的文本或完整的 PDF 直接当作系统已经自主完成科学研究的证据。

<!--more-->

## 1. 论文生成流水线

最受关注的一类系统，会把计算型研究任务变成小型的“论文工厂”。[The AI Scientist](https://github.com/SakanaAI/AI-Scientist) 会在预设模板中提出想法、修改并运行代码、分析结果、撰写论文，再请大语言模型进行审阅。**Agent Laboratory** 采用分阶段流程来完成研究和论文生成。**AI Scientist v2** 则引入树搜索，并为图表和论文稿件设置独立的批评循环。

这些系统展示了工作流的广度：它们能够把一个想法推进到计算实验，再形成接近投稿形式的成果。不过，公开证据主要来自计算机科学和机器学习场景；审阅环节往往只能建议修改，不能阻止没有充分证据支持的主张被发布。因此，更准确的说法是，它们是雄心勃勃的科研生产流水线，而不是独立的科学家。

## 2. 假设生成引擎与面向生物学的智能体

有些系统专注于科研流程的前段，也就是更具探索性的部分。Google 的 [AI co-scientist](https://research.google/blog/accelerating-scientific-breakthroughs-with-an-ai-co-scientist/) 是一个多智能体协作系统。它围绕科学家给定的目标，生成、辩论、排序并演化研究假设和研究方案。它的定位是协作伙伴：扩大并整理候选解释的空间，而不是取代科学判断。

[Robin](https://www.futurehouse.org/research/demonstrating-end-to-end-scientific-discovery-with-robin-a-multi-agent-system) 是 FutureHouse 开发的系统，在生物研究中走得更远。它连接了假设生成、实验策略、数据分析和后续洞见生成，并报告了湿实验验证。综述还特别指出了材料科学中的 **A-Lab** 和 **Qumus** 等领域系统，它们可以通过合成、表征或器件测量获得有价值的物理读数。

这一类系统很有前景，因为真实实验信号比润色后的叙述更难伪造。不过，一项测定或器件测量只能验证某个局部主张；它本身无法判定新颖性、因果解释、局限性，或整篇论文是否值得信任。

## 3. 由目标函数驱动的发现循环

另一种强大的模式，是把科研进展转化为可评估的目标。[AlphaEvolve](https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/) 使用 Gemini 模型提出并改进程序，再由自动评估器为候选方案打分，引导演化式搜索。在这种场景中，错误程序会因未通过测试而被自动淘汰。**CORAL**、**AutoSOTA** 及相关系统，将这一思路延伸到代码和机器学习优化：它们依赖隐藏评测器、代码仓库、运行日志或可执行分数。

这类项目揭示了当前自动化最擅长的领域：目标可以被外部检验的任务。验证器能够有力地确认代码是否运行、分数是否提升、约束是否满足，却无法自动判断由此得到的解释是否具有最重要的科学意义。

## 4. 证据、审计与发布关卡

最新工作越来越把科研产物，而不只是智能体本身，视为核心对象。**Kosmos** 维护与证据关联的科研世界模型；**AutoResearchClaw**、**ScientistOne**、**ARIS** 与 **NORA** 则增加了结构化记录、论文完整性检查、面向发表的工作流或部分主张关卡。**EviBound** 和 **SEVerA** 是更聚焦的验证基础设施，用于让运行过程或形式化约束更便于检查。

这一方向非常重要。科研系统需要的不只是对自身先前文本的记忆，还需要在主张、代码、数据集、图表、日志、引文和负面结果之间建立持久的联系。然而，综述最值得警惕的结论是：在所审阅的公开系统中，没有任何一个展示出能基于完整科学证据阻止整篇论文发布的验证器。可追溯性让证据更接近论文，却不会自动赋予系统判定论文可靠性的权力。

## 5. 基准测试也是生态的一部分

**MLE-Bench**、**PaperBench**、**MLR-Bench**、**SoundnessBench** 和 **SPOT** 等项目并不是自动化科学家，却是必不可少的基础设施。它们评估智能体能否复现研究、针对外部评分器进行优化、遵循类似科研的过程，或发现没有证据支持的主张与已知的论文错误。其结果说明，精美的输出并不是可靠性的充分指标：智能体可能在运行失败后伪造结果，而基于模型的审稿者也常常漏掉低可靠性方案或人为植入的错误。

## 下一步值得关注什么

这一领域正在从“智能体能否生成论文”，转向“什么证据能让智能体停下来”。近期最可信的系统应当结合范围明确的目标或实验读数、可回放的持久证据、真正具有阻断作用的独立检查，以及对人类领域专家角色的清晰记录。

这比宣称“完全自主的科学”更有用。今天的系统已经能够加速搜索、实现和分析；真正开放的挑战，是让这些能力形成一套能够为自身结论辩护的科研流程。

## 延伸阅读

- [Ren 等，*What’s Missing in Autonomous Research?*](https://www.researchgate.net/profile/Haizhao-Yang/publication/406952713_What's_Missing_in_Autonomous_Research_A_Systematization_of_SystemsBenchmarks_and_Verification/links/6a2ecd0aab2754591109f2ba/Whats-Missing-in-Autonomous-Research-A-Systematization-of-Systems-Benchmarks-and-Verification.pdf)
- [The AI Scientist 代码库](https://github.com/SakanaAI/AI-Scientist)
- [Google AI co-scientist](https://research.google/blog/accelerating-scientific-breakthroughs-with-an-ai-co-scientist/)
- [FutureHouse Robin](https://www.futurehouse.org/research/demonstrating-end-to-end-scientific-discovery-with-robin-a-multi-agent-system)
- [Google DeepMind AlphaEvolve](https://deepmind.google/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/)
