local textToASCII = require("textToASCII")
local component = require("component")
local gpu = component.getPrimary("gpu")
local term = require("term")
local rgbHex = require("rgbHex")

--Vars
changeTime = 5000 --How fast the screen changes
labelWidth = 90 --Width of Lables
tableTitleY = 10 --Y Coordinate of Table Title
tableTitleHeight = 4 --Height of Table Title
screenX=160 --Screen Size
screenY=45  --Max: 160x50 


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
	gpu.fill(labelX,tableTitleY,labelWidth,screenY-tableTitleY," ")
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
		{"IndustrialCraft 2",2},
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
		{"Integrated Dynamics",2},
		{"Unclaimed",4},
		{"Fancy Fluid Storage",2},
		{"Open Computers",4},
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
		{"Unclaimed",14},
		{"Fire's Random Things / Simply Caterpillar / Nether Essence / Adobe Blocks / More Anvils",2}
	}
}


function level(levelNo)
	labelX = screenX/2-labelWidth/2
	objects = {}
	newLabel("Level"..levelNo.."Title","Level "..levelNo,labelX,tableTitleY,labelWidth,tableTitleHeight,0xff9933)
	pos = tableTitleHeight+tableTitleY
	for i=1,#stalls[levelNo] do
		if i%2==0 then
			newLabel("L"..levelNo.."-Stall"..i,stalls[levelNo][i][1],labelX,pos,labelWidth,stalls[levelNo][i][2],0xffbf80)
		else
			newLabel("L"..levelNo.."-Stall"..i,stalls[levelNo][i][1],labelX,pos,labelWidth,stalls[levelNo][i][2],0xffd9b3)
		end
		pos = pos+ stalls[levelNo][i][2]
	end
	drawAll()
end

level(0)
levelNo = 0
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
	if timer == changeTime then
		if levelNo == 5 then
			levelNo = 0
		else
			levelNo = levelNo + 1
		end
		level(levelNo)
		timer = 0
	else
		timer = timer +1
	end
	
end