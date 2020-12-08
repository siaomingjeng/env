#!/usr/bin/env python3

import difflib
import sys

if len(sys.argv)<3:
    print(sys.argv)
    print("Not enough parameters: firstFile  secondFile and an optional number")
    sys.exit(1)
else:
    fa=sys.argv[1]
    fb=sys.argv[2]
    fn=0

if len(sys.argv)>3:
    fn=int(sys.argv[3])

with open(fa) as f1:
    text1 = f1.readlines()
with open(fb) as f2:
    text2 = f2.readlines()

for line in difflib.unified_diff(text1, text2, n=fn):
    print(line)
