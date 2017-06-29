DATE = '170629'
LOG_DIR = r'C:\Users\wenw\Desktop\117041115583204-Opera-IIS-Hang\20170629\IISlog'
STAT_DIR = r'C:\Users\wenw\Desktop\117041115583204-Opera-IIS-Hang\20170629\IISlog'

import os

aFile = os.path.join(LOG_DIR, r'u_ex%s.log' % DATE)

from collections import Counter

aList = [line for line in open(aFile) if line.startswith(r'20')]

'''
import re
reCmp = re.compile(r'^\S+\s+1[2-3]:')
aList = [i for i in aList if reCmp.search(i)]
'''
aList = [line.split() for line in aList]


bList = [line[1] for line in aList]
bCounter = Counter(bList)
cList = [r':'.join(line.split(r':')[:2]) for line in bList]
cCounter = Counter(cList)

secStat = open(os.path.join(STAT_DIR, r'%s-sec.csv' % DATE), 'w')
for i in range(24):
    for j in range(60):
        for k in range(60):
            bCounter.setdefault('%02d:%02d:%02d' % (i,j,k), 0)
for k in sorted(bCounter):
    secStat.write('%s, %s' % (k, bCounter[k]) + '\n')

secStat = open(os.path.join(STAT_DIR, r'%s-min.csv' % DATE), 'w')
for i in range(24):
    for j in range(60):
        cCounter.setdefault('%02d:%02d' % (i,j), 0)
for k in sorted(cCounter):
    secStat.write('%s, %s' % (k, cCounter[k]) + '\n')

dList = [line[1] for line in aList if int(line[-1]) > 10000]
dList = [r':'.join(line.split(r':')[:2]) for line in dList]
dCounter = Counter(dList)
for i in range(24):
    for j in range(60):
        dCounter.setdefault('%02d:%02d' % (i,j), 0)
secStat = open(os.path.join(STAT_DIR, r'%s-10sec.csv' % DATE), 'w')
for k in sorted(dCounter):
    secStat.write('%s, %s' % (k, dCounter[k]) + '\n')

dList = [line[1] for line in aList if int(line[-1]) > 30000]
dList = [r':'.join(line.split(r':')[:2]) for line in dList]
dCounter = Counter(dList)
for i in range(24):
    for j in range(60):
        dCounter.setdefault('%02d:%02d' % (i,j), 0)
secStat = open(os.path.join(STAT_DIR, r'%s-30sec.csv' % DATE), 'w')
for k in sorted(dCounter):
    secStat.write('%s, %s' % (k, dCounter[k]) + '\n')

aDict = {}
for line in aList:
    aDict.setdefault(line[8], [])
    aDict[line[8]].append(int(line[-1]))

bDict = {}
for k,v in aDict.items():
    reqNum = len(v)
    req30Num = len([i for i in v if i>30000])
    req30Rate = float(req30Num)/reqNum
    req10Num = len([i for i in v if i>10000])
    req10Rate = float(req10Num)/reqNum
    avg = sum(v) / len(v)
    bDict[k] = [reqNum, avg, req30Num, req30Rate, req10Num, req10Rate]

secStat = open(os.path.join(STAT_DIR, r'%s-IP-stat.csv' % DATE), 'w')
secStat.write('IP, Requests, Average, 30+sec, 30+Percent, 10+Sec, 10+Percent\n')
for k in sorted(bDict): #, key=(lamba x:bDict[x][0]), reverse=True):
    v = ['%s' % i for i in bDict[k]]
    v = ', '.join(v)
    secStat.write('%s, %s' % (k, v) + '\n')

aDict = {}
for line in aList:
    k = ' '.join(line[3:5])
    aDict.setdefault(k, [])
    aDict[k].append(int(line[-1]))

bDict = {}
for k,v in aDict.items():
    reqNum = len(v)
    req30Num = len([i for i in v if i>30000])
    req30Rate = float(req30Num)/reqNum
    req10Num = len([i for i in v if i>10000])
    req10Rate = float(req10Num)/reqNum
    avg = sum(v) / len(v)
    bDict[k] = [reqNum, avg, req30Num, req30Rate, req10Num, req10Rate]

secStat = open(os.path.join(STAT_DIR, r'%s-URL-stat.csv' % DATE), 'w')
secStat.write('URL, Requests, Average, 30+sec, 30+Percent, 10+Sec, 10+Percent\n')
for k in sorted(bDict): #, key=(lamba x:bDict[x][0]), reverse=True):
    v = ['%s' % i for i in bDict[k]]
    v = ', '.join(v)
    secStat.write('%s, %s' % (k, v) + '\n')



    
