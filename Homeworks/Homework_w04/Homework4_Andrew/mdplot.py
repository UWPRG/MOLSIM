import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


def plot_md_frame(atoms, box):
    key = {'Na':'g', 'Cl':'b', 'Ar':'r'}
    color = np.array([key[atom.name] for atom in atoms])
    l = pop
    positions = np.array([atom.xyz for atom in atoms])
    size = np.array([atom.sigma for atom in atoms]) * (5000 / box[0][1])
    # force square figure
    plt.figure(figsize=(5, 5))
    # plot atom position
    plt.scatter(positions[:, 0], positions[:, 1], s=size, c=color, alpha=0.5)
    # plot box limit to left
    plt.plot(
        [box[0][0], box[0][0]],
        [box[1][0], box[1][1]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    # plot box limit to right
    plt.plot(
        [box[0][1], box[0][1]],
        [box[1][0], box[1][1]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    # plot box limit to bottom
    plt.plot(
        [box[0][0], box[0][1]],
        [box[1][0], box[1][0]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    # plot box limit to top
    plt.plot(
        [box[0][0], box[0][1]],
        [box[1][1], box[1][1]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    plt.show()


def animate_md_traj(positions, atoms, box, speed=10):
    key = {'Na':'g', 'Cl':'b', 'Ar':'r'}
    color = np.array([key[atom.element] for atom in atoms])
    fig, ax = plt.subplots(figsize=(5, 5))
    size = np.array([atom.sigma for atom in atoms]) * (4000 / box[0][1])
    scat = ax.scatter(positions[0, :, 0], positions[0, :, 1], s=size, alpha=0.5, c=color)
    # plot box limit to left
    plt.plot(
        [box[0][0], box[0][0]],
        [box[1][0], box[1][1]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    # plot box limit to right
    plt.plot(
        [box[0][1], box[0][1]],
        [box[1][0], box[1][1]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    # plot box limit to bottom
    plt.plot(
        [box[0][0], box[0][1]],
        [box[1][0], box[1][0]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )
    # plot box limit to top
    plt.plot(
        [box[0][0], box[0][1]],
        [box[1][1], box[1][1]],
        ls="--",  # dashed line
        c="k",  # force line color to black
        alpha=0.3,  # turn down opacity to 30 %
    )

    def animate(i):
        x_i = positions[i, :, 0]
        y_i = positions[i, :, 1]
        scat.set_offsets(np.c_[x_i, y_i])

    return FuncAnimation(fig, animate, interval=speed, frames=positions.shape[0])
