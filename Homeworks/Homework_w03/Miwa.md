| walkers | nodes | ranks/walker | threads/rank | ns/day/walker | ns/day |
|---------|-------|--------------|--------------|---------------|--------|
| 1       | 1     | 1            | 1            | 1.566         | 1.566  |
| 1       | 1     | 2            | 1            | 3.041         | 3.041  |
| 1       | 1     | 4            | 1            | 5.796         | 5.796  |
| 1       | 1     | 8            | 1            | 10.769        | 10.769 |
| 1       | 1     | 16           | 1            | 19.563        | 19.563 |
| 1       | 1     | 8            | 2            | 18.274        | 18.274 |
| 1       | 1     | 4            | 4            | 18.098        | 18.098 |
| 1       | 1     | 2            | 8            | 17.448        | 17.448 |
| 1       | 1     | 1            | 16           | 18.275        | 18.275 |
| 2       | 1     | 8            | 1            | 10.234        | 20.468 |
| 4       | 1     | 4            | 1            | 5.322         | 21.291 |
| 8       | 1     | 2            | 1            | 2.721         | 21.767 |
| 2       | 2     | 16           | 1            | 11.075        | 22.215 |
| 4       | 2     | 8            | 1            | 6.373         | 35.492 |
| 8       | 2     | 4            | 1            | 4.105         | 32.841 |

I would recommend the 4 walkers with 2 nodes, 8 ranks/walker, and 1 thread/rank. This had by far the most ns/day othre than the very last option. It's possible the very last option might be better depending on the conditions though. Since they use the same number of nodes it might be worth trying either of them. 

I would NOT recommend the first or second options, or eight walkers with one node option. Out of all three, the very first one is the worst and not even worth considering. It almost took 8 hours. 
