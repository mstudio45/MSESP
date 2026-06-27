--!nocheck
--!nolint UnknownGlobal
--[[

		▄▄▄▄███▄▄▄▄      ▄████████         ▄████████    ▄████████    ▄███████▄
		▄██▀▀▀███▀▀▀██▄   ███    ███        ███    ███   ███    ███   ███    ███
		███   ███   ███   ███    █▀         ███    █▀    ███    █▀    ███    ███
		███   ███   ███   ███              ▄███▄▄▄       ███          ███    ███
		███   ███   ███ ▀███████████      ▀▀███▀▀▀     ▀███████████ ▀█████████▀
		███   ███   ███          ███        ███    █▄           ███   ███
		███   ███   ███    ▄█    ███        ███    ███    ▄█    ███   ███
		▀█   ███   █▀   ▄████████▀         ██████████  ▄████████▀   ▄████▀
								   v2.1.0

						Created by mstudio45 (Discord)
				Contributors: Dottik, Master Oogway, deividcomsono
						https://docs.mstudio45.com/
--]]

local getgenv = getgenv or function() return shared end

local VERSION = "2.1.0";
local DEBUG_ENABLED = getgenv().mstudio45_ESP_DEBUG == true;

local debug_print = if DEBUG_ENABLED then (function(...) print("[mstudio45's ESP]", ...) end) else (function() end);
local debug_warn  = if DEBUG_ENABLED then (function(...) warn("[mstudio45's ESP]", ...) end) else (function() end);
-- local debug_error = if DEBUG_ENABLED then (function(...) error("[mstudio45's ESP] " .. table.concat({ ... }, " ")) end) else (function() end);

if getgenv().mstudio45_ESP then
	debug_warn("Already loaded, returning currently loaded Library table.")
	return getgenv().mstudio45_ESP
end

-- // Type Definitions // --
export type TracerESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
	From: ("Top" | "Bottom" | "Center" | "Mouse")?,
}

export type ArrowESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	CenterOffset: number?,
}

export type Box2DESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
	Filled: boolean?,
}

export type Box3DESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
}

export type SkeletonESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
}

export type ESPSettings = {
	Name: string,
	Model: Object,
	TextModel: Object?,

	-- // General Settings // --
	Visible: boolean?,
	Color: Color3?,
	MaxDistance: number?,

	StudsOffset: Vector3?,
	TextSize: number?,

	-- // ESP Type Settings // --
	ESPType: ("Text" | "SphereAdornment" | "CylinderAdornment" | "Adornment" | "SelectionBox" | "Highlight"),
	Thickness: number?,
	Transparency: number?,

	-- // SelectionBox Settings // --
	SurfaceColor: Color3?,

	-- // Highlight Settings // --
	FillColor: Color3?,
	OutlineColor: Color3?,

	FillTransparency: number?,
	OutlineTransparency: number?,

	-- // Components // --
	Tracer: TracerESPSettings?,
	Arrow: ArrowESPSettings?,
	Box2D: Box2DESPSettings?,
	Box3D: Box3DESPSettings?,
	Skeleton: SkeletonESPSettings?,

	-- // Callbacks // --
	OnDestroy: BindableEvent?,
	OnDestroyFunc: (() -> nil)?,

	BeforeUpdate: ((self: ESPSettings) -> nil)?,
	AfterUpdate: ((self: ESPSettings) -> nil)?
}

export type ESPInstance = {
	Index: string,
	Hidden: boolean,
	Deleted: boolean,

	OriginalSettings: ESPSettings,
	CurrentSettings: ESPSettings,

	Connections: { RBXScriptConnection },
	Components: {},

	Show: (self, Force: boolean?) -> nil,
	Hide: (self, Force: boolean?) -> nil,
	ToggleVisibility: (self, Force: boolean?) -> nil,
	SetEveryColor: (self, Color: Color3, IncludeComponents: boolean) -> nil,
	Destroy: (self) -> nil
}

local DefaultSettings: ESPSettings = {
	Name = "New ESP",
	Model = nil,
	TextModel = nil,

	-- // General Settings // --
	Visible = true,
	Color = Color3.new(1, 1, 1),
	MaxDistance = 5000,
	
	StudsOffset = Vector3.new(),
	TextSize = 16,
	
	-- // ESP Type Settings // --
	ESPType = "Highlight",
	Thickness = 0.1,
	Transparency = 0.65,
	
	-- // SelectionBox Settings // --
	SurfaceColor = Color3.new(1, 1, 1),

	-- // Highlight Settings // --
	FillColor = Color3.new(1, 1, 1),
	OutlineColor = Color3.new(1, 1, 1),

	FillTransparency = 0.65,
	OutlineTransparency = 0,

	-- // Components // --
	Tracer = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 2,
		Transparency = 0,
		From = "Bottom"
	},
	Arrow = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		CenterOffset = 300,
	},

	Box2D = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 1,
		Transparency = 0,
		Filled = false,
	},
	Box3D = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 1,
		Transparency = 0,
	},
	Skeleton = {
		Enabled = false,
		Color = Color3.new(1, 1, 1),
		Thickness = 1,
		Transparency = 0,
	},

	-- // Callbacks // --
	OnDestroy = nil,
	OnDestroyFunc = nil,

	BeforeUpdate = nil,
	AfterUpdate = nil,
}

-- // Executor Variables // --
local cloneref = getgenv().cloneref or function(inst) return inst; end

-- // GUI Variables // --
local GuiParent, StorageParent;
local CoreGuiAllowed = false;

-- // Services // --
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

-- // Core Functions // --
local table_freeze = function<T>(provided_table: T): T
	local data = table.clone(provided_table)

	return setmetatable({}, {
		__index = function(table, key) return rawget(data, key) end,
		__newindex = function(table, key, value) end,
		__iter = function(_) return next, data end,
		__metatable = "The metatable is locked"
	}) :: typeof(provided_table)
end

-- // Functions // --
local function GetPivot(Instance: Bone | Attachment | CFrame | PVInstance)
	if Instance.ClassName == "Bone" then
		return Instance.TransformedWorldCFrame

	elseif Instance.ClassName == "Attachment" then
		return Instance.WorldCFrame

	elseif Instance.ClassName == "Camera" then
		return Instance.CFrame

	else
		return Instance:GetPivot()
	end
end

local function RandomString(name: string?)
	if DEBUG_ENABLED and name then
		return name
	end

	local length = math.random(10, 20)
	local array = {}

	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

local function SafeCallback(Func: (...any) -> ...any, ...: any)
	if not (Func and typeof(Func) == "function") then
		return
	end

	local Result = table.pack(xpcall(Func, function(Error)
		task.defer(error, debug.traceback(Error, 2))
		return Error
	end, ...))

	if not Result[1] then
		return nil
	end

	return table.unpack(Result, 2, Result.n)
end

local Validate; Validate = function(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
	if typeof(Table) ~= "table" then
		return Template
	end

	for k, v in Template do
		if typeof(k) == "number" then
			continue
		end

		if typeof(v) == "table" then
			Table[k] = Validate(Table[k], v)
		elseif Table[k] == nil then
			Table[k] = v
		end
	end

	return Table
end

-- // Instances // --
local InstancesLib = {
	Create = function(instanceType, properties)
		assert(typeof(instanceType) == "string", "Argument #1 must be a string.")
		assert(typeof(properties) == "table", "Argument #2 must be a table.")

		local instance = Instance.new(instanceType)
		for name, val in properties do
			if name == "Parent" then
				continue -- // Parenting is expensive, do last.
			end

			if instanceType == "Path2D" and name == "Transparency" and not CoreGuiAllowed then
				continue -- // Locked behind RobloxSecurity (why roblox?)
			end

			instance[name] = val
		end

		if properties["Parent"] ~= nil then
			instance.Parent = properties["Parent"]
		end

		return instance
	end,

	TryGetProperty = function(instance, propertyName)
		assert(typeof(instance) == "Instance", "Argument #1 must be an Instance.")
		assert(typeof(propertyName) == "string", "Argument #2 must be a string.")

		local success, property = pcall(function()
			return instance[propertyName]
		end)

		return if success then property else nil;
	end,

	FindPrimaryPart = function(instance)
		if typeof(instance) ~= "Instance" then
			return nil
		end

		return (instance:IsA("Model") and instance.PrimaryPart or nil)
			or instance:FindFirstChildWhichIsA("BasePart")
			or instance:FindFirstChildWhichIsA("UnionOperation")
			or instance;
	end,

	DistanceFrom = function(inst, from)
		if not (inst and from) then
			return 9e9;
		end

		local position     = if typeof(inst) == "Instance" then GetPivot(inst).Position else inst;
		local fromPosition = if typeof(from) == "Instance" then GetPivot(from).Position else from;
		return (fromPosition - position).Magnitude;
	end
}

-- // Thread Identity Test // --
do
	local testGui = Instance.new("ScreenGui")
	local successful = pcall(function()
		if not CoreGui then error("CoreGui is nil") end

		testGui.Parent = CoreGui;
	end)

	CoreGuiAllowed = successful;
	if not successful then
		debug_warn("CoreGUI is not accessible!")

		GuiParent = Players.LocalPlayer.PlayerGui;
		StorageParent = ReplicatedStorage;
	else
		GuiParent = CoreGui;
		StorageParent = typeof(game) == "userdata" and Players.Parent or game;
	end

	testGui:Destroy()
end

-- // Storage // --
local StorageFolder = InstancesLib.Create("Folder", {
	Parent = StorageParent,
	Name = RandomString("StorageFolder")
})

local ActiveFolder = InstancesLib.Create("Folder", {
	Parent = if CoreGuiAllowed then GuiParent else InstancesLib.Create("ScreenGui", {
		Parent = GuiParent,
		Name = RandomString("ActiveContainer"),
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ClipToDeviceSafeArea = false,
		DisplayOrder = 999999
	}),
	Name = RandomString("ActiveFolder")
})

local MainGUI = InstancesLib.Create("ScreenGui", {
	Parent = GuiParent,
	Name = RandomString("MainGUI"),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999999
})

local BillboardGUI = InstancesLib.Create("ScreenGui", {
	Parent = GuiParent,
	Name = RandomString("BillboardGUI"),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999999
})

-- // Library // --
local Library = {
	Destroyed = false,

	-- // Storages // --
	ActiveFolder = ActiveFolder,
	MainGUI = MainGUI,
	BillboardGUI = BillboardGUI,
	StorageFolder = StorageFolder,

	-- // Connections // --
	Connections = {},

	-- // ESP // --
	ESP = {},

	-- // Global Config // --
	GlobalConfig = {
		IgnoreCharacter = false,
		Rainbow = false,

		Billboards = true,
		Distance = true,

		Highlighters = true,
		Tracers = true,
		Arrows = true,
		Boxes2D = true,
		Boxes3D = true,
		Skeleton = true,

		Font = Enum.Font.RobotoCondensed
	},

	-- // Rainbow Variables // --
	RainbowHueSetup = 0,
	RainbowHue = 0,
	RainbowStep = 0,
	RainbowColor = Color3.new()
}

function Library:Clear()
	if Library.Destroyed == true then
		return
	end

	for _, ESP in Library.ESP do
		if not ESP then continue end
		ESP:Destroy()
	end

	debug_print("Cleared ESPs.")
end

function Library:Destroy()
	if Library.Destroyed == true then
		return
	end

	-- // Destroy Library // --
	Library:Clear();
	Library.Destroyed = true;

	-- // Destroy Folders // --
	ActiveFolder:Destroy();
	StorageFolder:Destroy();
	MainGUI:Destroy();
	BillboardGUI:Destroy();

	Library.ActiveFolder = nil;
	Library.MainGUI = nil;
	Library.BillboardGUI = nil;
	Library.StorageFolder = nil;

	-- // Clear connections // --
	for _, connection in Library.Connections do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(Library.Connections)

	-- // Clear getgenv // --
	getgenv().mstudio45_ESP = nil;
	debug_print("Unloaded!");
end

-- // Player Variables // --
local Character: Model?;
local RootPart: Part?;
local Camera: Camera = workspace.CurrentCamera;

local function WorldToViewport(...)
	Camera = (Camera or workspace.CurrentCamera);
	if Camera == nil then
		return Vector2.new(0, 0), false;
	end

	return Camera:WorldToViewportPoint(...);
end

local function UpdatePlayerVariables(newCharacter: Instance?, force: boolean?)
	-- // Update Root Part // --
	if force ~= true and Library.GlobalConfig.IgnoreCharacter == true then
		debug_warn("UpdatePlayerVariables: IgnoreCharacter enabled.");
		return;
	end;

	debug_print("Updating Player Variables...");
	Character = newCharacter or Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait();
	RootPart = Character:WaitForChild("HumanoidRootPart", 2.5) or Character:WaitForChild("UpperTorso", 2.5) or Character:WaitForChild("Torso", 2.5) or Character.PrimaryPart or Character:WaitForChild("Head", 2.5);
end
task.spawn(UpdatePlayerVariables, nil, true);

-- // Type Checks // --
local AllowedTracerFrom = {
	top = true,
	bottom = true,
	center = true,
	mouse = true,
}

local AllowedESPType = {
	text = true,
	sphereadornment = true,
	cylinderadornment = true,
	adornment = true,
	selectionbox = true,
	highlight = true,
}

-- // Helper Functions // --
local function GetModelCorners(Model: Instance?)
	if not Model then
		return false, {}, {}, 0, 0, 0, 0;
	end

	-- // Calculate Bounding Box // --
	local ModelCFrame, ModelSize = nil, nil

	if Model:IsA("Model") then
		ModelCFrame, ModelSize = Model:GetBoundingBox()
	else
		if not InstancesLib.TryGetProperty(Model, "Size") then
			local PrimaryPart = InstancesLib.FindPrimaryPart(Model)

			if InstancesLib.TryGetProperty(PrimaryPart, "Size") then
				ModelCFrame = PrimaryPart.CFrame
				ModelSize = PrimaryPart.Size
			end
		else
			ModelCFrame = Model.CFrame
			ModelSize = Model.Size
		end
	end

	if not (ModelCFrame and ModelSize) then
		return false, {}, {}, 0, 0, 0, 0
	end

	-- // Corners // --
	local sx, sy, sz = ModelSize.X / 2, ModelSize.Y / 2, ModelSize.Z / 2
	local corners = {
		ModelCFrame * Vector3.new(sx, sy, sz),      -- Top Right Back
		ModelCFrame * Vector3.new(sx, sy, -sz),     -- Top Right Front
		ModelCFrame * Vector3.new(sx, -sy, sz),     -- Bottom Right Back
		ModelCFrame * Vector3.new(sx, -sy, -sz),    -- Bottom Right Front

		ModelCFrame * Vector3.new(-sx, sy, sz),     -- Top Left Back
		ModelCFrame * Vector3.new(-sx, sy, -sz),    -- Top Left Front
		ModelCFrame * Vector3.new(-sx, -sy, sz),    -- Bottom Left Back
		ModelCFrame * Vector3.new(-sx, -sy, -sz),   -- Bottom Left Front
	}

	-- // Screen Position for Corners // --
	local screenCorners = {}
	local cornersOnScreen = 0;

	local minX, maxX = math.huge, -math.huge;
	local minY, maxY = math.huge, -math.huge;
	
	for idx, corner in corners do
		local cornerPos, cornerOnScreen = WorldToViewport(corner)
		screenCorners[idx] = cornerPos;

		if not cornerOnScreen then continue end
		cornersOnScreen = cornersOnScreen + 1;

		minX = math.min(minX, cornerPos.X);
		minY = math.min(minY, cornerPos.Y);
		maxX = math.max(maxX, cornerPos.X);
		maxY = math.max(maxY, cornerPos.Y);
	end

	return cornersOnScreen > 0, corners, screenCorners, minX, minY, maxX, maxY;
end

-- // ESP Instances // --
local Components = {}; do
	-- // Billboards // --
	Components.Billboard = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return 
		end

		-- // Create Billboard // --
		debug_print("Creating Billboard...")

		local Billboard = InstancesLib.Create("BillboardGui", {
			Parent = BillboardGUI,
			Name = ESP.Index,

			Enabled = true,
			ResetOnSpawn = false,
			AlwaysOnTop = true,
			Size = UDim2.new(0, 200, 0, 50),

			-- // Settings // --
			Adornee = ESP.CurrentSettings.TextModel or ESP.CurrentSettings.Model,
			StudsOffset = ESP.CurrentSettings.StudsOffset,
		})

		local BillboardText = InstancesLib.Create("TextLabel", {
			Parent = Billboard,

			Size = UDim2.new(0, 200, 0, 50),
			Font = Library.GlobalConfig.Font,
			TextWrap = true,
			TextWrapped = true,
			RichText = true,
			TextStrokeTransparency = 0,
			BackgroundTransparency = 1,

			-- // Settings // --
			Text = ESP.CurrentSettings.Name,
			TextColor3 = ESP.CurrentSettings.Color,
			TextSize = ESP.CurrentSettings.TextSize,
		})

		InstancesLib.Create("UIStroke", {
			Parent = BillboardText
		})

		-- // Billboard Data // --
		local BillboardData = {}
		BillboardData.Destroy = function(self)
			if not Billboard then return end
			
			Billboard:Destroy();
			Billboard = nil;
		end;

		BillboardData.Update = function(self)
			if not Billboard then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings
			local _screenPos, isOnScreen = unpack(ESP._LastScreenPos)
			local DistanceFromPlayer = ESP._LastDistance or 0
			local BillboardEnabled = isOnScreen == true and (Library.GlobalConfig.Billboards == true);
			
			Billboard.Enabled = BillboardEnabled;
			if not BillboardEnabled then return end

			-- // Update Visuals // --
			if Library.GlobalConfig.Distance then
				BillboardText.Text = string.format(
					'%s\n<font size="%d">[%s]</font>',
					ESPSettings.Name,
					ESPSettings.TextSize - 3,
					math.floor(DistanceFromPlayer)
				);
			else
				BillboardText.Text = ESPSettings.Name;
			end

			BillboardText.Font = Library.GlobalConfig.Font;
			BillboardText.TextColor3 = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.Color;
			BillboardText.TextSize = ESPSettings.TextSize;
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Billboard then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					Billboard.Enabled = value;
				else
					rawset(BillboardData, key, value);
				end
			end,

			__index = function(table, key)
				if not Billboard then return nil end

				if key == "Visible" then
					return Billboard.Enabled;
				else
					return rawget(BillboardData, key);
				end
			end,

			__iter = function(_) return next, BillboardData end,
			__metatable = "The metatable is locked"
		}) :: typeof(BillboardData)
	end
	
	-- // Highlighter // --
	Components.Highlighter = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return 
		end

		-- // Create Highlighter // --
		local Highlighter = nil

		local ESPType = string.lower(ESP.CurrentSettings.ESPType)
		local IsAdornment = string.match(ESPType, "adornment")

		debug_print("Creating Highlighter...", ESPType, IsAdornment)
		if IsAdornment then
			local _, ModelSize = nil, nil

			if ESP.CurrentSettings.Model:IsA("Model") then
				_, ModelSize = ESP.CurrentSettings.Model:GetBoundingBox()
			else
				if not InstancesLib.TryGetProperty(ESP.CurrentSettings.Model, "Size") then
					local PrimaryPart = InstancesLib.FindPrimaryPart(ESP.CurrentSettings.Model)

					if not InstancesLib.TryGetProperty(PrimaryPart, "Size") then
						debug_print("Couldn't get model size, switching to Highlight.", ESP.Index, "-", ESP.CurrentSettings.Name)

						ESP.CurrentSettings.ESPType = "Highlight"
						return Library:Add(ESP.CurrentSettings)
					end

					ModelSize = PrimaryPart.Size
				else
					ModelSize = ESP.CurrentSettings.Model.Size
				end
			end

			if ESPType == "sphereadornment" then
				Highlighter = InstancesLib.Create("SphereHandleAdornment", {
					Parent = ActiveFolder,
					Name = ESP.Index,

					Adornee = ESP.CurrentSettings.Model,

					AlwaysOnTop = true,
					ZIndex = 10,

					Radius = ModelSize.X * 1.085,
					CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),

					-- // Settings // --
					Color3 = ESP.CurrentSettings.Color,
					Transparency = ESP.CurrentSettings.Transparency,
				})

			elseif ESPType == "cylinderadornment" then
				Highlighter = InstancesLib.Create("CylinderHandleAdornment", {
					Parent = ActiveFolder,
					Name = ESP.Index,

					Adornee = ESP.CurrentSettings.Model,

					AlwaysOnTop = true,
					ZIndex = 10,

					Height = ModelSize.Y * 2,
					Radius = ModelSize.X * 1.085,
					CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),

					-- // Settings // --
					Color3 = ESP.CurrentSettings.Color,
					Transparency = ESP.CurrentSettings.Transparency,
				})
			else
				Highlighter = InstancesLib.Create("BoxHandleAdornment", {
					Parent = ActiveFolder,
					Name = ESP.Index,

					Adornee = ESP.CurrentSettings.Model,

					AlwaysOnTop = true,
					ZIndex = 10,

					Size = ModelSize,

					-- // Settings // --
					Color3 = ESP.CurrentSettings.Color,
					Transparency = ESP.CurrentSettings.Transparency,
				})
			end

		elseif ESPType == "selectionbox" then
			Highlighter = InstancesLib.Create("SelectionBox", {
				Parent = ActiveFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				Color3 = ESP.CurrentSettings.BorderColor,
				LineThickness = ESP.CurrentSettings.Thickness,

				SurfaceColor3 = ESP.CurrentSettings.SurfaceColor,
				SurfaceTransparency = ESP.CurrentSettings.Transparency
			})

		elseif ESPType == "highlight" then
			Highlighter = InstancesLib.Create("Highlight", {
				Parent = ActiveFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				-- // Settings // --
				FillColor = ESP.CurrentSettings.FillColor,
				OutlineColor = ESP.CurrentSettings.OutlineColor,

				FillTransparency = ESP.CurrentSettings.FillTransparency,
				OutlineTransparency = ESP.CurrentSettings.OutlineTransparency
			})
		end

		-- // Highlighter Data // --
		local function SetVisible(visible: boolean)
			if not Highlighter then return end

			local Parent = if visible then ActiveFolder else StorageFolder;
			if Highlighter.Parent == Parent then return end

			Highlighter.Parent  = Parent;
			Highlighter.Adornee = if visible then ESP.CurrentSettings.Model else nil;
		end

		local HighlighterData = {}
		HighlighterData.Destroy = function(self)
			if not Highlighter then return end

			Highlighter:Destroy();
			Highlighter = nil;
		end

		HighlighterData.Update = function(self)
			if not Highlighter then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings
			local _screenPos, isOnScreen = unpack(ESP._LastScreenPos)
			local HighlightEnabled = isOnScreen == true and (Library.GlobalConfig.Highlighters == true)

			SetVisible(HighlightEnabled);
			if not HighlightEnabled then return end

			-- // Update Visuals // --
			if IsAdornment then
				Highlighter.Color3 = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.Color;
				Highlighter.Transparency = ESPSettings.Transparency

			elseif ESPType == "selectionbox" then
				Highlighter.Color3 = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.Color;
				Highlighter.LineThickness = ESPSettings.Thickness;

				Highlighter.SurfaceColor3 = ESPSettings.SurfaceColor;
				Highlighter.SurfaceTransparency = ESPSettings.Transparency;

			else
				Highlighter.FillColor = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.FillColor;
				Highlighter.OutlineColor = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.OutlineColor;

				Highlighter.FillTransparency = ESPSettings.FillTransparency;
				Highlighter.OutlineTransparency = ESPSettings.OutlineTransparency;
			end
		end

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Highlighter then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					)

					SetVisible(value);
				else
					rawset(HighlighterData, key, value);
				end
			end,

			__index = function(table, key)
				if not Highlighter then return nil end

				if key == "Visible" then
					return Highlighter.Adornee ~= nil;
				else
					return rawget(HighlighterData, key);
				end
			end,

			__iter = function(_) return next, HighlighterData end,
			__metatable = "The metatable is locked"
		}) :: typeof(HighlighterData)
	end

	-- // Tracer // --
	Components.Tracer = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end

		if not ESP then
			return
		end

		if not ESP.CurrentSettings.Tracer.Enabled then
			return
		end

		-- // Fix Settings // --
		local ESPSettings = ESP.CurrentSettings

		ESPSettings.Tracer.From = string.lower(tostring(ESPSettings.Tracer.From))
		if AllowedTracerFrom[ESPSettings.Tracer.From] == nil then
			debug_warn(string.format("Invalid Tracer.From (%s), defaulting to 'Bottom'.", ESPSettings.Tracer.From))
			ESPSettings.Tracer.From = "bottom"
		end

		-- // Create Path2D // --
		debug_print("Creating Tracer...")

		local TracerPath = InstancesLib.Create("Path2D", {
			Parent = MainGUI,
			Name = (if DEBUG_ENABLED then "Tracer_" else "") .. ESP.Index,
			Closed = true,

			-- // Settings // --
			Color3 = ESPSettings.Tracer.Color,
			Thickness = ESPSettings.Tracer.Thickness,
			Transparency = ESPSettings.Tracer.Transparency
		})

		-- // Tracer Data // --
		local FromRaw, ToRaw = ESPSettings.Tracer.From, ESPSettings.Tracer.To
		local DefaultPoint = UDim2.fromOffset(0, 0)
		local TracerData = {}
		
		-- // Functions // --
		local function SetVisible(Visible: boolean)
			if not TracerPath then return end
			if TracerPath.Visible == Visible then return end

			TracerPath.Parent = if Visible then MainGUI else StorageFolder;
			TracerPath.Visible = Visible;
		end

		local function UpdateTracer(FromPoint: UDim2, ToPoint: UDim2)
			TracerPath:SetControlPoints({
				Path2DControlPoint.new(FromPoint),
				Path2DControlPoint.new(ToPoint)
			})
		end

		TracerData.Destroy = function(self)
			if not TracerPath then return end
			
			TracerPath:SetControlPoints({});
			TracerPath:Destroy();
			TracerPath = nil;
		end;

		TracerData.Update = function(self)
			if not TracerPath then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings;
			local screenPos, isOnScreen = unpack(ESP._LastScreenPos);
			local TracerEnabled = isOnScreen == true and (Library.GlobalConfig.Tracers == true and ESPSettings.Tracer.Enabled == true);

			SetVisible(TracerEnabled);
			if not TracerEnabled then return end

			-- // Update Visuals // --
			local ToPoint = UDim2.fromOffset(screenPos.X, screenPos.Y);
			local FromSetting = ESPSettings.Tracer.From;

			if FromSetting == "mouse" then
				local MousePos = UserInputService:GetMouseLocation()
				UpdateTracer(
					UDim2.fromOffset(MousePos.X, MousePos.Y),
					ToPoint
				)
			elseif FromSetting == "top" then
				UpdateTracer(
					UDim2.fromOffset(Camera.ViewportSize.X / 2, 0),
					ToPoint
				)
			elseif FromSetting == "center" then
				UpdateTracer(
					UDim2.fromOffset(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2),
					ToPoint
				)
			else
				UpdateTracer(
					UDim2.fromOffset(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
					ToPoint
				)
			end

			-- // Visuals // --
			TracerPath.Thickness = ESPSettings.Tracer.Thickness;
			TracerPath.Color3 = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.Tracer.Color;
			
			if CoreGuiAllowed then
				TracerPath.Transparency = ESPSettings.Tracer.Transparency;
			end;
		end;

		UpdateTracer(
			if typeof(FromRaw) ~= "Vector2" then DefaultPoint else UDim2.fromOffset(FromRaw.X, FromRaw.Y),
			if typeof(ToRaw) ~= "Vector2"   then DefaultPoint else UDim2.fromOffset(ToRaw.X,    ToRaw.Y)
		);

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not TracerPath then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					SetVisible(value);
				else
					rawset(TracerData, key, value);
				end
			end,

			__index = function(table, key)
				if not TracerPath then return nil end

				if key == "Visible" then
					return TracerPath.Visible;
				else
					return rawget(TracerData, key);
				end
			end,

			__iter = function(_) return next, TracerData end,
			__metatable = "The metatable is locked"
		}) :: typeof(TracerData)
	end

	-- // Arrow // --
	Components.Arrow = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return
		end

		if not ESP.CurrentSettings.Arrow.Enabled then
			return
		end

		-- // Create Arrow // --
		debug_print("Creating Arrow...")

		local Arrow = InstancesLib.Create("ImageLabel", {
			Parent = MainGUI,
			Name = (if DEBUG_ENABLED then "Arrow_" else "") .. ESP.Index,

			Size = UDim2.new(0, 48, 0, 48),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,

			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Image = "http://www.roblox.com/asset/?id=16368985219",
			ImageColor3 = ESP.CurrentSettings.Color or Color3.new(),
		});

		-- // Arrow Data // --
		local ArrowData = { }
		ArrowData.Destroy = function(self)
			if not Arrow then return end
			
			Arrow:Destroy();
			Arrow = nil;
		end;

		ArrowData.Update = function(self)
			if not Arrow then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings;
			local screenPos, isOnScreen = unpack(ESP._LastScreenPos);
			local ArrowEnabled = isOnScreen == false and (Library.GlobalConfig.Arrows == true and ESPSettings.Arrow.Enabled == true);
			
			Arrow.Visible = ArrowEnabled;
			if not ArrowEnabled then return end

			-- // Update Visuals // --
			local screenSize = Camera.ViewportSize
			local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

			-- use aspect to make oval circle
			-- local aspectRatioX = screenSize.X / screenSize.Y;
			-- local aspectRatioY = screenSize.Y / screenSize.X;
			-- local arrowPosPixel = Vector2.new(arrowTable.ArrowInstance.Position.X.Scale, arrowTable.ArrowInstance.Position.Y.Scale) * 1000;
			local partPos = Vector2.new(screenPos.X, screenPos.Y);

			local IsInverted = screenPos.Z <= 0;
			local invert = (IsInverted and -1 or 1);

			local direction = (partPos - centerPos);
			local arctan = math.atan2(direction.Y, direction.X);
			local angle = math.deg(arctan) + 90;
			local distance = (ESPSettings.Arrow.CenterOffset * 0.001) * screenSize.Y;

			-- // Update Position // --
			Arrow.Rotation = angle + 180 * (IsInverted and 0 or 1);
			Arrow.Position = UDim2.fromOffset(
				centerPos.X + (distance * math.cos(arctan) * invert),
				centerPos.Y + (distance * math.sin(arctan) * invert)
			);

			-- // Update Visuals // --
			Arrow.ImageColor3 = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.Arrow.Color;
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Arrow then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					Arrow.Visible = value;
				else
					rawset(ArrowData, key, value);
				end
			end,

			__index = function(table, key)
				if not Arrow then return nil end
				
				if key == "Visible" then
					return Arrow.Visible;
				else
					return rawget(ArrowData, key);
				end
			end,

			__iter = function(_) return next, ArrowData end,
			__metatable = "The metatable is locked"
		}) :: typeof(ArrowData)
	end

	-- // Box2D // --
	Components.Box2D = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return
		end

		if not ESP.CurrentSettings.Box2D.Enabled then
			return
		end

		debug_print("Creating Box2D...")

		-- // Create Frame // --
		local Frame = InstancesLib.Create("Frame", {
			Parent = MainGUI,
			Name = (if DEBUG_ENABLED then "Box2D_" else "") .. ESP.Index,

			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 2,

			-- // Settings // --
			BackgroundColor3 = ESP.CurrentSettings.Box2D.Color
		})
	
		local UIStroke = InstancesLib.Create("UIStroke", {
			Parent = Frame,

			-- // Settings // --
			Color = ESP.CurrentSettings.Box2D.Color,
			Thickness = ESP.CurrentSettings.Box2D.Thickness,
			Transparency = ESP.CurrentSettings.Box2D.Transparency,
		})

		-- // Box2D Data // --
		local Box2DData = {}
		Box2DData.Destroy = function(self)
			if not Frame then return end
			
			Frame:Destroy();
			Frame = nil;
		end;

		Box2DData.Update = function(self)
			if not Frame then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end

			local ESPSettings = ESP.CurrentSettings;
			local _, isOnScreen = unpack(ESP._LastScreenPos);
			local Box2DEnabled = isOnScreen == true and (Library.GlobalConfig.Boxes2D == true and ESPSettings.Box2D.Enabled == true);

			Frame.Visible = Box2DEnabled
			if not Box2DEnabled then return end

			-- // Corners // --
			local isCornerOnScreen, _corners, _screenCorners, minX, minY, maxX, maxY = GetModelCorners(ESPSettings.Model);
			if not isCornerOnScreen then
				Frame.Visible = false
				return
			end

			-- // Update Position // --
			Frame.Position = UDim2.fromOffset(minX, minY)
			Frame.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
			Frame.Visible = true
			
			-- // Update Visuals // --
			Frame.BackgroundColor3 = ESPSettings.Box2D.Color;
			UIStroke.Color = ESPSettings.Box2D.Color;

			UIStroke.Thickness = ESPSettings.Box2D.Thickness;
			UIStroke.Transparency = ESPSettings.Box2D.Transparency;
			Frame.BackgroundTransparency = if ESPSettings.Box2D.Filled then 0.5 else 1;
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not Frame then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					Frame.Visible = value;
				else
					rawset(Box2DData, key, value);
				end
			end,

			__index = function(table, key)
				if not Frame then return nil end
				
				if key == "Visible" then
					return Frame.Visible;
				else
					return rawget(Box2DData, key);
				end
			end,

			__iter = function(_) return next, Box2DData end,
			__metatable = "The metatable is locked"
		}) :: typeof(Box2DData)
	end

	-- // Box3D // --
	Components.Box3D = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return 
		end

		if not ESP.CurrentSettings.Box3D.Enabled then
			return
		end

		debug_print("Creating Box3D...")

		-- // Create Path2D // --
		local BoxPath = InstancesLib.Create("Path2D", {
			Parent = MainGUI,
			Name = (if DEBUG_ENABLED then "Box3D_" else "") .. ESP.Index,
			Visible = false,
			
			-- // Settings // --
			Color3 = ESP.CurrentSettings.Box3D.Color,
			Thickness = ESP.CurrentSettings.Box3D.Thickness,
			Transparency = ESP.CurrentSettings.Box3D.Transparency
		})
		
		-- // Functions // --
		local Box3DData = {}

		local function SetVisible(Visible: boolean)
			if not BoxPath then return end
			if BoxPath.Visible == Visible then return end

			if not Visible then
				BoxPath:SetControlPoints({})
			end

			BoxPath.Parent = if Visible then MainGUI else StorageFolder;
			BoxPath.Visible = Visible;
		end

		Box3DData.Destroy = function(self)
			if not BoxPath then return end
			
			BoxPath:SetControlPoints({});
			BoxPath:Destroy();
			BoxPath = nil;
		end;

		Box3DData.Update = function(self)
			if not BoxPath then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end
			
			local ESPSettings = ESP.CurrentSettings;
			local _, isOnScreen = unpack(ESP._LastScreenPos);
			local Box3DEnabled = isOnScreen == true and (Library.GlobalConfig.Boxes3D == true and ESPSettings.Box3D.Enabled == true);
			
			if not Box3DEnabled then
				SetVisible(false);
				return
			end

			-- // Path // --
			local _isCornerOnScreen, _corners, screenCorners, _minX, _minY, _maxX, _maxY = GetModelCorners(ESPSettings.Model);
			if not (screenCorners and screenCorners[1]) then
				SetVisible(false);
				return
			end
			
			-- // Update Visuals // --
			SetVisible(true);
			BoxPath.Color3 = ESPSettings.Box3D.Color;
			BoxPath.Thickness = ESPSettings.Box3D.Thickness;
			
			if CoreGuiAllowed then
				BoxPath.Transparency = ESPSettings.Box3D.Transparency;
			end;

			-- 1-2-4-3-1 (Right Face) | 5-6-8-7-5 (Left Face)
			-- Connect: 1-5, 2-6, 4-8, 3-7
			-- Path: 1-2-4-3-1-5-6-8-7-5-6-2-4-8-7-3
			local PointIndices = {1, 2, 4, 3, 1, 5, 6, 8, 7, 5, 6, 2, 4, 8, 7, 3}
			local ControlPoints = table.create(16)
			
			for idx, Index in PointIndices do
				local Point = screenCorners[Index]
				ControlPoints[idx] = Path2DControlPoint.new(
					UDim2.fromOffset(Point.X, Point.Y)
				)
			end
			
			-- // Update Points // --
			BoxPath:SetControlPoints(ControlPoints);
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not BoxPath then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					SetVisible(value);
				else
					rawset(Box3DData, key, value);
				end
			end,

			__index = function(table, key)
				if not BoxPath then return nil end
				
				if key == "Visible" then
					return BoxPath.Visible;
				else
					return rawget(Box3DData, key);
				end
			end,

			__iter = function(_) return next, Box3DData end,
			__metatable = "The metatable is locked"
		}) :: typeof(Box3DData)
	end

	-- // Skeleton // --
	local R15Sequence = {
		-- Root
		"LowerTorso",

		-- Left Leg
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"LeftLowerLeg",
		"LeftUpperLeg",
		"LowerTorso",

		-- Right Leg
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"RightLowerLeg",
		"RightUpperLeg",
		"LowerTorso",

		-- Up torso
		"UpperTorso",

		-- Left Arm
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"LeftLowerArm",
		"LeftUpperArm",
		"UpperTorso",

		-- Right Arm
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"RightLowerArm",
		"RightUpperArm",
		"UpperTorso",

		-- Finish
		"Head"
	}

	local R6Sequence = {
		"Torso",

		-- Left Arm
		"Left Arm",
		"Torso",

		-- Right Arm
		"Right Arm",
		"Torso",

		-- Left Leg
		"Left Leg",
		"Torso",

		-- Right Leg
		"Right Leg",
		"Torso",

		-- Head
		"Head"
	}

	Components.Skeleton = function(ESP)
		if Library.Destroyed == true then
			debug_warn("Library is destroyed, please reload it.")
			return
		end
		
		if not ESP then 
			return
		end

		if not ESP.CurrentSettings.Skeleton.Enabled then
			return
		end

		debug_print("Creating Skeleton...")

		-- // Detect Rig Type and Get Joints // --
		local Model = ESP.CurrentSettings.Model
		local RigType = "Unknown"

		if Model:FindFirstChild("Humanoid") then
			if Model.Humanoid.RigType == Enum.HumanoidRigType.R15 then
				RigType = "R15"
			else
				RigType = "R6"
			end
		end

		if RigType == "Unknown" then
			debug_warn("Could not detect rig type for", ESP.CurrentSettings.Name)
			return
		end

		debug_print("Detected", RigType, "rig for", ESP.CurrentSettings.Name)
		local Sequence = if RigType == "R15" then R15Sequence else R6Sequence

		-- // Create Path2D // --
		local SkeletonPath = InstancesLib.Create("Path2D", {
			Parent = Library.MainGUI,
			Name = (if DEBUG_ENABLED then "Skeleton_" else "") .. ESP.Index,
			Visible = false,
			
			-- // Settings // --
			Color3 = ESP.CurrentSettings.Skeleton.Color,
			Thickness = ESP.CurrentSettings.Skeleton.Thickness,
			Transparency = ESP.CurrentSettings.Skeleton.Transparency
		})

		-- // Skeleton Data // --
		local SkeletonData = {}
		local CachedParts = {}

		local function SetVisible(visible: boolean)
			if not SkeletonPath then return end
			if SkeletonPath.Visible == visible then return end

			SkeletonPath.Parent = if visible then Library.MainGUI else Library.StorageFolder
			SkeletonPath.Visible = visible
		end

		SkeletonData.Destroy = function(self)
			if not SkeletonPath then return end
			
			SkeletonPath:SetControlPoints({});
			SkeletonPath:Destroy();

			SkeletonPath = nil;
			Sequence = nil;
		end;

		SkeletonData.Update = function(self)
			if not SkeletonPath then return end

			-- // ESP Settings // --
			if not ESP._LastScreenPos then return end
			
			local ESPSettings = ESP.CurrentSettings;
			local _, isOnScreen = unpack(ESP._LastScreenPos);
			local SkeletonEnabled = isOnScreen == true and (Library.GlobalConfig.Skeleton == true and ESPSettings.Skeleton.Enabled == true);
			
			if not SkeletonEnabled then
				SetVisible(false);
				return
			end

			-- // Build Path from Joints // --
			local ControlPoints = {}
			local pointsMade = 0

			for idx, partName in Sequence do
				local part = CachedParts[partName]
				if not part then
					part = Model:FindFirstChild(partName)
					CachedParts[partName] = part

					if not part then 
						partName = 0
						break
					end
				end

				local pos, visible = WorldToViewport(part.Position)
				if not visible then
					partName = 0
					break
				end

				ControlPoints[idx] = Path2DControlPoint.new(UDim2.fromOffset(pos.X, pos.Y))
				pointsMade = pointsMade + 1 
			end

			if pointsMade == 0 then
				SetVisible(false);
				return
			end

			-- // Update Visuals // --
			SetVisible(true);
			SkeletonPath.Color3 = if Library.GlobalConfig.Rainbow then Library.RainbowColor else ESPSettings.Skeleton.Color;
			SkeletonPath.Thickness = ESPSettings.Skeleton.Thickness;
			
			if CoreGuiAllowed then
				SkeletonPath.Transparency = ESPSettings.Skeleton.Transparency;
			end;

			-- // Update Points // --
			SkeletonPath:SetControlPoints(ControlPoints);
		end;

		return setmetatable({}, {
			__newindex = function(table, key, value)
				if not SkeletonPath then return end

				if key == "Visible" then
					assert(
						typeof(value) == "boolean", 
						string.format("Visible; expected boolean, got %s", typeof(value))
					);

					SkeletonPath.Visible = value;
				else
					rawset(SkeletonData, key, value);
				end
			end,

			__index = function(table, key)
				if not SkeletonPath then return nil end
				
				if key == "Visible" then
					return SkeletonPath.Visible;
				else
					return rawget(SkeletonData, key);
				end
			end,

			__iter = function(_) return next, SkeletonData end,
			__metatable = "The metatable is locked"
		}) :: typeof(SkeletonData)
	end
end

function Library:Add(espSettings: ESPSettings)
	if Library.Destroyed == true then
		debug_warn("Library is destroyed, please reload it.")
		return
	end

	assert(
		typeof(espSettings) == "table", 
		string.format("espSettings; expected table, got %s", typeof(espSettings))
	)
	assert(
		typeof(espSettings.Model) == "Instance",
		string.format("espSettings.Model; expected Instance, got %s", typeof(espSettings.Model))
	)

	-- // Fix ESPType // --
	if not espSettings.ESPType then espSettings.ESPType = "Highlight" end
	assert(
		typeof(espSettings.ESPType) == "string",
		string.format("espSettings.ESPType; expected string, got %s", typeof(espSettings.ESPType))
	)

	espSettings.ESPType = string.lower(espSettings.ESPType)
	assert(
		AllowedESPType[espSettings.ESPType] == true, 
		string.format("espSettings.ESPType; invalid ESPType, got %s", espSettings.ESPType)
	)

	-- // Fix Settings // --
	espSettings.Name = if typeof(espSettings.Name) == "string" then espSettings.Name else espSettings.Model.Name;
	espSettings.TextModel = if typeof(espSettings.TextModel) == "Instance" then espSettings.TextModel else espSettings.Model;
	
	espSettings = Validate(espSettings, DefaultSettings)

	-- // ESP Data // --
	local ESP = {
		Index = RandomString(),
		OriginalSettings = table_freeze(espSettings) :: ESPSettings,
		CurrentSettings = setmetatable({}, {
			__tostring = function(_) return tostring(espSettings) end,

			__index = function(_, key) return rawget(espSettings, key); end,
			__newindex = function(_, key, value)
				if key == "Model" or key == "TextModel" or key == "ESPType" then
					error(string.format("%s cannot be changed, it is read-only.", key))
				end

				rawset(espSettings, key, value);
			end,

			__eq = function(_, other) return other == espSettings end,
			__iter = function(_) return next, espSettings end,
			__metatable = "The metatable is locked"
		}) :: ESPSettings,

		Hidden = false,
		Deleted = false,

		Connections = {} :: { RBXScriptConnection },
		Components = {}
	} :: ESPInstance;

	debug_print("Creating ESP...", ESP.Index, "-", ESP.CurrentSettings.Name)

	-- // Create Components // --
	ESP.Components["Billboard"] = Components.Billboard(ESP)
	ESP.Components["Highlighter"] = Components.Highlighter(ESP)

	for Name, CreateFunc in Components do
		local Data = espSettings[Name]
		if not Data then continue end

		local Component = CreateFunc(ESP)
		if not Component then continue end

		ESP.Components[Name] = Component
	end

	-- // Setup Destroy Handler // --
	function ESP:Destroy()
		debug_print("Deleting ESP...", tostring(ESP.Index) .. " - " .. tostring(ESP.CurrentSettings.Name))
		
		if ESP.Deleted == true then
			debug_warn("ESP Instance is already deleted.")
			return;
		end

		-- // Change State // --
		ESP.Deleted = true

		-- // Remove from Library // --
		local TableIndex = table.find(Library.ESP, ESP.Index)
		if TableIndex then table.remove(Library.ESP, TableIndex) end
		Library.ESP[ESP.Index] = nil

		-- // Destroy Components // --
		for _, Component in ESP.Components do
			if not Component.Destroy then continue end

			Component:Destroy()
		end
		table.clear(ESP.Components)

		-- // Clear connections // --
		for _, connection in ESP.Connections do
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
		table.clear(ESP.Connections)

		-- // Callbacks // --
		if ESP.OriginalSettings.OnDestroy then
			SafeCallback(ESP.OriginalSettings.OnDestroy.Fire, ESP.OriginalSettings.OnDestroy)
		end

		if ESP.OriginalSettings.OnDestroyFunc then
			SafeCallback(ESP.OriginalSettings.OnDestroyFunc)
		end

		-- // Replace Render // --
		ESP.Render = function(...) end

		debug_print("ESP deleted.", ESP.Index, "-", ESP.CurrentSettings.Name)
	end

	-- // Setup Show/Hide Handler // --
	local function Show(forceShow: boolean?)
		if not (ESP and ESP.Deleted ~= true) then return end
		if forceShow ~= true and not ESP.Hidden then
			return
		end

		ESP.Hidden = false;
		for Name, Component in ESP.Components do
			Component.Visible = true
		end
	end

	local function Hide(forceHide: boolean?)
		if not (ESP and ESP.Deleted ~= true) then return end
		if forceHide ~= true and ESP.Hidden then
			return
		end

		ESP.Hidden = true;
		for Name, Component in ESP.Components do
			Component.Visible = false
		end
	end

	function ESP:Show(force: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = true;
		Show(force);
	end

	function ESP:Hide(force: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = false;
		Hide(force);
	end

	function ESP:ToggleVisibility(force: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end

		ESP.CurrentSettings.Visible = not ESP.CurrentSettings.Visible;
		if ESP.CurrentSettings.Visible then
			Show(force);
		else
			Hide(force);
		end
	end

	-- // Setup Setting Helpers // --
	function ESP:SetEveryColor(Color: Color3, IncludeComponents: boolean?)
		if not (ESP and ESP.CurrentSettings and ESP.Deleted ~= true) then return end
		local ESPSettings = ESP.CurrentSettings

		ESPSettings.Color = Color;

		-- // SelectionBox // --
		ESPSettings.SurfaceColor = Color;

		-- // Highlights // --
		ESPSettings.FillColor = Color;
		ESPSettings.OutlineColor = Color;

		-- // Components // --
		if IncludeComponents == true then
			for Name, Component in ESP.Components do
				local ComponentTable = ESPSettings[Name]
				if typeof(ComponentTable) ~= "table" then continue end

				ComponentTable.Color = Color;
			end
		end
	end

	-- // Setup Render Handler // --
	function ESP:Render()
		if not ESP then return end

		local ESPSettings = ESP.CurrentSettings
		if ESP.Deleted == true or not ESPSettings then return end
		
		-- // Early exit conditions // --
		if ESPSettings.Visible == false or not (
			Camera and (
				if Library.GlobalConfig.IgnoreCharacter == true then true else RootPart
			)
		) then
			Hide(true)
			return
		end

		-- // Check Distance // --
		if not ESPSettings.ModelRoot then
			ESPSettings.ModelRoot = InstancesLib.FindPrimaryPart(ESPSettings.Model)
		end

		local ModelRoot = ESPSettings.ModelRoot or ESPSettings.Model
		local DistanceFromPlayer = InstancesLib.DistanceFrom(ModelRoot, RootPart or Camera)
		ESP._LastDistance = DistanceFromPlayer

		if DistanceFromPlayer > ESPSettings.MaxDistance then
			Hide(true)
			return
		end

		-- // Get Screen Information // --
		local screenPos, isOnScreen = WorldToViewport(GetPivot(ModelRoot).Position)
		ESP._LastScreenPos = { screenPos, isOnScreen }

		-- // Before Update Callback // --
		if ESPSettings.BeforeUpdate then
			SafeCallback(ESPSettings.BeforeUpdate, ESP)
		end

		-- // Update Components // --
		for Name, Component in ESP.Components do
			if not Component.Update then continue end

			local success, err = xpcall(Component.Update, debug.traceback, Component)
			if success then continue end

			debug_warn("Error updating component (" .. Name .. "):\n", err)
		end

		-- // After Update Callback // --
		if ESPSettings.AfterUpdate then
			SafeCallback(ESPSettings.AfterUpdate, ESP)
		end
	end

	if ESP.OriginalSettings.Visible == false then
		Hide()
	else
		Show()
	end

	Library.ESP[ESP.Index] = ESP
	debug_print("ESP created.", ESP.Index, "-", ESP.CurrentSettings.Name)
	return ESP
end

-- // Update Player Variables // --
table.insert(Library.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = workspace.CurrentCamera; end))
table.insert(Library.Connections, Players.LocalPlayer.CharacterAdded:Connect(UpdatePlayerVariables))

-- // Rainbow Handler // --
table.insert(Library.Connections, RunService.RenderStepped:Connect(function(Delta)
	-- // Only update rainbow if it's enabled // --
	if not Library.GlobalConfig.Rainbow then return end
	
	Library.RainbowStep = Library.RainbowStep + Delta
	if Library.RainbowStep >= (1 / 60) then
		Library.RainbowStep = 0

		Library.RainbowHueSetup = Library.RainbowHueSetup + (1 / 400)
		if Library.RainbowHueSetup > 1 then
			Library.RainbowHueSetup = 0
		end

		Library.RainbowHue = Library.RainbowHueSetup
		Library.RainbowColor = Color3.fromHSV(Library.RainbowHue, 0.8, 1)
	end
end))

-- // Main Handler // --
table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
	for Index, ESP in Library.ESP do
		if not ESP then 
			Library.ESP[Index] = nil
			continue 
		end

		if 
			ESP.Deleted == true or 
			not (ESP.CurrentSettings and (ESP.CurrentSettings.Model and ESP.CurrentSettings.Model.Parent)) 
		then
			ESP:Destroy()
			continue
		end

		-- // Render ESP // --
		ESP.Render(ESP)
	end
end))

debug_print("Loaded! (" .. tostring(VERSION) ..")")
getgenv().mstudio45_ESP = Library
return Library
