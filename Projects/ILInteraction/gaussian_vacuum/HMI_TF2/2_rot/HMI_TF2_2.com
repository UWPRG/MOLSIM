%chk=HMI_TF2_2.chk
%nprocshared=16
# opt 6-311+g(d) geom=connectivity m062x

Title Card Required

0 1
 N(PDBName=N1,ResName=TF2,ResNum=1)                    0.00008600    0.21342700    0.00083500
 S(PDBName=S1,ResName=TF2,ResNum=1)                   -1.42508100   -0.68198500   -0.28066500
 S(PDBName=S2,ResName=TF2,ResNum=1)                    1.42502600   -0.68195200    0.28061000
 O(PDBName=O1,ResName=TF2,ResNum=1)                   -1.48920400   -0.90765700   -1.69542600
 O(PDBName=O2,ResName=TF2,ResNum=1)                   -1.58716700   -1.70961800    0.70454900
 O(PDBName=O3,ResName=TF2,ResNum=1)                    1.48992800   -0.90867200    1.69520800
 O(PDBName=O4,ResName=TF2,ResNum=1)                    1.58664700   -1.70904000   -0.70530100
 C(PDBName=C1,ResName=TF2,ResNum=1)                   -2.61205600    0.69456900    0.14216500
 C(PDBName=C2,ResName=TF2,ResNum=1)                    2.61200600    0.69457100   -0.14205500
 F(PDBName=F1,ResName=TF2,ResNum=1)                   -3.83135200    0.21682900   -0.00720500
 F(PDBName=F2,ResName=TF2,ResNum=1)                   -2.41845400    1.06473100    1.39085400
 F(PDBName=F3,ResName=TF2,ResNum=1)                   -2.42137400    1.71139300   -0.66982400
 F(PDBName=F4,ResName=TF2,ResNum=1)                    2.42274700    1.71062900    0.67128700
 F(PDBName=F5,ResName=TF2,ResNum=1)                    2.41700600    1.06620500   -1.39011300
 F(PDBName=F6,ResName=TF2,ResNum=1)                    3.83131200    0.21621900    0.00523700
 C                                                     0.30383779   -5.19959938   -0.04835617
 C                                                    -0.74758921   -4.36407438    0.04898183
 C                                                     0.18996679   -4.03236938   -1.98340617
 N                                                     0.81881579   -5.12246038   -1.33866417
 H                                                     0.70146879   -5.89466438    0.67510183
 H                                                    -1.42761421   -4.20345738    0.87064083
 H                                                     0.02823079   -4.11457038   -3.05959417
 N                                                    -0.93330521   -3.73409038   -1.17862917
 C                                                     2.19976779   -5.45955238   -1.63683717
 H                                                     2.29954079   -5.50473338   -2.72561917
 H                                                     2.38980979   -6.46881838   -1.25749817
 C                                                     3.20763479   -4.46984038   -1.05461017
 H                                                     3.11635879   -4.47059138    0.03796283
 H                                                     2.93486379   -3.46370238   -1.38912917
 C                                                     4.64011579   -4.79935238   -1.46083317
 H                                                     4.88260179   -5.82855338   -1.16589217
 H                                                     4.72503779   -4.76848638   -2.55430217
 C                                                     5.66519079   -3.84763038   -0.84968417
 H                                                     5.41486679   -2.81675638   -1.12888417
 H                                                     5.59405379   -3.89133838    0.24419883
 C                                                     7.09883579   -4.15336838   -1.27527917
 H                                                     7.34420779   -5.18679238   -1.00528717
 H                                                     7.17108279   -4.09814238   -2.36729317
 C                                                     8.11238479   -3.20304038   -0.64450117
 H                                                     9.13230379   -3.43156038   -0.96077117
 H                                                     7.90207879   -2.16633338   -0.92097617
 H                                                     8.08068279   -3.26482938    0.44661483
 C                                                    -1.56626921   -2.43768938   -1.28321517
 H                                                    -2.47689221   -2.42783338   -0.68298617
 H                                                    -0.89548521   -1.63761838   -0.94656517
 H                                                    -1.83700521   -2.25024138   -2.32307817

 1 2 1.0 3 1.0
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
 16 17 2.0 19 1.0 20 1.0
 17 21 1.0 23 1.0
 18 19 1.0 22 1.0 23 1.0
 19 24 1.0
 20
 21
 22
 23 43 1.0
 24 25 1.0 26 1.0 27 1.0
 25
 26
 27 28 1.0 29 1.0 30 1.0
 28
 29
 30 31 1.0 32 1.0 33 1.0
 31
 32
 33 34 1.0 35 1.0 36 1.0
 34
 35
 36 37 1.0 38 1.0 39 1.0
 37
 38
 39 40 1.0 41 1.0 42 1.0
 40
 41
 42
 43 44 1.0 45 1.0 46 1.0
 44
 45
 46


