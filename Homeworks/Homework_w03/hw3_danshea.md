# Homework - Week 3

## Summary Table

|Number of walkers |Nodes |MPI ranks/walker |OpenMP threads/rank |ns/day/walker |total ns/day |
| ----- | ----- | ----- | ----- | ----- | ----- |
|1 |1 |1 |1 | 1.454| 1.454|
|1 |1 |2 |1 | 2.857| 2.857|
|1 |1 |4 |1 | 5.402| 5.402|
|1 |1 |8 |1 | 9.984| 9.984|
|1 |1 |16 |1 | 18.136| 18.136|
|1 |1 |8 |2 | 17.307| 17.307|
|1 |1 |4 |4 | 17.14| 17.14|
|1 |1 |2 |8 | 16.637| 16.637|
|1 |1 |1 |16 | 17.206| 17.206|
|2 |1 |8 |1 | 9.552 | 19.103|
|4 |1 |4 |1 | 4.980 | 19.919|
|8 |1 |2 |1 | 2.535 | 20.282|
|2 |2 |16 |1 | 18.118 | 36.236|
|4 |2 |8 |1 | 9.579 | 38.315|
|8 |2 |4 |1 | 4.975 | 39.803|
|16 |2 |2 |1 | 2.537 | 40.596|

## Optimal Choice
The overall fastest parallel computing scheme, in cumulative ns/day, is achieved by using 2 MPI ranks/walker and 16 total walkers.

It's worth noting that using multiple walkers and at least 2 MPI ranks per walker result in similar performance (as measured in cumulative ns/day). Thus, if 8 walkers is excessive for the application, similar results can be achieved with as few as 2 walkers as long as (# walkers * MPI ranks/walker) maximizes the number of cores on the given nodes (16 cores for 1 node).

The performance scales approximately linearly with two nodes (compared to one), so if results are required ASAP, this can be scaled well to two nodes.

## Other Comments
Similar results can be achieved in all single-walker cases where the node use is maximized (16 cores) no matter how the parallelization is performed (MPI or OpenMP). However, multiple walkers are the most significant improvement 

