# HW_3 Sabiha

# Results table:

|Number of walkers |Nodes |MPI ranks/walker |OpenMP threads/rank |ns/day/walker |total ns/day |
| ----- | ----- | ----- | ----- | ----- | ----- |
|1 |1 |1 |1 | 1.452 | 1.452 |
|1 |1 |2 |1 | 2.845 | 2.845 |
|1 |1 |4 |1 | 5.387 | 5.387 |
|1 |1 |8 |1 | 9.971 | 9.971 |
|1 |1 |16 |1 | 18.069 | 18.069 |
|1 |1 |8 |2 | 17.325 | 17.325 |
|1 |1 |4 |4 | 17.137 | 17.137 |
|1 |1 |2 |8 | 16.587 | 16.587 |
|1 |1 |1 |16 | 17.237 | 17.237 |
|2 |1 |8 |1 | 9.569 | 19.139 |
|4 |1 |4 |1 | 4.976 | 19.867 |
|8 |1 |2 |1 | 2.221 | 17.767 |
|2 |2 |16 |1 | 18.110 | 36.220 |
|4 |2 |8 |1 | 9.646 | 38.584 |
|8 |2 |4 |1 | 4.970 | 39.760 |


# Analizing:

Overall, when compare choces in single node, system doesn't scale well with changing only varieng the OpenMP thread per process. Actually Using 16 MPI processes, using 1 OpenMP thread per MPI process gave the best performance without adjustin number of walkers. When also changing the number of walkers, the best performance is when use 4 walkers each run with 4 MPI ranks and a single OpenMP thread.However there is no very significant differences among varient walker numbers. Doubling the number of nodes, roughly doubles the speed of the computation. But you are also doubling the resorces you are using.So this is not a optimal parameter to choose. The performace doubled with doubling the number of nodes, but this might not be the case in other situation. I would suggest not to use 2 nodes,or multiple nodes, unless you are really struggling to meet the deadline. ( for everyones sake!) 
