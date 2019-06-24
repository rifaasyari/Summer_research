------------------------------- Global Variables -------------------------------
lamda1=1;
lamda2=1.42;
lamda3=1.5;

n_PDMS=1.4^2;
n_si=3.54^2;

S = S4.NewSimulation()
ux = 1
uy = 0
vx = 0
vy = 1

S:AddMaterial('Vacuum', {1,0})
S:AddMaterial('Silicon', {n_si,0})
S:AddMaterial('PDMS', {n_PDMS,0})

period=600*10^-3;
h=750*10^-3;
h_relative=h/period;

S:SetLattice({ux,uy}, {vx,vy})
S:SetNumG(140)

S:AddLayer('top', 0, 'PDMS')
S:AddLayer('slab',h_relative , 'PDMS')
S:AddLayer('bottom', 0, 'PDMS')

--------------------------------- Functions -----------------------------------

function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function lines_from(file)
    if not file_exists(file) then return {} end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = tonumber(line)
    end
    return lines
end

-- you's function used in printing spectrum
function str_from_complex(a)
    return string.format('%.4f %.4f', a[1], a[2])
end

-- you's function
function polar_str_from_complex(a)
    local phase = math.atan2(a[1], a[2])
    if phase < 0 then
        phase = phase + 2*pi
    end
end

function generator(input)
    for freq = 1/lamda3*period, 1/lamda1*period, 0.001 do
        S:SetFrequency(freq)
        S:SetLayerPatternPolygon('slab', 'Silicon', {0, 0}, 0, input)
        S:SetExcitationPlanewave({0, 0}, {1, 0}, {0, 0})
        forw, back = S:GetAmplitudes('top', 0)
        forw, h = S:GetAmplitudes('bottom', 0)
        print(freq, str_from_complex(forw[1]))
    end
end

------------------------------- Main starts here -------------------------------

local file = 'data/DATA13_#13_gen.txt'
local data = lines_from(file)

size = 80
--print(#data)
count = 0
for i = 1, #data, size do
    count = count + 1
    --if i % size == 1 then
    --    print('Shape '.. i / size..': ')
    --end
    shape = {unpack(data, i, i + size - 1)}
    --print('Shape ' .. i / size.. ': ')
    --for j = 1, #shape, 2 do
    --    print(shape[j], shape[j + 1])
    --end
    --print(data[i], data[i + 1])
    --print(#shape)
    generator(shape)
end
--print(count)
