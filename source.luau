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

                         Created by mstudio45 (Discord)
                       Contributors: Dottik, Master Oogway
--]]

--[[
    https://docs.mstudio45.com/

    ESPLib:Add({
        Name : string [optional]

        Model : Object
        TextModel : Object [optional]
        
        -- General Settings --
        Visible : boolean [optional]
        Color : Color3 [default = Color3.new]
        MaxDistance : number [optional, default = 5000]
        
        -- Billboard Settings --
        StudsOffset : Vector3 [optional]
        TextSize : number [optional, default = 16]
        
        -- Highlighter Settings --
        ESPType : SphereAdornment | CylinderAdornment | Adornment | SelectionBox | Highlight [default = Highlight]
        Thickness : number [optional, default = 0.1]
        Transparency : number [optional, default = 0.65]

        -- Note: All Adornment Types use Color and Transparency, no need to add them again to the table 

        -- SelectionBox (only include when ESPType is SelectionBox) --
        SurfaceColor : Color3 [default = Color3.new]
    
        -- Highlight (only include when ESPType is Highlight) --
        FillColor : Color3 [default = Color3.new]
        OutlineColor : Color3 [default = Color3.new(1, 1, 1)]
    
        FillTransparency : number [optional, default = 0.65]
        OutlineTransparency : number [optional, default = 0]
            
        -- Tracer Settings --
        Tracer = {
            Enabled : boolean [required, default = false]

            Color : Color3 [optional, default = Color3.new]
            Thickness : number [optional, default = 2]
            Transparency : number [optional, default = 0] -- Note: Transparency works the opposite way than in Roblox
            From : Top | Bottom | Center | Mouse [optional, default = Bottom]
        }

        -- Arrow Settings --
        Arrow = {
            Enabled : boolean [required, default = false]

            Color : Color3 [optional, default = Color3.new]
            CenterOffset : number [optional, default = 300]
        }

        -- OnDestroy Settings --
        OnDestroy : BindableEvent [optional]
        OnDestroyFunc : function [optional]
    })
--]]

local debug_print = if getgenv().mstudio45_ESP_DEBUG
	then function(...)
		print("[mstudio45's ESP]", ...)
	end
	else function() end

if getgenv().mstudio45_ESP then
	debug_print("Already Loaded.")
	return getgenv().mstudio45_ESP
end

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

export type ESPSettings = {
	Name: string?,

	Model: Object,
	TextModel: Object?,

	Visible: boolean?,
	Color: Color3?,
	MaxDistance: number?,

	StudsOffset: Vector3?,
	TextSize: number?,

	ESPType: ("SphereAdornment" | "CylinderAdornment" | "Adornment" | "SelectionBox" | "Highlight")?,
	Thickness: number?,
	Transparency: number?,

	SurfaceColor: Color3?,

	FillColor: Color3?,
	OutlineColor: Color3?,

	FillTransparency: number?,
	OutlineTransparency: number?,

	Tracer: TracerESPSettings?,
	Arrow: ArrowESPSettings?,

	OnDestroy: BindableEvent?,
	OnDestroyFunc: (() -> nil)?,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

-- // Variables // --
local tablefreeze = function<T>(provided_table: T): T
	local proxy = {}
	local data = table.clone(provided_table)

	local mt = {
		__index = function(table, key)
			return data[key]
		end,

		__newindex = function(table, key, value)
			-- nope --
		end,
	}

	return setmetatable(proxy, mt) :: typeof(provided_table)
end

local gethui = getgenv().gethui
do
	local testGui = Instance.new("ScreenGui")
	local successful = pcall(function()
		testGui.Parent = gethui and gethui() or CoreGui
	end)

	if not successful then
		gethui = function()
			return Players.LocalPlayer.PlayerGui
		end
	else
		gethui = gethui or function()
			return CoreGui
		end
	end

	testGui:Destroy()
end

local function RandomString(length: number)
	length = tonumber(length) or math.random(10, 20)

	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

-- // Instances // --
local InstancesLib = {
	Create = function(instanceType, properties)
		assert(typeof(instanceType) == "string", "Argument #1 must be a string.")
		assert(typeof(properties) == "table", "Argument #2 must be a table.")

		local instance = Instance.new(instanceType)
		for name, val in pairs(properties) do
			if name == "Parent" then
				continue -- Parenting is expensive, do last.
			end
			instance[name] = val
		end

		if properties["Parent"] ~= nil then
			instance.Parent = properties.Parent
		end

		return instance
	end,

	TryGetProperty = function(instance, property)
		assert(typeof(instance) == "Instance", "Argument #1 must be an Instance.")
		assert(typeof(property) == "string", "Argument #2 must be a string.")

		local success, property = pcall(function()
			return instance[property]
		end)
		return success and property or nil
	end,

	FindPrimaryPart = function(instance)
		if typeof(instance) ~= "Instance" then
			return nil
		end

		return (instance:IsA("Model") and instance.PrimaryPart or nil)
			or instance:FindFirstChildWhichIsA("BasePart")
			or instance:FindFirstChildWhichIsA("UnionOperation")
			or instance
	end,

	DistanceFrom = function(instaceOrPosition, instanceFrom)
		if not instaceOrPosition or not instanceFrom then
			return 9e9
		end

		return instanceFrom
				and (
					instanceFrom.Position
					- (
						typeof(instaceOrPosition) == "Instance" and instaceOrPosition:GetPivot().Position
						or instaceOrPosition
					)
				).Magnitude
			or 9e9
	end,
}

local StorageFolder = InstancesLib.Create("Folder", {
	Parent = gethui(),
	Name = RandomString(),
})

local MainGUI = InstancesLib.Create("ScreenGui", {
	Parent = gethui(),
	Name = RandomString(),
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false,
	DisplayOrder = 999_999,
})

-- // Player Variables // --
local character: Model
local rootPart: Part?
local camera: Camera

local worldToViewport = function(...)
	camera = (camera or workspace.CurrentCamera)
        if camera == nil then
		return Vector2.new(0, 0), false
	end

	return camera:WorldToViewportPoint(...)
end

-- // Functions // --
local function UpdatePlayerVariables()
	debug_print("Updating Player Variables...")

	character = (Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait())
	rootPart = (
		character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character.PrimaryPart
	)
	camera = workspace.CurrentCamera
end
UpdatePlayerVariables()

-- // Library // --
local Library = {
	-- // Storages // --
	StorageFolder = StorageFolder,
	MainGUI = MainGUI,
	ESP = {},
	Connections = {},

	-- // Global Config // --
	GlobalConfig = {
		Rainbow = false,

		Billboards = true,
		Highlighters = true,
		Distance = true,
		Tracers = true,
		Arrows = true,

		Font = Enum.Font.RobotoCondensed,
	},

	-- // Rainbow Variables // --
	RainbowHueSetup = 0,
	RainbowHue = 0,
	RainbowStep = 0,
	RainbowColor = Color3.new(),
}

function Library:Clear()
	for _, ESP in pairs(Library.ESP) do
		if not ESP then
			continue
		end
		ESP:Destroy()
	end
end

local AllowedTracerFrom = {
	top = true,
	bottom = true,
	center = true,
	mouse = true,
}

local AllowedESPType = {
	sphereadornment = true,
	cylinderadornment = true,
	adornment = true,
	selectionbox = true,
	highlight = true,
}

function TracerCreate(espSettings: TracerESPSettings)
	if not espSettings then
		espSettings = {}
	end

	if espSettings.Enabled ~= true then
		debug_print("Tracer is not enabled.")
		return
	end
	debug_print("Creating Tracer...")

	-- // Fix Settings // --
	espSettings.Color = typeof(espSettings.Color) == "Color3" and espSettings.Color or Color3.new()
	espSettings.Thickness = typeof(espSettings.Thickness) == "number" and espSettings.Thickness or 2
	espSettings.Transparency = typeof(espSettings.Transparency) == "number" and espSettings.Transparency or 0
	espSettings.From = string.lower(typeof(espSettings.From) == "string" and espSettings.From or "bottom")
	if AllowedTracerFrom[espSettings.From] == nil then
		espSettings.From = "bottom"
	end

	-- // Create Path2D // --
	local Path2D = InstancesLib.Create("Path2D", {
		Parent = MainGUI,

		Closed = true,

		-- // Settings // --
		Color3 = espSettings.Color,
		Thickness = espSettings.Thickness,
		Transparency = espSettings.Transparency,
	})

	local FromControlPoint = Path2DControlPoint.new(
		typeof(espSettings.From) ~= "Vector2" and UDim2.fromOffset(0, 0)
			or UDim2.fromOffset(espSettings.From.X, espSettings.From.Y)
	)
	local ToControlPoint = Path2DControlPoint.new(
		typeof(espSettings.To) ~= "Vector2" and UDim2.fromOffset(0, 0)
			or UDim2.fromOffset(espSettings.To.X, espSettings.To.Y)
	)

	Path2D:SetControlPoints({ FromControlPoint, ToControlPoint })

	local data = {
		From = Vector2.new(0, 0),
		To = Vector2.new(0, 0),

		Visible = true,
		Color3 = espSettings.Color,
		Thickness = espSettings.Thickness,
		Transparency = espSettings.Transparency,
	}
	local proxy = {}

	local Tracer = {
		__newindex = function(table, key, value)
			if not Path2D then
				return
			end

			if key == "From" then
				assert(typeof(value) == "Vector2", tostring(key) .. "; expected Vector2, got " .. typeof(value))

				FromControlPoint = Path2DControlPoint.new(UDim2.fromOffset(value.X, value.Y))
				Path2D:SetControlPoints({ FromControlPoint, ToControlPoint })
			elseif key == "To" then
				assert(typeof(value) == "Vector2", tostring(key) .. "; expected Vector2, got " .. typeof(value))

				ToControlPoint = Path2DControlPoint.new(UDim2.fromOffset(value.X, value.Y))
				Path2D:SetControlPoints({ FromControlPoint, ToControlPoint })
			elseif key == "Transparency" or key == "Thickness" then
				assert(typeof(value) == "number", tostring(key) .. "; expected number, got " .. typeof(value))
				Path2D[key] = value
			elseif key == "Color3" then
				assert(typeof(value) == "Color3", tostring(key) .. "; expected Color3, got " .. typeof(value))
				Path2D.Color3 = value
			elseif key == "Visible" then
				assert(typeof(value) == "boolean", tostring(key) .. "; expected boolean, got " .. typeof(value))
				Path2D.Visible = value
			end

			data[key] = value
		end,

		__index = function(table, key)
			if not Path2D then
				return nil
			end

			if key == "Destroy" or key == "Delete" then
				return function()
					Path2D:SetControlPoints({})
					Path2D:Destroy()

					Path2D = nil
				end
			end

			return data[key]
		end,
	}

	debug_print("Tracer created.")
	return setmetatable(proxy, Tracer) :: typeof(data)
end

function Library:Add(espSettings: ESPSettings)
	assert(typeof(espSettings) == "table", "espSettings; expected table, got " .. typeof(espSettings))
	assert(
		typeof(espSettings.Model) == "Instance",
		"espSettings.Model; expected Instance, got " .. typeof(espSettings.Model)
	)

	-- // Fix ESPType // --
	if not espSettings.ESPType then
		espSettings.ESPType = "Highlight"
	end
	assert(
		typeof(espSettings.ESPType) == "string",
		"espSettings.ESPType; expected string, got " .. typeof(espSettings.ESPType)
	)

	espSettings.ESPType = string.lower(espSettings.ESPType)
	assert(AllowedESPType[espSettings.ESPType] == true, "espSettings.ESPType; invalid ESPType")

	-- // Fix Settings // --
	espSettings.Name = typeof(espSettings.Name) == "string" and espSettings.Name or espSettings.Model.Name
	espSettings.TextModel = typeof(espSettings.TextModel) == "Instance" and espSettings.TextModel or espSettings.Model

	espSettings.Visible = typeof(espSettings.Visible) == "boolean" and espSettings.Visible or true
	espSettings.Color = typeof(espSettings.Color) == "Color3" and espSettings.Color or Color3.new()

	espSettings.StudsOffset = typeof(espSettings.StudsOffset) == "Vector3" and espSettings.StudsOffset or Vector3.new()
	espSettings.TextSize = typeof(espSettings.TextSize) == "number" and espSettings.TextSize or 16

	espSettings.Thickness = typeof(espSettings.Thickness) == "number" and espSettings.Thickness or 0.1
	espSettings.Transparency = typeof(espSettings.Transparency) == "number" and espSettings.Transparency or 0.65

	espSettings.SurfaceColor = typeof(espSettings.SurfaceColor) == "Color3" and espSettings.SurfaceColor or Color3.new()

	espSettings.FillColor = typeof(espSettings.FillColor) == "Color3" and espSettings.FillColor or Color3.new()
	espSettings.OutlineColor = typeof(espSettings.OutlineColor) == "Color3" and espSettings.OutlineColor
		or Color3.new(1, 1, 1)

	espSettings.FillTransparency = typeof(espSettings.FillTransparency) == "number" and espSettings.FillTransparency
		or 0.65
	espSettings.OutlineTransparency = typeof(espSettings.OutlineTransparency) == "number"
			and espSettings.OutlineTransparency
		or 0

	espSettings.Tracer = typeof(espSettings.Tracer) == "table" and espSettings.Tracer or { Enabled = false }
	espSettings.Arrow = typeof(espSettings.Arrow) == "table" and espSettings.Arrow or { Enabled = false }

	local ESP = {
		Index = RandomString(),
		OriginalSettings = tablefreeze(espSettings),
		CurrentSettings = espSettings,

		Hidden = false,
		Deleted = false,
		Connections = {} :: { RBXScriptConnection },
		RenderThread = nil :: thread?,
	}

	debug_print("Creating ESP...", ESP.Index)

	-- // Create Billboard // --
	local Billboard = InstancesLib.Create("BillboardGui", {
		Parent = StorageFolder,
		Name = ESP.Index,

		Enabled = true,
		ResetOnSpawn = false,
		AlwaysOnTop = true,
		Size = UDim2.new(0, 200, 0, 50),

		-- // Settings // --
		Adornee = ESP.CurrentSettings.TextModel,
		StudsOffset = ESP.CurrentSettings.StudsOffset or Vector3.new(),
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
		TextColor3 = ESP.CurrentSettings.Color or Color3.new(),
		TextSize = ESP.CurrentSettings.TextSize or 16,
	})

	InstancesLib.Create("UIStroke", {
		Parent = BillboardText
	})

	-- // Create Highlighter // --
	local Highlighter, IsAdornment = nil, not not string.match(string.lower(ESP.OriginalSettings.ESPType), "adornment")
	debug_print("Creating Highlighter...", ESP.OriginalSettings.ESPType, IsAdornment)
	if IsAdornment then
		local _, ModelSize = nil, nil
		if ESP.CurrentSettings.Model:IsA("Model") then
			_, ModelSize = ESP.CurrentSettings.Model:GetBoundingBox()
		else
			if not InstancesLib.TryGetProperty(ESP.CurrentSettings.Model, "Size") then
				local prim = InstancesLib.FindPrimaryPart(ESP.CurrentSettings.Model)
				if not InstancesLib.TryGetProperty(prim, "Size") then
					debug_print("Couldn't get model size, switching to Highlight.", ESP.Index)

					espSettings.ESPType = "Highlight"
					return Library:Add(espSettings)
				end

				ModelSize = prim.Size
			else
				ModelSize = ESP.CurrentSettings.Model.Size
			end
		end

		if ESP.OriginalSettings.ESPType == "sphereadornment" then
			Highlighter = InstancesLib.Create("SphereHandleAdornment", {
				Parent = StorageFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				AlwaysOnTop = true,
				ZIndex = 10,

				Radius = ModelSize.X * 1.085,
				CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),

				-- // Settings // --
				Color3 = ESP.CurrentSettings.Color or Color3.new(),
				Transparency = ESP.CurrentSettings.Transparency or 0.65,
			})
		elseif ESP.OriginalSettings.ESPType == "cylinderadornment" then
			Highlighter = InstancesLib.Create("CylinderHandleAdornment", {
				Parent = StorageFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				AlwaysOnTop = true,
				ZIndex = 10,

				Height = ModelSize.Y * 2,
				Radius = ModelSize.X * 1.085,
				CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0),

				-- // Settings // --
				Color3 = ESP.CurrentSettings.Color or Color3.new(),
				Transparency = ESP.CurrentSettings.Transparency or 0.65,
			})
		else
			Highlighter = InstancesLib.Create("BoxHandleAdornment", {
				Parent = StorageFolder,
				Name = ESP.Index,

				Adornee = ESP.CurrentSettings.Model,

				AlwaysOnTop = true,
				ZIndex = 10,

				Size = ModelSize,

				-- // Settings // --
				Color3 = ESP.CurrentSettings.Color or Color3.new(),
				Transparency = ESP.CurrentSettings.Transparency or 0.65,
			})
		end
	elseif ESP.OriginalSettings.ESPType == "selectionbox" then
		Highlighter = InstancesLib.Create("SelectionBox", {
			Parent = StorageFolder,
			Name = ESP.Index,

			Adornee = ESP.CurrentSettings.Model,

			Color3 = ESP.CurrentSettings.BorderColor or Color3.new(),
			LineThickness = ESP.CurrentSettings.Thickness or 0.1,

			SurfaceColor3 = ESP.CurrentSettings.SurfaceColor or Color3.new(),
			SurfaceTransparency = ESP.CurrentSettings.Transparency or 0.65,
		})
	else
		Highlighter = InstancesLib.Create("Highlight", {
			Parent = StorageFolder,
			Name = ESP.Index,

			Adornee = ESP.CurrentSettings.Model,

			-- // Settings // --
			FillColor = ESP.CurrentSettings.FillColor or Color3.new(),
			OutlineColor = ESP.CurrentSettings.OutlineColor or Color3.new(1, 1, 1),

			FillTransparency = ESP.CurrentSettings.FillTransparency or 0.65,
			OutlineTransparency = ESP.CurrentSettings.OutlineTransparency or 0,
		})
	end

	-- // Create Tracer and Arrow // --
	local Tracer = typeof(ESP.OriginalSettings.Tracer) == "table" and TracerCreate(ESP.CurrentSettings.Tracer) or nil;
	local Arrow = nil;
	if typeof(ESP.OriginalSettings.Arrow) == "table" then
		debug_print("Creating Arrow...", ESP.Index)
		Arrow = InstancesLib.Create("ImageLabel", {
			Parent = MainGUI,

			Size = UDim2.new(0, 48, 0, 48),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,

			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Image = "http://www.roblox.com/asset/?id=16368985219",
			ImageColor3 = ESP.CurrentSettings.Color or Color3.new(),
		})

		ESP.CurrentSettings.Arrow.CenterOffset = typeof(ESP.CurrentSettings.Arrow.CenterOffset) == "number"
				and ESP.CurrentSettings.Arrow.CenterOffset
			or 300
	end

	-- // Setup Delete Handler // --
	function ESP:Destroy()
		if ESP.Deleted == true then
			return
		end
		debug_print("Deleting ESP...", ESP.Index)
		ESP.Deleted = true

		if ESP.RenderThread then
			debug_print("Stopping render coroutine", ESP.Index)
			pcall(coroutine.close, ESP.RenderThread)
		end

		if table.find(Library.ESP, ESP.Index) then
			table.remove(Library.ESP, table.find(Library.ESP, ESP.Index))
		end

		Library.ESP[ESP.Index] = nil

		if Billboard then
			Billboard:Destroy()
		end

		if Highlighter then
			Highlighter:Destroy()
		end

		if Tracer then
			Tracer:Destroy()
		end

		if Arrow then
			Arrow:Destroy()
		end

		for _, connection in ESP.Connections do
			if not connection.Connected then
				continue
			end

			connection:Disconnect()
		end

		table.clear(ESP.Connections)

		if ESP.OriginalSettings.OnDestroy then
			pcall(ESP.OriginalSettings.OnDestroy.Fire, ESP.OriginalSettings.OnDestroy)
		end

		if ESP.OriginalSettings.OnDestroyFunc then
			pcall(ESP.OriginalSettings.OnDestroyFunc)
		end

		debug_print("ESP deleted.", ESP.Index)
	end

	-- // Setup Update Handler // --
	local function Show(forceShow: boolean)
		if not forceShow and not ESP.Hidden or ESP.Deleted then
			return
		end

		ESP.Hidden = false

		Billboard.Enabled = true

		if Highlighter then
			Highlighter.Adornee = ESP.CurrentSettings.Model
		end

		if Tracer then
			Tracer.Visible = true
		end
	end

	local function Hide()
		if ESP.Deleted or ESP.Hidden then
			return
		end

		ESP.Hidden = true

		Billboard.Enabled = false

		if Highlighter then
			Highlighter.Adornee = nil
		end

		if Tracer then
			Tracer.Visible = false
		end
	end

	function ESP:Show()
		ESP.Visible = true
	end
	function ESP:Hide()
		ESP.Visible = false
	end
	function ESP:ToggleVisibility()
		ESP.Visible = not ESP.Visible
	end

	function ESP:Render()
		if ESP.Deleted or not ESP.Visible or not (rootPart and camera) then
			Hide()
			return
		end

		-- // Check Distance // --
		if not ESP.CurrentSettings.ModelRoot then
			ESP.CurrentSettings.ModelRoot = InstancesLib.FindPrimaryPart(ESP.CurrentSettings.Model)
		end

		local screenPos, isOnScreen =
			worldToViewport((ESP.CurrentSettings.ModelRoot or ESP.CurrentSettings.Model):GetPivot().Position)
		local distanceFromCharacter =
			InstancesLib.DistanceFrom((ESP.CurrentSettings.ModelRoot or ESP.CurrentSettings.Model), rootPart)
		if distanceFromCharacter > (ESP.CurrentSettings.MaxDistance or 5000) then
			Hide()
			return
		end

		-- // Update Arrow (only requires distance check) // --
		if Arrow then
                        Arrow.Visible = (not not Library.GlobalConfig.Arrows) and (not not ESP.CurrentSettings.Arrow.Enabled) and (isOnScreen ~= true)
			
                        if Arrow.Visible then
				local screenSize = camera.ViewportSize
				local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

				-- use aspect to make oval circle (it's more accurate) (no its not mstudio)
				-- local aspectRatioX = screenSize.X / screenSize.Y;
				-- local aspectRatioY = screenSize.Y / screenSize.X;
				-- local arrowPosPixel = Vector2.new(arrowTable.ArrowInstance.Position.X.Scale, arrowTable.ArrowInstance.Position.Y.Scale) * 1000;
				local partPos = Vector2.new(screenPos.X, screenPos.Y)

				local IsInverted = screenPos.Z <= 0
				local invert = (IsInverted and -1 or 1)

				local direction = (partPos - centerPos)
				local arctan = math.atan2(direction.Y, direction.X)
				local angle = math.deg(arctan) + 90
				local distance = (ESP.CurrentSettings.Arrow.CenterOffset * 0.001) * screenSize.Y

				Arrow.Rotation = angle + 180 * (IsInverted and 0 or 1)
				Arrow.Position = UDim2.new(
					0,
					centerPos.X + (distance * math.cos(arctan) * invert),
					0,
					centerPos.Y + (distance * math.sin(arctan) * invert)
				)
				Arrow.ImageColor3 = Library.GlobalConfig.Rainbow and Library.RainbowColor
					or ESP.CurrentSettings.Arrow.Color
			end
		end

		if isOnScreen == false then
			Hide()
			return
		else
			Show()
		end

		-- // Update Tracer // --
		if Tracer then
			Tracer.Visible = (not not Library.GlobalConfig.Tracers) and (not not ESP.CurrentSettings.Tracer.Enabled)

			if Tracer.Visible then
				if ESP.CurrentSettings.Tracer.From == "mouse" then
					local mousePos = UserInputService:GetMouseLocation()
					Tracer.From = Vector2.new(mousePos.X, mousePos.Y)
				elseif ESP.CurrentSettings.Tracer.From == "top" then
					Tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
				elseif ESP.CurrentSettings.Tracer.From == "center" then
					Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
				else
					Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
				end

				Tracer.To = Vector2.new(screenPos.X, screenPos.Y)

				Tracer.Transparency = ESP.CurrentSettings.Tracer.Transparency
				Tracer.Thickness = ESP.CurrentSettings.Tracer.Thickness
				Tracer.Color3 = Library.GlobalConfig.Rainbow and Library.RainbowColor
					or ESP.CurrentSettings.Tracer.Color
			end
		end

		-- // Update Billboard // --
		Billboard.Enabled = not not Library.GlobalConfig.Billboards

		if Billboard.Enabled then
			if Library.GlobalConfig.Distance then
				BillboardText.Text = string.format(
					'%s\n<font size="%d">[%s]</font>',
					ESP.CurrentSettings.Name,
					ESP.CurrentSettings.TextSize - 3,
					math.floor(distanceFromCharacter)
				)
			else
				BillboardText.Text = ESP.CurrentSettings.Name
			end

			BillboardText.Font = Library.GlobalConfig.Font
			BillboardText.TextColor3 = Library.GlobalConfig.Rainbow and Library.RainbowColor
				or ESP.CurrentSettings.Color
			BillboardText.TextSize = ESP.CurrentSettings.TextSize
		end

		-- // Update Highlighter // --
		if Library.GlobalConfig.Highlighters then
			if IsAdornment then
				Highlighter.Color3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Color
				Highlighter.Transparency = ESP.CurrentSettings.Transparency
			elseif ESP.OriginalSettings.ESPType == "selectionbox" then
				Highlighter.Color3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Color
				Highlighter.LineThickness = ESP.CurrentSettings.Thickness

				Highlighter.SurfaceColor3 = ESP.CurrentSettings.SurfaceColor
				Highlighter.SurfaceTransparency = ESP.CurrentSettings.Transparency
			else
				Highlighter.FillColor = Library.GlobalConfig.Rainbow and Library.RainbowColor
					or ESP.CurrentSettings.FillColor
				Highlighter.OutlineColor = Library.GlobalConfig.Rainbow and Library.RainbowColor
					or ESP.CurrentSettings.OutlineColor

				Highlighter.FillTransparency = ESP.CurrentSettings.FillTransparency
				Highlighter.OutlineTransparency = ESP.CurrentSettings.OutlineTransparency
			end
			Highlighter.Adornee = ESP.CurrentSettings.Model
		else
			Highlighter.Adornee = nil
		end
	end

	if not ESP.OriginalSettings.Visible then
		Hide()
	end

	ESP.RenderThread = coroutine.create(function()
		while true do
			ESP:Render()
			coroutine.yield()
		end
	end)

	coroutine.resume(ESP.RenderThread)

	Library.ESP[ESP.Index] = ESP
	debug_print("ESP created.", ESP.Index)
	return ESP
end

-- // Update Player Variables // --
table.insert(Library.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(UpdatePlayerVariables))
table.insert(Library.Connections, Players.LocalPlayer.CharacterAdded:Connect(UpdatePlayerVariables))

-- // Rainbow Handler // --
table.insert(
	Library.Connections,
	RunService.RenderStepped:Connect(function(Delta)
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
	end)
)

-- // Main Handler // --
table.insert(
	Library.Connections,
	RunService.RenderStepped:Connect(function()
		if not (character and rootPart and camera) then
			return
		end

		for _, ESP in Library.ESP do
			if not ESP then
				continue
			end

			if not ESP.CurrentSettings.Model or not ESP.CurrentSettings.Model.Parent then
				ESP:Destroy()
				continue
			end

			pcall(coroutine.resume, ESP.RenderThread)
		end
	end)
)

debug_print("[mstudio45's ESP] Loaded! (v2)")
getgenv().mstudio45_ESP = Library
return Library
