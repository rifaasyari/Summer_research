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
S:AddLayerCopy('bottom', 0, 'top')

d = {0, math.random()}
c = {math.random(), math.random()}
b = {math.random(), math.random()}
a = {math.random(), 0}

quarter = {a, b, c, d}
symmetry = {{1, 1}, {-1, 1}, {-1, -1}, {1, -1}}
shape = {}

for i = 1, #symmetry, 1 do
    if i % 2 == 1 then
        for j = 1, #quarter, 1 do
            for k = 1, 2, 1 do
                table.insert(shape, quarter[j][k] * symmetry[i][k])
            end
        end
    else
        for j = #quarter, 1 , -1 do
            for k = 1, 2, 1 do
                table.insert(shape, quarter[j][k] * symmetry[i][k])
            end
        end
    end
end


for freq = 1/lamda3*period, 1/lamda1*period, 0.005 do

    S:SetFrequency(freq)
    --S:SetLayerPatternRectangle('slab', 'Silicon', {0, 0}, 0, {0.1, 0.1})
     S:SetLayerPatternPolygon('slab', 'Silicon', {0, 0}, 0, shape)
    --S:SetLayerPatternCircle('slab', 'Silicon', {0,0}, r)
    S:SetExcitationPlanewave({0, 0}, {1, 0}, {0, 0})

    forw, back = S:GetAmplitudes('top', 0)
    forw, h = S:GetAmplitudes('bottom', 0)

    print(freq, str_from_complex(forw[1]))

end
