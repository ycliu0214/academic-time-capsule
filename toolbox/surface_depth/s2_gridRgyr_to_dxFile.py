#!/usr/bin/env python

import os
import numpy as np

fileList = os.listdir('rgyrFiles')

gridSize = 1

data = dict()
x_list = list()
y_list = list()
z_list = list()

for i in fileList:
    with open('rgyrFiles/'+i, 'r') as f:
        for line in f:
            word = line.split()
            coord = word[0].split('_')
            x_list.append(int(coord[0]))
            y_list.append(int(coord[1]))
            z_list.append(int(coord[2]))
            try:
                data[word[0]].append(float(word[1]))
            except KeyError:
                data[word[0]] = [float(word[1])]

for key in data.keys():
    data[key] = sum(data[key]) / len(data[key])


minCoord = min(min(x_list), min(y_list), min(z_list))
maxCoord = max(max(x_list), max(y_list), max(z_list))
boxLength = maxCoord - minCoord + 1


matrix = np.zeros([boxLength+4, boxLength+4, boxLength+4])
for key in data.keys():
    coord = key.split('_')
    coord = list(map(int, coord))
    matrix[coord[0] - minCoord + 2, coord[1] - minCoord + 2, coord[2] - minCoord + 2] = data[key]


#weightArray = np.array([0.17, 0.2155, 0.229, 0.2155, 0.17])
weightArray = np.array([0.4, 0.6, 0.0, 0.6, 0.4])
smoothMatrix = np.zeros([5,5,5])
for x in range(0,5):
    for y in range(0,5):
        for z in range(0,5):
            smoothMatrix[x,y,z] = weightArray[x] * weightArray[y] * weightArray[z]

newMatrix = np.zeros([boxLength+4, boxLength+4, boxLength+4])

for x in range(2,boxLength+2):
    for y in range(2,boxLength+2):
        for z in range(2,boxLength+2):
            newMatrix[x,y,z] = np.sum(np.multiply(matrix[x-2:x+3, y-2:y+3, z-2:z+3], smoothMatrix))


matrix = matrix.flatten()
newMatrix = newMatrix.flatten()


print('object 1 class gridpositions counts', boxLength+4, boxLength+4, boxLength+4)
print('origin {:0.6e} {:0.6e} {:0.6e}'.format((minCoord - 2) * gridSize, (minCoord - 2) * gridSize, (minCoord - 2) * gridSize))
print('delta {:0.6e} {:0.6e} {:0.6e}'.format(gridSize, 0, 0))
print('delta {:0.6e} {:0.6e} {:0.6e}'.format(0, gridSize, 0))
print('delta {:0.6e} {:0.6e} {:0.6e}'.format(0, 0, gridSize))
print('object 2 class gridconnections counts', boxLength+4, boxLength+4, boxLength+4)
print('object 3 class array type double rank 0 items', (boxLength+4)**3, 'data for follows')

for i in range(0,len(newMatrix),3):
    try:
        print('{:0.6e}'.format(newMatrix[i]),end=' ')
        print('{:0.6e}'.format(newMatrix[i+1]),end=' ')
        print('{:0.6e}'.format(newMatrix[i+2]))
    except IndexError:
        print('')

print('attribute "dep" string "positions"')
print('object "regular positions regular connections" class field')
print('component "positions" value 1')
print('component "connections" value 2')
print('component "data" value 3')

'''
with open('bbb.dx', 'w') as f:
    for i in range(0, len(matrix)):
        print('{:0.6e}'.format(matrix[i]), file=f)
'''
