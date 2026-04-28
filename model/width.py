import re
import model
import itertools as itools
from rich.progress import Progress

def cbns_width(re_im_width) -> int:

    """
    Find out numer of bits in CBNS representation required for
    a number with given width of re/im part in ordinary binary system
    """

    lo_bound_prev = -2**(re_im_width-2)
    lo_bound = -2**(re_im_width-1)

    up_bound_prev = 2**(re_im_width-2)+1
    up_bound = 2**(re_im_width-1)-1

    total = ((lo_bound_prev-lo_bound) + (up_bound-up_bound_prev))**2

    conv = model.Converter(re_im_width, debug=False)

    with Progress() as progress:

        task = progress.add_task("Performing tests...", total=total)
        width = 0

        for re in itools.chain(range(lo_bound, lo_bound_prev), range(up_bound_prev, up_bound)):
            for im in itools.chain(range(lo_bound, lo_bound_prev), range(up_bound_prev, up_bound)):

                num_cbns = conv.convert(re, im)
                width = max(width, model.bitarr_shrink(num_cbns).len)

                progress.update(task, advance=1)

    return width

if __name__ == '__main__':

    re_im_width = 4
    width = cbns_width(re_im_width)
    print(f'[{re_im_width} bits] ± [{re_im_width} bits]j -> [{width} bits] (cbns)')
