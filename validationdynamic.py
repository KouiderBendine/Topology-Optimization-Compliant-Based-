import numpy as np
import matplotlib.pyplot as plt
Vali=np.loadtxt('Validation.txt')
ValX=np.loadtxt('ValidationX.txt')
ValY=np.loadtxt('ValidationY.txt')
ValEPY=np.loadtxt('ValidationExpY.txt')
S=1e-1*np.array([
    0,
4.504504505,
10.6981982,
12.10585586,
13.51351351,
15.2027027,
16.32882883,
19.70720721,
26.7454955,
34.90990991,
40.54054054,
42.51126126,
43.63738739,
44.48198198,
44.48198198,
45.04504505,
45.60810811,
46.17117117,
46.4527027,
47.86036036,
53.77252252,
58.27702703,
62.5,
66.15990991,
68.41216216,
70.94594595,
73.1981982,
76.57657658,
78.82882883,
88.11936937,
97.12837838,
110.6418919,
112.8941441,
114.0202703,
114.8648649,
116.2725225,
116.5540541,
117.6801802,
119.0878378,
125])
## Deflection Experiment
S1=np.array([
-0.156950673,
-0.044843049,
-0.044843049,
-3.744394619,
-7.780269058,
-12.26457399,
-14.17040359,
-15.96412556,
-17.30941704,
-17.53363229,
-17.42152466,
-11.367713,
-6.771300448,
-2.286995516,
1.30044843,
5,
9.147982063,
12.73542601,
16.88340807,
21.367713,
26.74887892,
19.79820628,
12.95964126,
7.130044843,
2.757847534,
-1.726457399,
-5.650224215,
-11.59192825,
-15.51569507,
-16.74887892,
-17.30941704,
-17.19730942,
-9.798206278,
-1.278026906,
5,
10.2690583,
14.30493274,
18.90134529,
22.82511211,
26.41255605])

fig = plt.figure(1)
plt.plot(10*S, S1,label='Experiment')
#plt.plot(Vali[:,0], Vali[:,1],'k-*')
#plt.plot(Vali[:,0], Vali[:,2],'b-*')
plt.plot(10*ValX[:,0], 1e3*ValX[:,1],'r',label='Numerical Model')
plt.ylabel('Y Deflection [mm]', fontsize=14)
plt.xlabel('Steps', fontsize=14)
plt.legend()
plt.show()

fig = plt.figure(2)
#plt.plot(10*Vali[:,0], 1e3*Vali[:,1],'k-*')
#plt.plot(10*Vali[:,0], 1e3*Vali[:,2],'b-*')
plt.plot(ValEPY[:,0], ValEPY[:,1],label='Experiment')
plt.plot(ValY[:,0], ValY[:,1],'r',label='Numerical Model')
plt.ylabel('X Deflection [mm]', fontsize=14)
plt.xlabel('Steps', fontsize=14)
plt.legend()
plt.show()