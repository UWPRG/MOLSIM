%chk=bmim-cl-4.chk
%nprocshared=8
# opt M062X/6-311+G* geom=connectivity

Title Card Required

0 1
 C                 -1.14716579    0.85199878    0.00435833
 C                  0.50471415    2.42075659    0.23179416
 C                 -1.42155304    2.10739289   -0.74419013
 H                  1.40343770    2.89004960    0.57378837
 H                 -1.96807333    2.23691108   -1.65492643
 H                 -1.82031481    0.13626040    0.42801972
 C                  0.93263043    0.14073224    1.14279397
 H                  1.99162164    0.29381925    1.14138736
 H                  0.52640057    0.46652951    2.07753107
 C                  0.63011090   -1.35631623    0.94549268
 H                 -0.42888031   -1.50940324    0.94689929
 H                  1.03634076   -1.68211350    0.01075558
 C                  1.26707968   -2.16412940    2.09148948
 H                  2.32607089   -2.01104239    2.09008288
 H                  0.86084981   -1.83833213    3.02622658
 C                  0.96456015   -3.66117787    1.89418820
 H                  1.37079001   -3.98697514    0.95945110
 H                  1.40712936   -4.22245066    2.69043273
 H                 -0.09443106   -3.81426488    1.89559480
 C                 -0.99283938    4.42309544    0.36521144
 H                 -1.67074908    4.83413079   -0.35339025
 H                 -1.46323733    4.39844427    1.32594974
 H                 -0.11340510    5.03063090    0.41416047
 N                  0.32461478    0.91182663    0.04888793
 N                 -0.62345261    3.05761705   -0.03469128
 Cl                -3.00667921    1.54625919   -0.61293367

 1 3 1.0 6 1.0 24 1.0
 2 4 1.0 24 1.0 25 2.0
 3 5 1.0 25 1.0
 4
 5
 6
 7 8 1.0 9 1.0 10 1.0 24 1.0
 8
 9
 10 11 1.0 12 1.0 13 1.0
 11
 12
 13 14 1.0 15 1.0 16 1.0
 14
 15
 16 17 1.0 18 1.0 19 1.0
 17
 18
 19
 20 21 1.0 22 1.0 23 1.0 25 1.0
 21
 22
 23
 24
 25
 26

