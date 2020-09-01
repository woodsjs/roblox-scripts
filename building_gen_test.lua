-- add in straight buildings

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

function wallBuilder(x,y,z,l,h,w,part,wall, wallNumber)
	
	if wallNumber == 1 then
		for i = y, y+h, part.Size.y do
			-- if our x is even, only draw a wall every 2 blocks
			drawWall(x, i, z-1, x+l, i, z-1, part, wall)
			--drawWall(x, i, z-1, x+l, i, z-1, part, wall)
		end
	elseif wallNumber == 2 then
		for i = y, y+h, part.Size.y do			
			drawWall(x, i, z+(w*part.Size.x)+1, x+l, i, z+(w*part.Size.x)+1, part, wall)
		end
	elseif wallNumber == 3 then
		for i = y, y+h, part.Size.y do			
			drawWall(x-1, i, z, x-1, i, z+w, part, wall)
		end
	elseif wallNumber == 4 then
		for i = y, y+h, part.Size.y do	
			drawWall(x+(l*part.Size.x)+1, i, z, x+(l*part.Size.x)+1, i, z+w, part, wall)
		end		
	end
	
end

-- x,y,z are coordinates
-- l, h, w are how many blocks large the cube is, so if you use a block larger/smaller than standard
-- it SHOULD still work, but might not
-- l will always be that, regardless of wall
-- walls is binary - are there walls filled in or not filled in
-- model is the model we want created under workspace as the base model
function cubeIt(x, y, z, l, h, w, walls, model, hasWindows)
	-- TODO: want to pass in the part, so caller can decide what part they want to use
	-- draws the square and fills it in
	local function drawSquare(x, y, z, l, h, w, model)
		local basePart = Instance.new("Part")
		local part = basePart:Clone()
		part.Rotation = Vector3.new(0, 0, 0)
		
		if(walls) then
            local wallNumber
			local wall = getModel('wall', model)
            
			for wallNumber = 1, 4 do
				print('wall numer ' .. wallNumber)
				if hasWindows then
					if (wallNumber >= 3) then
						print('rotate part')
                        part.Rotation = Vector3.new(0,90,0)
                    end

                    -- we sub l with len of 2 or 3
                    -- compared to above, we have to swap out len and x values with width and z values
					local mainDirection = (wallNumber <= 2) and l or w
					print('main direction l or w ' .. tostring(mainDirection))
                    local isEven = math.fmod(mainDirection, 2) == 0
                    print('is even ' .. tostring(isEven))
                    -- draw a row so we're not on the ground
                    --drawWall(x, y, z-1, x+l, y, z-1, part, wall)
                    -- local drawWallWidth = wallNumber == 1 and z-1 or z+(w*part.Size.x)+1
                    -- drawWall(x, y, drawWallWidth, x+l, y, drawWallWidth, part, wall)
                            
                    --loop thought this level of wall, and put something every dos
					local offsetSize = (wallNumber <= 2) and l-1 or w-0.5
					print('offset size ' .. tostring(offsetSize))
                    local len = isEven and mainDirection or offsetSize
                    print('len ' .. len)
                    local w,l = 0,0
                    if (wallNumber <= 2) then
                        w = wallNumber == 1 and 0 or w
                    else
                        l = wallNumber == 3 and 0 or l
                    end
                    
                    for i = 0, len do
                        -- we don't need offset if we're on an even number length
                        local offsetSize = (wallNumber <= 2) and part.Size.z or part.Size.x/2
                        local offset = isEven and 0 or offsetSize
                        
                        local thisX, thisZ

                        if (wallNumber <= 2) then
                            thisX = x+(i*part.Size.x)+ offset
                            thisZ = z
                        else
                            thisZ = z+(i*part.Size.x)+ offset --(part.Size.z)
                            thisX = x
                        end
                        
                        if i == 0 then
							-- first column
                            wallBuilder(thisX,y,thisZ,l,h,w,part,wall,wallNumber)
                        elseif math.fmod(i, 2) == 1 then
                            -- windowed wall in the even spaces
                            local part = Instance.new("Part")
                            part.Material = "Glass"
                            part.Transparency = 0.5

                            if (wallNumber >= 3) then
                                part.Rotation = Vector3.new(0,90,0)
                            end

                            wallBuilder(thisX,y+part.Size.y,thisZ,l,h-part.Size.y,w,part,wall,wallNumber)
                        else
                            -- non windowed area in the odd spaces after 0
                            wallBuilder(thisX,y,thisZ,l,h,w,part,wall,wallNumber)
                        end
                        end
                        -- top ledge
                        --drawWall(x, y+h, z-1, x+l, 0, z-1, part, wall)
                    
                else
                    -- no windows
                    wallBuilder(x,y,z,l,h,z,part,wall,wallNumber)
                end
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
function skyscraper(x, y, z, l, h, w, walls, numFloors, model, straight, hasWindows)
	-- need to check floors, they can be +1 the highest of l or w, because numbers
	--if ( not walls ) then
	for i=0, numFloors-1 do
		-- we need to NOT adjust the x, z, len or width if we want a straight building
		local attenuateBy = straight and 0 or i
		cubeIt(x+(attenuateBy*2), y+(h*i), z+(attenuateBy*2), l-attenuateBy, h, w-attenuateBy, walls, model, hasWindows)
	end	
end

local skmodel = getModel('building', workspace)
skyscraper(40,0,50,15,15,15, true, 15, skmodel, false, true)

local skmodel = getModel('building', workspace)
skyscraper(0,0,50,6,11,10, true, 2, skmodel, true, true)

local model = getModel('building', workspace)
cubeIt(0, 0, 0, 10, 10, 6, true, model, true)
