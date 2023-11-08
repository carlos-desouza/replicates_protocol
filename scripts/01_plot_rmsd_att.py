import matplotlib.pyplot as plt
import numpy as np
import sys

#Usage: python3 01_plotter.py plot_type data figure.png

plottype = str(sys.argv[1])
###Define font size###
font = {'fontname':'Times New Roman','color':'black','size':15}
font_title = {'fontname':'Times New Roman','color':'black','size':20}
##Code, please change carefully
if plottype == "boxplot" or plottype == "BOXPLOT":
    data = np.loadtxt(str(sys.argv[2]))
    col_len = len(np.array((data[0,:])))
    replicas = [np.array(data[:, i]) for i in range(col_len)]
    plt.boxplot(replicas, showfliers=False)
    median = [np.median(replica) for replica in replicas]
    indices = range(1, len(replicas) + 1)
    plt.plot(indices, median, color='black', marker='.', linestyle='--', markersize=5, markerfacecolor='white')
#    plt.title("RMSD (Å) per Replica", fontdict = font_title)
    plt.xlabel("Replica", fontdict = font)
    plt.ylabel("RMSD (Å)", fontdict = font)
    plt.savefig(str(sys.argv[3]), dpi=600, transparent=True, bbox_inches='tight')
    plt.show()
elif plottype == "cboxplot" or plottype == "CBOXPLOT":
    col_len = len(np.array((data[0,:])))
    data = np.loadtxt(str(sys.argv[2]))
    col_len = len(np.array((data[0,:])))
    x = [np.array(data[:, i]) for i in range(col_len)]
    cores = ['black', 'red', 'green', 'blue', 'yellow', 'brown', 'orange', 'violet', 'cyan', 'magenta']
    bp = plt.boxplot(x, showfliers=False, patch_artist=True)
    for patch, cor in zip(bp['boxes'], cores):
        patch.set_facecolor(cor)
    plt.xlabel("Replica", fontdict=font)
    plt.ylabel("RMSD (Å)", fontdict=font)
    plt.savefig(str(sys.argv[3]), dpi=600, transparent=True, bbox_inches='tight')
    plt.show()
elif plottype == "fel" or plottype == "FEL":
    data = np.loadtxt(str(sys.argv[2]))
    col_len = len(np.array((data[0,:])))
    x = np.array((data[:, 0]))
    y = np.array((data[:, 1]))
    z = np.array((data[:, 2]))
    plt.scatter(x, y, c=z, cmap='CMRmap')
    plt.title("Free energy landscape of PC1 vs PC2", fontdict = font_title)
    plt.xlabel("PC1", fontdict = font)
    plt.ylabel("PC2", fontdict = font)
    plt.colorbar()
    plt.savefig(str(sys.argv[3]), dpi=400, transparent=True, bbox_inches='tight')
else:
    print("")
    print("")
    print("\x1b[1;31mUsage: python3 01_plotter.py plot_type data figure.png")
    print("")
    print("Avaliable plot types: boxplot, cboxplot and fel")
    print("")
    print("Try again")
#Written by Carlos Souza ; carlosss_gabriel@hotmail.com