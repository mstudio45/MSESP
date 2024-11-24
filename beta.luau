--[[
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
        Thickness : number [optional, default = 2]
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

local function debug_print(...)
    if getgenv().mstudio45_ESP_DEBUG == true then
        print("[mstudio45's ESP]", ...);
    end
end

if getgenv().mstudio45_ESP then
    debug_print("Already Loaded.");
    return getgenv().mstudio45_ESP;
end;

-- // Type Definitions // --
export type TracerESPSettings = {
    Enabled: boolean,
    
    Color: Color3?,
    Thickness: number?,
    Transparency: number?,
    From: ("Top" | "Bottom" | "Center" | "Mouse")?
}

export type ArrowESPSettings = {
    Enabled: boolean,

    Color: Color3?,
    CenterOffset: number?
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
    OnDestroyFunc: (() -> nil)?
}

-- // Variables // --
local tonumber_ = tonumber;
local tostring_ = tostring;
local typeof_ = typeof;
local pcall_ = pcall;

local mathrandom = math.random;
local mathrad = math.rad;

local tableconcat = table.concat;
local tableinsert = table.insert;
local tableclone = table.clone;
local tableremove = table.remove;
local tablefind = table.find;
local tablefreeze = function(table)
    local proxy = {};
    local data = tableclone(table);

    local mt = {
        __index = function(table, key)
            return data[key]
        end,

        __newindex = function(table, key, value)
            -- nope --
        end
    }

    return setmetatable(proxy, mt) :: typeof(table)
end;

local stringchar = string.char;

local CFrame_new = CFrame.new;
local CFrame_Angles = CFrame.Angles;

local Vec3_new = Vector3.new;
local Vec2_new = Vector2.new;
local UDim2_new = UDim2.new;
local Color3_new = Color3.new;

local Instance_new = Instance.new;

-- // Executor Variables // --
local cloneref = typeof_(cloneref) == "function" and cloneref or (function(obj) return obj end);
local getService = (function(name) return cloneref(game:GetService(name)) end);

-- // Services // --
local CoreGui = getService("CoreGui");
local gethui = typeof_(gethui) == "function" and gethui or (function() return CoreGui end);

local Players = getService("Players");
local RunService = getService("RunService");
local UserInputService = getService("UserInputService");
-- local GuiService = getService("GuiService");
local HiddenUI = (function()
    debug_print("Getting Hidden UI...");
    local TestGUI = Instance_new("ScreenGui");

    local parented = pcall_(function() TestGUI.Parent = gethui(); end);
    if not parented then
        TestGUI:Destroy();
        return Players.LocalPlayer.PlayerGui;
    end
    
    TestGUI:Destroy();
    return gethui();
end)()

-- // Strings // --
local function RandomString(length)
    length = tonumber_(length) or mathrandom(10,20)

    local array = {}
    for i = 1, length do
        array[i] = stringchar(mathrandom(32, 126))
    end

    return tableconcat(array)
end

-- // Instances // --
local InstancesLib = {
    Create = function(instanceType, properties)
        assert(typeof_(instanceType) == "string", "Argument #1 must be a string.");
        assert(typeof_(properties) == "table", "Argument #2 must be a table.");

        local instance = Instance_new(instanceType)
        for name, val in pairs(properties) do
            instance[name] = val;
        end

        return instance;
    end,

    HasProperty = function(instance, property)
        assert(typeof_(instance) == "Instance", "Argument #1 must be an Instance.");
        assert(typeof_(property) == "string", "Argument #2 must be a string.");

        local success, property = pcall_(function() return instance[property] end);
        return success and property or nil;
    end,

    FindPrimaryPart = function(instance)
        if typeof_(instance) ~= "Instance" then return nil end;
        return (instance:IsA("Model") and instance.PrimaryPart or nil) or instance:FindFirstChildWhichIsA("BasePart") or instance:FindFirstChildWhichIsA("UnionOperation") or instance;
    end,

    DistanceFrom = function(instaceOrPosition, instanceFrom)
        if not instaceOrPosition then return 9e9 end;
        if not instanceFrom then return 9e9 end;

        return instanceFrom ~= nil and 
            (instanceFrom.Position - (typeof_(instaceOrPosition) == "Instance" and (instaceOrPosition:GetPivot().Position) or instaceOrPosition)).Magnitude or 9e9;
    end
}

local StorageFolder = InstancesLib.Create("Folder", {
    Parent = HiddenUI;
    Name = RandomString();
});

local MainGUI = InstancesLib.Create("ScreenGui", {
    Parent = HiddenUI;
    Name = RandomString();
    IgnoreGuiInset = true;
    ResetOnSpawn = false;
    ClipToDeviceSafeArea = false;
    DisplayOrder = 999_999;
});

-- // Player Variables // --
local character;
local rootPart;
local camera;
local worldToViewport;

-- // Functions // --
local function UpdatePlayerVariables()
    debug_print("Updating Player Variables...");

    character = character or (Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait());
    rootPart = rootPart or (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character.PrimaryPart);

    camera = camera or workspace.CurrentCamera;
    worldToViewport = function(...) camera = (camera or workspace.CurrentCamera); return camera:WorldToViewportPoint(...) end;
end
UpdatePlayerVariables();

-- // Library // --
local Library = {
    -- // Storages // --
    StorageFolder = StorageFolder;
    MainGUI = MainGUI;
    ESP = {};
    Connections = {};

    -- // Global Config // --
    GlobalConfig = {
        Rainbow = false;

        Billboards = true;
        Highlighters = true;
        Distance = true;
        Tracers = true;
        Arrows = true;

        Font = Enum.Font.RobotoCondensed;
    };

    -- // Rainbow Variables // --
    RainbowHueSetup = 0;
    RainbowHue = 0;
    RainbowStep = 0;
    RainbowColor = Color3.new();
}

function Library:Clear()
    for _, ESP in pairs(Library.ESP) do
        if not ESP then continue end
        ESP:Destroy();
    end
end

local AllowedTracerFrom = {
    top = true,
    bottom = true,
    center = true,
    mouse = true
}

local AllowedESPType = {
    sphereadornment = true,
    cylinderadornment = true,
    adornment = true,
    selectionbox = true,
    highlight = true
}

function TracerCreate(espSettings: TracerESPSettings)
    if espSettings.Enabled ~= true then
        debug_print("Tracer is not enabled.");
        return
    end;
    debug_print("Creating Tracer...");

    -- // Fix Settings // --
    espSettings.Color = typeof(espSettings.Color) == "Color3" and espSettings.Color or Color3_new();
    espSettings.Thickness = typeof(espSettings.Thickness) == "number" and espSettings.Thickness or 2;
    espSettings.Transparency = typeof(espSettings.Transparency) == "number" and espSettings.Transparency or 0;
    espSettings.From = string.lower(typeof(espSettings.From) == "string" and espSettings.From or "bottom");
    if AllowedTracerFrom[espSettings.From] == nil then
        espSettings.From = "bottom";
    end;

    -- // Create Path2D // --
    local Path2D = InstancesLib.Create("Path2D", {
        Parent = MainGUI;

        Closed = true;

        -- // Settings // --
        Color3 = espSettings.Color;
        Thickness = espSettings.Thickness;
        Transparency = espSettings.Transparency;
    });

    local FromControlPoint = Path2DControlPoint.new(typeof_(espSettings.From) ~= "Vector2" and UDim2.fromOffset(0, 0) or UDim2.fromOffset(espSettings.From.X, espSettings.From.Y));
    local ToControlPoint = Path2DControlPoint.new(typeof_(espSettings.To) ~= "Vector2" and UDim2.fromOffset(0, 0) or UDim2.fromOffset(espSettings.To.X, espSettings.To.Y));
    Path2D:SetControlPoints({ FromControlPoint, ToControlPoint });

    local data = {
        From = Vec2_new(0, 0);
        To = Vec2_new(0, 0);

        Visible = true;
        Color3 = espSettings.Color;
        Thickness = espSettings.Thickness;
        Transparency = espSettings.Transparency;
    };
    local proxy = {};

    local Tracer = {
        __newindex = function(table, key, value)
            if Path2D == nil then return nil end

            if key == "From" then
                assert(typeof_(value) == "Vector2", tostring_(key) .. "; expected Vector2, got " .. typeof_(value));

                FromControlPoint = Path2DControlPoint.new(UDim2.fromOffset(value.X, value.Y))
                Path2D:SetControlPoints({ FromControlPoint, ToControlPoint });

            elseif key == "To" then
                assert(typeof_(value) == "Vector2", tostring_(key) .. "; expected Vector2, got " .. typeof_(value));

                ToControlPoint = Path2DControlPoint.new(UDim2.fromOffset(value.X, value.Y))
                Path2D:SetControlPoints({ FromControlPoint, ToControlPoint });

            elseif key == "Transparency" or key == "Thickness" then
                assert(typeof_(value) == "number", tostring_(key) .. "; expected number, got " .. typeof_(value));
                Path2D[key] = value;

            elseif key == "Color3" then
                assert(typeof_(value) == "Color3", tostring_(key) .. "; expected Color3, got " .. typeof_(value));
                Path2D.Color3 = value;
            
            elseif key == "Visible" then
                assert(typeof_(value) == "boolean", tostring_(key) .. "; expected boolean, got " .. typeof_(value));
                Path2D.Visible = value;

            end

            data[key] = value;
        end,
        
        __index = function(table, key)
            if Path2D == nil then return nil end

            if key == "Destroy" or key == "Delete" then
                return function()
                    Path2D:SetControlPoints({ });
                    Path2D:Destroy();

                    Path2D = nil;
                end
            end

            return data[key]
        end
    }

    debug_print("Tracer created.");
    return setmetatable(proxy, Tracer) :: typeof(data)
end

function Library:Add(espSettings: ESPSettings)
    assert(typeof_(espSettings) == "table", "espSettings; expected table, got " .. typeof_(espSettings));
    assert(typeof_(espSettings.Model) == "Instance", "espSettings.Model; expected Instance, got " .. typeof_(espSettings.Model));

    -- // Fix ESPType // --
    if espSettings.ESPType == nil then espSettings.ESPType = "Highlight"; end;
    assert(typeof_(espSettings.ESPType) == "string", "espSettings.ESPType; expected string, got " .. typeof_(espSettings.ESPType));

    espSettings.ESPType = string.lower(espSettings.ESPType);
    assert(AllowedESPType[espSettings.ESPType] == true, "espSettings.ESPType; invalid ESPType");

    -- // Fix Settings // --
    espSettings.Name = typeof_(espSettings.Name) == "string" and espSettings.Name or espSettings.Model.Name;
    espSettings.TextModel = typeof_(espSettings.TextModel) == "Instance" and espSettings.TextModel or espSettings.Model;

    espSettings.Visible = typeof_(espSettings.Visible) == "boolean" and espSettings.Visible or true;
    espSettings.Color = typeof_(espSettings.Color) == "Color3" and espSettings.Color or Color3_new();

    espSettings.StudsOffset = typeof_(espSettings.StudsOffset) == "Vector3" and espSettings.StudsOffset or Vec3_new();
    espSettings.TextSize = typeof_(espSettings.TextSize) == "number" and espSettings.TextSize or 16;

    espSettings.Thickness = typeof_(espSettings.Thickness) == "number" and espSettings.Thickness or 2;
    espSettings.Transparency = typeof_(espSettings.Transparency) == "number" and espSettings.Transparency or 0.65;

    espSettings.SurfaceColor = typeof_(espSettings.SurfaceColor) == "Color3" and espSettings.SurfaceColor or Color3_new();
    
    espSettings.FillColor = typeof_(espSettings.FillColor) == "Color3" and espSettings.FillColor or Color3_new();
    espSettings.OutlineColor = typeof_(espSettings.OutlineColor) == "Color3" and espSettings.OutlineColor or Color3_new(1, 1, 1);

    espSettings.FillTransparency = typeof_(espSettings.FillTransparency) == "number" and espSettings.FillTransparency or 0.65;    
    espSettings.OutlineTransparency = typeof_(espSettings.OutlineTransparency) == "number" and espSettings.OutlineTransparency or 0;

    espSettings.Tracer = typeof_(espSettings.Tracer) == "table" and espSettings.Tracer or { Enabled = false };
    espSettings.Arrow = typeof_(espSettings.Arrow) == "table" and espSettings.Arrow or { Enabled = false };

    local ESP = {
        Index = RandomString();
        OriginalSettings = tablefreeze(espSettings);
        CurrentSettings = espSettings;

        Hidden = false;
        Deleted = false;
        Connections = {};
    }

    debug_print("Creating ESP...", ESP.Index);

    -- // Create Billboard // --
    local Billboard = InstancesLib.Create("BillboardGui", {
        Parent = StorageFolder;
        Name = ESP.Index;

        Enabled = true;
        ResetOnSpawn = false;
        AlwaysOnTop = true;
        Size = UDim2_new(0, 200, 0, 50);

        -- // Settings // --
        Adornee = ESP.CurrentSettings.TextModel;
        StudsOffset = ESP.CurrentSettings.StudsOffset or Vec3_new();
    })

    local BillboardText = InstancesLib.Create("TextLabel", {
        Parent = Billboard;

        Size = UDim2_new(0, 200, 0, 50);
        Font = Library.GlobalConfig.Font;
        TextWrap = true;
        TextWrapped = true;
        RichText = true;
        TextStrokeTransparency = 0;
        BackgroundTransparency = 1;

        -- // Settings // --
        Text = ESP.CurrentSettings.Name;
        TextColor3 = ESP.CurrentSettings.Color or Color3_new();
        TextSize = ESP.CurrentSettings.TextSize or 16;
    });

    -- // Create Highlighter // --
    local Highlighter, IsAdornment = nil, ESP.OriginalSettings.ESPType:sub(9) == "adornment";
    debug_print("Creating Highlighter...", ESP.OriginalSettings.ESPType, IsAdornment);
    if IsAdornment == true then
        local _, ModelSize = ESP.CurrentSettings.Model:IsA("Model") and ESP.CurrentSettings.Model:GetBoundingBox() or nil, ESP.CurrentSettings.Model.Size;

        if ESP.OriginalSettings.ESPType == "sphereAdornment" then
            Highlighter = InstancesLib.Create("SphereHandleAdornment", {
                Parent = StorageFolder;
                Name = ESP.Index;

                Adornee = ESP.CurrentSettings.Model;
    
                AlwaysOnTop = true;
                ZIndex = 10;

                Radius = ModelSize.X * 1.085;
                CFrame = CFrame_new() * CFrame_Angles(mathrad(90), 0, 0);
    
                -- // Settings // --
                Color3 = ESP.CurrentSettings.Color or Color3_new();
                Transparency = ESP.CurrentSettings.Transparency or 0.65;
            });
        elseif ESP.OriginalSettings.ESPType == "cylinderAdornment" then
            Highlighter = InstancesLib.Create("CylinderHandleAdornment", {
                Parent = StorageFolder;
                Name = ESP.Index;

                Adornee = ESP.CurrentSettings.Model;
    
                AlwaysOnTop = true;
                ZIndex = 10;

                Height = ModelSize.Y * 2;
                Radius = ModelSize.X * 1.085;
                CFrame = CFrame_new() * CFrame_Angles(mathrad(90), 0, 0);
    
                -- // Settings // --
                Color3 = ESP.CurrentSettings.Color or Color3_new();
                Transparency = ESP.CurrentSettings.Transparency or 0.65;
            });
        else
            Highlighter = InstancesLib.Create("BoxHandleAdornment", {
                Parent = StorageFolder;
                Name = ESP.Index;

                Adornee = ESP.CurrentSettings.Model;
    
                AlwaysOnTop = true;
                ZIndex = 10;

                Size = ModelSize;
    
                -- // Settings // --
                Color3 = ESP.CurrentSettings.Color or Color3_new();
                Transparency = ESP.CurrentSettings.Transparency or 0.65;
            });
        end
    elseif ESP.OriginalSettings.ESPType == "selectionbox" then
        Highlighter = InstancesLib.Create("SelectionBox", {
            Parent = StorageFolder;
            Name = ESP.Index;

            Adornee = ESP.CurrentSettings.Model;
    
            Color3 = ESP.CurrentSettings.BorderColor or Color3_new();
            LineThickness = ESP.CurrentSettings.Thickness or 2;

            SurfaceColor3 = ESP.CurrentSettings.SurfaceColor or Color3_new();
            SurfaceTransparency = ESP.CurrentSettings.Transparency or 0.65;
        });
    else
        Highlighter = InstancesLib.Create("Highlight", {
            Parent = StorageFolder;
            Name = ESP.Index;

            Adornee = ESP.CurrentSettings.Model;

            -- // Settings // --
            FillColor = ESP.CurrentSettings.FillColor or Color3_new();
            OutlineColor = ESP.CurrentSettings.OutlineColor or Color3_new(1, 1, 1);
    
            FillTransparency = ESP.CurrentSettings.FillTransparency or 0.65;
            OutlineTransparency = ESP.CurrentSettings.OutlineTransparency or 0;
        });
    end

    -- // Create Tracer and Arrow // --
    local Tracer = (typeof_(ESP.OriginalSettings.Tracer) == "table" and ESP.OriginalSettings.Tracer.Enabled == true) and TracerCreate(ESP.CurrentSettings.Tracer) or nil;
    local Arrow = nil
    if typeof_(ESP.OriginalSettings.Arrow) == "table" and ESP.OriginalSettings.Arrow.Enabled == true then
        debug_print("Creating Arrow...", ESP.Index);
        Arrow = InstancesLib.Create("ImageLabel", {
            Parent = MainGUI;

            Size = UDim2.new(0, 48, 0, 48);
            SizeConstraint = Enum.SizeConstraint.RelativeYY;

            AnchorPoint = Vec2_new(0.5, 0.5);

            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Image = "http://www.roblox.com/asset/?id=16368985219";
            ImageColor3 = ESP.CurrentSettings.Color or Color3_new();
        });

        ESP.CurrentSettings.Arrow.CenterOffset = typeof_(ESP.CurrentSettings.Arrow.CenterOffset) == "number" and ESP.CurrentSettings.Arrow.CenterOffset or 300;
    end

    -- // Setup Delete Handler // --
    function ESP:Destroy()
        if ESP.Deleted == true then return end;
        debug_print("Deleting ESP...", ESP.Index);

        if tablefind(Library.ESP, ESP.Index) then tableremove(Library.ESP, tablefind(Library.ESP, ESP.Index)); end
        Library.ESP[ESP.Index] = nil;

        if Billboard ~= nil then Billboard:Destroy(); end
        if Highlighter ~= nil then Highlighter:Destroy(); end
        if Tracer ~= nil then Tracer:Destroy(); end
        if typeof(Arrow) == "Instance" then Arrow:Destroy(); end

        for Idx = #ESP.Connections, 1, -1 do
            local Connection = table.remove(ESP.Connections, Idx)
            if Connection == nil then continue end

            Connection:Disconnect()
        end

        ESP.Connections = {};
        ESP.Deleted = true;

        if ESP.OriginalSettings.OnDestroy ~= nil then
            pcall(function() ESP.OriginalSettings.OnDestroy:Fire(); end);
        end

        if ESP.OriginalSettings.OnDestroyFunc ~= nil then
            pcall(ESP.OriginalSettings.OnDestroyFunc);
        end

        debug_print("ESP deleted.", ESP.Index);
    end

    -- // Setup Update Handler // --
    local function Show(forceShow)
        if forceShow ~= true and ESP.Hidden == false then return end;
        ESP.Hidden = false;

        Billboard.Enabled = true;
        if Highlighter ~= nil then Highlighter.Adornee = ESP.CurrentSettings.Model; end
        if Tracer ~= nil then Tracer.Visible = true; end
    end

    local function Hide()
        if ESP.Hidden == true then return end;
        ESP.Hidden = true;

        Billboard.Enabled = false;
        if Highlighter ~= nil then Highlighter.Adornee = nil; end
        if Tracer ~= nil then Tracer.Visible = false; end
    end

    function ESP:Show() ESP.Visible = true; end
    function ESP:Hide() ESP.Visible = false end
    function ESP:ToggleVisibility() ESP.Visible = not ESP.Visible; end

    function ESP:Render()
        if ESP.Deleted == true then return end;
        if ESP.Visible == false or not (rootPart and camera) then
            Hide();
            return;
        end

        -- // Check Distance // --
        if ESP.CurrentSettings.ModelRoot == nil then
            ESP.CurrentSettings.ModelRoot = InstancesLib.FindPrimaryPart(ESP.CurrentSettings.Model);
        end

        local screenPos, isOnScreen = worldToViewport((ESP.CurrentSettings.ModelRoot or ESP.CurrentSettings.Model):GetPivot().Position);
        local distanceFromCharacter = InstancesLib.DistanceFrom((ESP.CurrentSettings.ModelRoot or ESP.CurrentSettings.Model), rootPart);
        if distanceFromCharacter > (ESP.CurrentSettings.MaxDistance or 5000) then
            Hide();
            return
        end

        -- // Update Arrow (only requires distance check) // --
        if typeof(Arrow) == "Instance" then
            if Library.GlobalConfig.Arrows == true and isOnScreen ~= true then
                local screenSize = camera.ViewportSize;
                local centerPos = Vec2_new(screenSize.X / 2, screenSize.Y / 2);

                -- use aspect to make oval circle (it's more accurate)
                -- local aspectRatioX = screenSize.X / screenSize.Y;
                -- local aspectRatioY = screenSize.Y / screenSize.X;
                -- local arrowPosPixel = Vec2_new(arrowTable.ArrowInstance.Position.X.Scale, arrowTable.ArrowInstance.Position.Y.Scale) * 1000;
                local partPos = Vec2_new(screenPos.X, screenPos.Y);

                local IsInverted = screenPos.Z <= 0;
                local invert = (IsInverted and -1 or 1);

                local direction = (partPos - centerPos);
                local arctan = math.atan2(direction.Y, direction.X);
                local angle = math.deg(arctan) + 90;
                local distance = (ESP.CurrentSettings.Arrow.CenterOffset * 0.001) * screenSize.Y;

                Arrow.Rotation = angle + 180 * (IsInverted and 0 or 1);
                Arrow.Position = UDim2.new(
                    0, centerPos.X + (distance * math.cos(arctan) * invert),
                    0, centerPos.Y + (distance * math.sin(arctan) * invert)
                );
                Arrow.Visible = true;

                Arrow.ImageColor3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Arrow.Color;
            else
                Arrow.Visible = false;
            end
        end

        if isOnScreen == false then
            Hide();
            return
        else
            Show();
        end

        -- // Update Tracer // --
        if Tracer ~= nil then
            if Library.GlobalConfig.Tracers == true then
                if ESP.CurrentSettings.Tracer.From == "mouse" then
                    local mousePos = UserInputService:GetMouseLocation();
                    Tracer.From = Vec2_new(mousePos.X, mousePos.Y);
                elseif ESP.CurrentSettings.Tracer.From== "top" then
                    Tracer.From = Vec2_new(camera.ViewportSize.X / 2, 0);

                elseif ESP.CurrentSettings.Tracer.From== "center" then
                    Tracer.From = Vec2_new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);

                else
                    Tracer.From = Vec2_new(camera.ViewportSize.X / 2, camera.ViewportSize.Y);
                end

                Tracer.To = Vec2_new(screenPos.X, screenPos.Y);

                Tracer.Transparency = ESP.CurrentSettings.Tracer.Transparency;
                Tracer.Thickness = ESP.CurrentSettings.Tracer.Thickness;
                Tracer.Color3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Tracer.Color;

                Tracer.Visible = true;
            else
                Tracer.Visible = false;
            end
        end

        -- // Update Billboard // --
        if Library.GlobalConfig.Billboards == true then
            if Library.GlobalConfig.Distance == true then
                BillboardText.Text = string.format("%s\n<font size=\"%d\">[%s]</font>", ESP.CurrentSettings.Name, ESP.CurrentSettings.TextSize - 3, math.floor(distanceFromCharacter));
            else
                BillboardText.Text = ESP.CurrentSettings.Name;
            end

            BillboardText.Font = Library.GlobalConfig.Font;
            BillboardText.TextColor3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Color;
            BillboardText.TextSize = ESP.CurrentSettings.TextSize;

            Billboard.Enabled = true;
        else
            Billboard.Enabled = false;
        end

        -- // Update Highlighter // --
        if Library.GlobalConfig.Highlighters == true then
            if IsAdornment == true then
                Highlighter.Color3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Color;
                Highlighter.Transparency = ESP.CurrentSettings.Transparency;

            elseif ESP.OriginalSettings.ESPType == "selectionbox" then
                Highlighter.Color3 = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.Color;
                Highlighter.LineThickness = ESP.CurrentSettings.Thickness;
    
                Highlighter.SurfaceColor3 = ESP.CurrentSettings.SurfaceColor;
                Highlighter.SurfaceTransparency = ESP.CurrentSettings.Transparency;

            else
                Highlighter.FillColor = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.FillColor;
                Highlighter.OutlineColor = Library.GlobalConfig.Rainbow and Library.RainbowColor or ESP.CurrentSettings.OutlineColor;
        
                Highlighter.FillTransparency = ESP.CurrentSettings.FillTransparency;
                Highlighter.OutlineTransparency = ESP.CurrentSettings.OutlineTransparency;

            end

            if Highlighter.Adornee == ESP.CurrentSettings.Model then Highlighter.Adornee = ESP.CurrentSettings.Model; end
        else
            Highlighter.Adornee = nil;
        end
    end

    if ESP.OriginalSettings.Visible == false then
        Hide();
    end

    Library.ESP[ESP.Index] = ESP;
    debug_print("ESP created.", ESP.Index);
    return ESP;
end

-- // Update Player Variables // --
tableinsert(Library.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(UpdatePlayerVariables));
tableinsert(Library.Connections, Players.LocalPlayer.CharacterAdded:Connect(UpdatePlayerVariables));

-- // Rainbow Handler // --
tableinsert(Library.Connections, RunService.RenderStepped:Connect(function(Delta)
    Library.RainbowStep = Library.RainbowStep + Delta

    if Library.RainbowStep >= (1 / 60) then
        Library.RainbowStep = 0

        Library.RainbowHueSetup = Library.RainbowHueSetup + (1 / 400);
        if Library.RainbowHueSetup > 1 then Library.RainbowHueSetup = 0; end;

        Library.RainbowHue = Library.RainbowHueSetup;
        Library.RainbowColor = Color3.fromHSV(Library.RainbowHue, 0.8, 1);
    end
end));

-- // Main Handler // --
tableinsert(Library.Connections, RunService.RenderStepped:Connect(function()
    if not (character and rootPart and camera) then return end;

    for _, ESP in pairs(Library.ESP) do
        if not ESP then continue end
        if ESP.CurrentSettings.Model == nil or ESP.CurrentSettings.Model.Parent == nil then 
            ESP:Destroy();
            continue
        end;

        ESP:Render();
    end
end));

debug_print("[mstudio45's ESP] Loaded! (v2)");
getgenv().mstudio45_ESP = Library;
return Library;
