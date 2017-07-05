import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import csv
import sys
import seaborn as sns
from matplotlib.ticker import FuncFormatter

'''
first input is the file to plot
second input is the control data
'''

#read in data from file
filename = str(sys.argv[1])
with open(filename, 'rb') as csvfile:
	#opens csv file and makes dict reader
	reader = csv.DictReader(csvfile)
	dataList = list(reader)#list of dictionaries

steps = []
cntBifi = []
errBifi = []
cntBact = []
errBact = []
cntClos = []
errClos = []
cntDesu = []
errDesu = []
spatial = [[] for x in range(100)]
errSpat = [[] for x in range(100)]

#moving all the data to lists for plotting
#spatial data in form of outer index = row num, inner index = step
for row in dataList:
    steps.append(float(row['step']))
    cntBifi.append(float(row['avg count bifidos']))
    errBifi.append(1.96 * float(row['std count bifidos']))
    cntBact.append(float(row['avg count bacteroides']))
    errBact.append(1.96 * float(row['std count bacteroides']))
    cntClos.append(float(row['avg count closts']))
    errClos.append(1.96 * float(row['std count closts']))
    cntDesu.append(float(row['avg count desulfos']))
    errDesu.append(1.96 * float(row['std count desulfos']))
    for i in range(100):
        spatial[i].append(float(row['avg row ' + str(i)]))
        errSpat[i].append(1.96 * float(row['std row ' + str(i)]))

#plotting

#populations
popFig = plt.figure()
desuLine = plt.errorbar(steps[::10], cntDesu[::10], errDesu[::10], linestyle='-',marker='o',label='Desulfobrivio')
plt.legend(handles=[desuLine], loc='best')
plt.title('Populations Over Time')
plt.xlabel('Step (100 min)')
plt.ylabel('Number of Agents')

plt.show()
