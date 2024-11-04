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
--]]

-- local getgenvFunc = typeof(getgenv) == "function" and getgenv;
local global = getgenv; -- function() return getgenvFunc and getgenvFunc() or _G; end

if global().mstudio45 and global().mstudio45.ESPLibrary then
   return global().mstudio45.ESPLibrary;
end

local __DEBUG = false;
local __LOG = true;
local __PREFIX = "mstudio45's ESP"

local Library = {
    -- // Loggin // --
    Print = function(...)
        if __LOG ~= true then return end;
        print("[💭 INFO] " .. __PREFIX .. ":", ...);
    end,
    Warn = function(...)
        if __LOG ~= true then return end;
        warn("[⚠ WARN] " .. __PREFIX .. ":", ...);
    end,
    Error = function(...)
        if __LOG ~= true then return end;
        error("[🆘 ERROR] " .. __PREFIX .. ":", ...);
    end,
    Debug = function(...)
        if __DEBUG ~= true or __LOG ~= true then return end;
        print("[🛠 DEBUG] " .. __PREFIX .. ":", ...);
    end,

    SetDebugEnabled     = function(bool) __DEBUG = bool end,
    SetIsLoggingEnabled = function(bool) __LOG = bool end,
    SetPrefix           = function(pref) __PREFIX = tostring(pref) end,

    -- // Storage // --
    ESP = {
        Billboards = {},
        Adornments = {},
        Highlights = {},
        Outlines = {},

        Arrows = {},
        Tracers = {}
    },

    Folders = {}
};
Library.Connections = { List = {} };
function Library.Connections.Add(connection, keyName, stopWhenKey)
    assert(typeof(connection) == "RBXScriptConnection", "Argument #1 must be a RBXScriptConnection.");
    local totalCount = 0; for _, v in pairs(Library.Connections.List) do totalCount = totalCount + 1; end
    local key = table.find({ "string", "number" }, typeof(keyName)) and tostring(keyName) or totalCount + 1;

    if table.find(Library.Connections.List, key) or typeof(Library.Connections.List[key]) == "RBXScriptConnection" then
        Library.Warn(key, "already exists in Connections!")
        if stopWhenKey then return; end

        key = totalCount + 1;
    end

    Library.Debug(key, "connection added.");
    Library.Connections.List[key] = connection;
    return key;
end;
function Library.Connections.Remove(key)
    if typeof(Library.Connections.List[key]) ~= "RBXScriptConnection" then return; end;

    if Library.Connections.List[key].Connected then
        Library.Debug(key, "connection disconnected.")
        Library.Connections.List[key]:Disconnect();

        local keyIndex = table.find(Library.Connections.List, key);
        if keyIndex then table.remove(Library.Connections.List, keyIndex); end;
    end
end;

--// Global Toggles \\--
Library.Adornments = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Adornments.Enabled = bool;
        end;
    end,
    Enable = function() Library.Adornments.Enabled = true; end,
    Disable = function() Library.Adornments.Enabled = false; end,
    Toggle = function() Library.Adornments.Enabled = not Library.Adornments.Enabled; end
};

Library.Billboards = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Billboards.Enabled = bool;
        end;
    end,
    Enable = function() Library.Billboards.Enabled = true; end,
    Disable = function() Library.Billboards.Enabled = false; end,
    Toggle = function() Library.Billboards.Enabled = not Library.Billboards.Enabled; end
};

Library.Highlights = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Highlights.Enabled = bool;
        end;
    end,
    Enable = function() Library.Highlights.Enabled = true; end,
    Disable = function() Library.Highlights.Enabled = false; end,
    Toggle = function() Library.Highlights.Enabled = not Library.Highlights.Enabled; end
};

Library.Outlines = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Outlines.Enabled = bool;
        end;
    end,
    Enable = function() Library.Outlines.Enabled = true; end,
    Disable = function() Library.Outlines.Enabled = false; end,
    Toggle = function() Library.Outlines.Enabled = not Library.Outlines.Enabled; end
};

Library.Distance = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Distance.Enabled = bool;
        end;
    end,
    Enable = function() Library.Distance.Enabled = true; end,
    Disable = function() Library.Distance.Enabled = false; end,
    Toggle = function() Library.Distance.Enabled = not Library.Distance.Enabled; end
};

Library.Tracers = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Tracers.Enabled = bool;
        end;
    end,
    Enable = function() Library.Tracers.Enabled = true; end,
    Disable = function() Library.Tracers.Enabled = false; end,
    Toggle = function() Library.Tracers.Enabled = not Library.Tracers.Enabled; end
};

Library.Arrows = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Arrows.Enabled = bool;
        end;
    end,
    Enable = function() Library.Arrows.Enabled = true; end,
    Disable = function() Library.Arrows.Enabled = false; end,
    Toggle = function() Library.Arrows.Enabled = not Library.Arrows.Enabled; end
};

Library.Rainbow = {
    HueSetup = 0, Hue = 0, Step = 0,
    Color = Color3.new(),
    Enabled = false,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Rainbow.Enabled = bool;
        end;
    end,
    Enable = function() Library.Rainbow.Enabled = true; end,
    Disable = function() Library.Rainbow.Enabled = false; end,
    Toggle = function() Library.Rainbow.Enabled = not Library.Rainbow.Enabled; end
};

-- // Services // --
local getService = typeof(cloneref) == "function" and (function(name) return cloneref(game:GetService(name)) end) or (function(name) return game:GetService(name) end)
local Players = getService("Players");
local CoreGui = getService("CoreGui");
--local CoreGui = typeof(gethui) == "function" and gethui() or getService("CoreGui");
local RunService = getService("RunService");
local UserInputService = getService("UserInputService");

-- // Variables // --
local DrawingLib = typeof(Drawing) == "table" and Drawing or { noDrawing = true };

local localPlayer = Players.LocalPlayer;
local character;
local rootPart;
local camera;
local worldToViewport;

local function updateVariables()
    Library.Debug("Updating variables...")
    localPlayer = Players.LocalPlayer;

    character = character or (localPlayer.Character or localPlayer.CharacterAdded:Wait());
    rootPart = rootPart or (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")) or nil);

    camera = camera or workspace.CurrentCamera;
    worldToViewport = function(...) camera = (camera or workspace.CurrentCamera); return camera:WorldToViewportPoint(...) end;
    Library.Debug("Variables updated!")
end
updateVariables();

-- // Functions // --
local function getFolder(name, parent, backup, typeOfInstance)
    assert(typeof(name) == "string", "Argument #1 must be a string.");
    assert(typeof(parent) == "Instance", "Argument #2 must be an Instance.");

    Library.Debug("Creating folder '" .. name .. "'.")
    local folder = parent:FindFirstChild(name);
    if folder == nil then
        folder = Instance.new(if typeOfInstance == nil then "Folder" else tostring(typeOfInstance));
        folder.Name = name;

        local parented = pcall(function() folder.Parent = CoreGui; end);
        if not parented and backup then folder.Parent = backup; end;
    end
    return folder;
end

local function randomString()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

local function hasProperty(instance, property) -- // Finds a property using a pcall call and then returns the value of it // --
    assert(typeof(instance) == "Instance", "Argument #1 must be an Instance.");
    assert(typeof(property) == "string", "Argument #2 must be a string.");

    local clone = instance;
    local success, property = pcall(function() return clone[property] end);
    return success and property or nil;
end

local function findPrimaryPart(inst)
    if inst == nil or typeof(inst) ~= "Instance" then return nil end;
    return (inst:IsA("Model") and inst.PrimaryPart or nil) or inst:FindFirstChildWhichIsA("BasePart") or inst:FindFirstChildWhichIsA("UnionOperation") or inst;
end

local function createInstance(instanceType, properties)
    assert(typeof(instanceType) == "string", "Argument #1 must be a string.");
    assert(typeof(properties) == "table", "Argument #2 must be a table.");

    local success, instance = pcall(function() return Instance.new(instanceType) end);
    assert(success, "Failed to create the instance.");

    for propertyName, propertyValue in pairs(properties) do
        local success, errorMessage = pcall(function()
            instance[propertyName] = propertyValue;
        end)

        if not success then Library.Warn("Failed to set '" .. propertyName .. "' property.", errorMessage) end;
    end

    return instance;
end

local function distanceFromCharacter(position, getPositionFromCamera) -- // mspaint.lua (line 1240) // --
    if typeof(position) == "Instance" then position = position:GetPivot().Position; end;

    if getPositionFromCamera == true and camera then
        return (camera.CFrame.Position - position).Magnitude;
    end

    if rootPart then
        return (rootPart.Position - position).Magnitude;
    elseif camera then
        return (camera.CFrame.Position - position).Magnitude;
    end

    return 9e9;
end

local function getTracerTable(uiTable)
    if uiTable.IsNormalTracer == true then
        return uiTable;
    end

    return uiTable.TracerInstance;
end

local function deleteTracer(tracerInstance)
    if tracerInstance ~= nil then
        tracerInstance.Visible = false;

        if typeof(tracerInstance.Destroy) == "function" then
            tracerInstance:Destroy();
        elseif typeof(tracerInstance.Remove) == "function" then
            tracerInstance:Remove();
        end

        tracerInstance = nil;
    end
end

local function getArrowTable(uiTable)
    if uiTable.IsNormalArrow == true then
        return uiTable;
    end

    return uiTable.ArrowInstance;
end

local function createDeleteFunction(TableName, TableIndex, Table)
    local function delete()
        if typeof(Library.ESP[TableName]) ~= "table" then
            Library.Warn("Table '" .. TableName .. "' doesn't exists in Library.ESP.");
            return;
        end

        for _, uiTable in pairs({ Library.ESP[TableName][TableIndex], Table }) do
            if uiTable == nil then
                Library.Warn("'???' (" .. tostring(TableName) .. ")' is nil.")
                continue;
            end

            local tracerTable = getTracerTable(uiTable);

            Library.Debug("Deleting '" .. tostring(uiTable.Settings.Name) .. "' (" .. tostring(TableName) .. ")...");

            -- // Disconnect connections // --
            if typeof(uiTable.Connections) == "table" then
                Library.Debug("Removing connections...");
                for index, connectionKey in pairs(uiTable.Connections) do
                    Library.Connections.Remove(connectionKey);
                    uiTable.Connections[index] = nil;
                end
            end

            -- // Remove Elements // --
            if typeof(uiTable.UIElements) == "table" then
                Library.Debug("Removing elements...");
                for index, element in pairs(uiTable.UIElements) do
                    if element == nil or typeof(element) ~= "Instance" then continue; end

                    element:Destroy()
                    uiTable.UIElements[index] = nil;
                end
            end

            -- // Remove Billboard // --
            if uiTable.BillboardInstance ~= nil and typeof(uiTable.BillboardInstance.Destroy) == "function" then
                uiTable.BillboardInstance.Destroy()
            end

            -- // Remove Tracer // --
            local successTracer, errorMessageTracer = pcall(function()
                if TableName == "Tracers" then
                    if typeof(uiTable.TracerInstance) == "table" then
                        Library.Debug("Removing tracer...");
                        deleteTracer(uiTable.TracerInstance)
                    end

                    local tracerTable = getTracerTable(uiTable);
                    if tracerTable ~= nil then
                        Library.Debug("Removing tracer (#2)...");
                        deleteTracer(tracerTable.TracerInstance)
                    end

                    Library.Debug("Tracer deleted!");
                else
                    if uiTable.TracerInstance ~= nil then
                        uiTable.TracerInstance:Destroy();
                    end
                end
            end);
            if not successTracer then
                Library.Warn("Failed to delete tracer.", errorMessageTracer);
            end

            -- // Remove Arrow // --
            local arrowTable = getArrowTable(uiTable);
            if arrowTable ~= nil and arrowTable ~= uiTable then
                arrowTable.Destroy()
            end
            --if uiTable.ArrowInstance ~= nil and typeof(uiTable.ArrowInstance.Destroy) == "function" then
            --    uiTable.ArrowInstance.Destroy()
            --end

            -- // Remove from Library // --
            uiTable.Deleted = true;
            local tableIndex = table.find(Library.ESP[TableName], TableIndex)
            if tableIndex then table.remove(Library.ESP[TableName], tableIndex) end

            if uiTable.TableIndex ~= nil then
                local uiTableIndex = table.find(Library.ESP[uiTable.TableName], uiTable.TableIndex)
                if uiTableIndex then table.remove(Library.ESP[uiTable.TableName], uiTableIndex) end
            end

            if typeof(uiTable.OnDestroy) == "function" then pcall(uiTable.OnDestroy) end

            Library.Debug("'" .. tostring(uiTable.Settings.Name) .. "' (" .. tostring(TableName) .. ") is now deleted!");
        end

        Library.Debug("----------")
        Library.Debug("Finished all system of deleting [", TableName, "]")
    end

    return delete;
end

-- // Setup ESP Info Table // --
Library.Folders.Main = getFolder("__ESP_FOLDER", CoreGui, localPlayer.PlayerGui);
Library.Folders.Billboards = getFolder("__BILLBOARDS_FOLDER", Library.Folders.Main);
Library.Folders.Adornments = getFolder("__ADORNMENTS_FOLDER", Library.Folders.Main);
Library.Folders.Highlights = getFolder("__HIGHLIGHTS_FOLDER", Library.Folders.Main);
Library.Folders.Outlines = getFolder("__OUTLINES_FOLDER", Library.Folders.Main);

Library.Folders.GUI = getFolder("__GUI", CoreGui, localPlayer.PlayerGui, "ScreenGui");
Library.Folders.GUI.IgnoreGuiInset = true;

-- // ESP Templates // --
local Templates = {
    Billboard = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,
        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        Color = Color3.new(),
        WasCreatedWithDifferentESP = false,

        Hidden = false,
        OnDestroy = nil,
    },

    Arrow = {
        Model = nil,
        Visible = true,
        MaxDistance = 5000,
        CenterOffset = 300,

        Color = Color3.new(),
        WasCreatedWithDifferentESP = false,

        FlipOnScreenCheck = false,
        Hidden = false,
        OnDestroy = nil,
    },

    Tracer = {
        Model = nil,
        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        From = "Bottom", -- // Top, Center, Bottom, Mouse // --

        Color = Color3.new(),

        Thickness = 2,
        Transparency = 0.65,

        Hidden = false,
        OnDestroy = nil,
    },

    Highlight = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,

        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        FillColor = Color3.new(),
        OutlineColor = Color3.new(),
        TextColor = Color3.new(),

        FillTransparency = 0.65,
        OutlineTransparency = 0,

        Hidden = false,
        OnDestroy = nil,
    },

    Adornment = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,

        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        Color = Color3.new(),
        TextColor = Color3.new(),

        Transparency = 0.65,
        Type = "Box", -- // Box, Cylinder, Sphere // --

        Hidden = false,
        OnDestroy = nil,
    },

    Outline = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,

        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        SurfaceColor = Color3.new(),
        BorderColor = Color3.new(),
        TextColor = Color3.new(),

        Thickness = 0.04, -- 2
        Transparency = 0.65,

        Hidden = false,
        OnDestroy = nil,
    }
}

-- // Library Handler // --
function Library.Validate(args, template)
    -- // Adds missing values depending on the 'template' argument // --
    args = type(args) == "table" and args or {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or type(argValue) ~= type(value) then
            args[key] = value
        elseif type(value) == "table" then
            args[key] = Library.Validate(argValue, value)
        end
    end

    return args
end

function Library.ESP.Clear()
    Library.Debug("---------------------------");

    for _, uiTable in pairs(Library.ESP) do
        if typeof(uiTable) ~= "table" then continue; end

        Library.Debug("Clearing '" .. tostring(_) .. "' ESP...")
        for _, uiElement in pairs(uiTable) do
            if not uiElement then continue; end
            -- task.spawn(function()
            if typeof(uiElement) == "table" and typeof(uiElement.Destroy) == "function" then
                local success, errorMessage = pcall(function()
                    uiElement.Destroy()
                end);

                if success == false then Library.Warn("Failed to ESP Element.", errorMessage); end;
            elseif typeof(uiElement) == "Instance" then
                uiElement:Destroy();
            end
        end
    end

    for name, uiFolder in pairs(Library.Folders) do
        if name == "Main" then continue; end

        Library.Debug("Clearing '" .. tostring(name) .. "' folder...")
        uiFolder:ClearAllChildren();
    end

    Library.Debug("---------------------------");
end

-- // ESP Handler // --
function Library.ESP.Billboard(args)
    assert(typeof(args) == "table", "args must be a table.");
    args = Library.Validate(args, Templates.Billboard);
    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");
    args.TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or args.Model;

    Library.Debug("Creating Billboard '" .. tostring(args.Name) .. "'...")
    -- // Instances // --
    local GUI = createInstance("BillboardGui", {
        Name = "GUI_" .. args.Name,
        Parent = Library.Folders.Billboards,

        ResetOnSpawn = false,
        Enabled = true,
        AlwaysOnTop = true,

        Size = UDim2.new(0, 200, 0, 50),
        StudsOffset = args.StudsOffset,

        Adornee = args.TextModel
    });

    local Text = createInstance("TextLabel", {
        Parent = GUI,
        Visible = true,

        Name = "Text",
        ZIndex = 0,

        Size = UDim2.new(0, 200, 0, 50),

        FontSize = Enum.FontSize.Size18,
        Font = Enum.Font.RobotoCondensed,

        Text = args.Name,
        TextColor3 = args.Color,
        TextStrokeTransparency = 0,
        TextSize = args.TextSize,

        TextWrapped = true,
        TextWrap = true,
        RichText = true,

        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    });
    createInstance("UIStroke", { Parent = Text });

    local TableName = "Billboards";
    local TableIndex = randomString();

    local BillboardTable = {
        TableIndex = TableIndex, TableName = TableName,

        Settings = args,
        UIElements = {
            GUI,
            Text
        },
        TracerInstance = nil
    };

    BillboardTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                BillboardTable.Destroy();
            end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function()
            BillboardTable.Destroy();
        end))
    };

    -- // Delete Handler // --
    BillboardTable.Hidden = args.Hidden;
    BillboardTable.Deleted = false;
    BillboardTable.Destroy = createDeleteFunction(TableName, TableIndex, BillboardTable);
    BillboardTable.OnDestroy = args.OnDestroy;
    --BillboardTable.Delete = BillboardTable.Destroy;

    BillboardTable.GetDistance = function()
        if BillboardTable.Deleted then return 9e9 end;
        if BillboardTable.Settings.Model == nil or BillboardTable.Settings.Model.Parent == nil then return 9e9 end;
        return math.round(distanceFromCharacter(BillboardTable.Settings.Model));
    end;

    BillboardTable.Update = function(args, updateVariables)
        if BillboardTable.Deleted or not Text then return; end
        args = Library.Validate(args, BillboardTable.Settings);

        local _Color = typeof(args.Color) == "Color3" and args.Color or BillboardTable.Settings.Color;
        local _TextSize = typeof(args.TextSize) == "number" and args.TextSize or BillboardTable.Settings.TextSize;
        local _TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or BillboardTable.Settings.TextModel;

        Text.TextColor3 = _Color;
        Text.TextSize = _TextSize;
        GUI.Adornee = _TextModel or BillboardTable.Settings.Model;

        if updateVariables ~= false then
            BillboardTable.Settings.Color       = _Color;
            BillboardTable.Settings.TextSize    = _TextSize;
            BillboardTable.Settings.TextModel   = _TextModel;

            BillboardTable.Settings.MaxDistance = typeof(args.MaxDistance) == "number" and args.MaxDistance or BillboardTable.Settings.MaxDistance;
        end
    end;
    BillboardTable.SetColor = BillboardTable.Update;

    BillboardTable.SetText = function(text)
        if BillboardTable.Deleted or not Text then return; end

        BillboardTable.Settings.Name = (typeof(text) == "string" and text or BillboardTable.Settings.Name);
        Text.Text = BillboardTable.Settings.Name;
    end;
    BillboardTable.SetDistanceText = function(distance)
        if BillboardTable.Deleted or not Text then return; end
        if typeof(distance) ~= "number" then return; end

        if Library.Distance.Enabled == true then
            Text.Text = string.format("%s\n<font size=\"%d\">[%s]</font>", BillboardTable.Settings.Name, BillboardTable.Settings.TextSize - 3, distance)
        else
            Text.Text = BillboardTable.Settings.Name
        end
    end;

    BillboardTable.SetVisible = function(visible)
        if BillboardTable.Deleted or not GUI then return; end

        BillboardTable.Settings.Visible = if typeof(visible) == "boolean" then visible else BillboardTable.Settings.Visible;
        GUI.Enabled = BillboardTable.Settings.Visible;
    end

    -- // Return // --
    Library.ESP[TableName][TableIndex] = BillboardTable;
    return BillboardTable;
end

function Library.ESP.Arrow(args)
    assert(typeof(args) == "table", "args must be a table.");
    args = Library.Validate(args, Templates.Arrow);
    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");

    Library.Debug("Creating Arrow '" .. tostring(args.Name) .. "'...")
    -- // Instances // --
    local Arrow = createInstance("ImageLabel", {
        Parent = Library.Folders.GUI,

        Visible = true,

        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Image = "http://www.roblox.com/asset/?id=16368985219",
        ImageColor3 = args.Color,

        Size = UDim2.new(0, 48, 0, 48),
        SizeConstraint = Enum.SizeConstraint.RelativeYY
    });

    local TableName = "Arrows";
    local TableIndex = randomString();

    local ArrowTable = {
        TableIndex = TableIndex, TableName = TableName,

        Settings = args,
        UIElements = { Arrow },
        ArrowInstance = Arrow,
        IsNormalArrow = true
    };

    ArrowTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                ArrowTable.Destroy();
            end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function()
            ArrowTable.Destroy();
        end))
    };

    -- // Delete Handler // --
    ArrowTable.Hidden = args.Hidden;
    ArrowTable.Deleted = false;
    ArrowTable.Destroy = createDeleteFunction(TableName, TableIndex, ArrowTable);
    ArrowTable.OnDestroy = args.OnDestroy;
    --ArrowTable.Delete = ArrowTable.Destroy;

    ArrowTable.Update = function(args, updateVariables)
        if ArrowTable.Deleted or not Arrow then return; end
        args = Library.Validate(args, ArrowTable.Settings);

        local _Color = if typeof(args.Color) == "Color3" then args.Color else ArrowTable.Settings.Color;
        Arrow.ImageColor3 = _Color;

        if updateVariables ~= false then
            ArrowTable.Settings.Color = _Color;
            ArrowTable.Settings.CenterOffset = if typeof(args.CenterOffset) == "number" then args.CenterOffset else ArrowTable.Settings.CenterOffset;
            ArrowTable.Settings.Visible = if typeof(args.Visible) == "boolean" then args.Visible else ArrowTable.Settings.Visible;

            ArrowTable.Settings.MaxDistance = if typeof(args.MaxDistance) == "number" then args.MaxDistance else ArrowTable.Settings.MaxDistance;
        end
    end;
    ArrowTable.SetColor = ArrowTable.Update;

    ArrowTable.SetVisible = function(visible)
        if ArrowTable.Deleted or not Arrow then return; end

        ArrowTable.Settings.Visible = if typeof(visible) == "boolean" then visible else ArrowTable.Settings.Visible;
        Arrow.Visible = ArrowTable.Settings.Visible;
    end;

    ArrowTable.UpdateArrow = function(rotation, position)
        if ArrowTable.Deleted or not Arrow then return; end

        ArrowTable.Settings.Rotation = if typeof(rotation) == "number" then rotation else ArrowTable.Settings.Rotation;
        ArrowTable.Settings.Position = if typeof(position) == "UDim2" then position else ArrowTable.Settings.Position;

        Arrow.Position = ArrowTable.Settings.Position or Arrow.Position;
        Arrow.Rotation = ArrowTable.Settings.Rotation or Arrow.Rotation;
    end;

    -- // Return // --
    Library.ESP[TableName][TableIndex] = ArrowTable;
    return ArrowTable;
end

function Library.ESP.Tracer(args)
    if DrawingLib.noDrawing == true then
        return {
            TableIndex = 0, TableName = "Tracers",

            Settings = {},
            UIElements = {},
            TracerInstance = nil,
            IsNormalTracer = true,
            DistancePart = nil,

            -- // Delete Handler // --
            Deleted = true,
            Destroy = function() end,

            -- // Misc Functions // --
            Update = function() end,
            SetColor = function() end,
            SetVisible = function() end
        }
    end

    assert(typeof(args) == "table", "args must be a table.");
    args = Library.Validate(args, Templates.Tracer);
    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");
    args.From = string.lower(args.From);

    Library.Debug("Creating Tracer...")
    -- // Create Tracer // --
    local TracerInstance = DrawingLib.new("Line")
    TracerInstance.Visible = args.Visible;
    TracerInstance.Color = args.Color;
    TracerInstance.Thickness = args.Thickness;
    TracerInstance.Transparency = args.Transparency;

    local TableName = "Tracers";
    local TableIndex = randomString();

    local TracerTable = {
        TableIndex = TableIndex, TableName = TableName,

        Settings = args,
        TracerInstance = TracerInstance,
        IsNormalTracer = true
    };

    TracerTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                TracerTable.Destroy();
            end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function()
            TracerTable.Destroy();
        end))
    };

    -- // Delete Handler // --
    TracerTable.Hidden = args.Hidden;
    TracerTable.Deleted = false;
    TracerTable.Destroy = createDeleteFunction(TableName, TableIndex, TracerTable);
    TracerTable.OnDestroy = args.OnDestroy;
    --TracerTable.Delete = TracerTable.Destroy;

    TracerTable.DistancePart = findPrimaryPart(TracerTable.Settings.Model);
    TracerTable.Update = function(args, updateVariables)
        if TracerTable.Deleted or not TracerTable.TracerInstance then return; end
        args = Library.Validate(args, TracerTable.Settings);

        local _Color = typeof(args.Color) == "Color3" and args.Color or TracerTable.Settings.Color;
        local _Thickness = typeof(args.Thickness) == "number" and args.Thickness or TracerTable.Settings.Thickness;
        local _Transparency = typeof(args.Transparency) == "number" and args.Transparency or TracerTable.Settings.Transparency;
        local _From = table.find({ "top", "center", "bottom", "mouse" }, string.lower(args.From)) and string.lower(args.From) or TracerTable.Settings.From;
        local _Visible = typeof(args.Visible) == "boolean" and args.Visible or TracerTable.Settings.Visible;

        TracerTable.TracerInstance.Color = _Color;
        TracerTable.TracerInstance.Thickness = _Thickness
        TracerTable.TracerInstance.Transparency = _Transparency;
        TracerTable.TracerInstance.Visible = _Visible;

        if updateVariables ~= false then
            TracerTable.Settings.Color         = _Color;
            TracerTable.Settings.Thickness     = _Thickness;
            TracerTable.Settings.Transparency  = _Transparency;
            TracerTable.Settings.From          = _From;
            TracerTable.Settings.Visible       = _Visible;

            TracerTable.Settings.MaxDistance = typeof(args.MaxDistance) == "number" and args.MaxDistance or TracerTable.Settings.MaxDistance;
        end
    end;
    TracerTable.SetColor = TracerTable.Update;

    TracerTable.SetVisible = function(visible)
        if TracerTable.Deleted or not TracerTable.TracerInstance then return; end
        TracerTable.Update({ Visible = visible })
    end

    -- // Return // --
    Library.ESP[TableName][TableIndex] = TracerTable;
    return TracerTable;
end

function Library.ESP.Highlight(args)
    assert(typeof(args) == "table", "args must be a table.");
    args = Library.Validate(args, Templates.Highlight)

    -- // Tracer // --
    do
        args.Tracer = Library.Validate(args.Tracer, Templates.Tracer);
        args.Tracer.Enabled = typeof(args.Tracer.Enabled) ~= "boolean" and false or args.Tracer.Enabled;
        args.Tracer.Model = args.Model;
    end

    -- // Arrow // --
    do
        args.Arrow = Library.Validate(args.Arrow, Templates.Arrow);
        args.Arrow.Enabled = typeof(args.Arrow.Enabled) ~= "boolean" and false or args.Arrow.Enabled;
        args.Arrow.Model = args.Model;
    end

    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");

    Library.Debug("Creating Highlight '" .. tostring(args.Name) .. "'...")
    local BillboardTable = Library.ESP.Billboard({
        Name = args.Name,
        Model = args.Model,
        TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or nil,

        MaxDistance = args.MaxDistance,
        StudsOffset = args.StudsOffset,
        Color = args.TextColor,

        WasCreatedWithDifferentESP = true
    });

    local Highlight = createInstance("Highlight", {
        Parent = Library.Folders.Highlights,

        FillColor = args.FillColor,
        OutlineColor = args.OutlineColor,

        FillTransparency = args.FillTransparency,
        OutlineTransparency = args.OutlineTransparency,

        Adornee = args.Model
    });

    local TableName = "Highlights";
    local TableIndex = randomString();

    local HighlightTable = {
        TableIndex = TableIndex, TableName = TableName,

        Settings = args,
        UIElements = { Highlight },
        TracerInstance = args.Tracer.Enabled == true and Library.ESP.Tracer(args.Tracer) or nil,
        BillboardInstance = BillboardTable,
        ArrowInstance = args.Arrow.Enabled == true and Library.ESP.Arrow(args.Arrow) or nil
    };
    HighlightTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                HighlightTable.Destroy();
            end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function()
            HighlightTable.Destroy();
        end))
    };

    -- // Delete Handler // --
    HighlightTable.Hidden = args.Hidden;
    HighlightTable.Deleted = false;
    HighlightTable.Destroy = createDeleteFunction(TableName, TableIndex, HighlightTable);
    HighlightTable.OnDestroy = args.OnDestroy;
    --HighlightTable.Delete = HighlightTable.Destroy;

    HighlightTable.GetDistance = BillboardTable.GetDistance;

    HighlightTable.Update = function(args, updateVariables)
        if HighlightTable.Deleted or (not Highlight and not BillboardTable) then return; end

        if HighlightTable.TracerInstance ~= nil and typeof(args.Tracer) == "table" then
            HighlightTable.TracerInstance.Update(args.Tracer, updateVariables);
        end;

        if HighlightTable.ArrowInstance ~= nil and typeof(args.Arrow) == "table" then
            HighlightTable.ArrowInstance.Update(args.Arrow, updateVariables);
        end;

        local settings = HighlightTable.Settings; HighlightTable.Settings.Tracer = nil;
        args = Library.Validate(args, settings);

        local _FillColor = typeof(args.FillColor) == "Color3" and args.FillColor or HighlightTable.Settings.FillColor;
        local _OutlineColor = typeof(args.OutlineColor) == "Color3" and args.OutlineColor or HighlightTable.Settings.OutlineColor;

        local _FillTransparency = typeof(args.FillTransparency) == "number" and args.FillTransparency or HighlightTable.Settings.FillTransparency;
        local _OutlineTransparency = typeof(args.OutlineTransparency) == "number" and args.OutlineTransparency or HighlightTable.Settings.OutlineTransparency;

        local _TextColor = typeof(args.TextColor) == "Color3" and args.TextColor or HighlightTable.Settings.TextColor;
        local _TextSize = typeof(args.TextSize) == "number" and args.TextSize or HighlightTable.Settings.TextSize;
        local _TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or HighlightTable.Settings.TextModel;

        Highlight.FillColor = _FillColor;
        Highlight.OutlineColor = _OutlineColor;
        BillboardTable.Update({ Color = _TextColor, TextSize = _TextSize, TextModel = _TextModel }, updateVariables);

        Highlight.FillTransparency = _FillTransparency;
        Highlight.OutlineTransparency = _OutlineTransparency;

        if updateVariables ~= false then
            HighlightTable.Settings.FillColor           = _FillColor;
            HighlightTable.Settings.OutlineColor        = _OutlineColor;

            HighlightTable.Settings.FillTransparency    = _FillTransparency;
            HighlightTable.Settings.OutlineTransparency = _OutlineTransparency;

            HighlightTable.Settings.TextColor           = _TextColor;
            HighlightTable.Settings.TextSize            = _TextSize;
            HighlightTable.Settings.TextModel           = _TextModel;

            HighlightTable.Settings.MaxDistance = typeof(args.MaxDistance) == "number" and args.MaxDistance or HighlightTable.Settings.MaxDistance;
        end
    end;
    HighlightTable.SetColor = HighlightTable.Update;

    HighlightTable.SetText = function(text)
        if HighlightTable.Deleted or not BillboardTable then return; end

        HighlightTable.Settings.Name = (typeof(text) == "string" and text or HighlightTable.Settings.Name);
        BillboardTable.SetText(HighlightTable.Settings.Name);
    end;
    HighlightTable.SetDistanceText = BillboardTable.SetDistanceText;

    HighlightTable.SetVisible = function(visible, tracer)
        if HighlightTable.Deleted or not Highlight then return; end

        HighlightTable.Settings.Visible = if typeof(visible) == "boolean" then visible else HighlightTable.Settings.Visible;
        Highlight.Enabled = HighlightTable.Settings.Visible;
        if tracer ~= false and HighlightTable.TracerInstance ~= nil then HighlightTable.TracerInstance.SetVisible(HighlightTable.Settings.Visible); end;
    end;

    -- // Return // --
    Library.ESP[TableName][TableIndex] = HighlightTable;
    return HighlightTable;
end

function Library.ESP.Adornment(args)
    assert(typeof(args) == "table", "args must be a table.")
    args = Library.Validate(args, Templates.Adornment);

    -- // Tracer // --
    do
        args.Tracer = Library.Validate(args.Tracer, Templates.Tracer);
        args.Tracer.Enabled = typeof(args.Tracer.Enabled) ~= "boolean" and false or args.Tracer.Enabled;
        args.Tracer.Model = args.Model;
    end

    -- // Arrow // --
    do
        args.Arrow = Library.Validate(args.Arrow, Templates.Arrow);
        args.Arrow.Enabled = typeof(args.Arrow.Enabled) ~= "boolean" and false or args.Arrow.Enabled;
        args.Arrow.Model = args.Model;
    end

    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");

    args.Type = string.lower(args.Type);

    Library.Debug("Creating Adornment '" .. tostring(args.Name) .. "'...")
    local BillboardTable = Library.ESP.Billboard({
        Name = args.Name,
        Model = args.Model,
        TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or nil,

        MaxDistance = args.MaxDistance,
        StudsOffset = args.StudsOffset,
        Color = args.TextColor,

        WasCreatedWithDifferentESP = true
    });

    local ModelSize;
    if args.Model:IsA("Model") then
        _, ModelSize = args.Model:GetBoundingBox()
    else
        ModelSize = args.Model.Size
    end

    local Adornment; do
        if args.Type == "sphere" then
            Adornment = createInstance("SphereHandleAdornment", {
                Radius = ModelSize.X * 1.085,
                CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0)
            });
        elseif args.Type == "cylinder" then
            Adornment = createInstance("CylinderHandleAdornment", {
                Height = ModelSize.Y * 2,
                Radius = ModelSize.X * 1.085,
                CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0)
            });
        else
            Adornment = createInstance("BoxHandleAdornment", {
                Size = ModelSize
            });
        end
    end;

    Adornment.Color3 = args.Color;
    Adornment.Transparency = args.Transparency;
    Adornment.AlwaysOnTop = true;
    Adornment.ZIndex = 10;
    Adornment.Adornee = args.Model;
    Adornment.Parent = Library.Folders.Adornments;

    local TableName = "Adornments";
    local TableIndex = randomString();

    local AdornmentTable = {
        TableIndex = TableIndex, TableName = TableName,

        Settings = args,
        UIElements = { Adornment },
        TracerInstance = args.Tracer.Enabled == true and Library.ESP.Tracer(args.Tracer) or nil,
        BillboardInstance = BillboardTable,
        ArrowInstance = args.Arrow.Enabled == true and Library.ESP.Arrow(args.Arrow) or nil
    };
    AdornmentTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                AdornmentTable.Destroy();
            end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function()
            AdornmentTable.Destroy();
        end))
    };

    -- // Delete Handler // --
    AdornmentTable.Hidden = args.Hidden;
    AdornmentTable.Deleted = false;
    AdornmentTable.Destroy = createDeleteFunction(TableName, TableIndex, AdornmentTable);
    AdornmentTable.OnDestroy = args.OnDestroy;
    --AdornmentTable.Delete = AdornmentTable.Destroy;

    AdornmentTable.GetDistance = BillboardTable.GetDistance;

    AdornmentTable.Update = function(args, updateVariables)
        if AdornmentTable.Deleted or (not Adornment and not BillboardTable) then return; end

        if AdornmentTable.TracerInstance ~= nil and typeof(args.Tracer) == "table" then
            AdornmentTable.TracerInstance.Update(args.Tracer, updateVariables);
        end;

        if AdornmentTable.ArrowInstance ~= nil and typeof(args.Arrow) == "table" then
            AdornmentTable.ArrowInstance.Update(args.Arrow, updateVariables);
        end;

        local settings = AdornmentTable.Settings; AdornmentTable.Settings.Tracer = nil;
        args = Library.Validate(args, settings);

        local _Color = typeof(args.Color) == "Color3" and args.Color or AdornmentTable.Settings.Color;

        local _TextColor = typeof(args.TextColor) == "Color3" and args.TextColor or AdornmentTable.Settings.TextColor;
        local _TextSize = typeof(args.TextSize) == "number" and args.TextSize or AdornmentTable.Settings.TextSize;
        local _TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or AdornmentTable.Settings.TextModel;

        Adornment.Color3 = _Color;
        BillboardTable.Update({ Color = _TextColor, TextSize = _TextSize, TextModel = _TextModel }, updateVariables);

        if updateVariables ~= false then
            AdornmentTable.Settings.Color     = _Color;

            AdornmentTable.Settings.TextSize  = _TextSize;
            AdornmentTable.Settings.TextColor = _TextColor;
            AdornmentTable.Settings.TextModel = _TextModel;

            AdornmentTable.Settings.MaxDistance = typeof(args.MaxDistance) == "number" and args.MaxDistance or AdornmentTable.Settings.MaxDistance;
        end
    end;
    AdornmentTable.SetColor = AdornmentTable.Update;

    AdornmentTable.SetText = function(text)
        if AdornmentTable.Deleted or not BillboardTable then return; end

        AdornmentTable.Settings.Name = (typeof(text) == "string" and text or AdornmentTable.Settings.Name);
        BillboardTable.SetText(AdornmentTable.Settings.Name);
    end;
    AdornmentTable.SetDistanceText = BillboardTable.SetDistanceText;

    AdornmentTable.SetVisible = function(visible, tracer)
        if AdornmentTable.Deleted or not Adornment then return; end

        AdornmentTable.Settings.Visible = if typeof(visible) == "boolean" then visible else AdornmentTable.Settings.Visible;
        Adornment.Adornee = AdornmentTable.Settings.Visible and AdornmentTable.Settings.Model or nil;
        if tracer ~= false and AdornmentTable.TracerInstance ~= nil then AdornmentTable.TracerInstance.SetVisible(AdornmentTable.Settings.Visible); end;
    end

    -- // Return // --
    Library.ESP[TableName][TableIndex] = AdornmentTable;
    return AdornmentTable;
end

function Library.ESP.Outline(args)
    assert(typeof(args) == "table", "args must be a table.")
    args = Library.Validate(args, Templates.Outline);

    -- // Tracer // --
    do
        args.Tracer = Library.Validate(args.Tracer, Templates.Tracer);
        args.Tracer.Enabled = typeof(args.Tracer.Enabled) ~= "boolean" and false or args.Tracer.Enabled;
        args.Tracer.Model = args.Model;
    end

    -- // Arrow // --
    do
        args.Arrow = Library.Validate(args.Arrow, Templates.Arrow);
        args.Arrow.Enabled = typeof(args.Arrow.Enabled) ~= "boolean" and false or args.Arrow.Enabled;
        args.Arrow.Model = args.Model;
    end

    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");

    Library.Debug("Creating Outline '" .. tostring(args.Name) .. "'...")
    local BillboardTable = Library.ESP.Billboard({
        Name = args.Name,
        Model = args.Model,
        TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or nil,

        MaxDistance = args.MaxDistance,
        StudsOffset = args.StudsOffset,
        Color = args.TextColor,

        WasCreatedWithDifferentESP = true
    });

    local Outline = createInstance("SelectionBox", {
        Parent = Library.Folders.Outlines,

        SurfaceColor3 = args.SurfaceColor,
        Color3 = args.BorderColor,
        LineThickness = args.Thickness,
        SurfaceTransparency = args.Transparency,

        Adornee = args.Model
    });

    local TableName = "Outlines";
    local TableIndex = randomString();

    local OutlineTable = {
        TableIndex = TableIndex, TableName = TableName,

        Settings = args,
        UIElements = { Outline },
        TracerInstance = args.Tracer.Enabled == true and Library.ESP.Tracer(args.Tracer) or nil,
        BillboardInstance = BillboardTable,
        ArrowInstance = args.Arrow.Enabled == true and Library.ESP.Arrow(args.Arrow) or nil
    };

    OutlineTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                OutlineTable.Destroy();
            end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function()
            OutlineTable.Destroy();
        end))
    };

    -- // Delete Handler // --
    OutlineTable.Hidden = args.Hidden;
    OutlineTable.Deleted = false;
    OutlineTable.Destroy = createDeleteFunction(TableName, TableIndex, OutlineTable);
    OutlineTable.OnDestroy = args.OnDestroy;
    --OutlineTable.Delete = OutlineTable.Destroy;

    OutlineTable.GetDistance = BillboardTable.GetDistance;

    OutlineTable.Update = function(args, updateVariables)
        if OutlineTable.Deleted or (not Outline and not BillboardTable) then return; end

        if OutlineTable.TracerInstance ~= nil and typeof(args.Tracer) == "table" then
            OutlineTable.TracerInstance.Update(args.Tracer, updateVariables);
        end;

        if OutlineTable.ArrowInstance ~= nil and typeof(args.Arrow) == "table" then
            OutlineTable.ArrowInstance.Update(args.Arrow, updateVariables);
        end;

        local settings = OutlineTable.Settings; OutlineTable.Settings.Tracer = nil;
        args = Library.Validate(args, settings);

        local _SurfaceColor = typeof(args.SurfaceColor) == "Color3" and args.SurfaceColor or OutlineTable.Settings.SurfaceColor;
        local _BorderColor = typeof(args.BorderColor) == "Color3" and args.BorderColor or OutlineTable.Settings.BorderColor;
        local _Thickness = typeof(args.Thickness) == "number" and args.Thickness or OutlineTable.Settings.Thickness;
        local _Transparency = typeof(args.Transparency) == "number" and args.Transparency or OutlineTable.Settings.Transparency;

        local _TextColor = typeof(args.TextColor) == "Color3" and args.TextColor or OutlineTable.Settings.TextColor;
        local _TextSize = typeof(args.TextSize) == "number" and args.TextSize or OutlineTable.Settings.TextSize;
        local _TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or OutlineTable.Settings.TextModel;

        Outline.SurfaceColor3 = _SurfaceColor;
        Outline.Color3 = _BorderColor;
        Outline.LineThickness = _Thickness;
        Outline.SurfaceTransparency = _Transparency;
        BillboardTable.Update({ Color = _TextColor, TextSize = _TextSize, TextModel = _TextModel }, updateVariables);

        if updateVariables ~= false then
            OutlineTable.Settings.SurfaceColor  = _SurfaceColor;
            OutlineTable.Settings.BorderColor   = _BorderColor;
            OutlineTable.Settings.Thickness     = _Thickness;
            OutlineTable.Settings.Transparency  = _Transparency;

            OutlineTable.Settings.TextColor     = _TextColor;
            OutlineTable.Settings.TextSize      = _TextSize;
            OutlineTable.Settings.TextModel     = _TextModel;

            OutlineTable.Settings.MaxDistance = typeof(args.MaxDistance) == "number" and args.MaxDistance or OutlineTable.Settings.MaxDistance;
        end
    end
    OutlineTable.SetColor = OutlineTable.Update;

    OutlineTable.SetText = function(text)
        if OutlineTable.Deleted or not BillboardTable then return; end

        OutlineTable.Settings.Name = (typeof(text) == "string" and text or OutlineTable.Settings.Name);
        BillboardTable.SetText(OutlineTable.Settings.Name);
    end
    OutlineTable.SetDistanceText = BillboardTable.SetDistanceText;

    OutlineTable.SetVisible = function(visible, tracer)
        if OutlineTable.Deleted or not Outline then return; end

        OutlineTable.Settings.Visible = if typeof(visible) == "boolean" then visible else OutlineTable.Settings.Visible;
        Outline.Adornee = OutlineTable.Settings.Visible and OutlineTable.Settings.Model or nil;
        if tracer ~= false and OutlineTable.TracerInstance ~= nil then OutlineTable.TracerInstance.SetVisible(OutlineTable.Settings.Visible); end;
    end

    -- // Return // --
    Library.ESP[TableName][TableIndex] = OutlineTable;
    return OutlineTable;
end

Library.Connections.Add(RunService.RenderStepped:Connect(function(Delta)
    Library.Rainbow.Step = Library.Rainbow.Step + Delta

    if Library.Rainbow.Step >= (1 / 60) then
        Library.Rainbow.Step = 0

        Library.Rainbow.HueSetup = Library.Rainbow.HueSetup + (1 / 400);
        if Library.Rainbow.HueSetup > 1 then Library.Rainbow.HueSetup = 0; end;

        Library.Rainbow.Hue = Library.Rainbow.HueSetup;
        Library.Rainbow.Color = Color3.fromHSV(Library.Rainbow.Hue, 0.8, 1);
    end
end), "RainbowStepped", true);

-- // Update Handler // --
local function checkUI(uiTable, TableName, TableIndex)
    if uiTable == nil and true or (
        typeof(uiTable) == "table" and uiTable.Deleted == true
    ) then
        if uiTable then
            if typeof(uiTable.Destroy) == "function" then uiTable.Destroy(); end
            Library.ESP[uiTable.TableName][uiTable.TableIndex] = nil;
        end

        Library.ESP[TableName][TableIndex] = nil;
        return false;
    end

    return true;
end

local function checkVisibility(ui, root, skipOnScreen)
    local pos, onScreen = worldToViewport(root:GetPivot().Position);
    local distanceFromChar = distanceFromCharacter(root);
    local maxDist = tonumber(ui.Settings.MaxDistance) or 5000

    -- // Check Distance and if its on the screen // --
    if skipOnScreen ~= true and onScreen == false then
       if ui.Hidden ~= true then
           ui.Hidden = true;
           ui.SetVisible(false);
       end

       return pos, onScreen, false;
    end

    if distanceFromChar > maxDist then
        if ui.Hidden ~= true then
            ui.Hidden = true;
            ui.SetVisible(false);
        end

        return pos, onScreen, false;
    end

    return pos, onScreen, true;
end



Library.Connections.Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then camera = workspace.CurrentCamera; end;
end), "CameraUpdate", true);

Library.Connections.Add(localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter;
    rootPart = character:WaitForChild("HumanoidRootPart", 5);
end), "CharacterUpdate", true);

Library.Connections.Add(RunService.RenderStepped:Connect(function(dt)
    if not (character and rootPart and camera) then return; end;

    -- // Update Tracers // --
    for _, tracerTable in pairs(Library.ESP.Tracers) do
        if not checkUI(tracerTable, "Tracers", tracerTable.TableIndex) then continue; end

        if tracerTable.Deleted ~= true and tracerTable.TracerDeleted ~= true and tracerTable.TracerInstance ~= nil then
            local pos, onScreen, canContinue = checkVisibility(tracerTable, tracerTable.DistancePart)
            if not (Library.Tracers.Enabled and canContinue) then tracerTable.TracerInstance.Visible = false; continue; end

            if onScreen and tracerTable.Settings.Visible == true then
                if tracerTable.Settings.From == "mouse" then
                    local mousePos = UserInputService:GetMouseLocation();
                    tracerTable.TracerInstance.From = Vector2.new(mousePos.X, mousePos.Y);
                elseif tracerTable.Settings.From == "top" then
                    tracerTable.TracerInstance.From = Vector2.new(camera.ViewportSize.X / 2, 0);
                elseif tracerTable.Settings.From == "center" then
                    tracerTable.TracerInstance.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
                else
                    tracerTable.TracerInstance.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y);
                end

                tracerTable.TracerInstance.To = Vector2.new(pos.X, pos.Y);
                tracerTable.Update({ Color = Library.Rainbow.Enabled and Library.Rainbow.Color or tracerTable.Settings.Color }, false);
            else
                tracerTable.TracerInstance.Visible = false;
            end;
        else
            if tracerTable.Deleted ~= true then
                tracerTable.Deleted = true;
                if tracerTable.TracerInstance ~= nil then
                    tracerTable.TracerInstance.Visible = false;
                end;
            end;
        end;
    end;

    -- // Update Arrows // --
    for _, arrowTable in pairs(Library.ESP.Arrows) do
        if not checkUI(arrowTable, "Arrows", arrowTable.TableIndex) then continue; end
        if not (Library.Arrows.Enabled == true and arrowTable.Settings.Visible == true) then arrowTable.ArrowInstance.Visible = false; continue; end

        local pos, onScreen, canContinue = checkVisibility(arrowTable, arrowTable.Settings.Model, true);
        if onScreen then arrowTable.ArrowInstance.Visible = false; continue; end

        local screenSize = camera.ViewportSize;
        local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y/2);

        -- use aspect to make oval circle (it's more accurate)
        -- local aspectRatioX = screenSize.X / screenSize.Y;
        -- local aspectRatioY = screenSize.Y / screenSize.X;
        local arrowPosPixel = Vector2.new(arrowTable.ArrowInstance.Position.X.Scale, arrowTable.ArrowInstance.Position.Y.Scale) * 1000;
        local partPos = Vector2.new(pos.X, pos.Y);

        local IsInverted = pos.Z <= 0;
        local invert = (IsInverted and -1 or 1);

        local direction = (partPos - centerPos);
        local arctan = math.atan2(direction.Y, direction.X);
        local angle = math.deg(arctan) + 90;
        local distance = (arrowTable.Settings.CenterOffset * 0.001) * screenSize.Y;

        arrowTable.UpdateArrow(
            angle + 180 * (IsInverted and 0 or 1),
            UDim2.new(
                0, centerPos.X + (distance * math.cos(arctan) * invert),
                0, centerPos.Y + (distance * math.sin(arctan) * invert)
            )
        );
        arrowTable.ArrowInstance.Visible = (onScreen == false);

        arrowTable.Update({ Color = Library.Rainbow.Enabled and Library.Rainbow.Color or arrowTable.Settings.Color }, false);
    end;

    for uiName, uiTable in pairs(Library.ESP) do
        if typeof(uiTable) ~= "table" or uiName == "Tracers" or uiName == "Arrows" then continue; end

        for _, ui in pairs(uiTable) do
            if not checkUI(ui, uiName, ui.TableIndex) then continue; end

            local pos, onScreen, canContinue = checkVisibility(ui, ui.Settings.Model);
            if not canContinue then continue; end

            local isVisible = (Library[uiName] == nil and true or Library[uiName].Enabled);
            if isVisible == ui.Hidden then ui.Hidden = not isVisible; ui.SetVisible(isVisible); end
            if not isVisible then continue; end

            if uiName == "Billboards" then
                ui.SetDistanceText(ui.GetDistance());

                if ui.WasCreatedWithDifferentESP == true then
                    ui.Update({ Color = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.Color }, false);
                end
            elseif uiName == "Adornments" then
                ui.Update({
                    Color        = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.Color,
                    TextColor    = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.TextColor
                }, false);
            elseif uiName == "Highlights" then
                ui.Update({
                    FillColor    = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.FillColor,
                    OutlineColor = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.OutlineColor,
                    TextColor    = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.TextColor
                }, false);
            elseif uiName == "Outlines" then
                ui.Update({
                    SurfaceColor = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.SurfaceColor,
                    OutlineColor = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.OutlineColor,
                    TextColor    = Library.Rainbow.Enabled and Library.Rainbow.Color or ui.Settings.TextColor
                }, false);
            end;
        end
    end
end), "MainUpdate", true);

-- // Set Library and return it // --
global().mstudio45 = global().mstudio45 or { };
global().mstudio45.ESPLibrary = Library;
Library.Print("Loaded!");
return Library;
