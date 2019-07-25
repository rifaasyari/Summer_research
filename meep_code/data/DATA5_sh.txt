#!/usr/bin/env python
# coding: utf-8

# In[7]:


#from matplotlib import pyplot as plt
import numpy as np
import math
import meep as mp
import cmath

shape_size = 48

sx, sy, sz = 1, 1, 4
h = 1.25
dpml = 0.5
b_m, c_m = 1.4, 3.54
res = 15
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

def get_trans(vertices):
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
    
    #get straight
    sim.reset_meep()
    geometry = [mp.Block(size = cell_size, material=mp.Medium(index=b_m))]
    pml_layers = [mp.PML(thickness= 1, direction = mp.Z, side=mp.High),
                  mp.Absorber(thickness=1,direction = mp.Z, side=mp.Low)]
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
    straight = mp.get_fluxes(trans)
    flux_freqs = mp.get_flux_freqs(trans)
    
    c = 300
    p = 0.6
    Ts = []
    for i in range(nfreq):
        Ts = np.append(Ts, bend[i]/straight[i])
    return np.multiply(flux_freqs, c/p),Ts


# In[8]:


def data_generator(batch):
    data = []
    # get shape from 'data/DATAX_sh.txt'
    coordinates = np.genfromtxt('data/DATA'+str(batch)+'_sh.txt')
    xc, yc = coordinates[:, 0], coordinates[:, 1]
    size = len(xc) // shape_size
    xc = np.reshape(xc, (size, shape_size))
    yc = np.reshape(yc, (size, shape_size))

    for i in range(size):
        # form shape
        vertices = [mp.Vector3(xc[i][0],yc[i][0])]
        for j in range(1, len(xc[i]) - 1):
            # eliminate duplicate point
            if xc[i][j] == xc[i][j - 1] and yc[i][j] == yc[i][j - 1]:
                continue
            vertices.append(mp.Vector3(xc[i][j], yc[i][j]))
        # calculate transmission
        _, Ts = get_trans(vertices)
        data.append(Ts)
    # save the spectrum to 'data/DATAX_sp.txt'
    np.savetxt('data/DATA'+str(batch)+'_sp.txt', data)
#     x = np.genfromtxt('data/SP_xaxis.txt')
#     y = np.genfromtxt('data/DATA'+str(batch)+'_sp.txt')
#     for i in range(size):
#         print('The '+str(i)+'th shape:')
#         plt.axis('equal')
#         plt.ylim(-0.5, 0.5)
#         plt.xlim(-0.5, 0.5)
#         plt.plot(xc[i], yc[i])
#         plt.fill(xc[i], yc[i])
#         plt.show()
#         plt.ylim(0, 1.1)
#         plt.plot(x, y[i])
#         plt.show()


# In[9]:


start, end = 5,6
for i in range(start, end):
    data_generator(i)

