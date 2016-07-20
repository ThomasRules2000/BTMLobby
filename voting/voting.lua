local component = require("component")
local keyboard = require("keyboard")
local term = require("term")
local event = require("event")
local gpu = component.gpu

local currentPlayer = ""
local function setPlayer(e,_,_,_,name)
	currentPlayer = name
end

local categories = {"Demo", "EEPROM", "Game", "Tool", "Artwork", "Wild"}

local contestants = {
["demo"] = {
		{"Test 1",0}
	},
["eeprom"] = {
		{"Test 2",0}
	},
["game"] = {
		{"Test 3",0}
	},
["tool"] = {
		{"Test 4",0}
	},
["artwork"] = {
		{"Test 5",0}
	},
["wild"] = {
		{"Test 6",0}
	}
}

local voted = {
["demo"] = {},
["eeprom"] = {},
["game"] = {},
["tool"] = {},
["artwork"] = {},
["wild"] = {}
}

local keyListener = event.listen("key_down", setPlayer)

local function main()
	term.clear()
	print("Welcome to the VotingSystem 5000. Please select the Category you wish to vote in")
	for i =1,#categories do
		print(categories[i])
	end
	print("")
	local cat = ""
	local valid = false
	repeat
		io.write("Category: ")
		cat = io.read():lower()
		for i=1,#categories do
			if cat == categories[i]:lower() then
				valid = true
				break
			end
		end
		if not valid then
			print("Invalid Input! Please select the Category you wish to vote in")
			os.sleep(0.5)
		end
	until valid
	
	for i = 1,#voted[cat] do
		if currentPlayer == voted[cat][i] then
			print("You have already voted in this category")
			os.sleep(0.5)
			return
		end
	end
	
	print("")
	print("Please select the Player you wish to vote for")
	for i=1,#contestants[cat] do
		print(contestants[cat][i][1])
	end
	print("")
	local vote = ""
	valid = false
	repeat
		io.write("Contestant:")
		vote = io.read():lower()
		for i=1,#contestants[cat] do 
			if vote == contestants[cat][i][1]:lower() then
				for i = 1,#voted[cat] do
					if currentPlayer == voted[cat][i] then
						print("You have already voted in this category")
						os.sleep(0.2)
						return
					end
				end
				valid = true
				contestants[cat][i][2] = contestants[cat][i][2]+1
				table.insert(voted[cat],currentPlayer)
				break
			end
		end
		if not valid then
			print("Invalid Input! Please select the Player you wish to vote for")
			os.sleep(0.5)
		end
	until valid
	print("")
	print("Your Vote has been counted! Thank you for voting with the VotingSystem 5000")
	os.sleep(0.5)
end

while true do
	main()
end