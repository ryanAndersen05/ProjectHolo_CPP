

state = 1
print ("{", end=" ")
for _ in range(5000):
    print ((state & 0xffff), end=", ")
    state = (134775813 * state + 1) % (1 << 32)
print ("}")