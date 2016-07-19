local Grid = require("jumper.grid")
local Pathfinder = require("jumper.pathfinder")
local term = require("term")
local sides = require("sides")

local component = require("component")
local beep = component.beep
local geo = component.geolyzer
local nav = component.navigation

local function getWalls(radius)
  local blocks = {}
  for x=-radius,radius do
    blocks[x+radius+1] = {}
    for z = -radius,radius do
      column = geo.scan(x,z,false)
      if column[33] > 1 then
        blocks[x+radius+1][z+radius+1] = 1
      else
        blocks[x+radius+1][z+radius+1] = 0
      end --if
    end --for
  end --for
  return blocks
end --func

local function dirToArrow(direction,facing,isX)
	local arrow
	if facing == direction then
		arrow = sides.north
	elseif isX then
		if facing == sides.south then
			if direction == sides.east then
				arrow = sides.left
			else 
				arrow = sides.right
			end
		else
			arrow = sides.south
		end
	else
		if facing == sides.east then
			if direction == sides.north then
				arrow = sides.left
			else 
				arrow = sides.right
			end
		elseif facing == sides.west then
			if direction == sides.south then
				arrow = sides.left
			else 
				arrow = sides.right
			end
		else
			arrow = sides.south
		end
	end
	return arrow
end

local function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

local arrows = { --Uses sides for cardinal and multiplies for inbetween (e.g. nw = north*west)
[sides.north] = [[
     .
   .:;:.
 .:;;;;;:.
   ;;;;;
   ;;;;;
   ;;;;;
   ;;;;;
   ;:;;;
   ;;;;;
]],
[sides.south] = [[
   ;;;;.
   ;;;;;
   ;;;;;
   ;;;;;
   ;;;;;
   ;;;;;
 ..;;;;;..
  ':::::'
    ':`
]],
[sides.east] = [[
            .
............;;.
::::::::::::;;;;.
::::::::::::;;:'
            :'
]],
[sides.west] = [[
    .
  .;;............
.;;;;::::::::::::
 ':;;::::::::::::
   ':
]],
[sides.north*sides.west] = [[
 ......
 ;;;:;
 ;::;;;.
 ' ':;;;;.
     ':;;;;
       ':;
]],
[sides.north*sides.east] = [[
     ......
      ;:;;;
    .;;;::;
  .;;;;:' '
 ;;;;:'
   ;:'
]],
[sides.south*sides.east] = [[
   ;:,
 ;;;;:,
  ';;;;:, ,
    ';;;::;
      ;:;;;
     ''''''
]],
[sides.south*sides.west] = [[
       ,:;
     ,:;;;;
 , ,:;;;;'
 ;::;;;'
 ;;;:;
 ''''''
]]
}
local radius = 10 --Range of the Tablet - higher number = higher range, but slower. Max 32
local walkable = 0
local startX,startZ = radius+1,radius+1
local endX,endZ = 0,0
local posX,posZ = radius+1,radius+1
local selected = ""
local selectedTab = {}
local instNo = 2
local path = nil
local nodeX,nodeZ = 0,0
local pathLength = 0
term.clear()
while true do
	local waypoints = nav.findWaypoints(radius)
	if selected~= "" then
		for i=1,#waypoints do
			if selected == waypoints[i]["label"] then
				selectedTab = waypoints[i]
				break
			end --if
		end --for
	end
	
	if selected ~= "" and path then
		print(instNo,pathLength)
		posX,posZ = -(selectedTab.position[1] -endX), -(selectedTab.position[3] -endZ)
		if posX>nodeX-1 and posX<nodeX+1 and posZ>nodeZ-1 and posZ<nodeZ+1 then
			instNo = instNo+1
		end
	end
	
	if selected == "" then --Select Waypoint
		print("Waypoints For This Floor:")
		for i = 1,#waypoints do
			if waypoints[i].position[2] >= -1 and waypoints[i].position[2] <=1 then
				print(waypoints[i]["label"])
			end
		end --for
		print("\n If you do not see your destination, please set your destination as the elevator")
		io.write("Destination: ")
		selected = io.read()
		local valid = false
		for i=1,#waypoints do
			if selected == waypoints[i]["label"] and waypoints[i].position[2] >= -1 and waypoints[i].position[2] <=1 then
				valid = true
				selectedTab = waypoints[i]
				break
			end --if
		end --for
		if not valid then
			print("Invalid Selection")
			selected = ""
		end
    elseif not path then-- Calculate Path
		print("Calculating Path")
		local map = getWalls(radius)
		local grid = Grid(map)
		local finder = Pathfinder(grid, 'JPS', walkable)
		endX,endZ = selectedTab.position[1]+radius+1, selectedTab.position[3]+radius+1
		path = finder:getPath(startX, startZ, endX, endZ)
		pathLength = 0
		for n,c in path:iter() do
			pathLength = pathLength+1
		end
		posX,posZ = radius,radius
		instNo = 2
		print("Path Found")
	elseif instNo<=pathLength then--Send user to waypoint
		local node
		for n, c in path:iter() do
			if c == instNo then
				node = n
				break
			end
		end
		local xExisits, zExists = false,false
		nodeX,nodeZ = node.x,node.y
		local xDif, zDif = nodeX-posX, nodeZ-posZ
		local facing = nav.getFacing()
		local xDir, zDir = 6,7
		local arrow = 1
		if xDif>0 then
			xDir = sides.west
			xExisits = true
		elseif xDif<0 then
			xDir = sides.east
			xExisits = true
		end
		if zDif>0 then
			zDir = sides.south
			zExists = true
		elseif zDif<0 then
			zDir = sides.north
			zExists = true
		end
		
		if facing == sides.up or facing == sides.down or facing == sides.north then
			if xExisits~= zExists then
				if xExisits then
					arrow = xDir
				else
					arrow = zDir
				end
			else
				local ratio = math.deg(math.atan(math.abs(xDif),math.abs(zDif)))
				if ratio>67.5 then
					arrow = xDir
				elseif ratio>22.5 then
					arrow = xDir*zDir
				else
					arrow = zDir
				end
			end
		else
			if xExisits~= zExists then
				if xExisits then direction = xDir else direction = zDir end
				arrow = dirToArrow(direction,facing,xExisits)
			else
				local ratio = math.deg(math.atan(math.abs(xDif),math.abs(zDif)))
				if ratio>67.5 then
					arrow = dirToArrow(xDir,facing,true)
				elseif ratio>22.5 then
					if facing == sides.south then
						if xDir == sides.east then xDir = sides.west else xDir = sides.east end
						if zDir == sides.north then zDir = sides.south else zDir = sides.north end
					elseif facing == sides.east then
						if xDir == sides.east then xDir = sides.north else xDir = sides.south end
						if zDir == sides.north then zDir = sides.west else zDir = sides.east end
					elseif facing == sides.west then
						if xDir == sides.east then xDir = sides.south else xDir = sides.north end
						if zDir == sides.north then zDir = sides.east else zDir = sides.west end
					end
					arrow = xDir*zDir
				else
					arrow = dirToArrow(zDir,facing,false)
				end
			end
		end
		local screenW,screenH = term.getViewport()
		local selectedArrow = arrows[arrow]
		local arrowTab = lines(selectedArrow)
		local arrowTabLens = {}
		for i = 1,#arrowTab do
			arrowTabLens[i] = #arrowTab[i]
		end
		local maxLen = math.max(table.unpack(arrowTabLens))
		local xPos = screenW/2-maxLen/2
		local yPos = screenH/2-#arrowTab/2
		term.clear()
		for i = 1,#arrowTab do
			term.setCursor(xPos,yPos+i-1)
			term.write(arrowTab[i])
		end
	else --Reset
		term.clear()
		print("Arrived")
		beep.beep({[261.63]=1})
		os.sleep(0.2)
		beep.beep({[349.23]=0.8})
		selected = ""
		path = nil
		instNo = 2
	end --if
end 