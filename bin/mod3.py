#!/usr/bin/python

import sys

x = int(sys.argv[1])
if x % 3 == 0:
    exit(1)
else:
    print(x*x)
