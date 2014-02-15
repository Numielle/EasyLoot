local f = CreateFrame("frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
local function iPrint(msg)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(msg), 1, 0, 0)
end

local auctionEnds = -1
local auctionItem = nil
local auctionState = "none" -- must be either "none", "link", "raid"
local auctionCounterInit = 6

local updateInterval = 1.5 
local lastUpdate = 0 
local function onUpdate()	
	lastUpdate = lastUpdate + arg1 -- elapsed = arg1

	if lastUpdate < updateInterval then return end  
	lastUpdate = 0  		

	if auctionEnds < 0 then return end

	if auctionEnds == auctionCounterInit then
		if auctionState == "link" then
			-- lua equivalent to conditional operator: IsRaidLeader() or IsRaidOfficer() ? "RAID_WARNING" : "RAID"
			local channel = (IsRaidLeader() or IsRaidOfficer()) and "RAID_WARNING" or "RAID"
						
			SendChatMessage(auctionItem.." LINK!", channel)
		end
	elseif auctionEnds > 0 then
		SendChatMessage(tostring(auctionEnds), "RAID")
	elseif auctionEnds == 0 then
		SendChatMessage("Closed!", "RAID")
		auctionState = "none"
	end

  auctionEnds = auctionEnds - 1	
end

local function onEvent() 	
	if event == "CHAT_MSG_SYSTEM" and auctionState == "raid" then		
		local _,_,roll = string.find(arg1, UnitName("player").." rolls (.+)% [(][0-9]+-[0-9]+[)]")		
		
		-- something went wrong
		if not roll then iPrint("Roll couldn't be parsed, please contact author!"); return end 
		
		SendChatMessage(string.format("Raid member #%s is %s!", roll, UnitName("raid"..roll)), "RAID")			
		auctionState = "none"	
	end
end

local function start(msg, state) 
	if not (auctionEnds < 0 and auctionState == "none") then
		iPrint("Please wait for current item distribution to end!")
	elseif not msg or string.len(msg) == 0 then
		iPrint("Please specifiy an item to distribute!")
	else
	auctionItem = msg
    auctionEnds = auctionCounterInit
	auctionState = state
    lastUpdate = updateInterval
	end
end

SLASH_MASTERLOOTING1 = '/loot'
function SlashCmdList.MASTERLOOTING(msg, editbox)	
	start(msg, "link")
end

SLASH_RAIDROLLING1, SLASH_RAIDROLLING2 = "/raidroll", "/rr"
function SlashCmdList.RAIDROLLING(msg, editbox)
	if not (auctionState == "none") then
		iPrint("Please wait for current item distribution to end!")
		return
	end

	auctionState = "raid"
	
	if msg then SendChatMessage(msg.." RAIDROLL", "RAID") end
		
	RandomRoll(1, GetNumRaidMembers())
end

f:SetScript("OnUpdate", onUpdate)
f:SetScript("OnEvent", onEvent)