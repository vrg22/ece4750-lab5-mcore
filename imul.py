import numpy
def imul( a,b ):

    result = 0
    for i in range(32):
        if b & 0x01 == 1:
            result += a
            result = result & 0xffffffff
            print("result: " + hex(result), "i: " + str(i))
        a = a << 1
        a = a & 0xffffffff
        b = b >> 1
        b = b & 0xffffffff
        print("a: " + hex(a) + ", b: " + hex(b))

    result = result & 0xffffffff
    return result

print("Should be -1: " + hex(imul( 2 , -3 )))
