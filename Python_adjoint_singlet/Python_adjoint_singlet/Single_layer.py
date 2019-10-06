import meep as mp
import numpy as np
from meep import mpb
import h5py
import cmath
import math

period_1 = 0.3 #the space between each rod and used to normalize most values
#dimensions of the cel size : x,y,z
sx = 2*int(50 / period_1/2)+1 #odd number
sy = int(20 / period_1) #30
n_rows = 2*int(sy/2) - 1 # Odd number the number of rows you need to duplicate the rods

resolution = 10

f = 50/period_1
fsquared = f**2

z_1 = 15 #80
dpml = 1.5 #thickness of pml boundary_layers
sx_source = sx - 2 #x direction size of the light source on x
sy_source = sy - 2 # "" but y direction

n = 3.547 #refractive index for epsilon square the values
freq = 1 / (1.180 / period_1) #frequency of the light source

n_PDMS = 1.4 #the index of the outside space of the rods
h = 0.75 / period_1 #the height of each rod normalized
deta = 0 #-30 #the Z position of every rod in the bottom layer
size_involume = h
Z_involume_bottom = deta #center of Z_involume
# size of the PDMS white boundary
deta_pdms_beginZ = 0
sz_PDMS = z_1
sx_PDMS = sx
sy_PDMS = sy

deta_sourceZ_forw = deta - 3
deta_sourceZ_back = deta + 3

cell = mp.Vector3(sx,sy,z_1)

filelist = []
floatlist = []
#open file f transfer int values to a list_f and then close file f
with open("Lens_layer1.txt", "r+") as f:
    numbers = f.read()
    filelist = numbers.split()
    for i in range(len(filelist)):
            floatlist.append(float(filelist[i]))
    f.close()

num = len(floatlist)
#length of list_f

geometry = [mp.Block(center = mp.Vector3(0,0,deta_pdms_beginZ), size = mp.Vector3(sx_PDMS, sy_PDMS, sz_PDMS), material = mp.Medium(index = n_PDMS))]

for i in range(num):
    geometry.append(mp.Block(center = mp.Vector3(((-(num-1)/2)+i), -(n_rows-1)/2, deta), size = mp.Vector3(1,1,h), material = mp.Medium(epsilon = floatlist[i]))) # defining the cylinders and duplicating them into g list

geometry = mp.geometric_objects_duplicates((mp.Vector3(0,1,0)), 0, n_rows, geometry)

pml_layers = [mp.PML(dpml)]

fcen = freq
df = 0.1
k = 2 * (math.pi) * fcen

def pw_amp(y):
    def lens_factor(k):
        v2 = k
        return cmath.exp(1j*y*(math.sqrt((v2[0] * v2[0] + fsquared))))
    return lens_factor

sources_forw = [mp.Source(mp.ContinuousSource(frequency = freq), component = mp.Ey,
center = mp.Vector3(0,0,deta_sourceZ_forw), size = mp.Vector3(sx_source, sy_source,0))]

sources_back = [mp.Source(mp.ContinuousSource(frequency = freq), component = mp.Ey,
center = mp.Vector3(0,0,deta_sourceZ_back), size = mp.Vector3(sx_source, sy_source,0), amp_func = pw_amp(k))]

symmetries = [mp.Mirror(mp.Y, phase = -1), mp.Mirror(mp.X)]

sim_forw = mp.Simulation(cell_size = cell, boundary_layers = pml_layers,
geometry = geometry, sources = sources_forw, resolution = resolution, force_complex_fields = True, symmetries = symmetries)

sim_back = mp.Simulation(cell_size = cell, boundary_layers = pml_layers,
geometry = geometry, sources = sources_back, resolution = resolution, force_complex_fields = True, symmetries = symmetries)

#sim.use_output_directory()
sim_forw.run(until = 30)#30
sim_back.run(until = 30)#30


ez_data_forw = sim_forw.get_array(center=mp.Vector3(0,0, deta), size=mp.Vector3(sx,sy,h), component=mp.Ey)
ez_data_back = sim_back.get_array(center=mp.Vector3(0,0, deta), size=mp.Vector3(sx,sy,h), component=mp.Ey)

'''
forw_field_1 = sim_forw.get_array(center=mp.Vector3(0,0, deta_sourceZ_back), size=mp.Vector3(sx,sy,0.1), component=mp.Ey)

forw_field_real=np.real(forw_field_1[:,:,1])
forw_field_imag=np.imag(forw_field_1[:,:,1])
np.savetxt('forw_field_real.txt', forw_field_real)
np.savetxt('forw_field_imag.txt', forw_field_imag)
'''

#--------------------
#----------------------------Data processing part--------------------
import os
[m_x,m_y,m_z]=(ez_data_forw.shape)

mul_array = np.multiply(ez_data_forw, ez_data_back)
summed = np.sum(mul_array, axis = 2)
real_sum = summed.real

real_sum_reduced=np.zeros((len(range(0,m_x,resolution)), len(range(0,m_y,resolution))))

for i in range(0,m_x,resolution):
 for j in range(0,m_y,resolution):
  real_sum_reduced[int(i/resolution),int(j/resolution)]=sum(sum(real_sum[i:i+resolution,j:j+resolution]))

np.savetxt('real_sum_reduced.txt', real_sum_reduced)

#how to get the y axis value of mul_array.shape
[x_size, y_size] = (real_sum_reduced.shape)
permitivity_change = real_sum_reduced[:,int(y_size/2)]

C=0.015
Updated_permitivity = floatlist + permitivity_change*C

for i in range(0,x_size):
 if Updated_permitivity[i]<n_PDMS**2:
     Updated_permitivity[i]=n_PDMS**2

fileID = open("Lens_layer1.txt", "w+")
np.savetxt("Lens_layer1.txt", Updated_permitivity)
fileID.close()
