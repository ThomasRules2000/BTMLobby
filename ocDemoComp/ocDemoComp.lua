local component = require("component")
local gpu = component.gpu
local term = (require("term"))
local screen = component.screen
local event = require("event")
local keyboard = require("keyboard")

local function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

local x,y = 150,50

gpu.setResolution(x,y) --160x50 = 5x4
gpu.setForeground(0xffffff,false)
gpu.setBackground(0x000000,false)

--[==[
local titleText = {
[[   ____                    _____                            _                 ]],
[[  / __ \                  / ____|                          | |                ]],
[[ | |  | |_ __   ___ _ __ | |     ___  _ __ ___  _ __  _   _| |_ ___ _ __ ___  ]],
[[ | |  | | '_ \ / _ \ '_ \| |    / _ \| '_ ` _ \| '_ \| | | | __/ _ \ '__/ __| ]],
[[ | |__| | |_) |  __/ | | | |___| (_) | | | | | | |_) | |_| | ||  __/ |  \__ \ ]],
[[  \____/| .__/ \___|_| |_|\_____\___/|_| |_| |_| .__/ \__,_|\__\___|_|  |___/ ]],
[[        | |                                    | |                            ]],
[[        |_|                                    |_|                            ]]
}

local titleText2 = {
[[  _____                            _____                           _   _ _   _              ]],
[[ |  __ \                          / ____|                         | | (_) | (_)             ]],
[[ | |  | | ___ _ __ ___   ___     | |     ___  _ __ ___  _ __   ___| |_ _| |_ _  ___  _ __   ]],
[[ | |  | |/ _ \ '_ ` _ \ / _ \    | |    / _ \| '_ ` _ \| '_ \ / _ \ __| | __| |/ _ \| '_ \  ]],
[[ | |__| |  __/ | | | | | (_) |   | |___| (_) | | | | | | |_) |  __/ |_| | |_| | (_) | | | | ]],
[[ |_____/ \___|_| |_| |_|\___/     \_____\___/|_| |_| |_| .__/ \___|\__|_|\__|_|\___/|_| |_| ]],
[[                                                       | |                                  ]],
[[                                                       |_|                                  ]]
}
--]==]

local titleText = {
[[____ ___  ____ _  _ ____ ____ _  _ ___  _  _ ___ ____ ____ ____    ___  ____ _  _ ____    ____ ____ _  _ ___  ____ ___ _ ___ _ ____ _  _ ]],
[[|  | |__] |___ |\ | |    |  | |\/| |__] |  |  |  |___ |__/ [__     |  \ |___ |\/| |  |    |    |  | |\/| |__] |___  |  |  |  | |  | |\ | ]],
[[|__| |    |___ | \| |___ |__| |  | |    |__|  |  |___ |  \ ___]    |__/ |___ |  | |__|    |___ |__| |  | |    |___  |  |  |  | |__| | \| ]],
[[                                                                                                                                         ]],
}

local titleTextLen = {}
for i=1,#titleText do
  titleTextLen[i] = #titleText[i]
end
term.clear()
for i = 1,#titleText do
  term.setCursor(x/2-math.max(table.unpack(titleTextLen))/2,i)
  term.write(titleText[i])
end

--[[
local titleTextLen2 = {}
for i=1,#titleText2 do
  titleTextLen2[i] = #titleText2[i]
end
for i = 1,#titleText2 do
  term.setCursor(x/2-math.max(table.unpack(titleTextLen2)/2),#titleText+i)
  term.write(titleText2[i])
end
--]]

local infoText = {[[
The following categories are being considered: Demo, EEPROM, Game, Tool, Artwork and Wild.]],
[[This is not final, however - categories with few entries may get merged into other ones and new categories might be created.
We will show every demo, however voting will only be allowed in official categories.

Entries are accepted until July 29th. Multiple entries from one person are allowed.
]],
[[For categories Demo, Game, Tool and EEPROM:]],
[[• As standard, you will get a Tier 3 GPU, 2 megabytes of RAM, a Tier 3 Lua 5.3 CPU and the latest version of OpenOS available at the time.
  Additional cards/peripherals may be requested - especially for sound - however we do not promise they will qualify outside of Wild (especially
  if they overpower OpenComputers’s built-in capabilities)!
• Hint from the organizers: OpenComputers has highly limited audio capabilities, but Computronics provides a Beep Card, Noise Card, Sound Card and
  Tape Drive!
• If you use the Tape Drive for audio, generating your music inside OpenComputers is considered good form even if it requires preload time to write
  to the tape.
• Any additional requirements, the author(s) and a short comment will be shown on an info panel before the demo is displayed on stage.
]],
[[For categories Demo, Game, Artwork and EEPROM:]],
[[  • No wireless/Internet connectivity is allowed - your demos must be self-contained.
]],
[[For categories Demo and EEPROM:]],
[[  • If your demo requires any user input, please let us know. If your demo requires any custom OSes/preparation, please let us know.

In the Demo category, your demo must fit on one unit’s worth of an OpenComputers storage medium (floppy disk or hard drive). Please note that floppy
disk contributions are encouraged as they’re cooler - and if we get enough of them, we might make a separate category for them!

In the EEPROM category, your demo must run fully off an OpenComputers EEPROM card and load no external data.

In the Game category, we’re going to do our best to play your game - please provide some sort of documentation on how to play the game.

In the Tool category, you can show non-game applications for OpenComputers - though this will probably involve you either providing some sort of
demonstration or showing it off yourself (in which case, audio chat is necessary).

In the Artwork category, your demo should be in the form of a static display on a Tier 3 GPU, coupled with its own Lua-based loader. (Hint - asie
made a loader called ctif: https://github.com/ChenThread/ctif)

For the Wild category - go wild! You can use Robots, Drones, even TIS-3D or redstone! 
]],
[[Note: Your demo can’t bring down the entire server in lag. Vanilla redstone might not be a good idea.

Try to do as much as you can yourself. Please state if you have used any of other people's code (including non standard apis), what they do and who
wrote them. (you could use a sign or monitor for this)
]]}
os.sleep(0.5)
--local pos = #titleText+#titleText2+2
local pos = #titleText+2
for i=1,#infoText do
  local col = 0xffffff
  if i%2 ==1 then col = 0xff0000 end
  gpu.setForeground(col,false)
  term.setCursor(1,pos)
  term.write(infoText[i])
  pos = pos+#lines(infoText[i])
end

while true do
  _, _, _, code = event.pull("key_down")
  if code == keyboard.keys.enter then
    gpu.setForeground(0xffffff,false)
    break
  end
end