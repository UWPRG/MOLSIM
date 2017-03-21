%chk=PAM.chk
%nprocshared=2
# opt M062X/6-311+G* geom=connectivity

Title Card Required

0 2
 C(PDBName=C1,ResName=PAM,ResNum=1)                   -2.10600000   -0.79400000    0.07900000
 H(PDBName=H1,ResName=PAM,ResNum=1)                   -1.87000000   -1.82300000    0.34000000
 H(PDBName=H2,ResName=PAM,ResNum=1)                   -3.18700000   -0.71300000    0.12000000
 C(PDBName=C2,ResName=PAM,ResNum=1)                   -1.53000000    0.14400000    1.14700000
 H(PDBName=H3,ResName=PAM,ResNum=1)                   -1.77900000    1.17300000    0.89600000
 H(PDBName=H4,ResName=PAM,ResNum=1)                   -2.01000000   -0.07100000    2.09800000
 C(PDBName=C3,ResName=PAM,ResNum=1)                   -0.01000000    0.02000000    1.32000000
 H(PDBName=H5,ResName=PAM,ResNum=1)                    0.49500000    0.29400000    0.39800000
 H(PDBName=H6,ResName=PAM,ResNum=1)                    0.24700000   -1.01500000    1.53600000
 C(PDBName=C4,ResName=PAM,ResNum=1)                    0.48100000    0.91300000    2.44900000
 H(PDBName=H7,ResName=PAM,ResNum=1)                    0.05900000    0.64100000    3.40600000
 H(PDBName=H8,ResName=PAM,ResNum=1)                    0.28800000    1.95900000    2.26200000
 N(PDBName=N1,ResName=PAM,ResNum=1)                    1.98800000    0.78800000    2.60600000
 H(PDBName=H9,ResName=PAM,ResNum=1)                    2.34100000    1.37200000    3.35200000
 H(PDBName=H10,ResName=PAM,ResNum=1)                   2.25700000   -0.16400000    2.81300000
 H(PDBName=H11,ResName=PAM,ResNum=1)                   2.46800000    1.05600000    1.75800000
 C(PDBName=C5,ResName=PAM,ResNum=1)                   -1.63900000   -0.49900000   -1.34700000
 H(PDBName=H12,ResName=PAM,ResNum=1)                  -0.57400000   -0.66700000   -1.47600000
 H(PDBName=H13,ResName=PAM,ResNum=1)                  -2.15000000   -1.14300000   -2.05200000
 H(PDBName=H14,ResName=PAM,ResNum=1)                  -1.85300000    0.52900000   -1.62500000

 1 2 1.0 3 1.0 4 1.0 17 1.0
 2
 3
 4 5 1.0 6 1.0 7 1.0
 5
 6
 7 8 1.0 9 1.0 10 1.0
 8
 9
 10 11 1.0 12 1.0 13 1.0
 11
 12
 13 14 1.0 15 1.0 16 1.0
 14
 15
 16
 17 18 1.0 19 1.0 20 1.0
 18
 19
 20


