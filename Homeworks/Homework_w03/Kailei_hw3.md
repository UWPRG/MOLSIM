# Homework - Week 3

|Number of walkers |Nodes |MPI ranks/walker |OpenMP threads/rank |ns/day/walker |total ns/day |
| ----- | ----- | ----- | ----- | ----- | ----- |
|1 |1 |1 |1 |1.460 |1.460|
|1 |1 |2 |1 |2.865 |2.865 |
|1 |1 |4 |1 |5.424 |5.424 |
|1 |1 |8 |1 |10.026 |10.026 |
|1 |1 |16 |1 |17.922 |17.922 |
|1 |1 |8 |2 |17.372 |17.372 |
|1 |1 |4 |4 |17.041 |17.041 |
|1 |1 |2 |8 |16.662 |16.662 |
|1 |1 |1 |16 |17.156 |17.156 |
|2 |1 |8 |1 |9.532 |19.065 |
|4 |1 |4 |1 |4.970 |19.878 |
|8 |1 |2 |1 |2.525 |20.199 |
|2 |2 |16 |1 |18.168 |36.337 |
|4 |2 |8 |1 |9.547 |38.189 |
|8 |2 |4 |1 |4.969 |39.749 |

## Analysis

Along with the increase of MPI ranks per walker, the system performance increase linearly. When the core number and number of walkers remain constant while OpenMP threads change, the performance are approximately same. If we keep the 16 cores unchanged but scale with various number of walkers, the system returns the best performance with 8 walkers and 2 ranks per walker. Also double the use of node increase the performance at approximate 2 times. So 8 walkers with 4 MPI is definitely the fastest combination. However, since the cost of using a second node may outweigh the advantage of saving time, I suggest to use the combination of 8 walkers with 2 MPI if not that urgent
