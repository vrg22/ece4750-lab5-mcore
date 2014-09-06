def imul( a,b ):

    result = 0
    for i in range(32):
        if b & 0x01 == 1:
            result += a
        a = a << 1
        b = b >> 1

    return result

