import pandas as pd
import numpy as np
from matplotlib import pyplot as plt

def load_data(filename):
    m = np.array(pd.read_csv(filename, header=None))
    mirrored = np.tril(m) + np.tril(m).transpose()
    return mirrored

def shuffle_numas(mirrored):
    new = mirrored.copy()
    for i in range(0, mirrored.shape[0]):
        for j in range(0, mirrored.shape[1]):
            i_new = i
            j_new = j
            if i%2==0:
              i_new = int(i/2)
            else:
              # shift to second quadrant
              i_new = 128 + int(i/2)

            if j%2==0:
              j_new = int(j/2)
            else:
              # shift to second quadrant
              j_new = 128 + int(j/2)

            new[i_new][j_new] = mirrored[i][j]

            # new[int(i/2+0.5)][int(j/2+0.5)] = mirrored[i][j]
    # breakpoint()
    return new

def show_heapmap(m, title=None, subtitle=None, vmin=None, vmax=None, yticks=True, figsize=None):
    vmin = np.nanmin(m) if vmin is None else vmin
    vmax = np.nanmax(m) if vmax is None else vmax
    black_at = (vmin+3*vmax)/4
    subtitle = "Core-to-core latency" if subtitle is None else subtitle

    isnan = np.isnan(m)

    plt.rcParams['xtick.bottom'] = plt.rcParams['xtick.labelbottom'] = False
    plt.rcParams['xtick.top'] = plt.rcParams['xtick.labeltop'] = True

    figsize = np.array(m.shape)*0.3 + np.array([6,1]) if figsize is None else figsize
    fig, ax = plt.subplots(figsize=figsize, dpi=130)

    fig.patch.set_facecolor('w')

    plt.imshow(np.full_like(m, 0.7), vmin=0, vmax=1, cmap = 'gray') # for the alpha value
    plt.imshow(m, cmap = plt.cm.get_cmap('viridis'), vmin=vmin, vmax=vmax)

    fontsize = 9 if vmax >= 100 else 10

    for (i,j) in np.ndindex(m.shape):
        t = "" if isnan[i,j] else f"{m[i,j]:.1f}" if vmax < 10.0 else f"{m[i,j]:.0f}"
        c = "w" if m[i,j] < black_at else "k"
        plt.text(j, i, t, ha="center", va="center", color=c, fontsize=fontsize)

    plt.xticks(np.arange(m.shape[1]), labels=[f"{i+1}" for i in range(m.shape[1])], fontsize=9)
    if yticks:
        plt.yticks(np.arange(m.shape[0]), labels=[f"CPU {i+1}" for i in range(m.shape[0])], fontsize=9)
    else:
        plt.yticks([])

    plt.tight_layout()
    plt.title(f"{title}\n" +
              f"{subtitle}\n" +
              f"Min={vmin:0.1f}ns Median={np.nanmedian(m):0.1f}ns Max={vmax:0.1f}ns",
              fontsize=11, linespacing=1.5)
    plt.savefig("foo.png")

# show_heapmap(shuffle_numas(load_data("/mnt/c/Users/okelmann/OneDrive - Nokia/excel/martha-latency.csv")), title="martha dynamic frequncy", vmax=400)
show_heapmap(load_data("/mnt/c/Users/okelmann/OneDrive - Nokia/excel/nokia04-latency.csv"), title="nokia04")
