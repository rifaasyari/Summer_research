pi = math.pi
deg = pi / 180
math.randomseed(os.time())


function str_from_complex(a)
      return string.format('%.4f %.4f', a[1], a[2])
--return string.format(a[1], a[2])
end

function polar_str_from_complex(a)
     local phase = math.atan2(a[1], a[2])
    if phase < 0 then
     phase = phase + 2*pi
end
-- return string.format('amp:%.4f, phase:%.4fdeg', math.sqrt(a[1]^2+a[2]^2), phase/deg)
--return string.format(math.sqrt(a[1]^2+a[2]^2), phase/deg)
--return string.format('amp:%.4f, phase:%.4fdeg', a[1]^2+a[2]^2, phase/deg)

--return string.format(a[1], a[2])
--return string.format(a[1])
return string.format(a[1], a[2])
--return string.format(phase/deg)

end

S = S4.NewSimulation()
ux = 1
uy = 0
vx = 0
vy = 1

S:SetLattice({ux,uy}, {vx,vy})

S:SetNumG(50)



lamda1=1;
lamda2=1.42;
lamda3=1.7;

n_PDMS=1.4^2;
--n_si=(-0.17/0.2*(lamda2-1.3)+3.626)^2;  --(3.626 at 1300, 3.54 at 1400, 3.49 at 1450, 3.45 at 1500, 3.36 at 1600 )
n_si=3.54^2;


S:AddMaterial('Vacuum', {1,0})
S:AddMaterial('Silicon', {n_si,0})
S:AddMaterial('PDMS', {n_PDMS,0})

period=600*10^-3;
h=750*10^-3;
h_relative=h/period;

S:AddLayer('top', 0, 'PDMS')
S:AddLayer('slab',h_relative , 'PDMS')
S:AddLayerCopy('bottom', 0, 'top')
--S:AddLayer('bottom', 0, 'Glass')

for r = 0.05/period, 0.255/period, 0.005/period do
for freq = 1/lamda3*period, 1/lamda1*period, 0.005 do

S:SetFrequency(freq)

S:SetLayerPatternCircle('slab', 'Silicon', {0,0}, r)

S:SetExcitationPlanewave({0, 0}, {1, 0}, {0, 0})

forw, back = S:GetAmplitudes('top', 0)
forw = S:GetAmplitudes('bottom', 0)

print(r, freq, str_from_complex(forw[1]))

end
end
