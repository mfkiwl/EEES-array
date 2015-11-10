from itertools import count, product, islice
from string import ascii_uppercase
from random import randrange, seed

def multiletters(seq):
    for n in count(1):
        for s in product(seq, repeat=n):
            yield ''.join(s)

#generate datasection out of python matrix (row major, nPE columns per row)
#CP data is specified as array (list)
def genDataSection(matrix, cp_dmem=[0], dataWidth=32):
        sec=".data\n"
        sec+=".type\t\tA,@object\n"
        for entry in cp_dmem:
            sec+= ".long\t\t%d\n"%(entry)
        sec+= ".size\t\tA,%d\n"%(len(cp_dmem)*dataWidth/8)
        sec+= "\n"

        sec+=".vdata\n"
        names=multiletters(ascii_uppercase)
        numberOfPEs=len(matrix[0])
        for i in range(len(matrix)):
                name=next(names)
                sec+=".type\t\t%s,@object\n"%(name)
                sec+= ".address\t%d\n"%(i*((dataWidth/8)*numberOfPEs))
                for j in range(numberOfPEs):
                        sec+= ".long\t\t%d\n"%(matrix[i][j])
                sec+= ".size\t\t%s,%d\n"%(name,(dataWidth/8)*numberOfPEs)
        sec+= "\n"
        return sec

def genRandomDataSection(nRows, nCols, maxValue=pow(2,16)-1):
	seed(1337)
	return genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])