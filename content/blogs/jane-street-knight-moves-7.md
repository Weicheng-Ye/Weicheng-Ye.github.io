---
title: "Solving Jane Street's Knight Moves 7"
date: 2026-07-25
draft: false
summary: "A complete reconstruction of the 3D knight path, tower placement, score checkpoints, and final neighbor-sum calculation for Jane Street's July 2026 puzzle."
---

Jane Street's July 2026 puzzle, [“Pent-Up” Frustration 3 / Knight Moves 7](https://www.janestreet.com/puzzles/pent-up-frustration-3-knight-moves-7-index/), combines a pentomino tiling, a knight moving in three dimensions, and a score whose update rule depends on whether the knight moves up, down, or stays level.

The unique solution has checkpoint interval **K = 7**. The thirteenth and final tower is at **h6**, where the score becomes **59,400**, and the answer requested by the puzzle is

<p style="text-align:center;font-size:1.35em"><strong>33,609</strong>.</p>

This post gives the full reconstruction. Everything below is a spoiler.

<!--more-->

<figure>
  <a href="https://www.janestreet.com/puzzles/pent-up-frustration-3-knight-moves-7-index/">
    <img src="https://www.janestreet.com/puzzles/pent-3-knight-7.png"
         alt="The original eight-by-eight Knight Moves 7 puzzle board, divided into twelve pentomino regions and one two-by-two region, with several recorded scores."
         loading="lazy">
  </a>
  <figcaption>The original puzzle board. Coordinates in this solution use a1 for the bottom-left square. Image source: Jane Street.</figcaption>
</figure>

## 1. Reading the board correctly

Each of the twelve pentominoes and the single 2-by-2 region receives one extra cube, or **tower**. It is useful to assign altitude 0 to an ordinary square and altitude 1 to the top of a tower.

The printed numbers are recorded **scores**. They are not tower heights or tower markers.

A legal three-dimensional knight move changes the absolute values of the three coordinates by 0, 1, and 2 in some order. That gives three cases:

| Move type | Altitude change | Displacement on the board | Score update on move n |
|:---:|:---:|:---:|:---|
| `S` | 0 | (1, 2) or (2, 1) | add n |
| `U` | +1 | (0, 2) or (2, 0) | multiply by n |
| `D` | −1 | (0, 2) or (2, 0) | divide by n, exactly |

Thus an ordinary chess-knight displacement is possible only between two locations at the same altitude. Moving between ground and a tower top instead looks like a two-square orthogonal move when projected onto the board.

The knight may pass over a tower. Only the starting and landing coordinates matter. For example, moving from ground-level e4 to a tower at e6 has displacement `(0, 2, 1)`, so it is legal even if the jump's projection crosses another occupied square.

## 2. The first three moves are forced

The knight starts at a1 with score 0, and the first printed checkpoint is the score 1 at g3 after move 3. The only valid operation pattern is

```text
move 1: S,  0 + 1 = 1
move 2: S,  1 + 2 = 3
move 3: D,  3 ÷ 3 = 1
```

The geometry then forces

```text
a1* → c2* → e3* → g3
```

where an asterisk marks a tower. The third move goes from e3 to g3 with displacement `(2, 0, −1)`: e3 is a tower top and g3 is at ground level. Since the first two moves stay at the same altitude, a1 and c2 must also be tower tops.

This resolves a potentially confusing feature of the diagram. The `1` printed at g3 is its recorded score, not its altitude. Likewise, f3 and e3 lie in the same F-shaped region, but only e3 is its tower; the printed `272` at f3 is another score checkpoint.

## 3. Reconstructing the early checkpoints

Before move 18, the knight records its score every three moves. The arithmetic and geometry leave only one chronological order for those clues:

| Moves | Operations | Arrival | Score |
|---:|:---:|:---:|---:|
| 0 | — | a1 | 0 |
| 1–3 | `SSD` | g3 | 1 |
| 4–6 | `SSS` | e4 | 16 |
| 7–9 | `UDS` | d6 | 23 |
| 10–12 | `SSU` | a5 | 528 |
| 13–15 | `SSD` | f8 | 37 |
| 16–18 | `SSS` | d3 | 88 |

Written as score calculations:

```text
0   --(+1, +2, ÷3)-->       1
1   --(+4, +5, +6)-->      16
16  --(×7, ÷8, +9)-->      23
23  --(+10, +11, ×12)-->  528
528 --(+13, +14, ÷15)-->   37
37  --(+16, +17, +18)-->   88
```

The large rises and falls are informative: they identify the upward and downward moves, which in turn constrain which squares can contain towers.

## 4. Why the later interval is K = 7

There are five printed checkpoints after move 18. A path on the 8-by-8 board can make at most 63 moves without revisiting a square, so

```text
18 + 5K ≤ 63.
```

Because the problem says the new interval is larger than 3, only `K = 4, 5, 6, 7, 8, 9` need to be checked.

For each candidate K, take the score 88 at move 18 and enumerate legal `S`, `U`, and `D` updates until the next possible printed checkpoint. A branch is rejected when:

- a division is not exact;
- the required planar displacement does not match its altitude change;
- a square would be revisited;
- a region would need zero or two towers; or
- the score and square disagree with the next printed checkpoint.

Only `K = 7` survives. Its first seven-move block reaches f6 with score 138:

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

Therefore the later checkpoints occur at moves 25, 32, 39, 46, and 53.

## 5. All remaining checkpoint arithmetic

The rest of the operation sequence is then forced:

| Moves | Operations | Arrival | Score |
|---:|:---:|:---:|---:|
| 19–25 | `SSUSSDS` | f6 | 138 |
| 26–32 | `SSSSUDS` | f3 | 272 |
| 33–39 | `UDSSSSS` | b4 | 449 |
| 40–46 | `SSSSSSS` | b3 | 750 |
| 47–53 | `SSSSSSS` | h8 | 1,100 |
| 54 | `U` | h6 | 59,400 |

The score calculations are:

```text
 88 --(+19, +20, ×21, +22, +23, ÷24, +25)--> 138
138 --(+26, +27, +28, +29, ×30, ÷31, +32)--> 272
272 --(×33, ÷34, +35, +36, +37, +38, +39)--> 449
449 --(+40, +41, +42, +43, +44, +45, +46)--> 750
750 --(+47, +48, +49, +50, +51, +52, +53)--> 1,100
```

The value at f3 is now easy to interpret: it is reached on move 32 at ground level, so the score changes from 240 to `240 + 32 = 272`. The tower in that F-shaped region remains at e3.

By move 53, the knight has visited twelve towers. The only legal completion is the upward move from ground-level h8 to the last tower at h6. On move 54,

```text
1,100 × 54 = 59,400.
```

## 6. The unique route

Once every move has been classified as `S`, `U`, or `D`, a direct backtracking search is small. A state needs only the current square and score, the visited squares, and the chosen tower square in each region. At a printed checkpoint, all branches except the matching square and score can be discarded.

Applying those constraints gives the following unique 55-square route:

```text
a1* → c2* → e3* → g3 → h1 → f2 → e4 → e6* → e8 → d6
→ c8 → a7 → a5* → b7* → d8* → f8 → d7 → c5 → d3 → b2
→ a4 → c4* → e5* → f7* → h7 → f6 → d5 → c3 → a2 → c1
→ e1* → g1 → f3 → h3* → h5 → g7 → f5 → e7 → c6 → b4
→ a6 → c7 → b5 → a3 → b1 → d2 → b3 → d4 → e2 → f4
→ g2 → h4 → g6 → h8 → h6*
```

Every consecutive pair has coordinate differences 0, 1, and 2 after altitude is included, and no board square appears twice.

## 7. The thirteen towers

The tower positions, listed in visitation order, are:

| Tower | Move | Square | Region shape | Arrival score |
|---:|---:|:---:|:---:|---:|
| 1 | 0 | a1 | T | 0 |
| 2 | 1 | c2 | X | 1 |
| 3 | 2 | e3 | F | 3 |
| 4 | 7 | e6 | P | 112 |
| 5 | 12 | a5 | Y | 528 |
| 6 | 13 | b7 | U | 541 |
| 7 | 14 | d8 | I | 555 |
| 8 | 21 | c4 | N | 2,667 |
| 9 | 22 | e5 | 2-by-2 | 2,689 |
| 10 | 23 | f7 | Z | 2,712 |
| 11 | 30 | e1 | W | 7,440 |
| 12 | 33 | h3 | L | 8,976 |
| 13 | 54 | h6 | V | 59,400 |

There is exactly one tower in each of the twelve pentomino regions and one in the central 2-by-2 region.

## 8. The completed score grid

Filling each visited square with its score gives the following board. An asterisk marks a tower, and an em dash marks an unvisited square.

<div style="display:block;max-width:100%;overflow-x:auto" role="region" aria-label="Completed score grid" tabindex="0">
  <table>
    <thead>
      <tr>
        <th scope="col">Rank</th>
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

## 9. The nine unvisited squares

For each unvisited square, the puzzle asks for the sum of the scores in its orthogonally adjacent visited squares.

| Unvisited square | Adjacent path scores | Neighbor sum |
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

Finally,

```text
44 + 574 + 1,436 + 2,012 + 1,646 + 1,890
   + 9,925 + 8,392 + 7,690
= 33,609.
```

So the answer to Jane Street's Knight Moves 7 is

<p style="text-align:center;font-size:1.35em"><strong>33,609</strong>.</p>
