#!/usr/bin/env python

# Check that no system packages are found in the environment.
import sys
assert all('/usr' not in p for p in sys.path), sys.path
print(sys.path)
