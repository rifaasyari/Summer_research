#!/usr/bin/env python
# coding: utf-8

# In[6]:


#from matplotlib import pyplot as plt
import numpy as np
import os.path
shape_size = 48
#freq = np.genfromtxt('data/freq.txt')
def spec(batch, ran):
    path = 'data/DATA'+str(batch)+'/DATA'+str(batch)+'_sp'
    miss = []
    for i in ran:
        if not os.path.exists(path+str(i)+'.txt'):
            miss.append(i)
    return miss

import meep as mp
import math
import cmath

shape_size = 48
sx, sy, sz = 1, 1, 4
h = 1.25
dpml = 0.5
b_m, c_m = 1.4, 3.54
res = 27
echo = 1000
cell_size = mp.Vector3(sx,sy,sz)
fcen = 0.5
df = 0.2
theta = math.radians(0)
nfreq = 200

# k with correct length (plane of incidence: XZ) 
k = mp.Vector3(math.sin(theta),0,math.cos(theta)).scale(fcen)
def pw_amp(k, x0):
    def _pw_amp(x):
        return cmath.exp(1j * 2 * math.pi * k.dot(x + x0))
    return _pw_amp

def get_spec(batch, index):
    b = np.genfromtxt('data/DATA'+str(batch) +'_sh.txt')
    start = index * shape_size
    xc = b[start:start + shape_size, 0]
    yc = b[start:start + shape_size, 1]
    vertices = [mp.Vector3(xc[0],yc[0])]

    for j in range(1, len(xc) - 1):
        # eliminate duplicate point
        if xc[j] == xc[j - 1] and yc[j] == yc[j - 1]:
            continue
        vertices.append(mp.Vector3(xc[j], yc[j]))
        #print(xc[i][j], yc[i][j])
    # calculate transmission
    bend = get_bend(vertices)
    Ts = []
    st = np.genfromtxt('data/straight.txt')
    for j in range(nfreq):
        Ts = np.append(Ts, bend[j]/st[j])
    return Ts
#     plt.axis('equal')
#     plt.ylim(-0.5, 0.5)
#     plt.xlim(-0.5, 0.5)
#     plt.plot(x, y)
#     plt.fill(x, y)
#     plt.show()
def get_bend(vertices):
    geometry = [mp.Block(size = cell_size, material=mp.Medium(index=b_m)),
                mp.Prism(vertices, 
                         height=h, 
                         material=mp.Medium(index=c_m),
                         center=mp.Vector3()
                        )]
    pml_layers = [mp.PML(thickness=1, direction = mp.Z, side=mp.High),
                  mp.Absorber(thickness=1,direction = mp.Z, side=mp.Low)]
    src_pos = -(sz/2 - dpml - 0.5)
    src = [mp.Source(src = mp.GaussianSource(fcen, fwidth=df),
                     component = mp.Ey,
                     center = mp.Vector3(0,0,src_pos),
                     size = mp.Vector3(sx,sy,0),
                     amp_func=pw_amp(k,mp.Vector3(0,0,src_pos)))]
    sim = mp.Simulation(resolution=res,
                        cell_size=cell_size,
                        boundary_layers=pml_layers,
                        sources=src,
                        geometry=geometry,
                        k_point=k)
    freg = mp.FluxRegion(center=mp.Vector3(0,0,-src_pos),
                         size = mp.Vector3(sx,sy,0))
    trans = sim.add_flux(fcen, df, nfreq, freg)
    sim.run(until = echo)
    bend = mp.get_fluxes(trans)
    return bend


# In[ ]:


batch = 62
ran = [i for i in range(272)]
miss = spec(batch, ran)
#freq = np.genfromtxt('data/freq.txt')
for i in ran:
    
    path = 'data/DATA'+str(batch)+'/DATA'+str(batch)+'_sp'
    if i in miss:
        print('Batch: '+str(batch)+ ' sample: '+str(i))
        Ts = get_spec(batch,i)
        np.savetxt(path +str(i)+'.txt', Ts)
        #Ts = np.genfromtxt(path +str(i)+'.txt')
        #plt.ylim(0, 1.1)
        #plt.plot(freq, Ts)
        #plt.show()

