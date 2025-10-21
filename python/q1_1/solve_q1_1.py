#Abdulla Al Harun

from __future__ import annotations
import sys
import re
import base64
import json
import codecs
from pathlib import Path
from typing import List, Iterable


# ---------- helpers ----------
BASE64_CHARS = set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")
HINT_PHRASE = "The remainder of this data has been reversed."

def _candidate_blocks(text: str) -> Iterable[str]:
    """Yield all plausible Base64 blocks (whitespace removed)."""
    # 1) Code fences first (``` ... ```)
    for block in re.findall(r"```[^\n]*\n([\s\S]*?)```", text):
        filtered = re.sub(r"[^A-Za-z0-9+/=\s]", "", block)
        packed = re.sub(r"\s+", "", filtered)
        if len(packed) >= 32 and set(packed) <= BASE64_CHARS:
            yield packed
    # 2) Long base64-ish runs anywhere in the file
    for m in re.finditer(r"([A-Za-z0-9+/=\s]{40,})", text):
        candidate = re.sub(r"\s+", "", m.group(1))
        if len(candidate) >= 32 and set(candidate) <= BASE64_CHARS:
            yield candidate
    # 3) Each non-empty line (to handle “line 3” style single-line blocks)
    for ln in (ln.strip() for ln in text.splitlines() if ln.strip()):
        if len(ln) >= 32 and set(ln) <= BASE64_CHARS:
            yield ln

def find_decoded_text(md_text: str) -> str:
    decoded_candidates: list[str] = []

    for packed in _candidate_blocks(md_text):
        try:
            raw = base64.b64decode(packed, validate=True)
        except Exception:
            continue
        try:
            text = raw.decode("utf-8")  # must be valid UTF-8
        except UnicodeDecodeError:
            continue

        if HINT_PHRASE in text or text.startswith("The "):
            return text  # best match
        decoded_candidates.append(text)

    if decoded_candidates:
        return decoded_candidates[0]

    raise ValueError("Could not locate a valid UTF-8 Base64 datablock in the file.")

def prime_factors(n: int) -> List[int]:

    factors: List[int] = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


# ---------- pipeline ----------
def run(path: Path) -> None:
    if not path.exists():
        raise SystemExit(f"File not found: {path}")

    md_text = path.read_text(encoding="utf-8")

    # Step 1 — Base64 decode (robust finder)
    decoded = find_decoded_text(md_text)
    first_line, rest = decoded.split("\n", 1)

    print("STEP 1 — Base64 decode:")
    print(first_line.strip())
    print()

    # Step 2 — Reverse the remainder
    reversed_text = rest[::-1]
    print("STEP 2 — Reverse the remainder (JSON should now be readable):")
    print(reversed_text.strip())
    print()

    # Step 3 — Parse JSON & ROT13 'final_step'
    data = json.loads(reversed_text)
    author = data.get("author")
    the_answer = data.get("theAnswer")
    next_step = data.get("next_step")
    final_step_rot13 = data.get("final_step") or ""
    final_step_plain = codecs.decode(final_step_rot13, "rot_13")

    print("STEP 3 — Parsed JSON fields:")
    print(f"- author: {author}")
    print(f"- theAnswer: {the_answer}")
    print(f"- next_step: {next_step}")
    print(f"- final_step (rot13 → plain): {final_step_plain}")
    print()

    # Step 4 — Execute the decoded instruction
    if not isinstance(the_answer, int) or the_answer >= 100:
        raise ValueError("theAnswer must be an integer < 100.")
    pf = prime_factors(the_answer)

    print("STEP 4 — Result:")
    print(f"Prime factors of {the_answer}: {pf}")
    print("FINAL SOLUTION:", " × ".join(map(str, pf)))


# ---------- entry ----------
if __name__ == "__main__":
    md_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("data.md")
    run(md_path)
