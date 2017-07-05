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
contName = str(sys.argv[2])
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

#now read in the control data
with open(contName, 'rb') as contfile:
    reader = csv.DictReader(contfile)
    contList = list(reader)

cntBifiC = []
errBifiC = []
cntBactC = []
errBactC = []
cntClosC = []
errClosC = []
cntDesuC = []
errDesuC = []

for row in contList:
    cntBifiC.append(float(row['avg count bifidos']))
    errBifiC.append(1.96 * float(row['std count bifidos']))
    cntBactC.append(float(row['avg count bacteroides']))
    errBactC.append(1.96 * float(row['std count bacteroides']))
    cntClosC.append(float(row['avg count closts']))
    errClosC.append(1.96 * float(row['std count closts']))
    cntDesuC.append(float(row['avg count desulfos']))
    errDesuC.append(1.96 * float(row['std count desulfos']))

#get percent difference
expData = [cntBifi, cntBact, cntClos, cntDesu]
contData = [cntBifiC, cntBactC, cntClosC, cntDesuC]
perData = [[] for x in range(4)]#[bifi, bact, clos, desu]
for i in range(len(expData)):
    myList = [];
    for j in range(len(expData[i])):
        myList.append((expData[i][j] - contData[i][j]) / contData[i][j])
    perData[i] = myList

#error propagation
expErrData = [errBifi, errBact, errClos, errDesu]
contErrData = [errBifiC, errBactC, errClosC, errDesuC]
perError = [[] for x in range(4)]
for i in range(len(perData)):
    otherList = []
    for j in range(len(perData[i])):
        R = perData[i][j]
        X = expData[i][j]
        Y = contData[i][j]
        dX = expErrData[i][j]
        dY = contErrData[i][j]
        subtr = X - Y
        subtrErr = np.sqrt( (dX)**2 + (dY)**2 )
        otherList.append(R * np.sqrt((subtrErr/subtr)**2 + (dY/Y)**2))
    perError[i] = otherList

#percent of total population
'''
get the totals into a list
then fill in the popData
'''
popData = []
for i in range(len(expData[0])):
    runningSum = 0
    for j in range(len(expData)):
        runningSum += expData[j][i]
    popData.append(runningSum)

expPopData = [[] for x in range(4)]
for i in range(len(expData)):
    myList = []
    for j in range(len(expData[i])):
        myList.append((expData[i][j] / popData[j]))
    expPopData[i] = myList

#plotting

#populations
popFig = plt.figure()
bifiLine = plt.errorbar(steps[::10], cntBifi[::10], errBifi[::10], linestyle='-',marker='o',label='Bifidobacterium')
bactLine = plt.errorbar(steps[::10], cntBact[::10], errBact[::10], linestyle='-',marker='o',label='Bacteroides')
closLine = plt.errorbar(steps[::10], cntClos[::10], errClos[::10], linestyle='-',marker='o',label='Clostridium')
desuLine = plt.errorbar(steps[::10], cntDesu[::10], errDesu[::10], linestyle='-',marker='o',label='Desulfobrivio')
plt.legend(handles=[bifiLine, bactLine, closLine, desuLine], loc='best')
plt.title('Populations Over Time')
plt.xlabel('Step (100 min)')
plt.ylabel('Number of Agents')
plt.savefig('bifi2APop.eps',format='eps', dpi=1000)

#percent difference from control
diffFig = plt.figure()
ax1 = diffFig.add_subplot(1,1,1)
bifiLine = ax1.errorbar(steps[::10], perData[0][::10], perError[0][::10], linestyle='-', marker='o',label='Bifidobacterium')
bactLine = ax1.errorbar(steps[::10], perData[1][::10], perError[1][::10], linestyle='-', marker='o',label='Bacteroides')
closLine = ax1.errorbar(steps[::10], perData[2][::10], perError[2][::10], linestyle='-', marker='o',label='Clostridium')
desuLine = ax1.errorbar(steps[::10], perData[3][::10], perError[3][::10], linestyle='-', marker='o',label='Deslfobrivio')
ax1.legend(handles=[bifiLine, bactLine, closLine, desuLine], loc='best')
ax1.set_title('Percent Difference')
ax1.set_xlabel('Step (100 min)')
ax1.set_ylabel('Percent Difference from Control')
ax1.yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.0%}'.format(y))) 
plt.savefig('bifi2ADiff.eps',format='eps', dpi=1000)

#percentage of total population
totFig = plt.figure()
ax2 = totFig.add_subplot(1,1,1)
#comma makes it so it only stores first entry of ax2.plot() return
bifiLine, = ax2.plot(steps[::10], expPopData[0][::10], linestyle='-', marker='o',label='Bifidobacterium')
bactLine, = ax2.plot(steps[::10], expPopData[1][::10], linestyle='-', marker='o',label='Bacteroides')
closLine, = ax2.plot(steps[::10], expPopData[2][::10], linestyle='-', marker='o',label='Clostridium')
desuLine, = ax2.plot(steps[::10], expPopData[3][::10], linestyle='-', marker='o',label='Deslfobrivio')
ax2.legend(handles=[bifiLine, bactLine, closLine, desuLine], loc='best')
ax2.set_title('Percentage of Total Population')
ax2.set_xlabel('Step (100 min)')
ax2.set_ylabel('Percent of Total')
ax2.yaxis.set_major_formatter(FuncFormatter(lambda y, _: '{:.0%}'.format(y))) 
plt.savefig('bifi2ATot.eps',format='eps', dpi=1000)

#surface spatial plot
fig = plt.figure()
ax = fig.gca(projection='3d')
X = np.arange(304)
Y = np.arange(100)
X, Y = np.meshgrid(X,Y)
Z = np.array(spatial)
surf = ax.plot_surface(X,Y,Z,cmap=cm.coolwarm, linewidth=0)
ax.invert_yaxis()
ax.legend()
ax.set_title('Spatial Data')
ax.set_xlabel('Step Number')
ax.set_ylabel('Row Number')
ax.set_zlabel('Total Number of Agents')
ax.view_init(elev=13, azim = -130)
plt.savefig('bifi2ASpatial.eps',format='eps', dpi=1000)
