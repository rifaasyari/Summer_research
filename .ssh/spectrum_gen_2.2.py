#!/usr/bin/env python
# coding: utf-8

# In[17]:


from matplotlib import pyplot as plt
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


# In[18]:


def get_bend(vertices, hole):
    # a pdms block with a si polygon
    geometry = [mp.Block(size = cell_size, material=mp.Medium(index=b_m)),
                mp.Prism(vertices, 
                         height=h, 
                         material=mp.Medium(index=c_m),
                         center=mp.Vector3())]
    # add hole index is the same as the block
    geometry.append(mp.Prism(hole, 
                             height=h, 
                             material=mp.Medium(index=b_m),
                             center=mp.Vector3()))
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

def data_generator(batch, ran):
    # data = []
    # get shape from 'data/DATAX_sh.txt'
    coordinates = np.genfromtxt('data/DATA'+str(batch)+'_sh.txt')
    xc, yc = coordinates[:, 0], coordinates[:, 1]
    size = len(xc) // shape_size
    xc = np.reshape(xc, (size, shape_size))
    yc = np.reshape(yc, (size, shape_size))
                    
    filt = []
    for i in ran:
        # form shape
        if i in filt:
            continue
        for scale in range(1, 3):
            vertices = [mp.Vector3(xc[i][0],yc[i][0])]
            hole = [mp.Vector3(xc[i][0] * (scale/3),yc[i][0] * (scale/3))]
            for j in range(1, len(xc[i]) - 1):
                # eliminate duplicate point
                if xc[i][j] == xc[i][j - 1] and yc[i][j] == yc[i][j - 1]:
                    continue
                vertices.append(mp.Vector3(xc[i][j], yc[i][j]))
                hole.append(mp.Vector3(xc[i][j] * (scale/3),yc[i][j] * (scale/3)))
                #print(xc[i][j], yc[i][j])

            # calculate transmission
            bend = get_bend(vertices, hole)
            Ts = []
            st = np.genfromtxt('data/straight.txt')
            for j in range(nfreq):
                Ts = np.append(Ts, bend[j]/st[j])
            #data.append(Ts)      
            print('\n Batch: ' + str(batch) + ' progress: '+ str(i + 1)+'/'+str(size))
            print('Hole Scale: ' + str(scale)+'/3\n')
            np.savetxt('data/DATA'+str(batch)+'_sp'+str(i)+'_s'+str(scale)+'-3.txt', Ts)
#             freq = np.genfromtxt('data/freq.txt')
#             plt.ylim(0, 1.1)
#             plt.plot(freq,Ts)
#             plt.show()  


# In[ ]:


batch = 2
ran = [x for x in range(7)]
data_generator(batch, ran)

