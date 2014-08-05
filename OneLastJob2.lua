-----------------------------------------------------------------------------------------------
-- Client Lua Script for OneLastJob
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "MatchingGame"
require "ChatSystemLib"
require "ChatChannelLib"
require "GroupLib"
 
-----------------------------------------------------------------------------------------------
-- OneLastJob Module Definition
-----------------------------------------------------------------------------------------------
local OneLastJob = {} 

-----------------------------------------------------------------------------------------------
-- Local Variables
-----------------------------------------------------------------------------------------------
local introEnabled = false
local victoryEnabled = false
local leader = false
local mySongs = {'small.wav', '2fast2.wav', 'Hands in the Air by 8Ball.wav', 
				 'Represent by Trick Daddy.wav', 'Slum by Titty Boi.wav', 
				 'Block Reincarnated by Shawnna.wav', "Rollin on 20's by Lil' Flip.wav",
				 'Assembling the Team.wav', 'Click Click Boom by Saliva.wav', "Dominic's Story.wav", 
				 'Fast and Furious by Ja Rule.wav', 'Furiously Dangerous.wav', 
				 'Hey Mami by FannyPack.wav', "Life Ain't a Game by Ja Rule.wav",
				 'Lock it Down by Digital Assasins.wav', 'Polkas Palabras by Molotov.wav',
				 'Rollin by Limp Bizkit.wav', 'Saucin.wav', 'Six Days by Dj Shadow and Mos Def.wav',
				 'Suicide by Scarface.wav', 'Tokyo Drift by Teriyaki Boyz.wav', 'Bawitaba by Kid Rock.wav',
				 'Brian Saves Dom.wav', 'Cho Large by Teriyaki Boyz.wav', 'Crawling in the Dark by Hoobastank.wav', 
				 'Debonaire by Dope.wav', 'Ditch the Fuzz.wav', 'Enter the Eclipse.wav',
				 'Get Back by Ludacris.wav', "Gettin' It by Chingy.wav", 'Hell Yeah by Dead Prez.wav', 'Hot Fuji.wav',
				 'Megaton.wav', 'Move Bitch by Ludacris.wav', 'Mustang Rismo by Brian Tyler feat Slash.wav', 
				 'Number One Spot by Ludacris.wav', 'Oye by Pit Bull.wav', 'Peel Off by Jin.wav', 
				 'Pov City Anthem by Caddillac Tah and Ja Rule.wav', 'Pump It Up by Joe Budden.wav',
				 'Put It On Me by Ja Rule.wav', 'Race Against Time Part 2 by Tank and Ja Rule.wav', 'Race Wars.wav'
				 'Resound by Dragon Ash.wav', 'Restless by Evil Nine.wav', 'Rollout by Ludacris.wav',
				 'Saturday by Ludacris.wav', 'Shade Sheist by Cali Diseaz.wav', "Speed of Light(Dominic's Story Part 2).wav", 
				 'Stand Up by Ludacris.wav', 'The Team Arrives.wav', 'Title Sequence(Vocals).wav', 
				 'Tudunn Tudunn Tudunn(Make U Jump) by Funkmaster Flex.wav', "What's Your Fantasy by Ludacris.wav", 
				 "You'll Be Under My Wheels by The Prodigy.wav"}
local isPlaying = false
local originalVolumeLevel = 1

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local kcrSelectedText = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local kcrNormalText = ApolloColor.new("UI_BtnTextHoloNormal")
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function OneLastJob:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	o.tItems = {} -- keep track of all the list items
	o.wndSelectedListItem = nil -- keep track of which list item is currently selected

    return o
end

function OneLastJob:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- OneLastJob OnLoad
-----------------------------------------------------------------------------------------------
function OneLastJob:OnLoad()
	--EVENT REGISTRATION
	Apollo.RegisterEventHandler("MatchingGameReady", "OnMatchReady", self)
	Apollo.RegisterEventHandler("MatchEntered", "OnMatchEntered", self)
	Apollo.RegisterEventHandler("MatchFinished", "OnMatchFinished", self)
	Apollo.RegisterEventHandler("ChatMessage","OnChatMessage", self)

    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("OneLastJob2.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- OneLastJob OnDocLoaded
-----------------------------------------------------------------------------------------------
function OneLastJob:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "OneLastJob2Form", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("onelastjob", "OnOneLastJobOn", self)
		Apollo.RegisterSlashCommand("play", "OnSyncPlaylist", self)
		Apollo.RegisterSlashCommand("stop", "OnStop", self)
		Apollo.RegisterSlashCommand("testsend", "OnTestSend", self)

		-- Do additional Addon initialization here
		--Create Chat Channel for Cross-Addon Communication
		ChatSystemLib.JoinChannel("OneLastSync");
	end
end

-----------------------------------------------------------------------------------------------
-- OneLastJob Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/onelastjob"



function OneLastJob:OnOneLastJobOn()
	
	self.wndMain:Invoke() -- show the window
	

	Sound.PlayFile("small.wav")

end


--------------
--Chat Parsing
--------------
function OneLastJob:OnChangeIsPlaying()
	isPlaying = false
end

function OneLastJob:OnChatMessage(channelCurrent, tMessage)
	local message = tMessage.arMessageSegments[1].strText
	
	if channelCurrent:GetName() == "OneLastSync" then	
		OneLastJob:OnPlay(message)
	end
end

function OneLastJob:OnSyncPlaylist()
	local trackNumber = math.random(#mySongs)
	for _,channel in pairs(ChatSystemLib.GetChannels()) do
		if channel:GetName() == "OneLastSync" then
			channel:Send(trackNumber)
		end
	end
end

function OneLastJob:OnPlay(trackNumberStr)
	if isPlaying == false then
		--local song = mySongs[ math.random(#mySongs) ]
		local trackNumber = tonumber(trackNumberStr)
		local song
		if(type(trackNumber) == 'number') then
			song = mySongs[ trackNumber ]
		else
			song = mySongs[ math.random(#mySongs) ]
		end
	    Print(song..' is now playing')
	    Sound.PlayFile(song)
	    isPlaying = true
        self.Timer = ApolloTimer.Create(1, false, "OnChangeIsPlaying", self)
	end
	
end

function OneLastJob:OnStop()
	originalVolumeLevel = Apollo.GetConsoleVariable("sound.volumeUI")
	Apollo.SetConsoleVariable("sound.volumeUI", 0)
	Print('Playing Stopped')
	self.Timer = ApolloTimer.Create(.1, false, "OnRestoreVolumeLevels", self)
	isPlaying = false
end

function OneLastJob:OnRestoreVolumeLevels()
	Apollo.SetConsoleVariable("sound.volumeUI", originalVolumeLevel)
end



-- PVP EVENTS
function OneLastJob:OnMatchReady()
	if GroupLib.InGroup() and GroupLib.AmILeader() then
		leader = true
		Print("You are the group leader")
		Print("Leader is "..tostring(leader))
	elseif not GroupLib.InGroup() then 
		leader = true
		Print("You are not in a group, but you are still the leader")
		Print("Leader is "..tostring(leader))
	end
end

function OneLastJob:OnMatchEntered()
	Print("If I said I was leader that would be "..tostring(leader))
	if leader then
		self.Timer = ApolloTimer.Create(30, false, "OnSyncPlaylist", self)
	end
end

function OneLastJob:OnMatchFinished()
	if leader then
		OneLastJob:OnSyncPlaylist()
	end
	leader = false
end

-----------------------------------------------------------------------------------------------
-- OneLastJobForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function OneLastJob:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function OneLastJob:OnCancel()
	self.wndMain:Close() -- hide the window
end

-----------------------------------------------------------------------------------------------
-- OneLastJob Instance
-----------------------------------------------------------------------------------------------
local OneLastJobInst = OneLastJob:new()
OneLastJobInst:Init()