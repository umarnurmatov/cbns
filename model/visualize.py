import model as model
import matplotlib.pyplot as plt

def visualize(re_im_width: int):

    conv = model.Converter(re_im_width*2, debug=False)
    l_range = -2**(re_im_width-1)
    h_range = 2**(re_im_width-1)-1

    max_width = 0

    points_x = []
    points_y = []
    colors = []
    print('Calculating...', end='', flush=True)
    for re in range(l_range, h_range+1):

        complete_percent = int((re-l_range)*100/(h_range-l_range))
        if complete_percent % 10 == 0:
            print(f'{complete_percent}%...', end='', flush=True)

        for im in range(l_range, h_range+1):
            num_cbns = conv.convert(re, im)
            width = model.bitarr_shrink(num_cbns).length
            points_x.append(re)
            points_y.append(im)
            colors.append(width)
            max_width = max(max_width, width)

    print('done')
    print(f'CBNS width = {max_width} for im/re in [{l_range},{h_range}]')

    plt.figure()
    plt.scatter(x=points_x, y=points_y, c=colors, cmap='rainbow')
    plt.colorbar()
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    visualize(8)
