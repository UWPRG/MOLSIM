# Final Project

Simulate a biphasic system (water/cyclohexane) with and without the
KALP<sub>15</sub> peptide. All files and commands can coincidentally be found at
 this [tutorial](http://www.mdtutorials.com/gmx/biphasic/index.html). Final
 presentations will be during the final class on March 15th.

<p align="center">
  <img src="peptide_chx.png" width="250">
</p>

## Project Instructions
1. Construct a box filled with water and cyclohexane.
2. Run classical MD on the biphasic system and observe the interface.
3. Calculate the average density (for water and cyclohexane separately) along
the z-axis for the production portion of the simulation (i.e., take small slices
 along the z-axis and calculate the density) and plot it as a function of z.
4. Repeat step 1, but add a KALP<sub>15</sub> peptide into the aqueous phase.
5. Run classical MD and observe how the peptide behaves.
6. Repeat steps 4-5, but with the peptide in the cyclohexane phase instead.

**Use VMD to create "publication ready" images of dominant peptide structures for
both simulations with the peptide.**

For Step 3, use the `MDTraj` python module, which can be installed by using
`conda install -c omnia mdtraj` or by following the instructions
[here](http://mdtraj.org/latest/installation.html)

## Presentation
- Outline each of the steps above (with VMD images) and explain the shape of the density profiles.

- Explain why you think the observed peptide configurations are dominant.

- Propose any further analysis that could be performed on this system to gain better insight into what is happening.

 **Duration: 8 minutes + 2 minutes for questions**

 ## Activating GROMACS on Hyak
 ...
