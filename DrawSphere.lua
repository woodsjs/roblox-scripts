function plotSphere(xc, yc, zc, r, density)
	local x=0
	local y=r	
	local coordinates = {}
	local M = density
	local m = 1

	
	while m <= M do
		local o = 1
		local O = density * 2
		while o <= O do
			-- I've read that running system functions from a local var
			-- speeds up execution. For large spheres we need this.
			local sin = math.sin
			local cos = math.cos
			local pi = math.pi
			
			local N = M
			local n = 1
			
			-- I don't have deep knowledge of math, but I think we want to thank
			-- Euler for this. Converting cartesian to polar coordinates of each
			-- circle. 
			-- We multiply by radius otherwise our numbers would be very small
			-- then we add in our center coordinate otherwise this would all have
			-- a center of 0,0,0
			while n <= N do
				local x = (sin(pi * o/M) * cos((2*pi) * n/N)) * (r*1)
				local y = (sin(pi * o/M) * sin((2*pi) * n/N)) * (r*1)
				local z = (cos(pi * o/M)) * (r*1)
				table.insert(coordinates, {x + xc, y + yc, z + zc})
				n = n + 1
			end
			
			o = o + 1
		end
		m = m + 1
	end

	return coordinates
end

function drawSphere(xc, yc, zc, radius, density, part)
	
	-- we don't want the blocks just popped into workspace, that would get hard to manage
	local model = Instance.new("Model")
	model.Parent = workspace
	model.Name = "sphere"

	local circleCoordinates = plotSphere(xc, yc, zc, radius, density)
	
	for _, coordinate in ipairs(circleCoordinates) do
		local thisPart = part:Clone()
		
		thisPart.Position = Vector3.new(coordinate[1], coordinate[2], coordinate[3])
		thisPart.Anchored = true
		thisPart.Parent = model
	end	
end


-- create your part, then call drawSphere with x,y,z center, radius, density and part
-- Density is how many poles it creates
local part = Instance.new("Part")
drawSphere(0, 20, 0, 20, 30, part)

local part = Instance.new("Part")
part.Size = Vector3.new(1,1,1)
drawSphere(-20, 10, -20, 10, 15, part )
--drawSphere(30, 40, -20, 10, 15 )