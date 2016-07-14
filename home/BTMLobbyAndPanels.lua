local textToASCII = require("textToASCII")
local component = require("component")
local gpu = component.getPrimary("gpu")
local term = require("term")
local rgbHex = require("rgbHex")

--Vars
changeTime = 500 --How fast the screen changes
labelWidth = 30 --Width of Lables
panelWidth = 80 --Width of Panel Labels
panelistWidth = 20 --Width of Panelist Labels
tableTitleY = 10 --Y Coordinate of Table Title
tableTitleHeight = 4 --Height of Table Title
screenX=130 --Screen Size (Don't Change X, can lower Y to aprox 37)
screenY=40  --Max: 160x50, 16:9 = 160x45, Default (2:1) = 130x40
label3X = screenX/2-labelWidth/2
panelX = screenX/2 -(panelWidth+panelistWidth)/2
panelistX = panelX+panelWidth

gpu.setResolution(screenX,screenY)
term.clear()

local objectsLobby = {}
local objectsLobby2 = {}
local objectsPanel = {}
function newLabel(ID,label,x,y,width,height,color,page)
	local table = {}
	table["label"] = label
	table["x"] = x
	table["y"] = y
	table["width"] = width
	table["height"] = height
	table["color"] = color
    if page == 1 then
		objectsLobby[ID] = table
	elseif page == 2 then
		objectsLobby2[ID] = table
	else
		objectsPanel[ID] = table
	end
end

function draw(ID,page)
	if page == 1 then
		data = objectsLobby[ID]
    elseif page == 2 then
		data = objectsLobby2[ID]
	else
		data = objectsPanel[ID]
	end
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

function drawAll(page)
	gpu.setForeground(0x000000)
	gpu.fill(label3X-2.5*(labelWidth+4),tableTitleY,labelWidth,screenY-tableTitleY," ")
	if page == 1 then
		for ID,data in pairs(objectsLobby) do
			draw(ID,page)
		end
	elseif page ==2 then
		for ID,data in pairs(objectsLobby2) do
			draw(ID,page)
		end
	else
		for ID,data in pairs(objectsPanel) do
			draw(ID,page)
		end
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
		{"Correlated Foodalistics",1}
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
		{"Dark",1,true},
		{"Utils",1},
		{"Unclaimed",1},
		{"Engination Enginogrammetry",1},
		{"Taam",2},
		{"RandomThings",1},
		{"AbbysalCraft",1}
	},
	[2]={
		{"Ender Utilities",1},
		{"Forestry",1},
		{"Integrated",1,true},
		{"Dynamics",1},
		{"Unclaimed",2},
		{"P&P",2},
		{"Fancy Fluid",1,true},
		{"Storage",1},
		{"",1,true},
		{"Open",1,true},
		{"Computers",1,true},
		{"",1},
		{"TechReborn",1},
		{"Autoverse",1}
	},
	[3]={
		{"Unclaimed",8},
		{"Blay09 and Zero_'s Mods",1},
		{"Unclaimed",3},
		{"DeepResonance",1},
		{"RFTools",1},
		{"Unclaimed",2}
	},
	[4]={
		{"Unclaimed",16}
	},
	[5]={
		{"Unclaimed",12},
		{"Better With Mods",1},
		{"Unclaimed",3}
	},
	[6]={
		{"Unclaimed",12},
		{"Fire's Random Things",1,true},
		{"Simply Caterpillar",1,true},
		{"Nether Essence",1,true},
		{"Adobe Blocks / More Anvils",1}
	}
}

panels = {
	{"IC2 Mystery Panel","Aroma1997"},
	{"MCubed - a project to build a Curse alternative", "Gaelan"},
	{"OpenGL for Minecraft Modders", "GreaseMonkey"},
	{"OpenOS 1.6 - What's New?", "payonel"},
	{"TIS-OC", "Sangar"},
	{"Translation in a Nutshell - The Chinese modded Minecraft community","3TUSK and exzhawk"},
	{"Will it run on Minecraft? - MIPS for OpenComputers","GreaseMonkey"},
	{"Beyond Cellular Automation - Designing better machines for multiplayer","Falkreon"},
	{"Please Stop Playing Minecraft - How to make better maps and mods","Moesh"}
}

function level()
	--Level 0
	newLabel("Level0Title","Level 0",label3X,tableTitleY+22,labelWidth,tableTitleHeight,0xff9933,1)
	pos = tableTitleHeight+tableTitleY+22
	for i=1,#stalls[0] do
		if i%2==0 then
			newLabel("L0-Stall"..i,stalls[0][i][1],label3X,pos,labelWidth,stalls[0][i][2],0xffbf80,1)
		else
			newLabel("L0-Stall"..i,stalls[0][i][1],label3X,pos,labelWidth,stalls[0][i][2],0xffd9b3,1)
		end
		pos = pos+ stalls[0][i][2]
	end
	
	--Levels 1-3
	for l=1,3 do
		newLabel("Level"..l.."Title","Level "..l,label3X+(l-2)*(labelWidth+4),tableTitleY,labelWidth,tableTitleHeight,0xff9933,1)
		pos = tableTitleHeight+tableTitleY
		rev = false
		for i=1,#stalls[l] do
			if (i%2==0)~=rev then
				newLabel("L"..l.."-Stall"..i,stalls[l][i][1],label3X+(l-2)*(labelWidth+4),pos,labelWidth,stalls[l][i][2],0xffbf80,1)
			else
				newLabel("L"..l.."-Stall"..i,stalls[l][i][1],label3X+(l-2)*(labelWidth+4),pos,labelWidth,stalls[l][i][2],0xffd9b3,1)
			end
			if stalls[l][i][3] then
				rev = not rev
			end
			pos = pos+ stalls[l][i][2]
		end
	end
end

function level2()
	--Levels 4-6
	for l=4,6 do
		newLabel("Level"..l.."Title","Level "..l,label3X+(l-5)*(labelWidth+4),tableTitleY,labelWidth,tableTitleHeight,0xff9933,2)
		pos = tableTitleHeight+tableTitleY
		rev = false
		for i=1,#stalls[l] do
			if (i%2==0)~=rev then
				newLabel("L"..l.."-Stall"..i,stalls[l][i][1],label3X+(l-5)*(labelWidth+4),pos,labelWidth,stalls[l][i][2],0xffbf80,2)
			else
				newLabel("L"..l.."-Stall"..i,stalls[l][i][1],label3X+(l-5)*(labelWidth+4),pos,labelWidth,stalls[l][i][2],0xffd9b3,2)
			end
			if stalls[l][i][3] then
				rev = not rev
			end
			pos = pos+ stalls[l][i][2]
		end
	end
end

function showPanels()
	newLabel("PanelTitle","Panel",panelX,tableTitleY,panelWidth,tableTitleHeight,0xff9933,3)
	newLabel("PanelistTitle","Panelist",panelistX,tableTitleY,panelistWidth,tableTitleHeight,0xff9933,3)
	pos = tableTitleHeight+tableTitleY
	for i=1,#panels do
		if i%2==0 then
			newLabel("Panel"..i,panels[i][1],panelX,pos,panelWidth,2,0xffbf80,3)
			newLabel("Panelist"..i,panels[i][2],panelistX,pos,panelistWidth,2,0xffbf80,3)
		else
			newLabel("Panel"..i,panels[i][1],panelX,pos,panelWidth,2,0xffd9b3,3)
			newLabel("Panelist"..i,panels[i][2],panelistX,pos,panelistWidth,2,0xffd9b3,3)
		end
		pos = pos+2
	end	
end

level()
level2()
showPanels()
drawAll(1)
timer = 0
page = 1
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
	
	if timer == changeTime then
		gpu.setForeground(0x000000)
		gpu.fill(1,tableTitleY,screenX,screenY-tableTitleY," ")
		if page == 3 then
			page = 1
		else
			page = page + 1
		end
		drawAll(page)
		timer = 0
	else
		timer = timer + 1
	end
	
	incrementRgb(col)
	hex = rgbHex.convert(rgb)
	gpu.setPaletteColor(1,tonumber(hex))
end
