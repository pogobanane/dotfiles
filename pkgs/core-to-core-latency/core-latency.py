import argparse
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
    return plt

def parse_args():
    parser = argparse.ArgumentParser(description="Generate a NUMA heatmap from a core-to-core-latency CSV file")
    parser.add_argument("csv_file", help="Path to the input CSV file")
    parser.add_argument("--shuffle", action="store_true", help="Untangle core numbers when even/odd cores belong to different NUMA nodes")
    parser.add_argument("--title", type=str, default="NUMA Heatmap", help="Title of the heatmap")
    parser.add_argument("--subtitle", type=str, help="Subtitle of the heatmap")
    parser.add_argument("--vmin", type=float, help="Minimum value for colormap")
    parser.add_argument("--vmax", type=float, help="Maximum value for colormap")
    parser.add_argument("--no-yticks", action="store_true", help="Hide Y-axis ticks (CPU labels)")
    parser.add_argument("--figsize", type=str, help="Figure size as 'width,height'")
    parser.add_argument("--output", type=str, default="core-to-core-latency-plot.png", help="Output image file name")
    parser.add_argument("--show", action="store_true", help="Display the plot interactively")
    args = parser.parse_args()
    return args


def main():
    args = parse_args()

    m = load_data(args.csv_file)
    if args.shuffle:
        m = shuffle_numas(m)

    figsize = None
    if args.figsize:
        try:
            w, h = map(float, args.figsize.split(","))
            figsize = (w, h)
        except:
            raise ValueError("Invalid format for --figsize. Use 'width,height' (e.g., 12,10)")

    show_heapmap(
        m,
        title=args.title,
        subtitle=args.subtitle,
        vmin=args.vmin,
        vmax=args.vmax,
        yticks=not args.no_yticks,
        figsize=figsize
    )

    if args.show:
        plt.show()
    else:
        plt.savefig(args.output)
        print(f"Saved heatmap to '{args.output}'")


if __name__ == "__main__":
    main()
