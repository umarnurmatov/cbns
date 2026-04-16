from bitstring import BitArray, Bits
import math

MAX_CARRY = 8 # as show in W.Gilbert article

def is_even(x: int):
    return True if x % 2 == 0 else False

def is_odd(x: int):
    return not is_even(x)

def zero_extend(x: BitArray, width: int):
    z_cnt = width-x.length
    if z_cnt > 0: 
        return BitArray(int=0, length=z_cnt) + x
    return x


class FullAdder:

    def add(self, a: bool, b: bool, carry: BitArray):

        assert carry.length == MAX_CARRY

        s = a + b + carry.count(1)
        carry_out = BitArray(length=MAX_CARRY)
        s_out = 0

        match s:
            case 0:
              s_out = 0
            case 1:
              s_out = 1
            case 2:
              s_out = 0
              carry_out = BitArray('0b00000110')
            case 3:
              s_out = 1
              carry_out = BitArray('0b00000110')
            case 4:
              s_out = 0
              carry_out = BitArray('0b11101000')
            case 5:
              s_out = 1
              carry_out = BitArray('0b11101000')
            case 6:
              s_out = 0
              carry_out = BitArray('0b11101110')
            case 7:
              s_out = 1
              carry_out = BitArray('0b11101110')
            case 8:
              s_out = 0
              carry_out = BitArray('0b11100000')
            case _:
              assert 0

        carry_out.reverse()
        return s_out, carry_out

class RippleCarryAdder:

    def __init__(self, arg_bitness: int, verbose: bool = False):
        self.arg_bitness = arg_bitness
        self.full_adder = FullAdder()
        self.verbose = verbose

    # len(output) = len(n1)+8
    def add(self, n1: BitArray, n2: BitArray) -> BitArray:

        # assert n1.length == n2.length == self.arg_bitness

        sum_len = n1.length + MAX_CARRY

        carries = []
        for i in range(sum_len):
            carries.append(BitArray(length=MAX_CARRY))

        sum_bits = BitArray(length=sum_len)

        for i in range(sum_len):
            
            if i < n1.length:
                s, carry = self.full_adder.add(n1[-i-1], n2[-i-1], carries[i])
            else:
                s, carry = self.full_adder.add(False, False, carries[i])

            for j in range(min(sum_len-i-1, MAX_CARRY)):
                carries[i+j+1][i % MAX_CARRY] = carry[j]

            if self.verbose:
                print(f'{i}\t| s: {s}, c_out: {carry.bin}, carries: ',end='')
                for cr in carries: print(cr.bin,end=' ')
                print()

            sum_bits.set(s, -i-1)

        return sum_bits


class Converter:

    __cnvrt_tbl_base_neg4 = { '00': 0, '01': 1, '10': 2, '11': 3 }

    __cnvrt_tbl_cbns = ['0000', '0001', '1100', '1101']

    def __init__(self, re_im_bitness: int):
        self.re_im_bitness = re_im_bitness
            
        nibble_cnt = self.re_im_bitness // 4 + 1
        self.__schroeppel4 = int('c' * nibble_cnt, 16)

        self.adder = RippleCarryAdder(self.re_im_bitness)

    def __convert_re(self, num: int) -> BitArray:
        """
        https://en.wikipedia.org/wiki/Negative_base#Shortcut_calculation
        """
        assert len(bin(num)[2:]) <= self.re_im_bitness

        base_neg4 = (num + self.__schroeppel4) ^ self.__schroeppel4
        base_neg4_bin = bin(base_neg4)[2:]

        if is_odd(len(base_neg4_bin)):
            base_neg4_bin  = '0' + base_neg4_bin

        base_neg4_lst = []
        for i in range(0, len(base_neg4_bin), 2):
            base_neg4_lst.append(self.__cnvrt_tbl_base_neg4[base_neg4_bin[i:i+2]])


        res = BitArray()
        for dgt_neg4 in base_neg4_lst:
            res.append(BitArray(bin=self.__cnvrt_tbl_cbns[dgt_neg4]))

        return res

    def __convert_im(self, num: int) -> BitArray:

        # i*im = '11'*im
        p_sum_0 = self.__convert_re(num)
        p_sum_1 = p_sum_0 + BitArray(bin='0')

        mult = self.adder.add(p_sum_0, p_sum_1)

        return mult

    def convert(self, re: int, im: int) -> BitArray:

        re_cbns = self.__convert_re(re)
        im_cbns = self.__convert_im(im)

        res = self.adder.add(re_cbns, im_cbns)

        return res

if __name__ == '__main__':
    re_im_bitness = 8
    conv = Converter(re_im_bitness)

    for re in range(-10,10):
        for im in range(-10,10):
            num = conv.convert(re, im)
            print(f'{re}+{im}i = {num.bin}')

