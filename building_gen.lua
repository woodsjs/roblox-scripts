-- inputs - origin (x1, y1, z1), destination (x2, y2, z2)
-- added l, h, w of the part to adjust the line for block size

function Bresenham3D(x1, y1, z1, x2, y2, z2, l, h, w)
	local ListOfPoints = {}
	table.insert(ListOfPoints, {x1, y1, z1}) 
	
	-- get the lengths of our lines
	local dx = x2 - x1 
	local dy = y2 - y1 
	local dz = z2 - z1 
	
	local xs, ys, zs, p1, p2
	
	-- check if the line is up or down
	if (x2 > x1) then 
		xs = 1
	else 
		xs = -1
	end
		
	if (y2 > y1) then
		ys = 1
	else
		ys = -1
	end
		
	if (z2 > z1) then 
		zs = 1
	else 
		zs = -1
	end
	
	-- if x is the largest number, so the dominant direction
	if (dx >= dy and dx >= dz) then	 
		p1 = 2 * dy - dx 
		p2 = 2 * dz - dx 
		local i = 1
		while (x1 ~= x2) do
			x1 = x1 + xs 
			-- if it's not a straight line
			if (p1 >= 0) then
				y1 = y1 + ys 
				p1 = p1 - 2 * dx 
			end
			if (p2 >= 0) then
				z1 = z1 + zs 
				p2 = p2 - 2 * dx
			end
			p1 = p1 + 2 * dy 
			p2 = p2 + 2 * dz 
			
			-- adjusts the points for the block size in that direction
			local xVal = x1 + (l-1)*i
			table.insert(ListOfPoints, {xVal, y1, z1})
			i = i + 1
		end
	-- if y is the largest number, so the dominant direction
	elseif (dy >= dx and dy >= dz) then 
		p1 = 2 * dx - dy 
		p2 = 2 * dz - dy 
		local i = 1
		while (y1 ~= y2) do
			y1 = y1 + ys 
			if (p1 >= 0) then 
				x1 = x1 + xs 
				p1 = p1 - 2 * dy 
			end
			if (p2 >= 0) then
				z1 = z1 + zs 
				p2 = p2 - 2 * dy 
			end
			p1 = p1 + 2 * dx 
			p2 = p2 + 2 * dz 
			--local yVal = y1 * h
			local yVal = y1 + (h-1)*i
			table.insert( ListOfPoints, {x1, yVal, z1}) 
			i = i + 1
		end
	-- if z is the largest number, so the dominant direction
	else
		p1 = 2 * dy - dz 
		p2 = 2 * dx - dz 
		local i = 1
		while (z1 ~= z2) do
			z1 = z1 + zs 
			if (p1 >= 0) then
				y1 = y1 + ys 
				p1 = p1 - 2 * dz
			end
			if (p2 >= 0) then
				x1 = x1 + xs 
				p2 = p2 - 2 * dz
			end
			p1 = p1 + 2 * dy 
			p2 = p2 + 2 * dx 
			--local zVal = z1 + (h-1)
			local zVal = z1 + (w-1)*i
			table.insert( ListOfPoints, {x1, y1, zVal}) 
			i = i + 1
		end
	end
		
	return ListOfPoints 
end

local function getModel(name, parent)
	local model = Instance.new("Model")
	model.Parent = parent
	model.Name = name	
	return model
end

-- takes the output of bresenham and plops the parts
local function drawLine(ListOfPoints, part, model)
	for i, points in ipairs(ListOfPoints) do
		local part = part:Clone()
		
		part.Position = Vector3.new(points[1], points[2], points[3])
		
		part.Anchored = true
		part.Parent = model	
	end
end

-- fills in the floor and ceiling, between the outlines
-- need to pass in the part
local function fillFloor(x, y, z, l, h, w,model)
	local basePart = Instance.new("Part")
	local part = basePart:Clone()
	local floorFill = getModel('fill', model)
	for i = z, z+(w*part.Size.x), part.Size.z do
		local ListOfPoints = Bresenham3D(x, y, i, x+l, h, z, part.Size.x, part.Size.y, part.Size.z)
		drawLine(ListOfPoints, part, floorFill)
	end	
	floorFill:MakeJoints()
end

	
-- connect the squares. 
-- We only need this when we don't have walls
local function drawFloorSupports(x, ys, ye ,z, model)	
	local basePart = Instance.new("Part")
	local part = basePart:Clone()
	part.Size = Vector3.new(2,1,2)
	local ListOfPoints = Bresenham3D(x, ys, z, x, ye, z, part.Size.x, part.Size.y, part.Size.z)
	drawLine(ListOfPoints, part, model)
end	

-- this draws the base of the wall, not the fill
local function drawWall(x, y, z, l, h, w, part, model)
	local sizeX = part.Size.x
	local sizeY = part.Size.y
	local sizeZ = part.Size.z
	
	-- if the part is rotated, swap X and Z because your Z will be the long side now
	if part.Orientation.y == 90 then
		sizeX, sizeZ = sizeZ, sizeX
	end

	local ListOfPoints = Bresenham3D(x, y, z, l, h, w, sizeX, sizeY, sizeZ)
	drawLine(ListOfPoints, part, model)	
end

-- x,y,z are coordinates
-- l, h, w are how many blocks large the cube is, so if you use a block larger/smaller than standard
-- it SHOULD still work, but might not
-- l will always be that, regardless of wall
-- walls is binary - are there walls filled in or not filled in
-- model is the model we want created under workspace as the base model
function cubeIt(x, y, z, l, h, w, walls, model)
	-- TODO: want to pass in the part, so caller can decide what part they want to use
	-- draws the square and fills it in
	local function drawSquare(x, y, z, l, h, w, model)
		local basePart = Instance.new("Part")
		local part = basePart:Clone()

		if(walls) then
			--for i = y, h*2, part.Size.y do	
			local wall = getModel('wall', model)
			part.Rotation = Vector3.new(0, 0, 0)
			for i = y, y+h, part.Size.y do
				drawWall(x, i, z-1, x+l, i, z-1, part, wall)
			end
			wall:MakeJoints()
			
			local wall = getModel('wall', model)
			for i = y, y+h, part.Size.y do			
				drawWall(x, i, z+(w*part.Size.x)+1, x+l, i, z+(w*part.Size.x)+1, part, wall)
			end
			wall:MakeJoints()
			
			part.Rotation = Vector3.new(0,90,0)
			local wall = getModel('wall', model)
			for i = y, y+h, part.Size.y do			
				drawWall(x-1, i, z, x-1, i, z+w, part, wall)
			end
			wall:MakeJoints()
			
			local wall = getModel('wall', model)
			for i = y, y+h, part.Size.y do	
				drawWall(x+(l*part.Size.x)+1, i, z, x+(l*part.Size.x)+1, i, z+w, part, wall)
			end		
			wall:MakeJoints()	
		else
			part.Rotation = Vector3.new(0, 0, 0)
			local wall = getModel('base', model)
			drawWall(x, y, z-1, x+l, y, z-1, part, wall)
			wall:MakeJoints()
				
			local wall = getModel('base', model)
			drawWall(x, y, z+(w*part.Size.x)+1, x+l, y, z+(w*part.Size.x)+1, part, wall)
			wall:MakeJoints()
				
			local wall = getModel('base', model)
			part.Rotation = Vector3.new(0,90,0)
			drawWall(x-1, y, z, x-1, y, z+w, part, wall)
			wall:MakeJoints()
				
			local wall = getModel('base', model)
			drawWall(x+(l*part.Size.x)+1, y, z, x+(l*part.Size.x)+1, y, z+w, part, wall)
			wall:MakeJoints()
		end
	end
	
	local level = getModel('level', model)
	
	local floor = getModel('floor', level)
	-- to get the floor to fill, we use y as the height
	local square = getModel('base', floor)
	drawSquare(x, y, z, l, h, w, square)
	fillFloor(x, y, z, l, y, w, floor)
	floor:MakeJoints()
	
	-- top square, notice we feed height instead of Y for 5th param
	-- we also feed y+height in case our square is floating, or a N floor
	-- to get the roof right
	local ceiling = getModel('ceiling', level)
	fillFloor(x, y + h, z, l, h, w, ceiling)
	ceiling:MakeJoints()

	if ( not walls ) then
		local support = getModel('support', level)
		drawFloorSupports(x-1, y, y + h, z-1,  support)
		support:MakeJoints()
		
		local support = getModel('support', level)
		drawFloorSupports(x-1, y, y + h, z+(w*4)+1, support)
		support:MakeJoints()
		
		local support = getModel('support', level)
		drawFloorSupports(x+(l*4)+1, y, y + h, z-1, support)
		support:MakeJoints()
		
		local support = getModel('support', level)
		drawFloorSupports(x+(l*4)+1, y, y + h, z+(w*4)+1, support)	
		support:MakeJoints()
	end
end

-- hard coded, ick. Need to update to take in a numFloors param
function skyscraper(x, y, z, l, h, w, walls, numFloors, model)
	-- need to check floors, they can be +1 the highest of l or w, because numbers
	--if ( not walls ) then
		for i=0, numFloors-1 do
			cubeIt(x+(i*2), y+(h*i), z+(i*2), l-i, h, w-i, walls, model)
		end	
end

local skmodel = getModel('building', workspace)
skyscraper(0,0,0,5,10,5, true, 6, skmodel)

local skmodel = getModel('building', workspace)
skyscraper(30, 0, 0, 10, 6, 6, false, 7, skmodel)
--skyscraper(-70, 0, -100, 15, 15, 20, true, 16)

--local skmodel = getModel('building', workspace)
--cubeIt(20, 0, 30, 10, 20, 12, true, skmodel)

local skmodel = getModel('building', workspace)
cubeIt(-50, 0, 30, 5, 10, 15, false, skmodel)

local skmodel = getModel('building', workspace)
cubeIt(-50, 0, 30, 5, 10, 15, false, skmodel)

for i=1, 10 do
	local model = getModel('building', workspace)
	cubeIt(0, 0, (i*-25)+20, 5, 10, 5, true, model)
end

for i=1, 10 do
	local model = getModel('building', workspace)
	cubeIt(100, 0, (i*-25)+20, 5, 10, 5, false, model)
end