-----------------------------------------------------------------------------------------------
-- Client Lua Script for OneLastJob
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "MatchingGame"
 
-----------------------------------------------------------------------------------------------
-- OneLastJob Module Definition
-----------------------------------------------------------------------------------------------
local OneLastJob = {} 

-----------------------------------------------------------------------------------------------
-- Local Variables
-----------------------------------------------------------------------------------------------
local introEnabled = false
local victoryEnabled = false
local mySongs = {'small.wav', '2fast2.wav', 'Hands in the Air by 8Ball.wav', 
				 'Represent by Trick Daddy.wav', 'Slum by Titty Boi.wav', 
				 'Block Reincarnated by Shawnna.wav', "Rollin on 20's by Lil' Flip.wav"}
local isPlaying = false


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
	Apollo.RegisterEventHandler("MatchEntered", "OnMatchEntered", self)
	Apollo.RegisterEventHandler("MatchFinished", "OnMatchFinished", self)

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
		Apollo.RegisterSlashCommand("play", "OnPlay", self)
		Apollo.RegisterSlashCommand("stop", "OnStop", self)

		-- Do additional Addon initialization here
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

function OneLastJob:OnChangeIsPlaying()
	isPlaying = false
end

function OneLastJob:OnPlay()
	if isPlaying == false then
		local song = mySongs[ math.random(#mySongs) ]
	    Print(song..' is now playing')
	    Sound.PlayFile(song)
	    isPlaying = true
        self.Timer = ApolloTimer.Create(1, false, "OnChangeIsPlaying", self)
	end
	
end

function OneLastJob:OnStop()
	self.originalVolumeLevel = Apollo.GetConsoleVariable("sound.volumeUI")
	Apollo.SetConsoleVariable("sound.volumeUI", 0)
	Print('Playing Stopped')
	Apollo.SetConsoleVariable("sound.volumeUI", oringalVolumeLevel)
	isPlaying = false
end


-- on PVP Match entered
function OneLastJob:OnMatchEntered()
	self.Timer = ApolloTimer.Create(30, false, "OnPlay", self)
end

function OneLastJob:OnMatchFinished()
	self.imer = ApolloTimer.Create(1, false, "OnPlay", self)
end



-- on timer
function OneLastJob:OnTimer()
	-- Do your timer-related stuff here.
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
-- ItemList Functions
-----------------------------------------------------------------------------------------------
-- populate item list
function OneLastJob:PopulateItemList()
	-- make sure the item list is empty to start with
	self:DestroyItemList()
	
    -- add 20 items
	for i = 1,20 do
        self:AddItem(i)
	end
	
	-- now all the item are added, call ArrangeChildrenVert to list out the list items vertically
	self.wndItemList:ArrangeChildrenVert()
end

-- clear the item list
function OneLastJob:DestroyItemList()
	-- destroy all the wnd inside the list
	for idx,wnd in ipairs(self.tItems) do
		wnd:Destroy()
	end

	-- clear the list item array
	self.tItems = {}
	self.wndSelectedListItem = nil
end

-- add an item into the item list
function OneLastJob:AddItem(i)
	-- load the window item for the list item
	local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.wndItemList, self)
	
	-- keep track of the window item created
	self.tItems[i] = wnd

	-- give it a piece of data to refer to 
	local wndItemText = wnd:FindChild("Text")
	if wndItemText then -- make sure the text wnd exist
		wndItemText:SetText("item " .. i) -- set the item wnd's text to "item i"
		wndItemText:SetTextColor(kcrNormalText)
	end
	wnd:SetData(i)
end

-- when a list item is selected
function OneLastJob:OnListItemSelected(wndHandler, wndControl)
    -- make sure the wndControl is valid
    if wndHandler ~= wndControl then
        return
    end
    
    -- change the old item's text color back to normal color
    local wndItemText
    if self.wndSelectedListItem ~= nil then
        wndItemText = self.wndSelectedListItem:FindChild("Text")
        wndItemText:SetTextColor(kcrNormalText)
    end
    
	-- wndControl is the item selected - change its color to selected
	self.wndSelectedListItem = wndControl
	wndItemText = self.wndSelectedListItem:FindChild("Text")
    wndItemText:SetTextColor(kcrSelectedText)
    
	Print( "item " ..  self.wndSelectedListItem:GetData() .. " is selected.")
end


-----------------------------------------------------------------------------------------------
-- OneLastJob Instance
-----------------------------------------------------------------------------------------------
local OneLastJobInst = OneLastJob:new()
OneLastJobInst:Init()