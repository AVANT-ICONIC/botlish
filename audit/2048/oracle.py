#!/usr/bin/env python3
# oracle.py -- an independent 2048 reference for the long scenario of
# examples/games/2048/golden.bot (2048-ENGINE-WORKLOAD.md, "Differential
# evidence").
#
#   python3 audit/2048/oracle.py            the scenario's final state
#   python3 audit/2048/oracle.py -trace     every step
#
# Deliberately unlike the Botlish engine: a flat 16-cell board, each
# direction's lines given as explicit index lists, and an imperative
# merge with a "last tile may merge" flag. It shares nothing with the
# engine but the rules, so a scenario value both agree on is evidence the
# engine computes the rules, not only that it computes what it computed.
#
# The scenario (the golden test `2048-scenario-until-game-over` plays the
# same one through the engine's public API):
#
#   start from the empty board and spawn a Two at the first and the last
#   empty position; then repeat: try the next direction of the cycle
#   Left, Down, Right, Up; if the move changed the board, spawn at the
#   empty position (7 * k) mod E (row by row, E the number of empty
#   cells, k the number of changed moves so far, counting this one from
#   0) a Four when k mod 5 == 4, else a Two; stop when the game is over
#   or after 400 tried moves.

import sys

LINES = {
    "Left":  [[r * 4 + c for c in range(4)] for r in range(4)],
    "Right": [[r * 4 + c for c in reversed(range(4))] for r in range(4)],
    "Up":    [[r * 4 + c for r in range(4)] for c in range(4)],
    "Down":  [[r * 4 + c for r in reversed(range(4))] for c in range(4)],
}
CYCLE = ["Left", "Down", "Right", "Up"]


def move(cells, direction):
    out = list(cells)
    gained = 0
    for line in LINES[direction]:
        values = [cells[i] for i in line if cells[i] != 0]
        result = []
        can_merge = False
        for v in values:
            if can_merge and result[-1] == v:
                result[-1] = 2 * v
                gained += 2 * v
                can_merge = False
            else:
                result.append(v)
                can_merge = True
        result += [0] * (4 - len(result))
        for i, v in zip(line, result):
            out[i] = v
    return out, gained


def over(cells):
    if 0 in cells:
        return False
    for r in range(4):
        for c in range(4):
            v = cells[r * 4 + c]
            if c < 3 and cells[r * 4 + c + 1] == v:
                return False
            if r < 3 and cells[(r + 1) * 4 + c] == v:
                return False
    return True


def scenario(trace=False):
    cells = [0] * 16
    cells[0] = 2
    cells[15] = 2
    score = 0
    tried = 0
    changed = 0
    while not over(cells) and tried < 400:
        direction = CYCLE[tried % 4]
        moved, gained = move(cells, direction)
        tried += 1
        if moved != cells:
            empties = [i for i in range(16) if moved[i] == 0]
            at = empties[(7 * changed) % len(empties)]
            moved[at] = 4 if changed % 5 == 4 else 2
            changed += 1
        cells = moved
        score += gained
        if trace:
            print(tried, direction, gained, score, [cells[r * 4:r * 4 + 4] for r in range(4)])
    return {
        "rows": [cells[r * 4:r * 4 + 4] for r in range(4)],
        "score": score,
        "tried": tried,
        "changed": changed,
        "over": over(cells),
    }


if __name__ == "__main__":
    result = scenario(trace="-trace" in sys.argv)
    for key in ("rows", "score", "tried", "changed", "over"):
        print(key, result[key])
