import math

pi = math.pi
deg = pi / 180

def str_from_complex(a):
	s = str[1] + "\t" + str(a[2])
	return s

def polar_str_from_complex(a):
	phase = math.atan2(a[1], a[2])
	if phase < 0:
		phase += 2*pi
	res = str(a[1]) +" " + str(a[2])
	return res

ux = 1
uy = 0
vx = 0
vy = 1

S = s4.NewSimulation(Lattice = ((ux, uy), (vx, vy)), NumBasis = 50)

lamda1=1
lamda2=1.42
lamda3=1.7


n_PDMS=1.4**2
n_si=3.54**2

S.SetMaterial(Name = 'Vacuum', Epsilon = ((1, 0)))
S.SetMaterial(Name = 'Silicon', Epsilon = ((n_si, 0)))
S.SetMaterial(Name = 'PDMS', Epsilon = ((n_PDMS, 0)))

period = 600*1e-3
h = 750*1e-3
h_relative = h/period

S.AddLayer('top', 0, 'PDMS')
S.AddLayer('slab',h_relative , 'PDMS')
S.AddLayerCopy('bottom', 0, 'top')

for r in range(0.05/period, 0.255/period, 0.005/period):
	for freq in range(1/lamda3*period, 1/lamda1*period, 0.005):
		S.SetFrequency(freq)
		S.SetRegionCircle('slab', 'Silicon', (0,0), r)
		S.SetExcitationPlanewave((0, 0), (1, 0), (0, 0))
		forw, back = S.GetAmplitudes('top', 0)
		forw, _ = S.GetAmplitudes('bottom', 0)
		print(r, freq, str_from_complex(forw[1]))

