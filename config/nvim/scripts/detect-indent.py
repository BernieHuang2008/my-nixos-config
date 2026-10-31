# auto detect file indent
# Code from: https://shaobin-jiang.github.io/blog/posts/neovim-auto-detect-indent/

import os, re, sys
from collections import Counter
from math import gcd
from functools import reduce

INDENT_RE = re.compile(r"^(?P<indent>[ \t]+)")


def _gcd_of_list(nums):
    nums = [n for n in nums if n > 0]
    if not nums:
        return 0
    return reduce(gcd, nums)


def detect_indentation(file: str, skip_prefixes=None) -> str:
    if skip_prefixes is None:
        skip_prefixes = ["#", "//", "--"]  # common comment starts (can be extended)

    with open(file, mode="r") as f:
        lines = f.readlines()

    indent_strings = []
    for ln in lines:
        s = ln.strip()
        if not s:
            continue
        if any(s.startswith(p) for p in skip_prefixes):
            continue
        m = INDENT_RE.match(ln)
        if m:
            indent_strings.append(m.group("indent"))

    if not indent_strings:
        return "unknown"

    tabs = list(filter(lambda x: x.startswith("\t"), indent_strings))
    if len(tabs) / len(indent_strings) > 0.5:
        return "tabs"

    indent = 4
    lengths = sorted({len(s) for s in indent_strings if s})
    g = _gcd_of_list(lengths)
    if g > 0:
        indent = g
    else:
        indent = Counter(len(s) for s in indent_strings).most_common(1)[0][0]

    return str(indent)


if __name__ == "__main__":
    file = sys.argv[1]
    if file and os.path.exists(file):
        print(detect_indentation(file))

