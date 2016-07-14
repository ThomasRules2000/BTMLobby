local textToASCII = require("textToASCII")
local component = require("component")
local gpu = component.getPrimary("gpu")
local term = require("term")
local rgbHex = require("rgbHex")

--Vars
changeTime = 500 --How fast the screen changes
labelWidth = 30 --Width of Lables
tableTitleY = 10 --Y Coordinate of Table Title
tableTitleHeight = 4 --Height of Table Title
screenX=160 --Screen Size (Don't Change X, can lower Y to aprox 37)
screenY=40  --Max: 160x50, 16:9 = 160x45


gpu.setResolution(screenX,screenY)
term.clear()

local objects = {}
function newLabel(ID,label,x,y,width,height,color)
	local table = {}
    table["label"] = label
    table["x"] = x
    table["y"] = y
    table["width"] = width
    table["height"] = height
    table["color"] = color
    objects[ID] = table
end

function draw(ID)
	data = objects[ID]
    local objtype = data["type"]
    local label = data["label"]
    local x = data["x"]
    local y = data["y"]
    local width = data["width"]
    local height = data["height"]
	
	gpu.setBackground(data["color"],false)
	gpu.fill(x,y,width,height," ")
	gpu.set((x+width/2)-string.len(label)/2,y+height/2,label)
	gpu.setBackground(0x000000,false)
end

function drawAll()
	gpu.setForeground(0x000000)
	gpu.fill(label3X-2.5*(labelWidth+2),tableTitleY,labelWidth,screenY-tableTitleY," ")
	for ID,data in pairs(objects) do
        draw(ID)
    end
end

local tapeDrive = {}
i = 1
for address, type in pairs(component.list("tape")) do
  tapeDrive[i] = address
  i = i+1
end

local w,h = gpu.getResolution()

drive = 1
component.invoke(tapeDrive[1],"play")
component.invoke(tapeDrive[1],"setSpeed",0.75)
component.invoke(tapeDrive[2],"setSpeed",0.75)

local rgb = {255,0,0}
local hex = rgbHex.convert(rgb)
local col = 2
local increment = true

gpu.setPaletteColor(1,tonumber(hex))
gpu.setForeground(1,true)
t = textToASCII.convert("Welcome to BTM 2016 2.0","big",true,true)
len = #t[1]
for i, line in ipairs(t) do
  term.setCursor(w/2-len/2,i)
  term.write(line)
end

function incrementRgb(index)
	if increment then
		rgb[index] = rgb[index]+1
		if rgb[index]>=255 then
			if col == 1 then
				col = 3
			else
				col = col -1
			end
			increment = false
		end
	else
		rgb[index] = rgb[index]-1
		if rgb[index]<=0 then
			if col == 1 then
				col = 3
			else
				col = col -1
			end
			increment = true
		end
	end
end

stalls = {
	[0]={
		{"DJ Flamin' GO",1},
		{"Corrilated Foodelastics",1}
	},
	[1]={
		{"IndustrialCraft",1,true},
		{"2",1},
		{"Harvest Festival",1},
		{"ArmorPlus / WeaponsPlus",1},
		{"OpenRadio",1},
		{"Correlated Potentialistics",1},
		{"Rarmor",1},
		{"Actually Additions",1},
		{"Unclaimed",1},
		{"Some weird capacitor thing?",1},
		{"Unclaimed",1},
		{"Engination Enginogrammetry",1},
		{"Taam",2},
		{"Unclaimed",1},
		{"AbbysalCraft",1}
	},
	[2]={
		{"Ender Utilities",1},
		{"Forestry",1},
		{"Integrated",1,true},
		{"Dynamics",1},
		{"Unclaimed",4},
		{"Fancy Fluid",1,true},
		{"Storage",1},
		{"",1,true},
		{"Open",1,true},
		{"Computers",1,true},
		{"",1},
		{"Unclaimed",1},
		{"Autoverse",1}
	},
	[3]={
		{"Unclaimed",16}
	},
	[4]={
		{"Unclaimed",12},
		{"Better With Mods",1},
		{"Unclaimed",3}
	},
	[5]={
		{"Unclaimed",12},
		{"Fire's Random Things",1,true},
		{"Simply Caterpillar",1,true},
		{"Nether Essence",1,true},
		{"Adobe Blocks / More Anvils",1}
	}
}


function level()
	label3X = screenX/2-labelWidth/2
	
	--Level 0
	newLabel("Level0Title","Level 0",label3X,tableTitleY+22,labelWidth,tableTitleHeight,0xff9933)
	pos = tableTitleHeight+tableTitleY+22
	for i=1,#stalls[0] do
		if i%2==0 then
			newLabel("L0-Stall"..i,stalls[0][i][1],label3X,pos,labelWidth,stalls[0][i][2],0xffbf80)
		else
			newLabel("L0-Stall"..i,stalls[0][i][1],label3X,pos,labelWidth,stalls[0][i][2],0xffd9b3)
		end
		pos = pos+ stalls[0][i][2]
	end
	
	--Levels 1-5
	for l=1,#stalls do
		newLabel("Level"..l.."Title","Level "..l,label3X+(l-3)*(labelWidth+2),tableTitleY,labelWidth,tableTitleHeight,0xff9933)
		pos = tableTitleHeight+tableTitleY
		rev = false
		for i=1,#stalls[l] do
			if (i%2==0)~=rev then
				newLabel("L"..l.."-Stall"..i,stalls[l][i][1],label3X+(l-3)*(labelWidth+2),pos,labelWidth,stalls[l][i][2],0xffbf80)
			else
				newLabel("L"..l.."-Stall"..i,stalls[l][i][1],label3X+(l-3)*(labelWidth+2),pos,labelWidth,stalls[l][i][2],0xffd9b3)
			end
			if stalls[l][i][3] then
				rev = not rev
			end
			pos = pos+ stalls[l][i][2]
		end
	end
	drawAll()
end

level()
timer = 0
--Main Loop
while true do
  --Tape Drive Script
	if component.invoke(tapeDrive[drive],"isEnd") then
		component.invoke(tapeDrive[drive],"seek",-component.invoke(tapeDrive[drive],"getSize"))
		if drive == 1 then
			drive = 2
		else
			drive = 1
		end
		component.invoke(tapeDrive[drive],"play")
	end
  
	incrementRgb(col)
	hex = rgbHex.convert(rgb)
	gpu.setPaletteColor(1,tonumber(hex))
end