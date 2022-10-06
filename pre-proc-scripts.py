#!/usr/bin/env python3

"""
turn scripts into .as scripts
"""

from pathlib import Path
import pathlib

script_folder = Path("ml-scripts")
output_folder = Path("src/scripts")


def script_to_as_files(sf: Path):
    script_as_name = sf.stem + ".as"
    constant_name = sf.name.replace(".", "_").upper()
    lines = [f'const string {constant_name} = """']
    lines.extend(sf.read_text().splitlines())
    lines.append(f'""";')
    output_file = output_folder / script_as_name
    output_file.write_text("\n".join(lines))
    print(f"Processed: {sf} -- output: {output_file}")


def main():
    for script_file in script_folder.iterdir():
        if script_file.name.lower().endswith(".script.txt"):
            script_to_as_files(script_file)
        else:
            print(
                f"Warning, file in {script_folder} does not end with .Script.txt: {script_file}; suffixes: {script_file.suffixes}"
            )


if __name__ == "__main__":
    main()
