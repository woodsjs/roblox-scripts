function plotCircle(xc, yc, zc, r, density)
	local x=0
	local y=r	
	local coordinates = {}

	local M = density
	local N = density * 2 -- how many points top to bottom
	
	local m = 1
	local n = 1

	while m <= M do
		local sin = math.sin
		local cos = math.cos
		local pi = math.pi
		local o = m
		while n <= N do
			local x = (sin(pi * o/M) * cos((2*pi) * n/N)) * (r*1)
			local y = (sin(pi * o/M) * sin((2*pi) * n/N)) * (r*1)
			local z = (cos(pi * o/M)) * (r*1)
			table.insert(coordinates, {x + xc, y + yc, z + zc})
			n = n + 1
		end
		
		m = m + 1
	end
	
	return coordinates
end

function drawCircle(xc, yc, zc, radius, density)
	
	local model = Instance.new("Model")
	model.Name = "circle"
	model.Parent = workspace

	local circleCoordinates = plotCircle(xc, yc, zc, radius, density)
	
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	
	for _, coordinate in ipairs(circleCoordinates) do
		local thisPart = part:Clone()
		
		thisPart.Position = Vector3.new(coordinate[1], coordinate[2], coordinate[3])
		thisPart.Anchored = true
		thisPart.Parent = model
	end	
end

drawCircle(10,0,0,5, 10)
drawCircle(0,10,0,5, 5)
drawCircle(0,0,10,5, 10)

drawCircle(5, 5, -10, 10, 10)
drawCircle(0, 10, 0, 20, 10)
