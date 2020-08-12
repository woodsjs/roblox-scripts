function Bresenham3D(x1, y1, z1, x2, y2, z2)
	local ListOfPoints = {}
	table.insert(ListOfPoints, {x1, y1, z1}) 
	local dx = x2 - x1 
	local dy = y2 - y1 
	local dz = z2 - z1 
	local xs, ys, zs, p1, p2

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

	if (dx >= dy and dx >= dz) then	 
		p1 = 2 * dy - dx 
		p2 = 2 * dz - dx 
		while (x1 ~= x2) do
			x1 = x1 + xs 
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
			table.insert(ListOfPoints, {x1, y1, z1})
		end

	elseif (dy >= dx and dy >= dz) then 
		p1 = 2 * dx - dy 
		p2 = 2 * dz - dy 
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
			table.insert( ListOfPoints, {x1, y1, z1}) 
		end

	else
		p1 = 2 * dy - dz 
		p2 = 2 * dx - dz 
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
			table.insert( ListOfPoints, {x1, y1, z1}) 
		end
	end
		
	return ListOfPoints 
end

x1, y1, z1 = 0, 5, 0
x2, y2, z2 = 10, 30, 10 
ListOfPoints = Bresenham3D(x1, y1, z1, x2, y2, z2) 

local basepart = Instance.new('Part')
basepart.Size = Vector3.new(1, 1, 1)

for i, points in pairs(ListOfPoints) do
	local part = basepart:Clone()
	part.Position = Vector3.new(points[1], points[2], points[3])
	part.Anchored = true
	part.Parent = workspace	
end

