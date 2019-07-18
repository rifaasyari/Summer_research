pi = math.pi
deg = pi / 180
math.randomseed(os.time())


function str_from_complex(a)
    return string.format('%.4f %.4f', a[1], a[2])
end

function polar_str_from_complex(a)
    local phase = math.atan2(a[1], a[2])
    if phase < 0 then
        phase = phase + 2*pi
    end
end

S = S4.NewSimulation()
ux = 1
uy = 0
vx = 0
vy = 1

S:SetLattice({ux,uy}, {vx,vy})
S:SetNumG(100)
S:UsePolarizationDecomposition()

lamda1=1;
lamda2=1.42;
lamda3=1.7;

n_PDMS=1.4^2;
n_si=3.54^2;

S:AddMaterial('Vacuum', {1,0})
S:AddMaterial('Silicon', {n_si,0})
S:AddMaterial('PDMS', {n_PDMS,0})

period=600*10^-3;
h=750*10^-3;
h_relative=h/period;

S:AddLayer('top', 0, 'PDMS')
S:AddLayer('slab',h_relative , 'PDMS')
S:AddLayer('bottom', 0, 'PDMS')
S:SetLayerPatternPolygon('slab', 'Silicon', {0, 0}, 0, {
0.24270509831248, 0.17633557568774,
0.28284271247462, 0.28284271247462,
0.17633557568774, 0.24270509831248,
-0.17633557568774, 0.24270509831248,
-0.28284271247462, 0.28284271247462,
-0.24270509831248, 0.17633557568774,
-0.24270509831248, -0.17633557568774,
-0.28284271247462, -0.28284271247462,
-0.17633557568774, -0.24270509831248,
0.17633557568774, -0.24270509831248,
0.28284271247462, -0.28284271247462,
0.24270509831248, -0.17633557568774})

S:SetExcitationPlanewave({0, 0}, {1, 0}, {0, 0})

    for freq = 1/lamda3*period, 1/lamda1*period, 0.001 do

        S:SetFrequency(freq)


        forw, back = S:GetPowerFlux('top', 0)
        forw = S:GetPowerFlux('bottom', 0)

        print(freq, forw)

    end
