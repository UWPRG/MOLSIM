import numpy as np
from scipy.spatial import distance_matrix


class Atom(object):
    def __init__(self, name, element, xyz, velocity, force_field=None):
        # name and element of the atom
        self.name = name
        self.element = element
        # array-like xyz coordinates
        self.xyz = np.array(xyz)
        self.velocity = np.array(velocity)

        # make dummy dictionary to ensure we initialize all properties
        if force_field is None:
            force_field = dict()

        atom_params = force_field.get(self.element, dict())
        self.mass = atom_params.get("mass", 1.0)
        self.charge = atom_params.get("charge", 0.0)
        self.sigma = atom_params.get("sigma", 0.3)
        self.epsilon = atom_params.get("epsilon", 0.0)


def update_velocity(vel, acc, dt):
    """
    Calculate new velocity based on velocity and acceleration from last frame.

    Parameters
    ----------
    vel : np.ndarray
        Velocity in x, y, and z from current MD frame for each atom.
    acc : np.ndarray
        Acceleration in x, y, and z from current MD frame for each atom.
    dt : float
        Time step for the update.

    Returns
    -------
     : array-like
        Velocities at t = t + dt.
    """
    return vel + acc * dt


def update_position(pos, vel, dt):
    """
    Calculate new positions based on positions and velocities from last frame.

    Parameters
    ----------
    pos : np.ndarray
         Current Cartesian (x, y, z) coordinates for every atom in the system.
    vel : np.ndarray
        Velocity in x, y, and z from current MD frame for each atom.
    dt : float
        Time step for the update.

    Returns
    -------
     : array-like
        Positions at t = t + dt.
    """
    return pos + vel * dt


def f_coulomb(pos, charge):
    f = np.zeros_like(pos)
    # todo: vectorized force calc
    return f


def f_lennard_jones(positions, sigmas, epsilons):
    """
    Calculate interatomic forces due to LJ potential.

    Parameters
    ----------
    positions : np.ndarray
        Cartesian (x, y, z) coordinates for every atom in the system.
    sigmas : np.ndarray
        Sigma value for each atom for the 12-6 LJ potential.
    epsilons : np.ndarray
        Epsilon value for each atom for the 12-6 LJ potential.

    Returns
    -------
    f : array-like
        LJ forces experienced by each atom in an MD frame, due to all
        other atoms in the frame.
    """
    # calculate pairwise distance matrix
    distances = distance_matrix(positions, positions)
    np.fill_diagonal(distances, 100000)

    # calculate forces
    f = np.zeros_like(positions)
    for idx in range(distances.shape[0]):
        du_dr = (
            4
            * epsilons
            * (
                12 * (distances[idx] / sigmas) ** (-11)
                - 6 * (distances[idx] / sigmas) ** (-5)
            )
        )
        # get each component of the distance
        x = (positions[:, 0] - positions[idx, 0]) / distances[idx]
        y = (positions[:, 1] - positions[idx, 1]) / distances[idx]
        z = (positions[:, 2] - positions[idx, 2]) / distances[idx]
        # store forces felt by atom idx in each direction
        f[idx] = [np.sum(x * (-du_dr)), np.sum(y * (-du_dr)), np.sum(z * (-du_dr))]

    return f


def optimize_geometry(atoms, box, cutoff=0.5):
    """
    Eliminate overlap in atomic positions.

    Parameters
    ----------
    atoms : list
        List of all Atom() objects in the system.
    box : array-like
        List of simulation box min/max values in x, y, and z.
    cutoff : float, 0.5
        Minimum allowable distance between atom centers.

    Returns
    -------
    None
    """
    # "energy minimization" loop
    init_pos = np.array([atom.xyz for atom in atoms])
    init_dists = distance_matrix(init_pos, init_pos)
    np.fill_diagonal(init_dists, 100000)
    too_close = np.unique(np.where(init_dists < cutoff)[0])
    while len(too_close) > 0:
        idx = too_close[0]
        atoms[idx].xyz = np.array(
            [
                np.random.uniform(low=box[0][0], high=box[0][1]),
                np.random.uniform(low=box[1][0], high=box[1][1]),
                0,
            ]
        )
        init_pos = np.array([atom.xyz for atom in atoms])
        init_dists = distance_matrix(init_pos, init_pos)
        np.fill_diagonal(init_dists, 100000)
        too_close = np.where(init_dists < cutoff)[0]


def calculate_acc(atoms):
    """
    Calculate atomic acceleration from atomic positions.

    Parameters
    ----------
    atoms : list
        List of all Atom() objects in the system.

    Returns
    -------
    np.ndarray
        Acceleration in x, y, and z for next MD frame for each atom.
    """
    # get positions for all force calculations
    positions = np.array([atom.xyz for atom in atoms])

    # get charges for electrostatic force calc
    charges = np.array([atom.charge for atom in atoms])
    # get sigmas and epsilons for LJ force calc
    sigmas = np.array([atom.sigma for atom in atoms])
    epsilons = np.array([atom.epsilon for atom in atoms])

    # get atomic masses to get acc from force
    masses = np.array([atom.mass if atom.mass is not None else 1 for atom in atoms])

    # calculate forces
    forces = np.zeros_like(positions)
    forces += (
        f_coulomb(positions, charges)
        + f_lennard_jones(positions, sigmas, epsilons)
        # + other terms?
    )

    return forces / masses[:, None]


def velocity_verlet(atoms, acc, dt):
    """
    Evolve MD system from time = t to time = t + dt.

    Parameters
    ----------
    atoms : list
        List of all Atom() objects in the system.
    acc : np.ndarray
        Acceleration in x, y, and z from current MD frame for each atom.
    dt : float
        Time step for the update.

    Returns
    -------
    tuple
        Cartesian (x, y, z) positions, velocities, and acceleration at
        time = t + dt.
    """
    # copy old positions
    old_pos = np.array([atom.xyz for atom in atoms])
    old_vel = np.array([atom.velocity for atom in atoms])

    # 1. half step velocity update
    half_vel = update_velocity(old_vel, acc, dt / 2)

    # 2. full step position update
    new_pos = update_position(old_pos, half_vel, dt)
    for idx, xyz in enumerate(new_pos):
        atoms[idx].xyz = xyz

    # 3. update forces
    new_acc = calculate_acc(atoms)

    # 4. half step velocity to new full step velocity
    new_vel = update_velocity(half_vel, new_acc, dt / 2)
    for idx, vel in enumerate(new_vel):
        atoms[idx].velocity = vel

    return new_pos, new_vel, new_acc


def bumpers(atoms, box):
    """
    Bounce atoms back into box if they try to cross the boundary.

    Parameters
    ----------
    atoms : list
        List of all Atom() objects in the system.
    box : array-like
        List of simulation box min/max values in x, y, and z.

    Returns
    -------
    pos, vel : Tuple(ndarray, ndarray)
        Updated positions and velocities for system after applying
        bumpers at boundary.
    """
    pos = np.array([atom.xyz for atom in atoms])
    vel = np.array([atom.velocity for atom in atoms])

    # adjust velocity if atom leaves box in x
    out_of_x_range = np.where(np.abs(pos[:, 0]) > box[0][1])[0]
    vel[out_of_x_range, 0] = -vel[out_of_x_range, 0]
    for idx in out_of_x_range:
        atoms[idx].velocity[0] = vel[idx, 0]

    # adjust velocity if atom leaves box in x
    out_of_y_range = np.where(np.abs(pos[:, 1]) > box[1][1])[0]
    vel[out_of_y_range, 1] = -vel[out_of_y_range, 1]
    for idx in out_of_y_range:
        atoms[idx].velocity[1] = vel[idx, 1]

    # adjust velocity if atom leaves box in x
    out_of_z_range = np.where(np.abs(pos[:, 2]) > box[2][1])[0]
    vel[out_of_z_range, 2] = -vel[out_of_z_range, 2]
    for idx in out_of_z_range:
        atoms[idx].velocity[2] = vel[idx, 2]

    return pos, vel


def molecular_dynamics(atoms, box, dt=0.002, t_max=1.0):
    """
    Perform simple molecular dynamics simulation.

    Parameters
    ----------
    atoms : list
        List of all Atom() objects in the system.
    box : array-like
        List of simulation box min/max values in x, y, and z.
    dt : float
        Time step between consecutive frames.
    t_max : float
        Total length, in time, of simulation.

    Returns
    -------
    positions, velocities : Tuple(np.ndarray, np.ndarray)
        Positions and velocities for each atom for each frame of the
        simulation. Each array is 3 dimensional, with the first
        dimension corresponding to time, the second corresponding to
        atom, and the third corresponding to spatial dimension.
        (e.g. positions[3, 2, 1] gives the y coordinate of the third
        atom in the fourth frame of the simulation)
    """
    # and velocities
    n_frames = int(t_max / dt)

    # create container for atom positions
    positions = np.zeros([n_frames, len(atoms), 3])
    pos = np.array([atom.xyz for atom in atoms])
    positions[0, :, :] = pos

    # create container for atom velocities
    velocities = np.zeros_like(positions)
    vel = np.array([atom.velocity for atom in atoms])
    velocities[0, :, :] = vel

    # set initial acceleration to 0
    acc = np.zeros([len(atoms), 3])

    # perform md steps
    for frame in range(1, n_frames):
        # take step with velocity verlet
        pos, vel, acc = velocity_verlet(atoms, acc, dt)
        # bounce atoms back into box if they're headed out
        pos, vel = bumpers(atoms, box)
        # save positions (and velocities) for our viewing pleasure!
        positions[frame, :, :] = pos
        velocities[frame, :, :] = vel

    return positions, velocities
