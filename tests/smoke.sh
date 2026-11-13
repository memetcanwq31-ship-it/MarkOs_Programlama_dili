#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

command -v nasm >/dev/null 2>&1 || { echo "test: nasm is required" >&2; exit 1; }
command -v ld >/dev/null 2>&1 || { echo "test: ld is required" >&2; exit 1; }

cd "$ROOT"
nasm -f elf64 MCII.asm -o "$TMP/mcii.o"
ld "$TMP/mcii.o" -o "$TMP/mcii"
"$TMP/mcii" examples/hello.mku "$TMP/hello.asm"
nasm -f elf64 "$TMP/hello.asm" -o "$TMP/hello.o"
ld "$TMP/hello.o" -o "$TMP/hello"

actual=$("$TMP/hello")
expected=$(printf 'Hello from MKU\n42')
if [ "$actual" != "$expected" ]; then
    printf 'FAIL: unexpected output\nExpected:\n%s\nActual:\n%s\n' "$expected" "$actual" >&2
    exit 1
fi

echo 'PASS: MCII compiles and runs the MKU hello example'
