#!/usr/bin/env python3
"""Update formula with bottle block after building."""

import argparse
import re
import sys


def update_formula(formula_file: str, sha256: str, root_url: str) -> None:
    """Update or insert bottle block in formula file."""
    with open(formula_file, "r") as f:
        content = f.read()

    bottle_block = f"""  bottle do
    root_url "{root_url}"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "{sha256}"
  end

"""

    if "bottle do" in content:
        # Update existing bottle block - update SHA256
        content = re.sub(
            r'sha256 cellar: :any_skip_relocation, x86_64_linux: "[a-f0-9]+"',
            f'sha256 cellar: :any_skip_relocation, x86_64_linux: "{sha256}"',
            content,
        )
        # Update root_url
        content = re.sub(
            r'root_url "https://github.com/[^"]+/releases/download/[^"]+"',
            f'root_url "{root_url}"',
            content,
        )
    else:
        # Insert bottle block after license or sha256 line
        # Homebrew order: url, sha256, license, bottle, livecheck, head, depends_on
        if re.search(r"^\s*license\s", content, re.MULTILINE):
            content = re.sub(
                r"(^\s*license\s+.*$)",
                r"\1\n\n" + bottle_block.rstrip(),
                content,
                count=1,
                flags=re.MULTILINE,
            )
        elif re.search(r'^  sha256 "[a-f0-9]+"', content, re.MULTILINE):
            content = re.sub(
                r'(^  sha256 "[a-f0-9]+")',
                r"\1\n\n" + bottle_block.rstrip(),
                content,
                count=1,
                flags=re.MULTILINE,
            )

    with open(formula_file, "w") as f:
        f.write(content)

    print(f"Updated {formula_file}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Update formula with bottle block")
    parser.add_argument("--formula", required=True, help="Path to formula file")
    parser.add_argument("--sha256", required=True, help="Bottle SHA256 checksum")
    parser.add_argument("--root-url", required=True, help="Bottle root URL")

    args = parser.parse_args()

    update_formula(args.formula, args.sha256, args.root_url)
    return 0


if __name__ == "__main__":
    sys.exit(main())
