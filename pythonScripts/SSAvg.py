import csv
import numpy
import sys

def mean(lst):
# calculates the mean of a list
	return numpy.mean(numpy.array(lst))

def stddev(lst):
# calculates stddev of a list
	return numpy.std(numpy.array(lst))
	
filename = str(sys.argv[1])
outName1 = str(sys.argv[2])
outName2 = str(sys.argv[3])
with open(filename, 'rb') as csvfile:
	#opens csv file and makes dict reader
	reader = csv.DictReader(csvfile)
	dataList = list(reader)#list of dictionaries

#split up the spatial data
for row in dataList:
    data = row['getAllBactPatchLin']
    #remove first and last character
    data = data[1:-1]
    splitData = data.split()
    for i in range(len(splitData)):
        row['row ' + str(i)] = splitData[i]

#list of entries to avg and format
entryList = sorted(dataList[0].keys())
entryList.remove('[run number]')
entryList.remove('[step]')
entryList.remove('initNumBacteroides')
entryList.remove('initNumBifidos')
entryList.remove('initNumClosts')
entryList.remove('initNumDesulfos')
entryList.remove('getAllBactPatchLin')

testSet = set()
stepSet = set()
for row in dataList:
	#check number of testConstants
	testSet.add(float(row['testConst']))
	stepSet.add(float(row['[step]']))
	
testList = list()
# create the list-tree data structure
for i in range(len(testSet)):
	testList.append(list())
	for j in range(len(stepSet)):
		testList[i].append(list())
		for k in range(len(entryList)):
			testList[i][j].append(list())

# make the sets into sorted lists
testSorted = sorted(testSet)
stepSorted = sorted(stepSet)

for data in dataList:
# put the data into the dataList
	i = testSorted.index(float(data['testConst']))
	j = stepSorted.index(float(data['[step]']))
	for k in range(len(entryList)):
		testList[i][j][k].append(float(data[entryList[k]]))

keyList = ['bact1', 'bact2', 'bact3', 'bifi1', 'bifi2', 'bifi3', 'clos1', 'clos2', 'clos3', 'desu1', 'desu2','desu3']

x = 0 # for testConst
for name in [outName1, outName2]:
    with open(name, 'w+') as file:
        # get the mean, stddev, median, and write to a csv file
        rowData = list()
        datawriter = csv.writer(file, delimiter=',',quotechar='|',quoting=csv.QUOTE_MINIMAL)
        rowData.append('testConst')
        for key in keyList:
            rowData.append('avg ' + key)
            rowData.append('std ' + key)
        datawriter.writerow(rowData) #first row

        rowData = list()

        rowData.append(testSorted[x])

        SSranges = [range(75, 100), range(175, 200), range(275, 300)]
        SSLists = [[] for item in range(4)] #holds 4 species, each of species lists holds data range
        SSData = list()
        for z in range(4):
            for myRange in SSranges:
                for y in myRange: #iterate over the ranges
                    SSData.append(testList[x][y][z])
                SSLists[z].append(SSData)
                SSData = list()

        SSFlatLists = [[] for item in range(4)]
        for i in range(len(SSLists)):
            for other in SSLists[i]:
                flatSS = [item for sublist in other for item in sublist] #flatten the list of lists
                SSFlatLists[i].append(flatSS)

        for species in SSFlatLists:
            for data in species:
                rowData.append(mean(data))
                rowData.append(stddev(data))
        
        datawriter.writerow(rowData)

        x += 1

