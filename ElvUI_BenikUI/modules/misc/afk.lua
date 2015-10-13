local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local AFK = E:GetModule('AFK')
local LSM = LibStub('LibSharedMedia-3.0')
local BUI = E:GetModule('BenikUI');

local format, random, lower, upper = string.format, random, string.lower, string.upper
local SPACING = (E.PixelMode and 1 or 5)

-- Credit for the Class logos: ADDOriN @DevianArt
-- http://addorin.deviantart.com/gallery/43689290/World-of-Warcraft-Class-Logos

-- Source wowhead.com
local stats = {
	60,		-- Total deaths
	97,		-- Daily quests completed
	98,		-- Quests completed
	107,	-- Creatures killed
	112,	-- Deaths from drowning
	114,	-- Deaths from falling
	319,	-- Duels won
	320,	-- Duels lost
	321,	-- Total raid and dungeon deaths
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	339,	-- Mounts owned
	342,	-- Epic items acquired
	349,	-- Flight paths taken
	377,	-- Most factions at Exalted
	588,	-- Total Honorable Kills
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	931,	-- Total factions encountered
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL'd
	1088,	-- Kael'thas Sunstrider kills (Tempest Keep)
	1149,	-- Talent tree respecs
	1197,	-- Total kills
	1098,	-- Onyxia kills (Onyxia's Lair)
	1198,	-- Total kills that grant experience or honor
	1339,	-- Mage portal taken most
	1487,	-- Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1716,	-- Battleground with the most Killing Blows
	4687,	-- Victories over the Lich King (Icecrown 25 player)
	5692,	-- Rated battlegrounds played
	5694,	-- Rated battlegrounds won
	6167,	-- Deathwing kills (Dragon Soul)
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
	8632,	-- Garrosh Hellscream (LFR Siege of Orgrimmar)
	
	-- Draenor Raiding stats. Thanks Flodropp for the effort :)
	--[[
	9297,	-- Brackenspore kills (Normal Highmaul)
	9298,	-- Brackenspore kills (Heroic Highmaul)
	9283,	-- Kargath Bladefist defeats (Normal Highmaul)
	9284,	-- Kargath Bladefist defeats (Heroic Highmaul)
	9287,	-- The Butcher kills (Normal Highmaul)
	9288,	-- The Butcher kills (Heroic Highmaul)
	9292,	-- Tectus kills (Normal Highmaul)
	9293,	-- Tectus kills (Heroic Highmaul)
	9302,	-- Twin Ogron kills (Normal Highmaul)
	9303,	-- Twin Ogron kills (Heroic Highmaul)
	9309,	-- Ko'ragh kills (Normal Highmaul)
	9310,	-- Ko'ragh kills (Heroic Highmaul)
	9313,	-- Imperator Mar'gok kills (Normal Highmaul)
	9314,	-- Imperator Mar'gok kills (Heroic Highmaul)
	9317,	-- Gruul kills (Normal Blackrock Foundry)
	9318,	-- Gruul kills (Heroic Blackrock Foundry)
	9321,	-- Oregorger kills (Normal Blackrock Foundry)
	9322,	-- Oregorger kills (Heroic Blackrock Foundry)
	9327,	-- Hans'gar and Franzok kills (Normal Blackrock Foundry)
	9328,	-- Hans'gar and Franzok kills (Heroic Blackrock Foundry)
	9331,	-- Flamebender Ka'graz kills (Normal Blackrock Foundry)
	9332,	-- Flamebender Ka'graz kills (Heroic Blackrock Foundry)
	9336,	-- Beastlord Darmac kills (Normal Blackrock Foundry)
	9337,	-- Beastlord Darmac kills (Heroic Blackrock Foundry)
	9340,	-- Operator Thogar kills (Normal Blackrock Foundry)
	9341,	-- Operator Thogar kills (Heroic Blackrock Foundry)
	9350,	-- Blast Furnace destructions (Normal Blackrock Foundry)
	9351,	-- Blast Furnace destructions (Heroic Blackrock Foundry)
	9355,	-- Kromog kills (Normal Blackrock Foundry)
	9356,	-- Kromog kills (Heroic Blackrock Foundry)
	9359,	-- Iron Maidens kills (Normal Blackrock Foundry)
	9360,	-- Iron Maidens kills (Heroic Blackrock Foundry)
	9363,	-- Warlord Blackhand kills (Normal Blackrock Foundry)
	9364,	-- Warlord Blackhand kills (Heroic Blackrock Foundry)
	]]
	9430,	-- Draenor dungeons completed (final boss defeated)
	9561,	-- Draenor raid boss defeated the most
	9558,	-- Draenor raids completed (final boss defeated)
	10060,	-- Garrison Followers recruited
	10181,	-- Garrision Missions completed
	10184,	-- Garrision Rare Missions completed
}

-- Remove capitals from class except first letter
local function handleClass()
	local lowclass = E.myclass:lower()
    local firstclass = lowclass:gsub("^%l", upper)
	return firstclass
end

-- Create Time
local function createTime()
	local hour, hour24, minute, ampm = tonumber(date("%I")), tonumber(date("%H")), tonumber(date("%M")), date("%p"):lower()
	local sHour, sMinute = GetGameTime()
	
	local localTime = format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute, ampm)
	local localTime24 = format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour24, minute)
	local realmTime = format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute, ampm)
	local realmTime24 = format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute)
	
	if E.db.datatexts.localtime then
		if E.db.datatexts.time24 then
			return localTime24
		else
			return localTime
		end
	else
		if E.db.datatexts.time24 then
			return realmTime24
		else
			return realmTime
		end
	end
end

local monthAbr = {
	[1] = L["Jan"],
	[2] = L["Feb"],
	[3] = L["Mar"],
	[4] = L["Apr"],
	[5] = L["May"],
	[6] = L["Jun"],
	[7] = L["Jul"],
	[8] = L["Aug"],
	[9] = L["Sep"],
	[10] = L["Oct"],
	[11] = L["Nov"],
	[12] = L["Dec"],
}

local daysAbr = {
	[1] = L["Sun"],
	[2] = L["Mon"],
	[3] = L["Tue"],
	[4] = L["Wed"],
	[5] = L["Thu"],
	[6] = L["Fri"],
	[7] = L["Sat"],
}

-- Create Date
local function createDate()
	local curDayName, curMonth, curDay, curYear = CalendarGetDate()
	AFK.AFKMode.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[curDayName], monthAbr[curMonth], curDay, curYear)
end

-- Create random stats
local function createStats()
	local id = stats[random( #stats )]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)
	if result == "--" then result = NONE end
	return format("%s: |cfff0ff00%s|r", name, result)
end

local x, y
local timer = 0
local showTime = 5
local total = 0

local function GetMousePosition()
	x, y = GetCursorPosition();
end

AFK.UpdateTimerBui = AFK.UpdateTimer
function AFK:UpdateTimer()
	self:UpdateTimerBui()

	local createdTime = createTime()
	local minutes = floor(timer/60)
	local neg_seconds = -timer % 60
	
	-- Accurate AFK Timer by catching mouse movements. Credit: Nikita S. Doroshenko,
	-- http://www.wowinterface.com/forums/showthread.php?t=52742
	local nx, ny = GetCursorPosition();
	if x ~= nx and y ~= ny then
		x, y = GetCursorPosition();
		if timer > 0 then
			self.AFKMode.countd.text:SetFormattedText("|cffff8000%s|r", L["Cursor moved. Timer reset."])
			timer = 0
		end
	else
		timer = timer + 1
		if timer > 1 then
			if (minutes -29 >= 0) and (neg_seconds >= 0) then
				self.AFKMode.countd.text:SetFormattedText("|cffff8000"..CAMP_TIMER.."|r", neg_seconds, L["sec"])
				if neg_seconds <= 30 then
					E:Flash(self.AFKMode.countd.text, 0.5, true)
				else
					E:StopFlash(self.AFKMode.countd.text)
				end
			else
				self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00%02d:%02d|r", L["Logout Timer"], minutes -29, neg_seconds)
			end
		end
	end
	GetMousePosition()

	total = total + 1
	if total >= showTime then
		local createdStat = createStats()
		self.AFKMode.statMsg.info:AddMessage(createdStat)
		E:UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 0, 1)
		total = 0
	end

	-- Set the value on log off statusbar
	self.AFKMode.top.style.Status:SetValue(floor(timer))
	
	-- Set time
	self.AFKMode.top.time:SetFormattedText(createdTime)
	
	-- Set Date
	createDate()
	
	-- Don't need the default timer
	self.AFKMode.bottom.time:SetText(nil)
end

AFK.SetAFKBui = AFK.SetAFK
function AFK:SetAFK(status)
	self:SetAFKBui(status)
	
	if (self.isAFK) then
		total = 0
		timer = 0
		self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00-30:00|r", L["Logout Timer"])
		self.AFKMode.statMsg.info:AddMessage(format("|cffb3b3b3%s|r", L["Random Stats"]))
	end
end

--[[local creatures = {
	62835, -- peng
	87257, -- cow
	32398, -- peng2
	15552, -- Doctor Weavil
	48040, -- Pygmy Oaf
	86470, -- Pepe
}

local find = string.find

local function IsFoolsDay()
	if find(date(), '04/01/') then
		return true;
	else
		return false;
	end
end

local function prank(self, status)
	if(InCombatLockdown()) then return end
	if not IsFoolsDay() then return end
	if(status) then
		local id = creatures[random( #creatures )]
		self.AFKMode.bottom.model:SetCreature(id)
		self.AFKMode.bottom.model:SetAnimation(1) -- die
	end
end
hooksecurefunc(AFK, "SetAFK", prank)]]

local classColor = RAID_CLASS_COLORS[E.myclass]

AFK.InitializeBuiAfk = AFK.Initialize
function AFK:Initialize()
	self:InitializeBuiAfk()

	local level = UnitLevel('player')
	local nonCapClass = handleClass()
	local className = E.myclass
	
	-- Create Top frame
	self.AFKMode.top = CreateFrame('Frame', nil, self.AFKMode)
	self.AFKMode.top:SetFrameLevel(0)
	self.AFKMode.top:SetTemplate('Transparent')
	self.AFKMode.top:SetPoint("TOP", self.AFKMode, "TOP", 0, E.Border)
	self.AFKMode.top:SetWidth(GetScreenWidth() + (E.Border*2))
	self.AFKMode.top:SetHeight(GetScreenHeight() * (1 / 20))

	--Style the top frame
	self.AFKMode.top:Style('Under')
	
	-- move the chat lower
	self.AFKMode.chat:SetPoint("TOPLEFT", self.AFKMode.top.style, "TOPLEFT", 4, -4)
	
	-- WoW logo
	self.AFKMode.top.wowlogo = CreateFrame('Frame', nil, self.AFKMode) -- need this to upper the logo layer
	self.AFKMode.top.wowlogo:SetPoint("TOP", self.AFKMode.top, "TOP", 0, -5)
	self.AFKMode.top.wowlogo:SetFrameStrata("MEDIUM")
	self.AFKMode.top.wowlogo:SetSize(300, 150)
	self.AFKMode.top.wowlogo.tex = self.AFKMode.top.wowlogo:CreateTexture(nil, 'OVERLAY')
	self.AFKMode.top.wowlogo.tex:SetTexture("Interface\\Glues\\Common\\GLUES-WOW-WODLOGO")
	self.AFKMode.top.wowlogo.tex:SetInside()
	
	-- Server/Local Time text
	self.AFKMode.top.time = self.AFKMode.top:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.top.time:FontTemplate(nil, 16)
	self.AFKMode.top.time:SetText("")
	self.AFKMode.top.time:SetPoint("RIGHT", self.AFKMode.top, "RIGHT", -20, 0)
	self.AFKMode.top.time:SetJustifyH("LEFT")
	self.AFKMode.top.time:SetTextColor(classColor.r, classColor.g, classColor.b)
	
	-- Date text
	self.AFKMode.top.date = self.AFKMode.top:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.top.date:FontTemplate(nil, 16)
	self.AFKMode.top.date:SetText("")
	self.AFKMode.top.date:SetPoint("LEFT", self.AFKMode.top, "LEFT", 20, 0)
	self.AFKMode.top.date:SetJustifyH("RIGHT")
	self.AFKMode.top.date:SetTextColor(classColor.r, classColor.g, classColor.b)
	
	-- Statusbar on Top frame decor showing time to log off (30mins)
	self.AFKMode.top.style.Status = CreateFrame('StatusBar', nil, self.AFKMode.top.style)
	self.AFKMode.top.style.Status:SetStatusBarTexture((E["media"].normTex))
	self.AFKMode.top.style.Status:SetMinMaxValues(0, 1800)
	self.AFKMode.top.style.Status:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
	self.AFKMode.top.style.Status:SetInside()
	self.AFKMode.top.style.Status:SetValue(0)
	
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 9))
	
	-- Style the bottom frame
	self.AFKMode.bottom:Style('Inside')
	
	-- Move the factiongroup sign to the center
	self.AFKMode.bottom.factionb = CreateFrame('Frame', nil, self.AFKMode) -- need this to upper the faction logo layer
	self.AFKMode.bottom.factionb:SetPoint("BOTTOM", self.AFKMode.bottom, "TOP", 0, -40)
	self.AFKMode.bottom.factionb:SetFrameStrata("MEDIUM")
	self.AFKMode.bottom.factionb:SetSize(220, 220)
	self.AFKMode.bottom.faction:ClearAllPoints()
	self.AFKMode.bottom.faction:SetParent(self.AFKMode.bottom.factionb)
	self.AFKMode.bottom.faction:SetInside()
	-- Apply class texture rather than the faction
	self.AFKMode.bottom.faction:SetTexture('Interface\\AddOns\\ElvUI_BenikUI\\media\\textures\\classIcons\\CLASS-'..className)
	
	-- Add more info in the name and position it to the center
	self.AFKMode.bottom.name:ClearAllPoints()	
	self.AFKMode.bottom.name:SetPoint("TOP", self.AFKMode.bottom.factionb, "BOTTOM")
	self.AFKMode.bottom.name:SetFormattedText("%s - %s \n%s %s %s %s", E.myname, E.myrealm, LEVEL, level, E.myrace, nonCapClass)
	self.AFKMode.bottom.name:SetJustifyH("CENTER")
	self.AFKMode.bottom.name:FontTemplate(nil, 18)	

	-- Lower the guild text size a bit
	self.AFKMode.bottom.guild:ClearAllPoints()
	self.AFKMode.bottom.guild:SetPoint("TOP", self.AFKMode.bottom.name, "BOTTOM", 0, -6)
	self.AFKMode.bottom.guild:FontTemplate(nil, 12)
	self.AFKMode.bottom.guild:SetJustifyH("CENTER")

	-- Add ElvUI name
	self.AFKMode.bottom.logotxt = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.logotxt:FontTemplate(nil, 24)
	self.AFKMode.bottom.logotxt:SetText("ElvUI")
	self.AFKMode.bottom.logotxt:SetPoint("LEFT", self.AFKMode.bottom, "LEFT", 25, 8)
	self.AFKMode.bottom.logotxt:SetTextColor(classColor.r, classColor.g, classColor.b)
	-- and ElvUI version
	self.AFKMode.bottom.etext = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.etext:FontTemplate(nil, 10)
	self.AFKMode.bottom.etext:SetFormattedText("v%s", E.version)
	self.AFKMode.bottom.etext:SetPoint("TOP", self.AFKMode.bottom.logotxt, "BOTTOM")
	self.AFKMode.bottom.etext:SetTextColor(0.7, 0.7, 0.7)
	-- Hide ElvUI logo
	self.AFKMode.bottom.logo:Hide()
	
	-- Add BenikUI name
	self.AFKMode.bottom.benikui = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.benikui:FontTemplate(nil, 24)
	self.AFKMode.bottom.benikui:SetText("BenikUI")
	self.AFKMode.bottom.benikui:SetPoint("RIGHT", self.AFKMode.bottom, "RIGHT", -25, 8)
	self.AFKMode.bottom.benikui:SetTextColor(classColor.r, classColor.g, classColor.b)
	-- and version
	self.AFKMode.bottom.btext = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.btext:FontTemplate(nil, 10)
	self.AFKMode.bottom.btext:SetFormattedText("v%s", BUI.Version)
	self.AFKMode.bottom.btext:SetPoint("TOP", self.AFKMode.bottom.benikui, "BOTTOM")
	self.AFKMode.bottom.btext:SetTextColor(0.7, 0.7, 0.7)
	
	-- Random stats decor (taken from install routine)
	self.AFKMode.statMsg = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.statMsg:Size(418, 72)
	self.AFKMode.statMsg:Point("CENTER", 0, 200)
	
	self.AFKMode.statMsg.bg = self.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.bg:SetPoint('BOTTOM')
	self.AFKMode.statMsg.bg:Size(326, 103)
	self.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	self.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)
	
	self.AFKMode.statMsg.lineTop = self.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.statMsg.lineTop:SetDrawLayer('BACKGROUND', 2)
	self.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineTop:SetPoint("TOP")
	self.AFKMode.statMsg.lineTop:Size(418, 7)
	self.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	
	self.AFKMode.statMsg.lineBottom = self.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.statMsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
	self.AFKMode.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineBottom:SetPoint("BOTTOM")
	self.AFKMode.statMsg.lineBottom:Size(418, 7)
	self.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	
	-- Countdown decor
	self.AFKMode.countd = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.countd:Size(418, 36)
	self.AFKMode.countd:Point("TOP", self.AFKMode.statMsg.lineBottom, "BOTTOM")
	
	self.AFKMode.countd.bg = self.AFKMode.countd:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.countd.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.countd.bg:SetPoint('BOTTOM')
	self.AFKMode.countd.bg:Size(326, 56)
	self.AFKMode.countd.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	self.AFKMode.countd.bg:SetVertexColor(1, 1, 1, 0.7)
	
	self.AFKMode.countd.lineBottom = self.AFKMode.countd:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.countd.lineBottom:SetDrawLayer('BACKGROUND', 2)
	self.AFKMode.countd.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.countd.lineBottom:SetPoint('BOTTOM')
	self.AFKMode.countd.lineBottom:Size(418, 7)
	self.AFKMode.countd.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- 30 mins countdown text
	self.AFKMode.countd.text = self.AFKMode.countd:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.countd.text:FontTemplate(nil, 12)
	self.AFKMode.countd.text:SetPoint("CENTER", self.AFKMode.countd, "CENTER")
	self.AFKMode.countd.text:SetJustifyH("CENTER")
	self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00-30:00|r", L["Logout Timer"])
	self.AFKMode.countd.text:SetTextColor(0.7, 0.7, 0.7)
	
	self.AFKMode.bottom.time:Hide()
	
	-- Random stats frame
	self.AFKMode.statMsg.info = CreateFrame("ScrollingMessageFrame", nil, self.AFKMode.statMsg)
	self.AFKMode.statMsg.info:FontTemplate(nil, 18)
	self.AFKMode.statMsg.info:SetPoint("CENTER", self.AFKMode.statMsg, "CENTER", 0, 0)
	self.AFKMode.statMsg.info:SetSize(800, 24)
	self.AFKMode.statMsg.info:AddMessage(format("|cffb3b3b3%s|r", L["Random Stats"]))
	self.AFKMode.statMsg.info:SetFading(true)
	self.AFKMode.statMsg.info:SetFadeDuration(1)
	self.AFKMode.statMsg.info:SetTimeVisible(4)
	self.AFKMode.statMsg.info:SetJustifyH("CENTER")
	self.AFKMode.statMsg.info:SetTextColor(0.7, 0.7, 0.7)
end