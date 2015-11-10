
def section_index(sec, lns):
    try:
        s = lns.index('>> BEGIN %s'%sec)
    except ValueError:
        return None, None
    try:
        e = lns.index('>> END %s'%sec)
    except ValueError:
        raise ValueError('Miss-match section marker for %s'%sec)
    return s, e
