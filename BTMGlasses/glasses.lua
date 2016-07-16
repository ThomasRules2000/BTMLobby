local fs = require("filesystem")
local component = require("component")
local internet = require("internet")
local glasses = component.getPrimary("glasses")

function dateRL(zone,format)
  local time = ""
  local newFormat = ""
  for i=1,#format do
    if string.sub(format,i,i) == "%" then
      newFormat = newFormat.."%25"
    else
      newFormat = newFormat..string.sub(format,i,i)
    end
  end
  local request = internet.request("http://www.timeapi.org/"..zone.."/now?format="..newFormat)
  for line in request do
    time = time..line
  end
  return(time)
end

local rectangles = {}
function createRectangle(name,pos,size,col,alpha)
	rectangles[name] = glasses.addRect()
	rectangles[name].setPosition(pos[1],pos[2])
	rectangles[name].setSize(size[1],size[2])
	rectangles[name].setColor(col[1],col[2],col[3])
	rectangles[name].setAlpha(alpha)
end

local panels = {
	{"IC2 Mystery Panel","Aroma1997"},
	{"MCubed - a project to build a","Gaelan",true},
	{"Curse alternative", ""},
	{"OpenGL for Minecraft Modders", "GreaseMonkey"},
	{"OpenOS 1.6 - What's New?", "payonel"},
	{"TIS-OC", "Sangar"},
	{"Translation in a Nutshell","",true},
	{"The Chinese modded Minecraft","3TUSK and",true},
	{"community","exzhawk"},
	{"Will it run on Minecraft?","",true},
	{"MIPS for OpenComputers","GreaseMonkey"},
	{"Beyond Cellular Automation","",true},
	{"Designing better machines","Falkreon",true},
	{"for multiplayer",""},
	{"Please Stop Playing Minecraft","",true},
	{"How to make better maps and mods","Moesh"}
}

local labels = {}
function newLabel(name,text,pos,scale)
	labels[name] = glasses.addTextLabel()
	labels[name].setPosition(pos[1],pos[2])
	labels[name].setText(text)
	labels[name].setScale(scale)
end

local panelX = 20
local panelistX = 200
local tableTitleY = 15
function showPanels()
	newLabel("PanelTitle","Panel",{panelX+50,tableTitleY},0.7)
	newLabel("PanelistTitle","Panelist",{panelistX+10,tableTitleY},0.7)
	
	local pos = 20+tableTitleY
	for i=1,#panels do
		newLabel("Panel"..i,panels[i][1],{panelX,pos},0.7)
		newLabel("Panelist"..i,panels[i][2],{panelistX,pos},0.7)
		if panels[i][3] then
			pos = pos+12
		else
			pos = pos+17
		end
	end	
end

local titleOrange = {255/255,153/255,51/255}
local orange1 = {255/255,191/255,128/255}
local orange2 = {255/255,217/255,179/255}
local black = {0,0,0}

glasses.removeAll()

local rev = false
local bgPos = 19
local panH = 12
for i = 1,#panels do
	if (i%2 == 1)~=rev then col = orange1 else col = orange2 end
	if panels[i][3] then panH = 9 else panH = 12 end
	createRectangle("lineBg"..i,{5,bgPos},{panH,190},col,0.7)
	if panels[i][3] then
		rev = not rev
		bgPos = bgPos+9
	else
		bgPos = bgPos+12
	end
end
local bottom = bgPos

createRectangle("titleRect",{5,5},{15,190},titleOrange,0.7)

createRectangle("borderT",{5,5},{2,188},black,0.7)
createRectangle("borderB",{5,bottom-2},{2,188},black,0.7)
createRectangle("borderL",{5,5},{bottom-5,2},black,0.7)
createRectangle("borderR",{193,5},{bottom-5,2},black,0.7)

timeLab = glasses.addTextLabel()
timeLab.setPosition(110,5)
timeLab.setText("00:00")

showPanels()


while true do
  timeLab.setText(dateRL("utc","%H:%M"))
  os.sleep(1)
end