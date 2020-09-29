#!/usr/bin/env python3

import sys

with open(sys.argv[1], 'r') as rin:
    x = int(rin.readline().strip())
    if x % 3 == 0:
        exit(1)
    else:
        res = (x*x)

    with open(f'flaky.{x}.dat', 'w') as rout:
        rout.write(f'{res}\n')
