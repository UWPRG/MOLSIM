The error from the simulation is:
WARNING 1 [file topol.top, line 364]:

The bond in molecule-type Protein between atoms 5 C and 6 O has an estimated oscillational period of 2.3e-02 ps, which is less than 5 times the time step of 2.0e-02 ps.
Maybe you forgot to change the constraints mdp option.

The reason for getting this error is cause the dt= 0.02 is a huge timestep.  One of the explanations is that stable dynamics will be executed only if we use the smaller
time step compared to the period of the highest vibrational frequency of the molecule. If we can determine the biggest time step for a stable dynamics, it is expected that the efficiency of the molecular dynamics simulation will be maximized.
When choosing the time step, although the 1fs is normally used is molecular simulation, one can choose higher time step based on the bond oscilation length and calculate the minumum and maximum time step according to the mathimaticaL equations provided in the reference paper.


ref: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.597.5016&rep=rep1&type=pdf