import sys, math

val = int(sys.argv[1])
val = val >> 1
floating = 0

for i in range(1,14):
    if (val & 1):
        floating += math.pow(1/2, 14 - i)
    val = val >> 1

if (val & 1):
    floating = -floating

print("Value: " + str(floating))
