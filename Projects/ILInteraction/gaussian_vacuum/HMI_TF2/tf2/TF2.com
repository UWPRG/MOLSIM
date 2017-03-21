%chk=TF2.chk
%nprocshared=16
# opt M062X/6-311+G* geom=connectivity

Title Card Required

0 2
 N(PDBName=N1,ResName=TF2,ResNum=1)                   -0.32800000    0.53200000    1.56700000
 S(PDBName=S1,ResName=TF2,ResNum=1)                   -1.28800000   -0.37000000    0.69500000
 S(PDBName=S2,ResName=TF2,ResNum=1)                   -0.76000000    1.38700000    2.80900000
 O(PDBName=O1,ResName=TF2,ResNum=1)                   -1.96400000   -1.41000000    1.41200000
 O(PDBName=O2,ResName=TF2,ResNum=1)                   -2.03100000    0.35000000   -0.29700000
 O(PDBName=O3,ResName=TF2,ResNum=1)                    0.08200000    2.53700000    2.93500000
 O(PDBName=O4,ResName=TF2,ResNum=1)                   -2.17500000    1.54300000    2.96500000
 C(PDBName=C1,ResName=TF2,ResNum=1)                    0.00700000   -1.23000000   -0.24500000
 C(PDBName=C2,ResName=TF2,ResNum=1)                   -0.26100000    0.35600000    4.22300000
 F(PDBName=F1,ResName=TF2,ResNum=1)                   -0.57300000   -2.07000000   -1.08100000
 F(PDBName=F2,ResName=TF2,ResNum=1)                    0.73800000   -0.39900000   -0.95000000
 F(PDBName=F3,ResName=TF2,ResNum=1)                    0.80000000   -1.92200000    0.54000000
 F(PDBName=F4,ResName=TF2,ResNum=1)                    1.03000000    0.10800000    4.19700000
 F(PDBName=F5,ResName=TF2,ResNum=1)                   -0.90000000   -0.78800000    4.23800000
 F(PDBName=F6,ResName=TF2,ResNum=1)                   -0.53000000    0.99200000    5.34600000

 1 2 1.5 3 1.5
 2 4 2.0 5 2.0 8 1.0
 3 6 2.0 7 2.0 9 1.0
 4
 5
 6
 7
 8 10 1.0 11 1.0 12 1.0
 9 13 1.0 14 1.0 15 1.0
 10
 11
 12
 13
 14
 15


