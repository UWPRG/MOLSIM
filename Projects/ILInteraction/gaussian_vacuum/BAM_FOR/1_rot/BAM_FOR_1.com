%chk=BAM_FOR_1.chk
%nprocshared=2
# opt M062X/6-311+G* geom=connectivity

Title Card Required

0 1
 C(PDBName=C1,ResName=BAM,ResNum=1)                   -2.11315576   -0.83181451    0.11398377
 H(PDBName=H1,ResName=BAM,ResNum=1)                   -1.85474898   -1.84087161    0.35878922
 H(PDBName=H2,ResName=BAM,ResNum=1)                   -1.67421366   -0.56920784   -0.82583939
 H(PDBName=H3,ResName=BAM,ResNum=1)                   -3.17735147   -0.74212123    0.04808529
 C(PDBName=C2,ResName=BAM,ResNum=1)                   -1.58517061    0.11342476    1.20913417
 H(PDBName=H4,ResName=BAM,ResNum=1)                   -1.84357739    1.12248186    0.96432872
 H(PDBName=H5,ResName=BAM,ResNum=1)                   -2.02411271   -0.14918190    2.14895733
 C(PDBName=C3,ResName=BAM,ResNum=1)                   -0.05352445   -0.01566650    1.30397870
 H(PDBName=H6,ResName=BAM,ResNum=1)                    0.38541766    0.24694016    0.36415554
 H(PDBName=H7,ResName=BAM,ResNum=1)                    0.20488233   -1.02472360    1.54878415
 C(PDBName=C4,ResName=BAM,ResNum=1)                    0.47446071    0.92957277    2.39912911
 H(PDBName=H8,ResName=BAM,ResNum=1)                    0.03551861    0.66696610    3.33895227
 H(PDBName=H9,ResName=BAM,ResNum=1)                    0.21605393    1.93862987    2.15432366
 N(PDBName=N1,ResName=BAM,ResNum=1)                    1.93648659    0.80634929    2.48966253
 H(PDBName=H10,ResName=BAM,ResNum=1)                   2.27933409    1.42014103    3.20079915
 H(PDBName=H11,ResName=BAM,ResNum=1)                   2.17798825   -0.13669473    2.71845266
 H(PDBName=H12,ResName=BAM,ResNum=1)                   2.34671285    1.05177608    1.61132312
 C                                                     1.21069818    3.79448615    2.51758074
 H                                                     1.73743798    4.53940460    3.07663502
 O                                                     0.01111779    3.98562570    2.18888162
 O                                                     1.79079310    2.72726666    2.18879051

 1 2 1.0 3 1.0 4 1.0 5 1.0
 2
 3
 4
 5 6 1.0 7 1.0 8 1.0
 6
 7
 8 9 1.0 10 1.0 11 1.0
 9
 10
 11 12 1.0 13 1.0 14 1.0
 12
 13
 14 15 1.0 16 1.0 17 1.0
 15
 16
 17
 18 19 1.0 20 2.0 21 2.0
 19
 20
 21


