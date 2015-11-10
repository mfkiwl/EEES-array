from PIL import Image

rows = 1024
startAddr = 0
columnThreshold = 2
rowThreshold = 2

def dataFromImage(filename):
    im = Image.open(filename)
    (w, h)=im.size
    pixels = list(im.getdata())
    return [ pixels[i*w:(i+1)*w]  for i in range(h) ]

def scaleData(data, rows, cols):
    r_in=len(data)
    c_in=len(data[0])

    #get desired number of rows by wrapping round
    dataOut=[]
    for i in range(rows):
        #construct desired length row by wrapping around again
        row=[]
        for j in range(cols):
            row.append(data[i%len(data)][j%c_in])
        dataOut.append(row)
    return dataOut

def genMem(rows, cols):
    data=dataFromImage("oled.pgm")
    return scaleData(data, rows, cols)
