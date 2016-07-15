local component = require("component")
local internet = require("internet")
local textToASCII = require("textToASCII")
local term = require("term")

local screen = component.getPrimary("screen")
local gpu = component.getPrimary("gpu")

local switchTime = 10 --10s
local refreshRate = 1

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

function stringToTable(inputString)
  local table = {}
  for i = 1,#inputString do
    table[i]=string.sub(inputString,i,i)
  end
  return(table)
end

function asciiConvert(numIn)
  os.sleep(0)
  toConvert = tostring(numIn)
  return textToASCII.convert(toConvert,"big",true,false)
end

--Resolution
local x,y = screen.getAspectRatio()
local ratio = x/y
local multiplier = math.min(60/ratio,50*ratio)
gpu.setResolution(x*2.66666667*multiplier,y*multiplier)

local timePlainText = {
  {
    {"AKDT",-8},
    {"PDT",-7},
    {"MDT",-6},
    {"CDT",-5},
    {"EDT",-4}
  },
  {
    {"WGST",-2},
    {"UTC",0},
    {"BST",1},
    {"CEST",2},
    {"EEST",3}
  },
  {
    {"YETK",5},
    {"CST",8},
    {"ACST",9,30},
    {"AEST",10},
    {"NZST",12}
  }
}

local time = {}
local letters = {}
local timeUTC = ""

for i = 1,#timePlainText do
  time[i] = {}
  for j=1,#timePlainText[i] do
    time[i][j] = {}
    time[i][j][1] = textToASCII.convert(timePlainText[i][j][1],"cybermedium",false,false)
  end
end

for i = 0,9 do
  letters[i] = asciiConvert(i)
end
letters[":"]= textToASCII.convert(":","big",true,false)

local page = 1
local counter = 0
while true do
  timeUTC = dateRL("utc","%H:%M")
  
  for i=1,#timePlainText[page] do
    local hourConverted = string.sub(timeUTC,1,2)+timePlainText[page][i][2]
    
    if timePlainText[page][i][3] then
      local minutesConverted = string.sub(timeUTC,4)+timePlainText[page][i][3]
      
      if minutesConverted >=60 then
        minutesConverted = minutesConverted-60
        hourConverted = hourConverted +1
      end    
    else
      minutesConverted = string.sub(timeUTC,4)
    end
    
    if hourConverted >=24 then
      hourConverted = hourConverted-24
    end
    if #tostring(hourConverted) == 1 then
        hourConverted = "0"..hourConverted
    end
    time[page][i][2] = stringToTable(hourConverted..":"..minutesConverted)
  end
  
  term.clear()
  
  for zone = 1,#time[page] do
    for i, line in ipairs(time[page][zone][1]) do
      term.setCursor(7+(zone-1)*32,i)
      term.write(line)
    end

    for i=1,#letters[1] do
      term.setCursor(1+(zone-1)*32,i+4)
      local toWrite = ""
      for j = 1,#time[page][zone][2] do
        if tonumber(time[page][zone][2][j]) then
          toWrite = toWrite..letters[tonumber(time[page][zone][2][j])][i]
        else
          toWrite = toWrite..letters[":"][i]
        end
      end
      term.write(toWrite)
    end
  end
  
  if counter == switchTime then
    if page == 3 then
      page = 1
    else
      page = page + 1
    end
    counter = 0
  else
    counter = counter + 1
  end

  os.sleep(refreshRate)
end

gpu.setResolution(160,50)