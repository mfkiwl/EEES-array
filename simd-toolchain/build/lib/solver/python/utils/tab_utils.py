import os, sys

def aligned_str(s, w, align='c', padding=' '):
    p = w - len(s)
    pad_front, pad_back = 0, 0
    if align == 'c':
        pad_front = p/2
        pad_back = p - pad_front
    elif align == 'r':
        pad_front = p
    elif align == 'l':
        pad_back = p
    else: raise ValueError('Unknow alignment %s'%str(algin))
    return padding*pad_front + s + padding*pad_back
