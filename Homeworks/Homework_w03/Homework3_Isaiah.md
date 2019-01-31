| Number of walkers | Nodes | MPI ranks/walker | OpenMP threads/rank | ns/day/walker | total ns/day |
|-------------------|-------|------------------|---------------------|---------------|--------------|
| 1                 | 1     | 1                | 1                   | 1.455         | 1.455        |
| 1                 | 1     | 2                | 1                   | 2.866         | 2.866        |
| 1                 | 1     | 4                | 1                   | 5.479         | 5.479        |
| 1                 | 1     | 8                | 1                   | 9.984         | 9.984        |
| 1                 | 1     | 16               | 1                   | 18.124        | 18.124       |
| 1                 | 1     | 8                | 2                   | 17.315        | 17.315       |
| 1                 | 1     | 4                | 4                   | 17.088        | 17.088       |
| 1                 | 1     | 2                | 8                   | 16.608        | 16.808       |
| 1                 | 1     | 1                | 16                  | 17.192        | 17.192       |
| 2                 | 1     | 8                | 1                   | 9.592         | 19.184       |
| 4                 | 1     | 4                | 1                   | 4.966         | 19.864       |
| 8                 | 1     | 2                | 1                   | 2.536         | 20.288       |
| 2                 | 2     | 16               | 1                   | 17.938        | 35.876       |
| 4                 | 2     | 8                | 1                   | 9.562         | 38.248       |
| 8                 | 2     | 4                | 1                   | 4.968         | 39.744       |


The best combination of nodes/walkers/ranks/threads for this simulation depends on our goals. If we only care about the trajectory, 
we should run one walker with 16 ranks and one thread per walker. This produces the overall fastest time/day/walker at 18.124ns.
If we care about raw ns simulated per day, the best results come from 8 walkers, 2 ranks per walker, and one thread per rank on one node at
20.288ns/day, and 8 walkers, 4 ranks per walker, and one thread per rank on two nodes at 39.744 ns/day. Since the run time scales ~linearly 
from one node to two node, there's no concern about efficiency drop off. If the resources are available, the two node run is the favorable choice.
