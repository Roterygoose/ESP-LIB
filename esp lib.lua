--[[
	Universal Extra-Sensory Perception (ESP) Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys
	- Box						  > [Players, NPCs & Parts]
	- Health Bar				  > [Players & NPCs]
	- Health Text				  > [Players & NPCs]
]]

--// Caching
local game = game
local assert, loadstring, select, next, type, typeof, pcall, xpcall, setmetatable, getmetatable, tick, warn = assert, loadstring, select, next, type, typeof, pcall, xpcall, setmetatable, getmetatable, tick, warn
local mathfloor, mathabs, mathcos, mathsin, mathrad, mathdeg, mathmin, mathmax, mathclamp, mathrandom = math.floor, math.abs, math.cos, math.sin, math.rad, math.deg, math.min, math.max, math.clamp, math.random
local stringformat, stringfind, stringchar = string.format, string.find, string.char
local unpack = table.unpack
local wait, spawn = task.wait, task.spawn
local getgenv, getrawmetatable, getupvalue, gethiddenproperty, cloneref, clonefunction = getgenv, getrawmetatable, debug.getupvalue, gethiddenproperty, cloneref or function(...)
	return ...
end, clonefunction or function(...)
	return ...
end

--// Custom Drawing Library
if not Drawing or not Drawing.new or not Drawing.Fonts then
	loadstring(game.HttpGet(game, "https://pastebin.com/raw/huyiRsK0"))()

	repeat
		wait(0)
	until Drawing and Drawing.new and type(Drawing.new) == "function" and Drawing.Fonts and type(Drawing.Fonts) == "table"
end

local Vector2new, Vector3zero, CFramenew = Vector2.new, Vector3.zero, CFrame.new
local Drawingnew, DrawingFonts = Drawing.new, Drawing.Fonts
local Color3fromRGB, Color3fromHSV = Color3.fromRGB, Color3.fromHSV

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	__index = function(self, Index)
		return self[Index]
	end,
	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local getrenderproperty, setrenderproperty, cleardrawcache = getrenderproperty or __index, setrenderproperty or __newindex, cleardrawcache

local _get, _set = function(self, Index)
	return self[Index]
end, function(self, Index, Value)
	self[Index] = Value
end

if identifyexecutor() == "Solara" then
	local DrawQuad = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/Exunys/Custom-Quad-Render-Object/main/Main.lua"))()
	local _Drawingnew = clonefunction(Drawing.new)

	Drawingnew = function(...)
		return ({...})[1] == "Quad" and DrawQuad(...) or _Drawingnew(...)
	end
end

local _GetService = __index(game, "GetService")
local FindFirstChild, WaitForChild = __index(game, "FindFirstChild"), __index(game, "WaitForChild")
local IsA = __index(game, "IsA")

local GetService = function(Service)
	return cloneref(_GetService(game, Service))
end

local Workspace = GetService("Workspace")
local Players = GetService("Players")
local RunService = GetService("RunService")
local UserInputService = GetService("UserInputService")

local CurrentCamera = __index(Workspace, "CurrentCamera")
local LocalPlayer = __index(Players, "LocalPlayer")

local FindFirstChildOfClass = function(self, ...)
	return typeof(self) == "Instance" and self.FindFirstChildOfClass(self, ...)
end

local Cache = {
	WorldToViewportPoint = __index(CurrentCamera, "WorldToViewportPoint"),
	GetPlayers = __index(Players, "GetPlayers"),
	GetPlayerFromCharacter = __index(Players, "GetPlayerFromCharacter"),
	GetMouseLocation = __index(UserInputService, "GetMouseLocation")
}

local WorldToViewportPoint = function(...)
	return Cache.WorldToViewportPoint(CurrentCamera, ...)
end

local GetPlayers = function()
	return Cache.GetPlayers(Players)
end

local GetPlayerFromCharacter = function(...)
	return Cache.GetPlayerFromCharacter(Players, ...)
end

local GetMouseLocation = function()
	return Cache.GetMouseLocation(UserInputService)
end

local IsDescendantOf = function(self, ...)
	return typeof(self) == "Instance" and self.IsDescendantOf(self, ...)
end

local Connect, Disconnect = __index(game, "DescendantAdded").Connect

--// Variables
local Inf, Nan, Loaded = 1 / 0, 0 / 0, false

--// Checking for multiple processes
if ExunysDeveloperESP and ExunysDeveloperESP.Exit then
	ExunysDeveloperESP:Exit()
end

--// Settings
getgenv().ExunysDeveloperESP = {
	DeveloperSettings = {
		Path = "Exunys Developer/Exunys ESP/Configuration.cfg",
		UnwrapOnCharacterAbsence = false,
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1,
		WidthBoundary = 1.5
	},

	Settings = {
		Enabled = true,
		PartsOnly = false,
		TeamCheck = false,
		AliveCheck = true,
		LoadConfigOnLaunch = true,
		EnableTeamColors = false,
		TeamColor = Color3fromRGB(170, 170, 255)
	},

	Properties = {
		Box = {
			Enabled = true,
			RainbowColor = false,
			RainbowOutlineColor = false,

			Color = Color3fromRGB(255, 255, 255),
			Transparency = 1,
			Thickness = 1,
			Filled = false,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true
		},

		HealthBar = {
			Enabled = true,
			RainbowOutlineColor = false,
			Offset = 4,
			Blue = 100,
			Position = 3,

			Thickness = 1,
			Transparency = 1,

			OutlineColor = Color3fromRGB(0, 0, 0),
			Outline = true
		},
		
		HealthText = {
			Enabled = true,
			RainbowOutlineColor = false,
			Offset = 4,
			Position = 3,
			Size = 13,
			Font = DrawingFonts.UI,
			Outline = true,
			
			Transparency = 1,
			OutlineColor = Color3fromRGB(0, 0, 0)
		}
	},

	UtilityAssets = {
		WrappedObjects = {},
		ServiceConnections = {}
	}
}

local Environment = getgenv().ExunysDeveloperESP

--// Functions
local function Recursive(Table, Callback)
	for Index, Value in next, Table do
		Callback(Index, Value)

		if type(Value) == "table" then
			Recursive(Value, Callback)
		end
	end
end

local CoreFunctions = {
	ConvertVector = function(Vector)
		return Vector2new(Vector.X, Vector.Y)
	end,

	GetColorFromHealth = function(Health, MaxHealth, Blue)
		return Color3fromRGB(255 - mathfloor(Health / MaxHealth * 255), mathfloor(Health / MaxHealth * 255), Blue or 0)
	end,

	GetRainbowColor = function()
		local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed

		return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
	end,

	GetLocalCharacterPosition = function()
		local LocalCharacter = __index(LocalPlayer, "Character")
		local LocalPlayerCheckPart = LocalCharacter and (__index(LocalCharacter, "PrimaryPart") or FindFirstChild(LocalCharacter, "Head"))

		return LocalPlayerCheckPart and __index(LocalPlayerCheckPart, "Position") or __index(CurrentCamera, "CFrame").Position
	end,

	GenerateHash = function(Bits)
		local Result = ""

		for _ = 1, Bits do
			Result ..= ("EXUNYS_ESP")[mathrandom(1, 2) == 1 and "upper" or "lower"](stringchar(mathrandom(97, 122)))
		end

		return Result
	end,

	CalculateBoundingBox = function(Object)
		Object = type(Object) == "table" and Object.Object or Object

		local IsAPlayer = IsA(Object, "Player")
		local Part = IsAPlayer and (FindFirstChild(Players, __index(Object, "Name")) and __index(Object, "Character"))
		Part = IsAPlayer and Part and (__index(Part, "PrimaryPart") or FindFirstChild(Part, "HumanoidRootPart")) or Object

		if not Part or IsA(Part, "Player") then
			return nil, false
		end

		-- Get the model that contains the part
		local Model = IsAPlayer and __index(Object, "Character") or __index(Part, "Parent")
		if not Model or not IsA(Model, "Model") then
			return nil, false
		end

		-- Calculate bounding box corners
		local CF = __index(Part, "CFrame")
		local Size = Vector3zero
		
		-- Try to get the actual model size if possible
		if pcall(function() Size = __index(Model, "GetExtentsSize") and __index(Model, "GetExtentsSize")(Model) end) then
			-- Use model extents size
		else
			-- Fallback to part size for non-models
			Size = __index(Part, "Size")
		end

		local Corners = {
			CF * CFramenew(Size.X/2, Size.Y/2, Size.Z/2),  -- Top Front Right
			CF * CFramenew(-Size.X/2, Size.Y/2, Size.Z/2), -- Top Front Left
			CF * CFramenew(Size.X/2, -Size.Y/2, Size.Z/2), -- Bottom Front Right
			CF * CFramenew(-Size.X/2, -Size.Y/2, Size.Z/2),-- Bottom Front Left
			CF * CFramenew(Size.X/2, Size.Y/2, -Size.Z/2), -- Top Back Right
			CF * CFramenew(-Size.X/2, Size.Y/2, -Size.Z/2),-- Top Back Left
			CF * CFramenew(Size.X/2, -Size.Y/2, -Size.Z/2),-- Bottom Back Right
			CF * CFramenew(-Size.X/2, -Size.Y/2, -Size.Z/2) -- Bottom Back Left
		}

		-- Convert corners to screen space
		local ScreenCorners = {}
		local AllOnScreen = true
		
		for i, Corner in ipairs(Corners) do
			local ScreenPos, OnScreen = WorldToViewportPoint(Corner.Position)
			ScreenCorners[i] = Vector2new(ScreenPos.X, ScreenPos.Y)
			if not OnScreen then
				AllOnScreen = false
			end
		end

		return ScreenCorners, AllOnScreen
	end,

	GetColor = function(Player, DefaultColor)
		local Settings, TeamCheckOption = Environment.Settings, Environment.DeveloperSettings.TeamCheckOption

		return Settings.EnableTeamColors and __index(Player, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) and Settings.TeamColor or DefaultColor
	end
}

local UpdatingFunctions = {
	Box = function(Entry, BoxLines, BoxOutlineLines)
		local Settings = Environment.Properties.Box

		local ScreenCorners, OnScreen = CoreFunctions.CalculateBoundingBox(Entry)

		-- Update visibility
		for i = 1, 12 do
			setrenderproperty(BoxLines[i], "Visible", OnScreen)
			if Settings.Outline then
				setrenderproperty(BoxOutlineLines[i], "Visible", OnScreen)
			end
		end

		if OnScreen then
			-- Update line properties
			for i = 1, 12 do
				for Index, Value in next, Settings do
					if Index == "Color" or Index == "OutlineColor" then
						continue
					end

					if not pcall(getrenderproperty, BoxLines[i], Index) then
						continue
					end

					setrenderproperty(BoxLines[i], Index, Value)
					if Settings.Outline then
						setrenderproperty(BoxOutlineLines[i], Index, Value)
					end
				end

				setrenderproperty(BoxLines[i], "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and CoreFunctions.GetRainbowColor() or Settings.Color))
				
				if Settings.Outline then
					setrenderproperty(BoxOutlineLines[i], "Color", Settings.RainbowOutlineColor and CoreFunctions.GetRainbowColor() or Settings.OutlineColor)
					setrenderproperty(BoxOutlineLines[i], "Thickness", Settings.Thickness + 1)
				end
			end

			-- Define box edges (12 lines for a complete box)
			local Edges = {
				{1, 2}, {2, 4}, {4, 3}, {3, 1}, -- Front face
				{5, 6}, {6, 8}, {8, 7}, {7, 5}, -- Back face
				{1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Connecting edges
			}

			-- Update line positions
			for i, Edge in ipairs(Edges) do
				local FromCorner, ToCorner = ScreenCorners[Edge[1]], ScreenCorners[Edge[2]]
				setrenderproperty(BoxLines[i], "From", FromCorner)
				setrenderproperty(BoxLines[i], "To", ToCorner)
				
				if Settings.Outline then
					setrenderproperty(BoxOutlineLines[i], "From", FromCorner)
					setrenderproperty(BoxOutlineLines[i], "To", ToCorner)
				end
			end
		end
	end,

	HealthBar = function(Entry, MainObject, OutlineObject, Humanoid)
		local Settings = Environment.Properties.HealthBar

		local ScreenCorners, OnScreen = CoreFunctions.CalculateBoundingBox(Entry)

		setrenderproperty(MainObject, "Visible", OnScreen)
		setrenderproperty(OutlineObject, "Visible", OnScreen and Settings.Outline)

		if getrenderproperty(MainObject, "Visible") then
			for Index, Value in next, Settings do
				if Index == "Color" then
					continue
				end

				if not pcall(getrenderproperty, MainObject, Index) then
					continue
				end

				setrenderproperty(MainObject, Index, Value)
			end

			Humanoid = Humanoid or FindFirstChildOfClass(__index(Entry.Object, "Character"), "Humanoid")

			local MaxHealth = Humanoid and __index(Humanoid, "MaxHealth") or 100
			local Health = Humanoid and mathclamp(__index(Humanoid, "Health"), 0, MaxHealth) or 0

			local Offset = mathclamp(Settings.Offset, 4, 12)

			setrenderproperty(MainObject, "Color", CoreFunctions.GetColorFromHealth(Health, MaxHealth, Settings.Blue))

			-- Calculate health bar position based on bounding box
			local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
			for _, Corner in ipairs(ScreenCorners) do
				minX = mathmin(minX, Corner.X)
				maxX = mathmax(maxX, Corner.X)
				minY = mathmin(minY, Corner.Y)
				maxY = mathmax(maxY, Corner.Y)
			end

			local BoxWidth = maxX - minX
			local BoxHeight = maxY - minY

			if Settings.Position == 1 then -- Top
				setrenderproperty(MainObject, "From", Vector2new(minX, minY - Offset))
				setrenderproperty(MainObject, "To", Vector2new(minX + (Health / MaxHealth) * BoxWidth, minY - Offset))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(minX - 1, minY - Offset))
					setrenderproperty(OutlineObject, "To", Vector2new(minX + BoxWidth + 1, minY - Offset))
				end
			elseif Settings.Position == 2 then -- Bottom
				setrenderproperty(MainObject, "From", Vector2new(minX, maxY + Offset))
				setrenderproperty(MainObject, "To", Vector2new(minX + (Health / MaxHealth) * BoxWidth, maxY + Offset))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(minX - 1, maxY + Offset))
					setrenderproperty(OutlineObject, "To", Vector2new(minX + BoxWidth + 1, maxY + Offset))
				end
			elseif Settings.Position == 3 then -- Left
				setrenderproperty(MainObject, "From", Vector2new(minX - Offset, maxY))
				setrenderproperty(MainObject, "To", Vector2new(minX - Offset, maxY - (Health / MaxHealth) * BoxHeight))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(minX - Offset, maxY + 1))
					setrenderproperty(OutlineObject, "To", Vector2new(minX - Offset, maxY - BoxHeight - 1))
				end
			elseif Settings.Position == 4 then -- Right
				setrenderproperty(MainObject, "From", Vector2new(maxX + Offset, maxY))
				setrenderproperty(MainObject, "To", Vector2new(maxX + Offset, maxY - (Health / MaxHealth) * BoxHeight))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(maxX + Offset, maxY + 1))
					setrenderproperty(OutlineObject, "To", Vector2new(maxX + Offset, maxY - BoxHeight - 1))
				end
			else
				Settings.Position = 3
			end

			if Settings.Outline then
				setrenderproperty(OutlineObject, "Color", Settings.RainbowOutlineColor and CoreFunctions.GetRainbowColor() or Settings.OutlineColor)
				setrenderproperty(OutlineObject, "Thickness", Settings.Thickness + 1)
				setrenderproperty(OutlineObject, "Transparency", Settings.Transparency)
			end
		end
	end,
	
	HealthText = function(Entry, TextObject, OutlineObject, Humanoid)
		local Settings = Environment.Properties.HealthText

		local ScreenCorners, OnScreen = CoreFunctions.CalculateBoundingBox(Entry)

		setrenderproperty(TextObject, "Visible", OnScreen)
		setrenderproperty(OutlineObject, "Visible", OnScreen and Settings.Outline)

		if getrenderproperty(TextObject, "Visible") then
			for Index, Value in next, Settings do
				if Index == "Color" or Index == "Text" or Index == "Position" then
					continue
				end

				if not pcall(getrenderproperty, TextObject, Index) then
					continue
				end

				setrenderproperty(TextObject, Index, Value)
			end

			Humanoid = Humanoid or FindFirstChildOfClass(__index(Entry.Object, "Character"), "Humanoid")

			local MaxHealth = Humanoid and __index(Humanoid, "MaxHealth") or 100
			local Health = Humanoid and mathclamp(__index(Humanoid, "Health"), 0, MaxHealth) or 0
			local HealthPercentage = Health / MaxHealth

			-- Calculate health bar position based on bounding box
			local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
			for _, Corner in ipairs(ScreenCorners) do
				minX = mathmin(minX, Corner.X)
				maxX = mathmax(maxX, Corner.X)
				minY = mathmin(minY, Corner.Y)
				maxY = mathmax(maxY, Corner.Y)
			end

			local BoxWidth = maxX - minX
			local BoxHeight = maxY - minY

			local HealthColor = CoreFunctions.GetColorFromHealth(Health, MaxHealth, 0)
			setrenderproperty(TextObject, "Color", HealthColor)
			setrenderproperty(TextObject, "Text", tostring(mathfloor(Health)))

			local TextPosition
			local Offset = mathclamp(Settings.Offset, 4, 12)

			if Settings.Position == 1 then -- Top
				TextPosition = Vector2new(minX - 20, minY - Offset - 6)
			elseif Settings.Position == 2 then -- Bottom
				TextPosition = Vector2new(minX - 20, maxY + Offset - 6)
			elseif Settings.Position == 3 then -- Left
				TextPosition = Vector2new(minX - Offset - 20, maxY - BoxHeight * HealthPercentage - 6)
			elseif Settings.Position == 4 then -- Right
				TextPosition = Vector2new(maxX + Offset - 20, maxY - BoxHeight * HealthPercentage - 6)
			else
				Settings.Position = 3
				TextPosition = Vector2new(minX - Offset - 20, maxY - BoxHeight * HealthPercentage - 6)
			end

			setrenderproperty(TextObject, "Position", TextPosition)

			if Settings.Outline then
				setrenderproperty(OutlineObject, "Position", TextPosition + Vector2new(1, 1))
				setrenderproperty(OutlineObject, "Color", Settings.RainbowOutlineColor and CoreFunctions.GetRainbowColor() or Settings.OutlineColor)
				setrenderproperty(OutlineObject, "Text", tostring(mathfloor(Health)))
				setrenderproperty(OutlineObject, "Transparency", Settings.Transparency)
				setrenderproperty(OutlineObject, "Size", Settings.Size)
				setrenderproperty(OutlineObject, "Font", Settings.Font)
			end
		end
	end
}

local CreatingFunctions = {
	Box = function(Entry)
		local Allowed = Entry.Allowed

		if type(Allowed) == "table" and type(Allowed.Box) == "boolean" and not Allowed.Box then
			return
		end

		local Settings = Environment.Properties.Box

		-- Create 12 lines for the box (4 front, 4 back, 4 connecting)
		local BoxLines = {}
		local BoxOutlineLines = {}
		
		for i = 1, 12 do
			BoxLines[i] = Drawingnew("Line")
			if Settings.Outline then
				BoxOutlineLines[i] = Drawingnew("Line")
			end
		end

		Entry.Visuals.Box = {Lines = BoxLines, OutlineLines = BoxOutlineLines}

		Entry.Connections.Box = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
			local Functionable, Ready = pcall(function()
				return Environment.Settings.Enabled and Settings.Enabled and Entry.Checks.Ready
			end)

			if not Functionable then
				for i = 1, 12 do
					pcall(BoxLines[i].Remove, BoxLines[i])
					if Settings.Outline then
						pcall(BoxOutlineLines[i].Remove, BoxOutlineLines[i])
					end
				end
				return Disconnect(Entry.Connections.Box)
			end

			if Ready then
				UpdatingFunctions.Box(Entry, BoxLines, BoxOutlineLines)
			else
				for i = 1, 12 do
					setrenderproperty(BoxLines[i], "Visible", false)
					if Settings.Outline then
						setrenderproperty(BoxOutlineLines[i], "Visible", false)
					end
				end
			end
		end)
	end,

	HealthBar = function(Entry)
		local Allowed = Entry.Allowed

		if type(Allowed) == "table" and type(Allowed.HealthBar) == "boolean" and not Allowed.HealthBar then
			return
		end

		local Humanoid = FindFirstChildOfClass(__index(Entry.Object, "Parent"), "Humanoid")

		if not Entry.IsAPlayer and not Humanoid then
			return
		end

		local Settings = Environment.Properties.HealthBar

		local Outline = Drawingnew("Line")
		local OutlineObject = Outline

		local Main = Drawingnew("Line")
		local MainObject = Main

		Entry.Visuals.HealthBar[1] = Main
		Entry.Visuals.HealthBar[2] = Outline

		Entry.Connections.HealthBar = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
			local Functionable, Ready = pcall(function()
				return Environment.Settings.Enabled and Settings.Enabled and Entry.Checks.Ready
			end)

			if not Functionable then
				pcall(Main.Remove, Main)
				pcall(Outline.Remove, Outline)

				return Disconnect(Entry.Connections.HealthBar)
			end

			if Ready then
				UpdatingFunctions.HealthBar(Entry, MainObject, OutlineObject, Humanoid)
			else
				setrenderproperty(MainObject, "Visible", false)
				setrenderproperty(OutlineObject, "Visible", false)
			end
		end)
	end,
	
	HealthText = function(Entry)
		local Allowed = Entry.Allowed

		if type(Allowed) == "table" and type(Allowed.HealthText) == "boolean" and not Allowed.HealthText then
			return
		end

		local Humanoid = FindFirstChildOfClass(__index(Entry.Object, "Parent"), "Humanoid")

		if not Entry.IsAPlayer and not Humanoid then
			return
		end

		local Settings = Environment.Properties.HealthText

		local Outline = Drawingnew("Text")
		local OutlineObject = Outline

		local Main = Drawingnew("Text")
		local MainObject = Main

		Entry.Visuals.HealthText = {Main, Outline}

		Entry.Connections.HealthText = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
			local Functionable, Ready = pcall(function()
				return Environment.Settings.Enabled and Settings.Enabled and Entry.Checks.Ready
			end)

			if not Functionable then
				pcall(Main.Remove, Main)
				pcall(Outline.Remove, Outline)

				return Disconnect(Entry.Connections.HealthText)
			end

			if Ready then
				UpdatingFunctions.HealthText(Entry, MainObject, OutlineObject, Humanoid)
			else
				setrenderproperty(MainObject, "Visible", false)
				setrenderproperty(OutlineObject, "Visible", false)
			end
		end)
	end
}

local UtilityFunctions = {
	InitChecks = function(self, Entry)
		if not Entry.IsAPlayer and not Entry.PartHasCharacter and not Entry.RenderDistance then
			return
		end

		local Player = Entry.Object
		local Checks = Entry.Checks
		local Hash = Entry.Hash

		local IsAPlayer = Entry.IsAPlayer
		local PartHasCharacter = Entry.PartHasCharacter

		local Settings = Environment.Settings

		local DeveloperSettings = Environment.DeveloperSettings

		local LocalCharacterPosition = CoreFunctions.GetLocalCharacterPosition()

		Entry.Connections.UpdateChecks = Connect(__index(RunService, DeveloperSettings.UpdateMode), function()
			local RenderDistance = Entry.RenderDistance

			if not IsAPlayer and not PartHasCharacter then
				Checks.Ready = (__index(Player, "Position") - LocalCharacterPosition).Magnitude <= RenderDistance; return
			end

			if not IsAPlayer then
				local PartHumanoid = FindFirstChildOfClass(__index(Player, "Parent"), "Humanoid")

				Checks.Ready = PartHasCharacter and PartHumanoid and IsDescendantOf(Player, Workspace)

				if not Checks.Ready then
					return self.UnwrapObject(Hash)
				end

				local IsInDistance = (__index(Player, "Position") - CoreFunctions.GetLocalCharacterPosition()).Magnitude <= RenderDistance

				if Settings.AliveCheck then
					Checks.Alive = __index(PartHumanoid, "Health") > 0
				end

				Checks.Ready = Checks.Ready and Checks.Alive and IsInDistance and Environment.Settings.EntityESP

				return
			end

			local Character = __index(Player, "Character")
			local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")
			local Head = Character and FindFirstChild(Character, "Head")

			local IsInDistance

			if Character and IsDescendantOf(Character, Workspace) and Humanoid and Head then
				local TeamCheckOption = DeveloperSettings.TeamCheckOption

				Checks.Alive = true
				Checks.Team = true

				if Settings.AliveCheck then
					Checks.Alive = __index(Humanoid, "Health") > 0
				end

				if Settings.TeamCheck then
					Checks.Team = __index(Player, TeamCheckOption) ~= __index(LocalPlayer, TeamCheckOption)
				end

				IsInDistance = (__index(Head, "Position") - LocalCharacterPosition).Magnitude <= RenderDistance
			else
				Checks.Alive = false
				Checks.Team = false

				if DeveloperSettings.UnwrapOnCharacterAbsence then
					self.UnwrapObject(Hash)
				end
			end

			Checks.Ready = Checks.Alive and Checks.Team and not Settings.PartsOnly and IsInDistance

			if Checks.Ready then
				local Part = IsAPlayer and (FindFirstChild(Players, __index(Player, "Name")) and __index(Player, "Character"))
				Part = IsAPlayer and (Part and (__index(Part, "PrimaryPart") or FindFirstChild(Part, "HumanoidRootPart"))) or Player

				Entry.RigType = Humanoid and FindFirstChild(__index(Part, "Parent"), "Torso") and "R6" or "R15"
				Entry.RigType = Entry.RigType == "N/A" and Humanoid and (__index(Humanoid, "RigType") == 0 and "R6" or "R15") or "N/A"
				Entry.RigType = Entry.RigType == "N/A" and Humanoid and (__index(Humanoid, "RigType") == Enum.HumanoidRigType.R6 and "R6" or "R15") or "N/A"
			end
		end)
	end,

	GetObjectEntry = function(Object, Hash)
		Hash = type(Object) == "string" and Object or Hash

		for _, Value in next, Environment.UtilityAssets.WrappedObjects do
			if Hash and Value.Hash == Hash or Value.Object == Object then
				return Value
			end
		end
	end,

	WrapObject = function(self, Object, PseudoName, Allowed, RenderDistance)
		assert(self, "EXUNYS_ESP > UtilityFunctions.WrapObject - Internal error, unassigned parameter \"self\".")

		if pcall(gethiddenproperty, Object, "PrimaryPart") then
			Object = __index(Object, "PrimaryPart")
		end

		if not Object then
			return
		end

		local DeveloperSettings = Environment.DeveloperSettings
		local WrappedObjects = Environment.UtilityAssets.WrappedObjects

		for _, Value in next, WrappedObjects do
			if Value.Object == Object then
				return
			end
		end

		local Entry = {
			Hash = CoreFunctions.GenerateHash(0x100),

			Object = Object,
			Allowed = Allowed,
			Name = PseudoName or __index(Object, "Name"),
			DisplayName = PseudoName or __index(Object, (IsA(Object, "Player") and "Display" or "").."Name"),
			RenderDistance = RenderDistance or Inf,

			IsAPlayer = IsA(Object, "Player"),
			PartHasCharacter = false,
			RigType = "N/A",

			Checks = {
				Alive = true,
				Team = true,
				Ready = true
			},

			Visuals = {
				Box = {},
				HealthBar = {},
				HealthText = {}
			},

			Connections = {}
		}

		repeat wait(0) until Entry.IsAPlayer and FindFirstChildOfClass(__index(Entry.Object, "Character"), "Humanoid") or true

		if not Entry.IsAPlayer then
			if not pcall(function()
				return __index(Entry.Object, "Position"), __index(Entry.Object, "CFrame")
			end) then
				warn("EXUNYS_ESP > UtilityFunctions.WrapObject - Attempted to wrap object of an unsupported class type: \""..(__index(Entry.Object, "ClassName") or "N / A").."\"")
				return self.UnwrapObject(Entry.Hash)
			end

			Entry.Connections.UnwrapSignal = Connect(Entry.Object.Changed, function(Property)
				if Property == "Parent" and not IsDescendantOf(__index(Entry.Object, Property), Workspace) then
					self.UnwrapObject(nil, Entry.Hash)
				end
			end)
		end

		local Humanoid = Entry.IsAPlayer and FindFirstChildOfClass(__index(Entry.Object, "Character"), "Humanoid") or FindFirstChildOfClass(__index(Entry.Object, "Parent"), "Humanoid")

		Entry.PartHasCharacter = not Entry.IsAPlayer and Humanoid
		Entry.RigType = Humanoid and (__index(Humanoid, "RigType") == 0 and "R6" or "R15") or "N/A"

		self:InitChecks(Entry)

		spawn(function()
			repeat
				wait(0)
			until Entry.Checks.Ready

			CreatingFunctions.Box(Entry)
			CreatingFunctions.HealthBar(Entry)
			CreatingFunctions.HealthText(Entry)

			WrappedObjects[Entry.Hash] = Entry

			Entry.Connections.PlayerUnwrapSignal = Connect(Entry.Object.Changed, function(Property)
				if DeveloperSettings.UnwrapOnCharacterAbsence and Property == "Parent" and not IsDescendantOf(__index(Entry.Object, (Entry.IsAPlayer and "Character" or Property)), Workspace) then
					self.UnwrapObject(nil, Entry.Hash)
				end
			end)

			return Entry.Hash
		end)
	end,

	UnwrapObject = function(Object, Hash)
		Hash = type(Object) == "string" and Object
		Object = type(Object) == "string" and nil

		for _, Value in next, Environment.UtilityAssets.WrappedObjects do
			if Value.Object == Object or Value.Hash == Hash then
				for _, _Value in next, Value.Connections do
					pcall(Disconnect, _Value)
				end

				Recursive(Value.Visuals, function(_, _Value)
					if type(_Value) == "table" then
						if _Value.Lines then
							for _, Line in ipairs(_Value.Lines) do
								pcall(Line.Remove, Line)
							end
						end
						if _Value.OutlineLines then
							for _, Line in ipairs(_Value.OutlineLines) do
								pcall(Line.Remove, Line)
							end
						end
					elseif _Value then
						pcall(_Value.Remove, _Value)
					end
				end)

				Environment.UtilityAssets.WrappedObjects[Hash] = nil; break
			end
		end
	end
}

local LoadESP = function()
	for _, Value in next, GetPlayers() do
		if Value == LocalPlayer then
			continue
		end

		UtilityFunctions:WrapObject(Value)
	end

	local ServiceConnections = Environment.UtilityAssets.ServiceConnections

	ServiceConnections.PlayerRemoving = Connect(__index(Players, "PlayerRemoving"), UtilityFunctions.UnwrapObject)

	ServiceConnections.CharacterAdded = Connect(__index(Workspace, "DescendantAdded"), function(Object)
		if not IsA(Object, "Model") then
			return
		end

		if not GetPlayerFromCharacter(Object) or not FindFirstChild(Players, __index(Object, "Name")) then
			return
		end

		for _, Value in next, GetPlayers() do
			local Player = nil

			for _, _Value in next, Environment.UtilityAssets.WrappedObjects do
				if not _Value.IsAPlayer then
					continue
				end

				if __index(_Value.Object, "Name") == __index(Value, "Name") then
					Player = _Value
				end
			end

			if not Player then
				UtilityFunctions:WrapObject(GetPlayerFromCharacter(Object))
			end
		end
	end)

	ServiceConnections.PlayerAdded = Connect(__index(Players, "PlayerAdded"), function(Player)
		local WrappedObjects = Environment.UtilityAssets.WrappedObjects
		local Hash = UtilityFunctions:WrapObject(Player)

		for _, Entry in next, WrappedObjects do
			if Entry.Hash ~= Hash then
				continue
			end

			Entry.Connections[__index(Player, "Name").."CharacterAdded"] = Connect(__index(Player, "CharacterAdded"), function(Object)
				for _, _Value in next, Environment.UtilityAssets.WrappedObjects do
					if not _Value.Name == __index(Object, "Name") then
						continue
					end

					UtilityFunctions:WrapObject(GetPlayerFromCharacter(Object))
				end
			end)
		end
	end)
end

local Environment = getgenv().ExunysDeveloperESP or {}
local Loaded = false

setmetatable(Environment, {
    __call = function()
        if Loaded then return end
        Loaded = true

        if LoadESP and type(LoadESP) == "function" then
            pcall(LoadESP)
        end
    end
})

pcall(spawn, function()
	if Environment.Settings.LoadConfigOnLaunch then
		repeat wait(0) until Environment.LoadConfiguration

		Environment:LoadConfiguration()
	end
end)

--// Interactive User Functions
Environment.UnwrapPlayers = function()
    local UtilityAssets = Environment.UtilityAssets or {}
    local WrappedObjects = UtilityAssets.WrappedObjects or {}
    local ServiceConnections = UtilityAssets.ServiceConnections or {}

    for _, Entry in next, WrappedObjects do
        if UtilityFunctions and UtilityFunctions.UnwrapObject then
            pcall(UtilityFunctions.UnwrapObject, Entry.Hash)
        end
    end

    for _, ConnectionIndex in next, {"PlayerRemoving", "PlayerAdded", "CharacterAdded"} do
        if ServiceConnections[ConnectionIndex] and Disconnect then
            pcall(Disconnect, ServiceConnections[ConnectionIndex])
        end
    end

    return #WrappedObjects == 0
end

Environment.UnwrapAll = function(self)
    if not self then return false end
    if self.UnwrapPlayers and self.UnwrapPlayers() then
        return true
    end
    local wrappedCount = self.UtilityAssets and #self.UtilityAssets.WrappedObjects or 0
    return wrappedCount == 0
end

Environment.Restart = function(self)
    if not self then return end
    local Objects = {}
    local WrappedObjects = (self.UtilityAssets and self.UtilityAssets.WrappedObjects) or {}

    for _, Value in next, WrappedObjects do
        Objects[#Objects + 1] = {Value.Hash, Value.Object, Value.Name, Value.Allowed, Value.RenderDistance}
    end

    for _, Value in next, Objects do
        if self.UnwrapObject then pcall(self.UnwrapObject, Value[1]) end
    end

    for _, Value in next, Objects do
        if self.WrapObject then pcall(self.WrapObject, select(2, unpack(Value))) end
    end
end

Environment.Exit = function(self)
    if not self then return end
    if self:UnwrapAll() then
        local ServiceConnections = (self.UtilityAssets and self.UtilityAssets.ServiceConnections) or {}
        for _, Connection in next, ServiceConnections do
            if Disconnect then pcall(Disconnect, Connection) end
        end

        for _, Table in next, {CoreFunctions, UpdatingFunctions, CreatingFunctions, UtilityFunctions} do
            if Table then
                for k in next, Table do Table[k] = nil end
            end
        end

        for k in next, Environment do
            if getgenv().ExunysDeveloperESP then
                getgenv().ExunysDeveloperESP[k] = nil
            end
        end

        LoadESP, Recursive, Loaded = nil, nil, false
        if cleardrawcache then pcall(cleardrawcache) end
        getgenv().ExunysDeveloperESP = nil
    end
end

Environment.WrapObject = function(...)
    if UtilityFunctions and UtilityFunctions.WrapObject then
        return UtilityFunctions:WrapObject(...)
    end
end

Environment.UnwrapObject = function(...)
    if UtilityFunctions and UtilityFunctions.UnwrapObject then
        return UtilityFunctions.UnwrapObject(...)
    end
end

Environment.WrapPlayers = function()
    if LoadESP then pcall(LoadESP) end
end

Environment.GetEntry = function(...)
    if UtilityFunctions and UtilityFunctions.GetObjectEntry then
        return UtilityFunctions.GetObjectEntry(...)
    end
end

Environment.Load = function()
    if Loaded then return end
    if LoadESP then pcall(LoadESP) end
    Loaded = true
end

Environment.UpdateConfiguration = function(DeveloperSettings, Settings, Properties)
    if not DeveloperSettings or not Settings or not Properties then return end
    if not getgenv().ExunysDeveloperESP then return end

    getgenv().ExunysDeveloperESP.DeveloperSettings = DeveloperSettings
    getgenv().ExunysDeveloperESP.Settings = Settings
    getgenv().ExunysDeveloperESP.Properties = Properties

    Environment = getgenv().ExunysDeveloperESP
    return Environment
end

Environment.LoadConfiguration = function(self)
    if not self then return end
    local Path = (self.DeveloperSettings and self.DeveloperSettings.Path) or nil
    if not Path then return end

    if self:UnwrapAll() then
        pcall(function()
            local Configuration = ConfigLibrary and ConfigLibrary:LoadConfig(Path) or {}
            local Data = {}

            for _, Index in next, {"DeveloperSettings", "Settings", "Properties"} do
                if ConfigLibrary and Configuration[Index] then
                    Data[#Data + 1] = ConfigLibrary:CloneTable(Configuration[Index])
                end
            end

            self:UpdateConfiguration(unpack(Data))
        end)
    end
end

Environment.SaveConfiguration = function(self)
	assert(self, "EXUNYS_ESP.SaveConfiguration: Missing parameter #1 \"self\" <table>.")

	local DeveloperSettings = self.DeveloperSettings

	ConfigLibrary:SaveConfig(DeveloperSettings.Path, {
		DeveloperSettings = DeveloperSettings,
		Settings = self.Settings,
		Properties = self.Properties
	})
end

return Environment
