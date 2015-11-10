#!/usr/bin/python
#
# Python implementation of FFoS, 
# useful as reference or for debugging 
#

from template_helper import *
from math import floor, ceil
from imageToData import *

def histogram(matrix, h):
  hist=[0]*256
  for vect in matrix[0:h-1]:
    for e in vect:
      hist[e]+=1
  return hist

def CH(hist):
  return [ sum(hist[0:idx+1]) for idx in range(len(hist))]

def CIA(hist):
  return CH([ h*idx for idx, h in enumerate(hist)])

def printHex(l):
  for idx, e in enumerate(l):
    print "%d: 0x%08x"%(idx, e)

def sigma(matrix, w, h):
  hist = histogram(matrix, h)
  ch=CH(hist)
  cia=CIA(hist)

  s=h*w
  sigmas=[]
  for i in range(len(ch)):
    if ((s-ch[i])!=0) and (ch[i]!=0):
      t1=int((cia[i]<<11)/ch[i])
      t1=int((t1*s)>>11)
      t2=int((cia[255]-cia[i])<<11)
      t2=int(t2/(s-ch[i]))
      t2=int((ch[i]*t2)>>11)
      sigmas.append( int(((t2-cia[i])>>6) * ((cia[255]-t1)>>6)) )
    else:
      sigmas.append(0)

  return sigmas

def maxList(l):
  return l.index(max(l))

def binarize(matrix, threshold):
  return [ [ 1 if (e >= threshold) else 0 for e in vect] for vect in matrix  ]

def erosion(matrix):
  h=len(matrix)
  w=len(matrix[0])
  new=[ [0 for i in range(w)] for j in range(h) ]
  for k in range(1,len(new)-1):
    for j in range(1,len(new[0])-1):
      if ((matrix[k][j]==1) and (matrix[k-1][j]==1) and (matrix[k+1][j]==1) and (matrix[k][j-1]==1) and (matrix[k][j+1]==1)):
        new[k][j]=1
      else:
        new[k][j]=0
  return new


def columnSum(matrix):
  Sums=[]
  for x in range(len(matrix[0])):
    Sum=0
    for y in range(len(matrix)):
      Sum+=matrix[y][x]
    Sums.append(Sum)
  return Sums

def rowSum(matrix):
  return [sum(vector) for vector in matrix]

def extractMatrix(nPE, nVect, filename):
    with open(filename, 'rt') as fp:
         lines=fp.readlines()[1:] #skip first line
         return [  [ int(e.strip(),16) for e in lines[i*nPE:(i+1)*nPE] ] for i in range(nVect)]

def compare(m1, m2):
    for i in range(len(m1)):
        for j in range(len(m1[0])):
            if m1[i][j]!=m2[i][j]:
                return (False, i, j)
    else:
        return (True, None, None)

def threshold(vector, th):
  return [ 1 if e>=th else 0 for e in vector]

def centers(vector):
  start=0
  start_x=0
  for idx, e in enumerate(vector):
    if e==1 and start==0:
      startx=idx
      start=1
    if e==0 and start==1:
      start=0
      idx-=1
      diff=(idx-startx)
      if diff>=3:
        print "center at 0x%x"%(startx+floor((idx-startx)/2.0))


def checkMem(checkData, filename='./sim-out/dump/dmem.baseline.vector.dump'):
  with open(filename) as fp:
      flat=[ int(line, 16) for line in fp.readlines()[1:]]

  cols=len(checkData[0])
  rows=[ flat[i*cols:(i+1)*cols] for i in range(len(flat)/cols) ]

  VERBOSE=True
  for a, b in zip(checkData, rows[:len(checkData)]):
    if VERBOSE:
      print str(a)+'\t'+str(b)
    for c, d in zip(a,b):
      if c!=d:
        print 'mismatch'
        #return False
  print 'Succes'
  return True



Npe=128
Nrows=1024 #16384
matrix=genMem(Nrows, Npe)
dataToImage('inputImage.png',matrix)

sigmas=sigma(matrix, Npe, Nrows)
bin_th=maxList(sigmas)

binary=binarize(matrix, bin_th)

bin_img=[]
for row in binary:
  bin_img.append([p*255 for p in row])
dataToImage('binarized.png',bin_img)


ero=erosion(binary)

ero_img=[]
for row in ero:
  ero_img.append([p*255 for p in row])
dataToImage('erosion.png',ero_img)


#checkMem(ero)
#exit()

centers( threshold(columnSum(ero), 2))
print 0
centers( threshold(rowSum(ero), 2))
