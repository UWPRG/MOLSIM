This file contains ALL steps (jk probably forgot some) required 
to complete HW3 for  MOLSIM, Win 2017. $ represents your command
 prompt, as is tradition.

0) Add Files to Hyak and prepare GROMACS

go to directory of HW3 where MOLSIM_HW3.tar is located. 
Run the following command:

$ scp MOLSIM_HW3.tar youraddress@hyak.washington.edu:/suppscr/pfaendtner/youraddress

Now navigate to hyak and set up your GROMACS path:

$ ssh youraddress@hyak.washington.edu
$ cd /suppscr/pfaendtner/youraddress/
$ source /gscratch/pfaendtner/cdf6gc/codes/PRG_USE/activate_gromacs.sh

1) Untar HW3 directory

$ tar -xvf MOLSIM_HW3.tar

You should now have an ensembles/ directory with NVT/ and
NPT/ subdirectories

2) Set up NVT simulation

$ cd NVT/

3) Run NVT simulation

$ gmx grompp -f nvt.mdp -c conf.gro -p topol.top -maxwarn 1
$ qsub GROMACS.pbs

This simulation will take a few minutes to run. Steps for 
analysis are included below. You can skip to NPT to get
other jobs submitted and come back to this if you like.

3a) Analyze temperature 

$ gmx energy -f ener.edr -o temperature.xvg

3b) Analyze pressure

$ gmx energy -f ener.edr -o pressure.xvg

3c) Plot temperature and pressure

We will use gnuplot to visualize our simulation results.
gnuplot > represents the gnuplot command prompt.

$ gnuplot

The command above opens the gnuplot program. To plot the 
temperature over the course of our simulation:

gnuplot > p "temperature.xvg" u 1:2 w l

To plot pressure:

gnuplot > p "pressure.xvg" u 1:2 w l

The procedures above, along with HW3.txt instructions, 
should be sufficient to complete the NVT portion of
your assignment. NPT instructions are found below.

4) Setup NPT/ simulations

$ cd /suppscr/pfaendtner/youraddress/ensembles/NPT/

There are 4 subdirectories with the necessary files for NPT
simulation of a water box with different thermostat coupling
time constants (0.1, 1, 10, 100 ps). We will be submitting 1
"job" for each of these subdirectories to the scheduler, for
 a total of 4 jobs.

These will take a couple of minutes to run, so we will submit
all 4 jobs before going back for analysis.

4a) Run 0.1_tau

$ cd 0.1_tau
$ gmx grompp -f npt.mdp -c conf.gro -p topol.top -maxwarn 1
$ qsub GROMACS.pbs

4b) Run 1_tau

$ cd ../1_tau
$ gmx grompp -f npt.mdp -c conf.gro -p topol.top -maxwarn 1
$ qsub GROMACS.pbs

4c) Run 10_tau

$ cd ../10_tau
$ gmx grompp -f npt.mdp -c conf.gro -p topol.top -maxwarn 1
$ qsub GROMACS.pbs

4d) Run 100_tau

$ cd ../100_tau
$ gmx grompp -f npt.mdp -c conf.gro -p topol.top -maxwarn 1
$ qsub GROMACS.pbs

4e) Temperature/Pressure analysis

The following commandss should be taken in each of the 
4 NPT subdirectories.

$ gmx energy -f ener.edr -o temperature.xvg
$ gmx energy -f ener.edr -o pressure.xvg

Plots should be generated as described in step 3c)
For tau T comparison plot, navigate to the NPT 
directory:

$ cd /suppscr/pfaendtner/youraddress/ensembles/NPT/

And run the following:

$ gnuplot
gnuplot > p "0.1_tau/temperature.xvg" u 1:2 w l, "1_tau/temperature.xvg" u 1:2 w l, "10_tau/temperature.xvg" u 1:2 w l, "100_tau/temperature.xvg" u 1:2 w l

Please contact me by Wednesday, 1/25, if you are having 
problems with the assignment after thoroughly reading
the intructions here and in HW3.txt. 

Happy simulating.
