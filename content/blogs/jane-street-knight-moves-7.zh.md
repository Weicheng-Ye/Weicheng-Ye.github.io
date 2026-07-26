---
title: "Jane Street Knight Moves 7 详解"
date: 2026-07-25
draft: false
summary: "完整重构 Jane Street 2026 年 7 月谜题中的三维骑士路径、塔块位置、计分检查点与最终相邻和。"
---

Jane Street 2026 年 7 月的谜题 [“Pent-Up” Frustration 3 / Knight Moves 7](https://www.janestreet.com/puzzles/pent-up-frustration-3-knight-moves-7-index/) 把五连方铺砌、三维空间中的骑士移动，以及一套随上升、下降或保持高度而变化的计分规则结合在了一起。

本文给出完整的重构过程。以下内容包含全部剧透。

<!--more-->

<style>
  article.single-page .highlight {
    width: fit-content;
    max-width: 100%;
    margin: 1.25rem auto;
  }

  article.single-page .highlight pre {
    box-sizing: border-box;
    max-width: 100%;
    margin: 0;
    padding: 1rem 1.2rem;
    overflow-x: auto;
    color: #292b2f !important;
    background: #f8f7f3 !important;
    border: 1px solid #dedbd2;
    border-radius: 0.55rem;
    box-shadow: 0 0.3rem 1rem rgba(35, 31, 24, 0.06);
  }

  article.single-page .highlight code,
  article.single-page .highlight code span {
    color: inherit !important;
  }

  article.single-page table {
    margin: 1.4rem auto;
    border: 1px solid #8a867d;
    border-collapse: collapse;
    background: #ffffff;
  }

  article.single-page table th,
  article.single-page table td {
    padding: 0.65rem 0.8rem;
    border: 1px solid #8a867d;
    vertical-align: middle;
  }

  article.single-page table thead th {
    color: #25272b;
    background: #f1efe8;
    font-weight: 700;
  }

  article.single-page table tbody tr:nth-child(even) {
    background: #faf9f5;
  }

  article.single-page .solution-table-scroll {
    display: block;
    width: fit-content;
    max-width: 100%;
    margin: 1.4rem auto;
    overflow-x: auto;
  }

  article.single-page .solution-table-scroll table {
    min-width: max-content;
    margin: 0;
  }

  body.dark-mode article.single-page .highlight pre {
    color: #eef0f3 !important;
    background: #272a30 !important;
    border-color: #3d424a;
    box-shadow: none;
  }

  body.dark-mode article.single-page table {
    color: #eef0f3;
    background: #24272d;
    border-color: #737b87;
  }

  body.dark-mode article.single-page table th,
  body.dark-mode article.single-page table td {
    border-color: #737b87;
  }

  body.dark-mode article.single-page table thead th {
    color: #f5f6f8;
    background: #30343b;
  }

  body.dark-mode article.single-page table tbody tr:nth-child(even) {
    background: #2a2e35;
  }
</style>

## 题目

<figure>
  <a href="https://www.janestreet.com/puzzles/pent-up-frustration-3-knight-moves-7-index/">
    <img src="https://www.janestreet.com/puzzles/pent-3-knight-7.png"
         alt="Knight Moves 7 的原始 8×8 棋盘，被划分为十二个五连方区域和一个 2×2 区域，并标有若干已记录的分数。"
         loading="lazy">
  </a>
  <figcaption>原始谜题棋盘。本文以左下角为 a1。图片来源：Jane Street。</figcaption>
</figure>

上图的棋盘由 12 种五连方以及一个 2×2 四连方铺成，共分为 13 个区域。把每个区域想象成由 1×1×1 的立方体组成，并在每个区域上增加一座塔。所谓一座塔，就是在该区域的某个方格上再叠放一个单位立方体。

放好所有塔以后，把一个骑士棋子放在左下角。它不断作骑士移动，直到访问过所有塔，并且不会重复访问同一个空间位置。（一次三维骑士移动在三个维度上的位移绝对值分别为 0、1、2；移动过程中允许“穿过”塔。）

计分规则还有一个关键限制：骑士从 0 分开始。在第 N 步，如果落点与起点高度相同，分数增加 N；如果向上移动，分数乘以 N；如果向下移动，分数除以 N。只有当前分数能够被 N 整除时，向下移动才是合法的。

直到第 18 步为止，骑士每三步在落点记录一次分数。此后，它改为每 K 步记录一次，其中 K 是一个更大的数。能否利用这些信息重构骑士的完整路径？

补全所有已访问方格上缺失的分数后，找出没有被访问的方格。对每个未访问方格，把所有与它正交相邻、且属于骑士路径的方格分数相加，得到它的“相邻和”。谜题答案就是全部未访问方格相邻和的总和。

## 1. 正确理解棋盘

十二个五连方区域和一个 2×2 区域都要额外放置一个立方体，也就是一座**塔**。可以把普通方格的相对高度记为 0，把塔顶的相对高度记为 1。

棋盘上印出的数字是骑士记录的**分数**，不是塔的高度，也不是塔的位置标记。

合法的三维骑士移动要求三个坐标的位移绝对值以任意顺序取 0、1、2。因此共有三种情形：

| 移动类型 | 高度变化 | 棋盘平面位移 | 第 n 步的分数变化 |
|:---:|:---:|:---:|:---|
| `S` | 0 | (1, 2) 或 (2, 1) | 加 n |
| `U` | +1 | (0, 2) 或 (2, 0) | 乘 n |
| `D` | −1 | (0, 2) 或 (2, 0) | 除以 n，且必须整除 |

因此，普通国际象棋中马的位移只可能发生在两个高度相同的位置之间。从地面移动到塔顶，或从塔顶回到地面，在棋盘平面上的投影则是沿横向或纵向恰好移动两格。

骑士可以越过塔；是否合法只取决于起点和落点。例如，从地面上的 e4 移动到 e6 的塔顶，位移为 `(0, 2, 1)`，因此即使二维投影跨过了另一个被占据的方格，这一步仍然合法。

## 2. 最初三步被唯一确定

骑士从 a1 出发，初始分数为 0。第一个印出的检查点是第 3 步到达 g3 时的分数 1。唯一可行的运算模式为：

```text
第 1 步：S，0 + 1 = 1
第 2 步：S，1 + 2 = 3
第 3 步：D，3 ÷ 3 = 1
```

几何约束随即唯一确定路径：

```text
a1* → c2* → e3* → g3
```

星号表示塔。第三步从 e3 到 g3，位移为 `(2, 0, −1)`：e3 是塔顶，而 g3 位于地面。前两步始终保持与 e3 相同的高度，所以 a1 和 c2 也必须是塔顶。

## 3. 重构前期检查点

在第 18 步之前，骑士每三步记录一次分数。算术和几何约束只允许这些线索按以下顺序出现：

| 步数 | 运算 | 到达方格 | 分数 |
|---:|:---:|:---:|---:|
| 0 | — | a1 | 0 |
| 1–3 | `SSD` | g3 | 1 |
| 4–6 | `SSS` | e4 | 16 |
| 7–9 | `UDS` | d6 | 23 |
| 10–12 | `SSU` | a5 | 528 |
| 13–15 | `SSD` | f8 | 37 |
| 16–18 | `SSS` | d3 | 88 |

相应的分数计算为：

```text
0   --(+1, +2, ÷3)-->       1
1   --(+4, +5, +6)-->      16
16  --(×7, ÷8, +9)-->      23
23  --(+10, +11, ×12)-->  528
528 --(+13, +14, ÷15)-->   37
37  --(+16, +17, +18)-->   88
```

这些显著的上升与下降非常有用：它们确定了哪些步骤向上或向下，从而限制了哪些方格能够放塔。

## 4. 为什么后期记录间隔是 K = 7

第 18 步以后共有五个印出的检查点。骑士不能重复访问方格，因此在 8×8 棋盘上最多只能移动 63 步，所以

```text
18 + 5K ≤ 63。
```

题目说明新的间隔大于 3，因此只需检验 `K = 4, 5, 6, 7, 8, 9`。

对每个候选 K，从第 18 步的分数 88 出发，枚举所有合法的 `S`、`U`、`D` 更新，直到下一个可能的印出检查点。遇到以下任一情形就剪去该分支：

- 除法不能整除；
- 平面位移与所需的高度变化不匹配；
- 重复访问某个方格；
- 某个区域被迫没有塔或出现两座塔；
- 分数或方格与下一个印出检查点不符。

只有 `K = 7` 能通过所有约束。第一个七步区间在 f6 结束，分数为 138：

```text
88
 +19 = 107
 +20 = 127
 ×21 = 2,667
 +22 = 2,689
 +23 = 2,712
 ÷24 = 113
 +25 = 138
```

因此，后续检查点分别位于第 25、32、39、46、53 步。

## 5. 其余检查点的全部运算

接下来的运算序列也被唯一确定：

| 步数 | 运算 | 到达方格 | 分数 |
|---:|:---:|:---:|---:|
| 19–25 | `SSUSSDS` | f6 | 138 |
| 26–32 | `SSSSUDS` | f3 | 272 |
| 33–39 | `UDSSSSS` | b4 | 449 |
| 40–46 | `SSSSSSS` | b3 | 750 |
| 47–53 | `SSSSSSS` | h8 | 1,100 |
| 54 | `U` | h6 | 59,400 |

对应的分数计算如下：

```text
 88 --(+19, +20, ×21, +22, +23, ÷24, +25)--> 138
138 --(+26, +27, +28, +29, ×30, ÷31, +32)--> 272
272 --(×33, ÷34, +35, +36, +37, +38, +39)--> 449
449 --(+40, +41, +42, +43, +44, +45, +46)--> 750
750 --(+47, +48, +49, +50, +51, +52, +53)--> 1,100
```

现在很容易解释 f3 上的 272：骑士在第 32 步从地面到达 f3，因此分数从 240 变成 `240 + 32 = 272`。该 F 形区域的塔仍然位于 e3。

到第 53 步为止，骑士已经访问了十二座塔。唯一合法的收尾是从地面上的 h8 向上移动到 h6 的最后一座塔。第 54 步得到：

```text
1,100 × 54 = 59,400。
```

## 6. 唯一路径

一旦每一步都被分类为 `S`、`U` 或 `D`，直接进行回溯搜索的规模就很小。一个状态只需记录当前方格和分数、已经访问的方格，以及每个区域中选定的塔位。到达印出的检查点时，凡是方格或分数不匹配的分支都可以立即丢弃。

应用这些约束后，得到下面这条唯一的 55 方格路径：

```text
a1* → c2* → e3* → g3 → h1 → f2 → e4 → e6* → e8 → d6
→ c8 → a7 → a5* → b7* → d8* → f8 → d7 → c5 → d3 → b2
→ a4 → c4* → e5* → f7* → h7 → f6 → d5 → c3 → a2 → c1
→ e1* → g1 → f3 → h3* → h5 → g7 → f5 → e7 → c6 → b4
→ a6 → c7 → b5 → a3 → b1 → d2 → b3 → d4 → e2 → f4
→ g2 → h4 → g6 → h8 → h6*
```

计入高度以后，每一对相邻位置的三个坐标差绝对值都恰好为 0、1、2，并且没有任何棋盘方格被重复访问。

## 7. 十三座塔

按照访问顺序，十三座塔的位置如下：

| 塔序号 | 步数 | 方格 | 区域形状 | 到达分数 |
|---:|---:|:---:|:---:|---:|
| 1 | 0 | a1 | T | 0 |
| 2 | 1 | c2 | X | 1 |
| 3 | 2 | e3 | F | 3 |
| 4 | 7 | e6 | P | 112 |
| 5 | 12 | a5 | Y | 528 |
| 6 | 13 | b7 | U | 541 |
| 7 | 14 | d8 | I | 555 |
| 8 | 21 | c4 | N | 2,667 |
| 9 | 22 | e5 | 2×2 | 2,689 |
| 10 | 23 | f7 | Z | 2,712 |
| 11 | 30 | e1 | W | 7,440 |
| 12 | 33 | h3 | L | 8,976 |
| 13 | 54 | h6 | V | 59,400 |

十二个五连方区域各有且仅有一座塔，中央的 2×2 区域也恰好有一座塔。

## 8. 补全后的分数棋盘

把分数填入每个已访问方格，得到下表。星号表示塔，长破折号表示未访问的方格。

<div class="solution-table-scroll" role="region" aria-label="补全后的分数棋盘" tabindex="0">
  <table>
    <thead>
      <tr>
        <th scope="col">行</th>
        <th scope="col">a</th>
        <th scope="col">b</th>
        <th scope="col">c</th>
        <th scope="col">d</th>
        <th scope="col">e</th>
        <th scope="col">f</th>
        <th scope="col">g</th>
        <th scope="col">h</th>
      </tr>
    </thead>
    <tbody>
      <tr><th scope="row">8</th><td>—</td><td>—</td><td>33</td><td>555*</td><td>14</td><td>37</td><td>—</td><td>1,100</td></tr>
      <tr><th scope="row">7</th><td>44</td><td>541*</td><td>530</td><td>53</td><td>372</td><td>2,712*</td><td>299</td><td>113</td></tr>
      <tr><th scope="row">6</th><td>489</td><td>—</td><td>410</td><td>23</td><td>112*</td><td>138</td><td>1,047</td><td>59,400*</td></tr>
      <tr><th scope="row">5</th><td>528*</td><td>572</td><td>70</td><td>164</td><td>2,689*</td><td>335</td><td>—</td><td>264</td></tr>
      <tr><th scope="row">4</th><td>127</td><td>449</td><td>2,667*</td><td>797</td><td>16</td><td>894</td><td>—</td><td>995</td></tr>
      <tr><th scope="row">3</th><td>615</td><td>750</td><td>191</td><td>88</td><td>3*</td><td>272</td><td>1</td><td>8,976*</td></tr>
      <tr><th scope="row">2</th><td>219</td><td>107</td><td>1*</td><td>704</td><td>845</td><td>10</td><td>944</td><td>—</td></tr>
      <tr><th scope="row">1</th><td>0*</td><td>659</td><td>248</td><td>—</td><td>7,440*</td><td>—</td><td>240</td><td>5</td></tr>
    </tbody>
  </table>
</div>

## 9. 九个未访问方格

对每个未访问方格，把与它正交相邻且位于骑士路径上的方格分数相加。

| 未访问方格 | 相邻路径分数 | 相邻和 |
|:---:|:---|---:|
| a8 | 44 | 44 |
| b8 | 33 + 541 | 574 |
| g8 | 37 + 1,100 + 299 | 1,436 |
| b6 | 489 + 410 + 541 + 572 | 2,012 |
| g5 | 335 + 264 + 1,047 | 1,646 |
| g4 | 894 + 995 + 1 | 1,890 |
| h2 | 944 + 8,976 + 5 | 9,925 |
| d1 | 248 + 7,440 + 704 | 8,392 |
| f1 | 7,440 + 240 + 10 | 7,690 |

最后，

```text
44 + 574 + 1,436 + 2,012 + 1,646 + 1,890 + 9,925 + 8,392 + 7,690 = 33,609。
```

因此，唯一解的记录间隔为 **K = 7**。第十三座、也是最后一座塔位于 **h6**，到达时分数为 **59,400**；谜题所求答案为

<p style="text-align:center;font-size:1.35em"><strong>33,609</strong>。</p>
