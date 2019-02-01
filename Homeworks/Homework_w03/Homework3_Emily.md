# Homework - Week 3

Simulations still running/unable to see jobs. I will input numbers when simulations finish.

|Number of walkers |Nodes |MPI ranks/walker |OpenMP threads/rank |ns/day/walker |total ns/day |
| ----- | ----- | ----- | ----- | ----- | ----- |
|1 |1 |1 |1 | ?| ?|
|1 |1 |2 |1 | ?| ?|
|1 |1 |4 |1 | ?| ?|
|1 |1 |8 |1 | ?| ?|
|1 |1 |16 |1 | ?| ?|
|1 |1 |8 |2 | ?| ?|
|1 |1 |4 |4 | ?| ?|
|1 |1 |2 |8 | ?| ?|
|1 |1 |1 |16 | ?| ?|
|2 |1 |8 |1 | ? | ?|
|4 |1 |4 |1 | ? | ?|
|8 |1 |2 |1 | ? | ?|
|2 |2 |16 |1 | ? | ?|
|4 |2 |8 |1 | ? | ?|
|8 |2 |4 |1 | ? | ?|

I recommend not trying to script the entire set of simulations into a single run, unless you feel very comfortable with bash coding. I would just run all of the simulations with `-ntomp 1`, and then move to the set of simulations where `-ntomp` is changing as `-n` changes.
