--[[
	Universal Extra-Sensory Perception (ESP) Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys
	- Box						  > [Players, NPCs & Parts]
	- Health Bar				  > [Players & NPCs]
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

	CalculateParameters = function(Object)
		Object = type(Object) == "table" and Object.Object or Object

		local DeveloperSettings = Environment.DeveloperSettings
		local WidthBoundary = DeveloperSettings.WidthBoundary

		local IsAPlayer = IsA(Object, "Player")

		local Part = IsAPlayer and (FindFirstChild(Players, __index(Object, "Name")) and __index(Object, "Character"))
		Part = IsAPlayer and Part and (__index(Part, "PrimaryPart") or FindFirstChild(Part, "HumanoidRootPart")) or Object

		if not Part or IsA(Part, "Player") then
			return nil, nil, false
		end

		local PartCFrame, PartPosition, PartUpVector = __index(Part, "CFrame"), __index(Part, "Position")
		PartUpVector = PartCFrame.UpVector

		local RigType = FindFirstChild(__index(Part, "Parent"), "Torso") and "R6" or "R15"

		local CameraUpVector = __index(CurrentCamera, "CFrame").UpVector

		local Top, TopOnScreen = WorldToViewportPoint(PartPosition + (PartUpVector * (RigType == "R6" and 0.5 or 1.8)) + CameraUpVector)
		local Bottom, BottomOnScreen = WorldToViewportPoint(PartPosition - (PartUpVector * (RigType == "R6" and 4 or 2.5)) - CameraUpVector)

		local TopX, TopY = Top.X, Top.Y
		local BottomX, BottomY = Bottom.X, Bottom.Y

		local Width = mathmax(mathfloor(mathabs(TopX - BottomX)), 3)
		local Height = mathmax(mathfloor(mathmax(mathabs(BottomY - TopY), Width / 2)), 3)
		local BoxSize = Vector2new(mathfloor(mathmax(Height / (IsAPlayer and WidthBoundary or 1), Width)), Height)
		local BoxPosition = Vector2new(mathfloor(TopX / 2 + BottomX / 2 - BoxSize.X / 2), mathfloor(mathmin(TopY, BottomY)))

		return BoxPosition, BoxSize, (TopOnScreen and BottomOnScreen)
	end,

	GetColor = function(Player, DefaultColor)
		local Settings, TeamCheckOption = Environment.Settings, Environment.DeveloperSettings.TeamCheckOption

		return Settings.EnableTeamColors and __index(Player, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) and Settings.TeamColor or DefaultColor
	end
}

local UpdatingFunctions = {
	Box = function(Entry, BoxObject, BoxOutlineObject)
		local Settings = Environment.Properties.Box

		local Position, Size, OnScreen = CoreFunctions.CalculateParameters(Entry)

		setrenderproperty(BoxObject, "Visible", OnScreen)
		setrenderproperty(BoxOutlineObject, "Visible", OnScreen and Settings.Outline)

		if getrenderproperty(BoxObject, "Visible") then
			setrenderproperty(BoxObject, "Position", Position)
			setrenderproperty(BoxObject, "Size", Size)

			for Index, Value in next, Settings do
				if Index == "Color" then
					continue
				end

				if not pcall(getrenderproperty, BoxObject, Index) then
					continue
				end

				setrenderproperty(BoxObject, Index, Value)
			end

			setrenderproperty(BoxObject, "Color", CoreFunctions.GetColor(Entry.Object, Settings.RainbowColor and CoreFunctions.GetRainbowColor() or Settings.Color))

			if Settings.Outline then
				setrenderproperty(BoxOutlineObject, "Position", Position)
				setrenderproperty(BoxOutlineObject, "Size", Size)

				setrenderproperty(BoxOutlineObject, "Color", Settings.RainbowOutlineColor and CoreFunctions.GetRainbowColor() or Settings.OutlineColor)

				setrenderproperty(BoxOutlineObject, "Thickness", Settings.Thickness + 1)
				setrenderproperty(BoxOutlineObject, "Transparency", Settings.Transparency)
			end
		end
	end,

	HealthBar = function(Entry, MainObject, OutlineObject, Humanoid)
		local Settings = Environment.Properties.HealthBar

		local Position, Size, OnScreen = CoreFunctions.CalculateParameters(Entry)

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

			if Settings.Position == 1 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X, Position.Y - Offset))
				setrenderproperty(MainObject, "To", Vector2new(Position.X + (Health / MaxHealth) * Size.X, Position.Y - Offset))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X - 1, Position.Y - Offset))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X + Size.X + 1, Position.Y - Offset))
				end
			elseif Settings.Position == 2 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X, Position.Y + Size.Y + Offset))
				setrenderproperty(MainObject, "To", Vector2new(Position.X + (Health / MaxHealth) * Size.X, Position.Y + Size.Y + Offset))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X - 1, Position.Y + Size.Y + Offset))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X + Size.X + 1, Position.Y + Size.Y + Offset))
				end
			elseif Settings.Position == 3 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X - Offset, Position.Y + Size.Y))
				setrenderproperty(MainObject, "To", Vector2new(Position.X - Offset, getrenderproperty(MainObject, "From").Y - (Health / MaxHealth) * Size.Y))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X - Offset, Position.Y + Size.Y + 1))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X - Offset, (getrenderproperty(OutlineObject, "From").Y - 1 * Size.Y) - 2))
				end
			elseif Settings.Position == 4 then
				setrenderproperty(MainObject, "From", Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y))
				setrenderproperty(MainObject, "To", Vector2new(Position.X + Size.X + Offset, getrenderproperty(MainObject, "From").Y - (Health / MaxHealth) * Size.Y))

				if Settings.Outline then
					setrenderproperty(OutlineObject, "From", Vector2new(Position.X + Size.X + Offset, Position.Y + Size.Y + 1))
					setrenderproperty(OutlineObject, "To", Vector2new(Position.X + Size.X + Offset, (getrenderproperty(OutlineObject, "From").Y - 1 * Size.Y) - 2))
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
	end
}

local CreatingFunctions = {
	Box = function(Entry)
		local Allowed = Entry.Allowed

		if type(Allowed) == "table" and type(Allowed.Box) == "boolean" and not Allowed.Box then
			return
		end

		local Settings = Environment.Properties.Box

		local BoxOutline = Drawingnew("Square")
		local BoxOutlineObject = BoxOutline--[[._OBJECT]]

		local Box = Drawingnew("Square")
		local BoxObject = Box--[[._OBJECT]]

		Entry.Visuals.Box[1] = Box
		Entry.Visuals.Box[2] = BoxOutline

		Entry.Connections.Box = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
			local Functionable, Ready = pcall(function()
				return Environment.Settings.Enabled and Settings.Enabled and Entry.Checks.Ready
			end)

			if not Functionable then
				pcall(Box.Remove, Box)
				pcall(BoxOutline.Remove, BoxOutline)

				return Disconnect(Entry.Connections.Box)
			end

			if Ready then
				UpdatingFunctions.Box(Entry, BoxObject, BoxOutlineObject)
			else
				setrenderproperty(BoxObject, "Visible", false)
				setrenderproperty(BoxOutlineObject, "Visible", false)
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
		local OutlineObject = Outline--[[._OBJECT]]

		local Main = Drawingnew("Line")
		local MainObject = Main--[[._OBJECT]]

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
				HealthBar = {}
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
					if type(_Value) == "table" and _Value--[[._OBJECT]] then
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
