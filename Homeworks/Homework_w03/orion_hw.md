# Scaling Results

|Number of walkers |Nodes |MPI ranks/walker |OpenMP threads/rank |ns/day/walker |total ns/day |
| ----- | ----- | ----- | ----- | ----- | ----- |
|1 |1 |1 |1 | 1.452 | 1.452 |
|1 |1 |2 |1 | 2.826 | 2.826 |
|1 |1 |4 |1 | 5.400 | 5.400 |
|1 |1 |8 |1 | 10.057 | 10.057 |
|1 |1 |16 |1 | 18.149 | 18.149 |
|1 |1 |8 |2 | 17.257 | 17.257 |
|1 |1 |4 |4 | 17.073 | 17.073 |
|1 |1 |2 |8 | 16.675 | 16.675 |
|1 |1 |1 |16 | 17.128 | 17.128 |
|2 |1 |8 |1 | 9.554 | 19.107 |
|4 |1 |4 |1 | 4.967 | 19.867 |
|8 |1 |2 |1 | 2.221 | 17.767 |
|2 |2 |16 |1 | 18.094 | 36.188 |
|4 |2 |8 |1 | 9.543 | 38.173 |
|8 |2 |4 |1 | 4.960 | 39.678 |


# Analysis of Results

Increasing the MPI ranks from 1 to 16 at a constant OpenMP thread count of 1 proves that the system does scale with the number of cores. With a single node run with all 16 cores, the difference between the various combinations of walkers, MPI ranks and OpenMP threads was small with the best performance coming with 4 walkers each run with 4 MPI ranks and a single OpenMP thread. Doubling the number of MPI ranks per walker (such that 32 cores are used across 2 nodes) roughly doubles the speed of the computation. The fastest run conditions were with 8 walkers each run with 4 MPI ranks (39.678 total ns/day). Because the simulation scales linearly with the number of nodes up to 2, I would recommend using both nodes at the fastest conditions unless there's a computational time crunch elsewhere in the group. 
