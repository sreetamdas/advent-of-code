import sys
from z3 import Int, Optimize, sat

with open(sys.argv[1]) as f:
    data = f.read()

p2 = 0
for line in data.strip().splitlines():
    words = line.split()
    buttons = words[1:-1]
    joltage_str = words[-1]
    joltage_ns = [int(x) for x in joltage_str[1:-1].split(",")]
    NS = [[int(x) for x in b[1:-1].split(",")] for b in buttons]

    V = [Int(f"B{i}") for i in range(len(buttons))]
    EQ = []
    for i in range(len(joltage_ns)):
        terms = [V[j] for j in range(len(buttons)) if i in NS[j]]
        EQ.append(sum(terms) == joltage_ns[i])
    o = Optimize()
    o.minimize(sum(V))
    for eq in EQ:
        o.add(eq)
    for v in V:
        o.add(v >= 0)
    assert o.check() == sat
    M = o.model()
    p2 += sum(M[d].as_long() for d in M.decls())

print(p2)
