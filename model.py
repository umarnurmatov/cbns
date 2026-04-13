from bitstring import BitArray, Bits
import math

def is_even(x: int):
    return True if x % 2 == 0 else False

def is_odd(x: int):
    return not is_even(x)

def is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0

class Converter:

    __cnvrt_tbl_base_neg4 = { '00': 0, '01': 1, '10': 2, '11': 3 }

    __cnvrt_tbl_cbns = ['0000', '0001', '1100', '1101']

    def __init__(self, re_im_bitness: int):
        self.re_im_bitness = re_im_bitness

        # constant for fast convertion to base (-4)
        self.__shroeppel4 = (BitArray(hex='c')*(self.re_im_bitness // 4 + 1))[:self.re_im_bitness]

    # https://en.wikipedia.org/wiki/Negative_base#Shortcut_calculation
    def convert_to_cbns(self, num: BitArray):

        assert num.length == self.re_im_bitness

        base_neg4 = BitArray(int=num.int + self.__shroeppel4.int, length=self.re_im_bitness+1)[:self.re_im_bitness] ^ self.__shroeppel4

        base_neg4_lst = []
        for half_nibble in base_neg4.cut(2):
            base_neg4_lst.append(
                self.__cnvrt_tbl_base_neg4[half_nibble.bin])

        print(base_neg4_lst)

        res = BitArray()
        for dgt_neg4 in base_neg4_lst:
            res.append(BitArray(bin=self.__cnvrt_tbl_cbns[dgt_neg4]))

        return res


if __name__ == '__main__':

    re_im_bitness = 4
    conv = Converter(re_im_bitness)
    re = BitArray(int=-2, length=re_im_bitness)
    print(re.bin)
    real = conv.convert_to_cbns(re)
    print(real.bin)
