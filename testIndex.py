testArray = []
outputArray = []
for i in range(0, 25):
    testArray.append(i)
    outputArray.append(0)

for x in range(0,5):
    for y in range(0,5):
        outputArray[x+y*5] = testArray[(x*5)+(4-y)]

print(outputArray)