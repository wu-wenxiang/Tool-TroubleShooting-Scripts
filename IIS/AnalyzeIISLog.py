aFile = r"C:\Users\wenw\Desktop\IIS-log\u_ex170606.log"

from collections import Counter

aList = [line.split() for line in open(aFile) if line.startswith(r'2017-')]
bList = [line[1] for line in aList]
bCounter = Counter(bList)
cList = [r':'.join(line.split(r':')[:2]) for line in bList]
cCounter = Counter(cList)


#secStat = open(r'C:\Users\wenw\Desktop\IIS-log\170606-sec.csv', 'w')
#for k in sorted(bCounter):
#    secStat.write('%s, %s' % (k, bCounter[k]) + '\n')

#secStat = open(r'C:\Users\wenw\Desktop\IIS-log\170606-min.csv', 'w')
#for k in sorted(cCounter):
#    secStat.write('%s, %s' % (k, cCounter[k]) + '\n')

dList = [line[1] for line in aList if int(line[-1]) > 10000]
dList = [r':'.join(line.split(r':')[:2]) for line in dList]
dCounter = Counter(dList)
secStat = open(r'C:\Users\wenw\Desktop\IIS-log\170606-10Sec.csv', 'w')
for k in sorted(dCounter):
    secStat.write('%s, %s' % (k, dCounter[k]) + '\n')

dList = [line[1] for line in aList if int(line[-1]) > 30000]
dList = [r':'.join(line.split(r':')[:2]) for line in dList]
dCounter = Counter(dList)
secStat = open(r'C:\Users\wenw\Desktop\IIS-log\170606-30Sec.csv', 'w')
for k in sorted(dCounter):
    secStat.write('%s, %s' % (k, dCounter[k]) + '\n')


    
