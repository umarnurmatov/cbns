import cmath


def complex_to_cbns(z: complex) -> str:
    """
    Converts a complex number to its CBNS (Complex Binary Number System) representation.
    """
    digits = []
    base = complex(-1, 1)
    n = z
    while n != 0:
        r = int(n.real) % 2
        digits.append(str(r))
        n = (n - r) / base
        n = complex(round(n.real), round(n.imag))  # Round to the nearest integer
    return ''.join(digits[::-1]) if digits else '0'


def cbns_to_complex(s: str) -> complex:
    """
    Converts a CBNS (Complex Binary Number System) representation to a complex number.
    """
    base = complex(-1, 1)
    result = complex(0, 0)
    for i, bit in enumerate(s[::-1]):
        if bit == '1':
            result += base ** i
    return result


def add_cbns(a: str, b: str):
    result = cbns_to_complex(a) + cbns_to_complex(b)
    return complex_to_cbns(result), result


def sub_cbns(a: str, b: str):
    result = cbns_to_complex(a) - cbns_to_complex(b)
    return complex_to_cbns(result), result


def mul_cbns(a: str, b: str):
    result = cbns_to_complex(a) * cbns_to_complex(b)
    return complex_to_cbns(result), result


def div_cbns(a: str, b: str):
    ca = cbns_to_complex(a)
    cb = cbns_to_complex(b)
    if cb == 0:
        return "Error", "Division by zero"
    result = ca / cb
    return complex_to_cbns(result), result


mlen = 0
for i in range(-255,255):
    for j in range(-255,255):
        a = complex(i, j)
        cbns = complex_to_cbns(a)
        if len(cbns) == 21:
            print(f'{i}+i{j}={cbns} [{len(cbns)}]')
        mlen = max(mlen,len(cbns))

print(mlen)
