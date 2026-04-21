from bitstring import BitArray

MAX_CARRY = 8  # as shown in W.Gilbert article


def is_even(x: int):
    return True if x % 2 == 0 else False


def is_odd(x: int):
    return not is_even(x)


def zero_extend(x: BitArray, width: int):
    z_cnt = width-x.length
    if z_cnt > 0:
        return BitArray(int=0, length=z_cnt) + x
    return x


def from_cbns_to_cns(cbns: BitArray) -> complex:
    base = complex(-1, 1)
    res = complex(0, 0)

    for i in range(cbns.length):
        res += cbns[i] * base**(cbns.length-i-1)

    return res


def from_base_neg4_to_dec(base_neg4_lst: list) -> int:
    base = -4
    res = 0

    for i, dgt in enumerate(reversed(base_neg4_lst), start=0):
        res += dgt * base**i

    return res


def bitarr_str(barr: BitArray):
    return f'[{barr.bin}, {barr.length} bits]'

def bitarr_shrink(barr: BitArray):
    return BitArray(bin=barr.bin.lstrip('0'))


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

    def __init__(self, arg_bitness: int, debug: bool = False):
        self.arg_bitness = arg_bitness
        self.full_adder = FullAdder()
        self.verbose = debug

    # len(output) = len(n1)+8
    def add(self, n1: BitArray, n2: BitArray) -> BitArray:

        # assert n1.length == n2.length == self.arg_bitness
        assert n1.length == n2.length

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
                print(f'{i}\t| s: {s}, c_out: {carry.bin}, carries: ', end='')
                for cr in carries:
                    print(cr.bin, end=' ')
                print()

            sum_bits.set(s, -i-1)

        return sum_bits


class Converter:

    __cnvrt_tbl_base_neg4 = {'00': 0, '01': 1, '10': 2, '11': 3}

    __cnvrt_tbl_cbns = ['0000', '0001', '1100', '1101']

    def __init__(self, re_im_bitness: int, debug: bool = False):
        self.re_im_bitness = re_im_bitness

        nibble_cnt = self.re_im_bitness // 4 + 1
        self.__schroeppel4 = int('c' * nibble_cnt, 16)

        self.adder = RippleCarryAdder(self.re_im_bitness, debug)

        self.debug = debug

    def __convert_re(self, num: int) -> BitArray:
        """
        https://en.wikipedia.org/wiki/Negative_base#Shortcut_calculation
        """
        assert len(bin(num)[2:]) <= self.re_im_bitness

        base_neg4 = (num + self.__schroeppel4) ^ self.__schroeppel4
        base_neg4_bin = bin(base_neg4)[2:]

        if is_odd(len(base_neg4_bin)):
            base_neg4_bin = '0' + base_neg4_bin

        base_neg4_lst = []
        for i in range(0, len(base_neg4_bin), 2):
            base_neg4_lst.append(
                self.__cnvrt_tbl_base_neg4[base_neg4_bin[i:i+2]])

        if self.debug:
            print(f'### converting real (dec) to cbns ###')
            num_base_neg4_dec = from_base_neg4_to_dec(base_neg4_lst)
            valid = num == num_base_neg4_dec
            base_neg4_str = "".join([str(x) for x in base_neg4_lst])
            if valid:
                print(f'{num} (dec) = {base_neg4_str} (base -4)')
            else:
                print(
                    f'{num}: converseion to base -4 failed (got {base_neg4_str} = {num_base_neg4_dec})')

        num_cbns = BitArray()
        for dgt_neg4 in base_neg4_lst:
            num_cbns.append(BitArray(bin=self.__cnvrt_tbl_cbns[dgt_neg4]))

        if self.debug:
            num_cbs = complex(num, 0)
            num_cbs_from_cbns = from_cbns_to_cns(num_cbns)
            valid = num_cbs == num_cbs_from_cbns
            if valid:
                print(f'{num} (dec) = {bitarr_str(num_cbns)} (cbns)')
            else:
                print(
                    f'{num} (dec) conversion failed (got {bitarr_str(num_cbns)} = {num_cbs_from_cbns})')

        return num_cbns

    def __convert_im(self, num: int) -> BitArray:

        if self.debug:
            print(f'### converting imaginary (dec) to cbns ###')

        # i*im = '11'*im
        p_sum_0 = self.__convert_re(num)
        p_sum_1 = p_sum_0 + BitArray(bin='0')
        p_sum_0 = BitArray(bin='0') + p_sum_0

        if self.debug:
            print(
                f'partial sum 0: {from_cbns_to_cns(p_sum_0)} (dec) = {bitarr_str(p_sum_0)} (cbns)')
            print(
                f'partial sum 1: {from_cbns_to_cns(p_sum_1)} (dec) = {bitarr_str(p_sum_1)} (cbns)')

        product = self.adder.add(p_sum_0, p_sum_1)

        if self.debug:
            print(f'{num}j = psum0 + psum1 = {bitarr_str(product)}')

        return product

    def convert(self, re: int, im: int) -> BitArray:

        if self.debug:
            print(f'########## CONVERTING {complex(re, im)} ##########')

        re_cbns = self.__convert_re(re)
        im_cbns = self.__convert_im(im)

        if re_cbns.length < im_cbns.length:
            re_cbns = zero_extend(re_cbns, im_cbns.length)
        else:
            im_cbns = zero_extend(im_cbns, re_cbns.length)

        res = self.adder.add(re_cbns, im_cbns)

        if self.debug:
            print(
                f'{complex(re, im)} (dec) = {bitarr_str(re_cbns)}+{bitarr_str(im_cbns)} = {bitarr_str(res)} (cbns)')

        return res


def test() -> bool:
    re_im_bitness = 8
    lim = 10
    conv = Converter(re_im_bitness, debug=False)

    for re in range(-lim, lim):
        for im in range(-lim, lim):

            num_cbs = complex(re, im)
            num_cbns = conv.convert(re, im)
            num_cbs_from_cbns = from_cbns_to_cns(num_cbns)
            valid = num_cbs == num_cbs_from_cbns
            if valid:
                print(f'{num_cbs} = {bitarr_str(bitarr_shrink(num_cbns))}')
            else:
                print(
                    f'{num_cbs} conversion failed (got {num_cbns.bin} = {num_cbs_from_cbns})')
                return False

    return True

if __name__ == '__main__':
    if test():
        print('TEST PASSED')
    else:
        print('TEST FAILED')
