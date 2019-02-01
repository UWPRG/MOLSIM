# Homework - Week 3

In this homework, you will perform a scaling analysis for a relatively large system of multiple LK-alpha peptides on Ikt.

You are to perform the scaling listed below on your own and decide which set makes the most sense and justify your answer based on the scaling data. This can be submitted as a markdown file (`.md` extension) with your scaling results included as an image in the file along with your explanation.

Instructions on how to run the simulations are given below the table.

|Number of walkers |Nodes |MPI ranks/walker |OpenMP threads/rank |ns/day/walker |total ns/day |
| ----- | ----- | ----- | ----- | ----- | ----- |
|1 |1 |1 |1 | 1.459| 1.459|
|1 |1 |2 |1 | 2.819| 2.819|
|1 |1 |4 |1 | 5.467| 5.467|
|1 |1 |8 |1 | 9.953| 9.953|
|1 |1 |16 |1 | 18.051| 18.051|
|1 |1 |8 |2 | 17.187| 17.187|
|1 |1 |4 |4 | 17.021| 17.021|
|1 |1 |2 |8 | 16.475| 16.475|
|1 |1 |1 |16 | 16.878| 16.878|
|2 |1 |8 |1 | 10.23 | 20.46|
|4 |1 |4 |1 | 4.949 | 19.796|
|8 |1 |2 |1 | 2.218 | 17.744|
|2 |2 |16 |1 | 16.197 | 32.394|
|4 |2 |8 |1 | 10.459 | 41.836|
|8 |2 |4 |1 | 4.954 | 39.632|

## Input file
The input file (`topol.tpr`) can be found on Ikt at the path: `/suppscr/pfaendtner/ldgibson/molsim/gromacs_scaling/lk-alpha`. Be sure to copy it to your directory and from there you can make all the copies you need for each of the simulations. This homework requires that you have been added to the `pfaendtner` account on Hyak. If you cannot access that account, you will not have the permissions to run Gromacs or even look in the `/suppscr/pfaendtner` directory. You can check to see if you are in the group by typing `groups` on Hyak. It should list `hyak-pfaendtner` as one of your groups. If you are not in the group, you will need to be added, so please let me know as soon as possible if you are not in the group.

## Launching the simulation
I have set up (_Sarah set up_) a Gromacs file that you can use to run each of the short simulations on Ikt (`ikt.hyak.uw.edu`). You can launch the MD simulation using the following command:

`mpiexec.hydra -n <MPI_ranks> gmx_mpi mdrun -ntomp <OMP_threads>`

where the flags `-n` and `-ntomp` indicate the number of MPI ranks and OpenMP threads, respectively. *Note: replace anything in `<...>` with numbers **without** the angled brackets, e.g., `mpiexec.hydra -n 4 gmx_mpi mdrun -ntomp 4`.*

**This command will only work if you have the `topol.tpr` file in the same directory.**

Prior to launching the simulations, you will need to make sure that you you activate the program by running the command: `source /suppscr/pfaendtner/sarahh/scripts/environments/activate_gromacs18.3`

## Multiple walkers
In the table above, I'm asking you to run simulations with multiple walkers. You can do this by adding the flag `-multi <N_walkers>`. Here is an example of running with 2 walkers: `mpiexec.hydra -n 4 gmx_mpi mdrun -ntomp 4 -multi 2`.

There are a couple things to remember when running with multiple walkers:
- You must have multiple `topol.tpr` files in the directory and they must be named numerically for the number of walkers, e.g., if you set `-multi 2`, then you would need`topol0.tpr` and `topol1.tpr` in your directory.
- The number of MPI ranks are divided among the walkers. So if you ask for 4 MPI ranks and are running with 2 walkers, then each walker gets 2 MPI ranks.

## Automating the process
I highly recommend that you create a bash script to automate this process for you. Otherwise, things can become very unorganized very quickly.

An example of what that for-loop may look like is shown below. You can modify it to actually run each of the short simulations successively. Go ahead and copy this script into a file and run it to see how it works. (You may need to clean up any directories that it makes.)

```bash
# Some other lines may need to be added as needed, for copying files possibly.
for mpi in 1 2 4 8 16; do
    omp=$((16 / mpi))
    mkdir mpi${mpi}omp${omp}
    cd mpi${mpi}omp${omp}
    echo "MPI ranks: " $mpi " OpenMP threads: " $omp  # This is the line that should be changed
    cd ..
done
```

I recommend not trying to script the entire set of simulations into a single run, unless you feel very comfortable with bash coding. I would just run all of the simulations with `-ntomp 1`, and then move to the set of simulations where `-ntomp` is changing as `-n` changes.
