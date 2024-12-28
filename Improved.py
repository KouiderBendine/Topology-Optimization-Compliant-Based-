# This Code tested the aerodynamic performance of a NACA 0024
# Last Update : 12-02-2024
# Author: K. Bendine

"""Runs an XFOIL analysis for a given airfoil and flow conditions"""
import os
import subprocess
import numpy as np
import matplotlib.pyplot as plt

# Inputs
airfoil_name = "NACA0024"
alpha_i = -10
alpha_f = 20
alpha_step = 2
Re = 1000000
MAC=0.15
n_iter = 100
Xloc = 0.45
Yloc = 0
Degreee = [-10,-5,0,5,10,15,20]  # Airfoil Deflection Angel

# %% XFOIL input file writer
for Degree in Degreee:
    input_file = open(str(Degree)+"input_file.in", 'w')
    input_file.write("LOAD {0}.dat\n".format(airfoil_name))
    input_file.write(airfoil_name + '\n')
    input_file.write("GDES\n")
    input_file.write("flap\n")
    input_file.write(str(Xloc) + "\n")
    input_file.write(str(Yloc) + "\n")
    input_file.write(str(Degree) + "\n")
    input_file.write("exec\n")
    input_file.write("\n")
    input_file.write("PPAR\n")
    input_file.write("\n\n")
    input_file.write("PSAV " + str(Degree)+"Airfoil.txt\n\n")
    input_file.write("PANE\n")
    input_file.write("OPER\n")
    input_file.write("Visc {0}\n".format(Re))
    input_file.write("m {0}\n".format(MAC))
    input_file.write("PACC\n")
    input_file.write(str(Degree)+"polar_file.txt\n\n")
    input_file.write("ITER {0}\n".format(n_iter))
    input_file.write("ASeq {0} {1} {2}\n".format(alpha_i, alpha_f,
                                                 alpha_step))
    input_file.write("\n\n")
    input_file.write("quit\n")
    input_file.close()
    FileIN='xfoil.exe'+'<'+str(Degree)+'input_file.in'
    subprocess.call(FileIN, shell=True)
    #subprocess.call("xfoil.exe < input_file.in", shell=True)

if os.path.exists("polar_file.txt"):
    os.remove("polar_file.txt")



# Plot AOA vs CL
markers = ['o', 's', 'D', '*', 'x', '^', 'v', '<', '>', 'h', 'p']
fig = plt.figure(1)

cmap = plt.get_cmap("viridis")
for i, Degree in enumerate(Degreee, start=1):
    # Construct the input file name
    FileINn = str(Degree) + 'polar_file.txt'

    # Load polar data
    try:
        polar_data = np.loadtxt(FileINn, skiprows=12)
    except Exception as e:
        print(f"Error loading file '{FileINn}': {e}")
        continue

    # Get a unique color for each iteration
    color = cmap(i / len(Degreee))  # Normalize iteration index to [0, 1]

    marker = markers[i % len(markers)]  # Cycle through the list of markers

    # Plot CL vs AOA with unique marker and color
    plt.plot(
        polar_data[1:14, 0],
        polar_data[1:14, 1],
        linestyle='-',
        marker=marker,
        color=color,
        label=f'{Degree}\u00b0'
    )

# Add labels, legend, and title
plt.xlabel('Angle Of Attack')
plt.ylabel('CL')
#plt.title('AOA vs CL')
plt.legend()
plt.show()

# Plot AOA vs CD
fig = plt.figure(2)
cmap = plt.get_cmap("viridis")
for i, Degree in enumerate(Degreee, start=1):
    # Construct the input file name
    FileINn = str(Degree) + 'polar_file.txt'

    # Load polar data
    try:
        polar_data = np.loadtxt(FileINn, skiprows=12)
    except Exception as e:
        print(f"Error loading file '{FileINn}': {e}")
        continue

    # Get a unique color for each iteration
    color = cmap(i / len(Degreee))  # Normalize iteration index to [0, 1]
    marker = markers[i % len(markers)]
    # Plot CD vs AOA
    plt.plot(polar_data[1:14, 0], polar_data[1:14,  2],linestyle='-',
        marker=marker,
        color=color,
        label=f'{Degree}\u00b0')

# Add labels, legend, and title
plt.xlabel('Angle Of Attack')
plt.ylabel('CD')
#plt.title('AOA vs CD')
plt.legend()
plt.show()


# Plot AOA vs CD
fig = plt.figure(3)
cmap = plt.get_cmap("viridis")
for i, Degree in enumerate(Degreee, start=1):
    # Construct the input file name
    FileINn = str(Degree) + 'polar_file.txt'

    # Load polar data
    try:
        polar_data = np.loadtxt(FileINn, skiprows=12)
    except Exception as e:
        print(f"Error loading file '{FileINn}': {e}")
        continue

    # Get a unique color for each iteration
    color = cmap(i / len(Degreee))  # Normalize iteration index to [0, 1]
    marker = markers[i % len(markers)]
    # Plot CD vs AOA
    plt.plot(polar_data[1:14,  0], polar_data[1:14,  1]/polar_data[1:14, 2], linestyle='-',
        marker=marker,
        color=color,
        label=f'{Degree}\u00b0')

# Add labels, legend, and title
plt.xlabel('Angle Of Attack')
plt.ylabel('CL/CD')
#plt.title('AOA vs CL/CD')
plt.legend()
plt.show()

fig = plt.figure(4)
cmap = plt.get_cmap("viridis")
for i, Degree in enumerate(Degreee, start=1):
    # Load the data from the text file
    dataBuffer = np.loadtxt(str(Degree)+'Airfoil.txt', skiprows=3)
    # Extract data from the loaded dataBuffer array
    XB = dataBuffer[:, 0]
    YB = dataBuffer[:, 1]
    X_0 = dataBuffer[:, 0]
    Y_0 = dataBuffer[:, 1]

    # Delete file after loading
    # EXTRACT UPPER AND LOWER AIRFOIL DATA

    XB_U = XB[YB >= 0]
    XB_L = XB[YB < 0]
    YB_U = YB[YB >= 0]
    YB_L = YB[YB < 0]
    X_U = X_0[YB >= 0]
    X_L = X_0[YB < 0]
    color = cmap(i / len(Degreee))  # Normalize iteration index to [0, 1]

    plt.plot(XB_U[:], YB_U[:], color=color,        label=f'{Degree}\u00b0')
    plt.plot(XB_L[:], YB_L[:],  color=color)
    plt.ylim(-0.30,0.30)

plt.xlabel('X-Coordinate')
plt.ylabel('Y-Coordinate')
plt.legend()
plt.show()