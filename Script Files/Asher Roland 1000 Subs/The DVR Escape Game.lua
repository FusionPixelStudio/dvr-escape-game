-- Get API
local fu = fu or app:GetFusion()
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local flow = comp.CurrentFrame.FlowView

-- Create Variables
local MediaOut
local wallCoords = {}
local bedroomDooropen
local easterEggObtained
local objectObtained
local key
local officeDooropen
local clueObtained
local codeObtained
local doorOpen

------------------------------------------------------------------------------
-- parseFilename() from bmd.scriptlib | Also can be found in LoaderFromSaver Script by Alexey Bogomolov
--
-- this is a great function for ripping a filepath into little bits
-- returns a table with the following
--
-- FullPath	: The raw, original path sent to the function
-- Path		: The path, without filename
-- FullName	: The name of the clip w\ extension
-- Name     : The name without extension
-- CleanName: The name of the clip, without extension or sequence
-- SNum		: The original sequence string, or "" if no sequence
-- Number 	: The sequence as a numeric value, or nil if no sequence
-- Extension: The raw extension of the clip
-- Padding	: Amount of padding in the sequence, or nil if no sequence
-- UNC		: A true or false value indicating whether the path is a UNC path or not
------------------------------------------------------------------------------
function parseFilename(filename)
    local seq = {}
    seq.FullPath = filename
    string.gsub(seq.FullPath, "^(.+[/\\])(.+)", function(path, name)
        seq.Path = path
        seq.FullName = name
    end)
    string.gsub(seq.FullName, "^(.+)(%..+)$", function(name, ext)
        seq.Name = name
        seq.Extension = ext
    end)

    if not seq.Name then -- no extension?
        seq.Name = seq.FullName
    end

    string.gsub(seq.Name, "^(.-)(%d+)$", function(name, SNum)
        seq.CleanName = name
        seq.SNum = SNum
    end)

    if seq.SNum then
        seq.Number = tonumber(seq.SNum)
        seq.Padding = string.len(seq.SNum)
    else
        seq.SNum = ""
        seq.CleanName = seq.Name
    end

    if not seq.Extension then seq.Extension = "" end
    seq.UNC = (string.sub(seq.Path, 1, 2) == [[\\]])

    return seq
end

-- Get Assets
local currFolder = parseFilename(arg[0])
local tvCode = currFolder.Path .. "/assets/TV_CODE (Small).png"
local couchCode = currFolder.Path .. "/assets/COUCH_CODE (Small).png"
local drawerCode = currFolder.Path .. "/assets/DRAWER_CODE (Small).png"
local safeCode = currFolder.Path .. "/assets/SAFE_CODE (Small).png"

local amulet = currFolder.Path .. "/assets/Pendant Macro.setting"
local amuletData = bmd.readfile(amulet)

local function script_path()
    return arg[0]
end

local scriptFolder = app:MapPath("Scripts:")

local function ScriptIsInstalled()
    local script_path = script_path()
    if platform == "Mac" then
        scriptFolder = removeFirstTwoItemsFromPath(scriptFolder)
    end
    local match = script_path:find(scriptFolder)
    return match ~= nil
end

local SCRIPT_INSTALLED = ScriptIsInstalled()

local function copyFolderSameName(sourceFolder, targetParentFolder)
    -- Remove trailing slash/backslash from sourceFolder
    if sourceFolder:sub(-1) == "/" or sourceFolder:sub(-1) == "\\" then
        sourceFolder = sourceFolder:sub(1, -2)
    end

    -- Remove trailing slash/backslash from targetParentFolder
    if targetParentFolder:sub(-1) == "/" or targetParentFolder:sub(-1) == "\\" then
        targetParentFolder = targetParentFolder:sub(1, -2)
    end

    -- Determine the path separator based on OS
    -- Windows: "\"; macOS/Linux: "/"
    local pathSeparator = package.config:sub(1, 1)

    -- Extract the folder name from the source path
    local folderName = sourceFolder:match("[^/\\]+$")
    if not folderName then
        return false, "Could not determine source folder name."
    end

    -- Construct the final target path, preserving the folder name
    local targetFolder = targetParentFolder .. pathSeparator .. folderName

    -- Build the copy command depending on the OS
    local ret
    if pathSeparator == "\\" then
        -- Windows
        -- /E copies subdirectories (including empty ones)
        -- /I assumes destination is a directory
        -- /Y suppresses overwrite prompts
        local cmd = string.format('xcopy "%s" "%s" /E /I /Y', sourceFolder, targetFolder)
        ret = os.execute(cmd)
    else
        -- macOS/Linux
        local cmd = string.format('cp -R "%s" "%s"', sourceFolder, targetParentFolder)
        ret = os.execute(cmd)
    end

    -- os.execute() returns true or 0 on success (depending on Lua version/OS)
    if ret == true or ret == 0 then
        return true
    else
        return false, ("Failed to copy folder '%s' to '%s'"):format(sourceFolder, targetFolder)
    end
end

if not SCRIPT_INSTALLED then
    copyFolderSameName(currFolder.Path, scriptFolder .. 'Utility/')

    local installWindow = disp:AddWindow({
        ID = 'installWindow',
        WindowTitle = 'Script Installed',

        ui:VGroup {
            ID = 'root',
            FixedSize = { 400, 200 },
            ui:Label { ID = 'Label1', Text = 'The Script was Successfully Installed!\nPlease Reopen the Script from "Workflow/Scripts/Asher Roland 1000 Subs"', WordWrap = true, Alignment = { AlignCenter = true }, Weight = 1, StyleSheet = [[color: white; font-size: 20px; font-weight: 500; font-family: 'Arial';]] },
            ui:Button { ID = 'Butt1', Text = 'Okay!(Close)', Flat = false, Checkable = false, Weight = 0.15, StyleSheet = [[color: white; font-size: 20px; font-weight: 500; font-family: 'Arial';]] },
        }
    })

    function installWindow.On.installWindow.Close(ev)
        disp:ExitLoop()
    end

    function installWindow.On.Butt1.Clicked(ev)
        disp:ExitLoop()
    end

    installWindow:RecalcLayout()
    installWindow:Show()
    disp:RunLoop()
    installWindow:Hide()
    do return end
end

comp:StartUndo('RPG') -- Save Pre-Game Comp State

function round(num)
    if num % 1 >= 0.5 then
        return math.ceil(num)
    else
        return math.floor(num)
    end
end

math.randomseed(os.clock() * 100000)
local code1 = round(math.random(0, 9))
local code2 = round(math.random(0, 9))
local code3 = round(math.random(0, 9))
local code4 = round(math.random(0, 9))

-- Doors
local SetdoorCoords = { 0, 10 }
local SetSeconddoorCoords = { -4, 2 }
local SetThirddoorCoords = { -4, -2 }

-- Objects
local setDesk1Coords = { 7, -3 }
local setDesk2Coords = { -6, 9 }
local SetSafeCoords = { -6, -9 }
local SetFridgeCoords = { 1, -9 }
local SetCabinetCoords1 = { 0, -9 }
local SetCabinetCoords2 = { 0, -8 }
local SetCabinetCoords3 = { 0, -7 }
local SetCounterCoords1 = { 2, -9 }
local SetCounterCoords2 = { 3, -9 }
local SetCounterCoords3 = { 4, -9 }
local SetCouchCoords1 = { 4, 3 }
local SetCouchCoords2 = { 4, 4 }
local SetCouchCoords3 = { 4, 5 }
local SetTVCoords1 = { 7, 3 }
local SetTVCoords2 = { 7, 4 }
local SetTVCoords3 = { 7, 5 }

-- Decorations
local SetBedCoords1 = { -3, -9 }
local SetBedCoords2 = { -3, -8 }
local SetBedCoords3 = { -3, -7 }
local SetMeetingTableCoords1 = { -4, 5 }
local SetMeetingTableCoords2 = { -4, 6 }
local SetMeetingTableCoords3 = { -3, 5 }
local SetMeetingTableCoords4 = { -3, 6 }

-- Walls
local SetwallCoords = {
    Right = {
        { 8, 0 },
        { 8, -1 },
        { 8, -2 },
        { 8, -3 },
        { 8, -4 },
        { 8, -5 },
        { 8, -6 },
        { 8, -7 },
        { 8, -8 },
        { 8, -9 },
        { 8, -10 },
        { 8, 1 },
        { 8, 2 },
        { 8, 3 },
        { 8, 4 },
        { 8, 5 },
        { 8, 6 },
        { 8, 7 },
        { 8, 8 },
        { 8, 9 },
        { 8, 10 },
    },
    Top = {
        { 7,  -10 },
        { 6,  -10 },
        { 5,  -10 },
        { 4,  -10 },
        { 3,  -10 },
        { 2,  -10 },
        { 1,  -10 },
        { 0,  -10 },
        { -1, -10 },
        { -2, -10 },
        { -3, -10 },
        { -4, -10 },
        { -5, -10 },
        { -6, -10 },
        { -7, -10 },
    },
    Left = {
        { -7, 0 },
        { -7, -1 },
        { -7, -2 },
        { -7, -3 },
        { -7, -4 },
        { -7, -5 },
        { -7, -6 },
        { -7, -7 },
        { -7, -8 },
        { -7, -9 },
        { -7, -10 },
        { -7, 1 },
        { -7, 2 },
        { -7, 3 },
        { -7, 4 },
        { -7, 5 },
        { -7, 6 },
        { -7, 7 },
        { -7, 8 },
        { -7, 9 },
        { -7, 10 },
    },
    Bottom = {
        { 7,  10 },
        { 6,  10 },
        { 5,  10 },
        { 4,  10 },
        { 3,  10 },
        { 2,  10 },
        { 1,  10 },
        -- {0, 10},
        { -1, 10 },
        { -2, 10 },
        { -3, 10 },
        { -4, 10 },
        { -5, 10 },
        { -6, 10 },
        { -7, 10 },
    },
    Inner = {
        { -1, 9 },
        { -1, 8 },
        { -1, 7 },
        { -1, 6 },
        { -1, 5 },
        { -1, 4 },
        { -1, 3 },
        { -1, 2 },

        { -2, 2 },
        { -3, 2 },
        -- { -4, 2 },
        { -5, 2 },
        { -6, 2 },

        { -6, -2 },
        { -5, -2 },
        -- { -4, -2 },
        { -3, -2 },
        { -2, -2 },
        { -1, -2 },

        { -1, -3 },
        { -1, -4 },
        { -1, -5 },
        { -1, -6 },
        { -1, -7 },
        { -1, -8 },
        { -1, -9 },

        { 0,  -2 },
        { 1,  -2 },
        { 2,  -2 },
        -- { 3,  -2 },
        -- { 4,  -2 },
        { 5,  -2 },
        { 6,  -2 },
        { 7,  -2 },
    }
}

-- Move MediaOut and Delete All Other Nodes
local otherNodes = comp:GetToolList(false)
if #otherNodes > 0 then
    for _, node in ipairs(otherNodes) do
        if node.Name == "MediaOut1" then
            local out = node:FindMainOutput(1)
            if out then
                views = out:GetConnectedInputs()
            end
            for i, v in pairs(views) do
                local o = v:GetConnectedOutput()
                if not o then
                    ok = v:ViewOn()
                end
            end
            node:SetAttrs({ TOOLS_Name = "Inventory", TOOLB_Locked = false })
            flow:SetPos(node, 50, 0)
            MediaOut = node
        else
            node:Delete()
        end
    end
end

-- Create Walls
wallCoords = {}
for _, Sec in pairs(SetwallCoords) do
    for num, coords in ipairs(Sec) do
        local wall = comp:AddTool("Background")
        wall:SetAttrs({ TOOLS_Name = "Wall_" .. num, TOOLB_Locked = false })
        flow:SetPos(wall, coords[1], coords[2])
        local wallPos = flow:GetPosTable(wall)
        table.insert(wallCoords, wallPos)
    end
end

local doors = {}

-- Create Door 1
local Door = comp:AddTool("sRectangle")
Door:SetAttrs({ TOOLS_Name = "Exit_Door", TOOLB_Locked = true })
flow:SetPos(Door, SetdoorCoords[1], SetdoorCoords[2])
local door1Location = flow:GetPosTable(Door)
table.insert(doors, door1Location)
-- Create Door 2
local Door2 = comp:AddTool("sRectangle")
Door2:SetAttrs({ TOOLS_Name = "Office_Door", TOOLB_Locked = true })
flow:SetPos(Door2, SetSeconddoorCoords[1], SetSeconddoorCoords[2])
local door2Location = flow:GetPosTable(Door2)
table.insert(doors, door2Location)
-- Create Door 3
local Door3 = comp:AddTool("sRectangle")
Door3:SetAttrs({ TOOLS_Name = "Bedroom_Door", TOOLB_Locked = false })
flow:SetPos(Door3, SetThirddoorCoords[1], SetThirddoorCoords[2])
local door3Location = flow:GetPosTable(Door3)
table.insert(doors, door3Location)

-- Setup Inventory
local invLabel = comp:AddTool("TextPlus")
local invMrg = comp:AddTool("MultiMerge")
local invbg = comp:AddTool("Background")
if invLabel and invMrg and invbg then
    invLabel:SetAttrs({ TOOLS_Name = "invLabel", TOOLB_Locked = false })
    invMrg:SetAttrs({ TOOLS_Name = "invMrg", TOOLB_Locked = false })
    invbg:SetAttrs({ TOOLS_Name = "invBG", TOOLB_Locked = false })

    flow:SetPos(invbg, 48, 2)
    flow:SetPos(invLabel, 46, 0)
    flow:SetPos(invMrg, 48, 0)

    MediaOut:ConnectInput("Input", invMrg)
    invMrg:ConnectInput("Background", invbg)
    invMrg:ConnectInput("Layer1.Foreground", invLabel)

    invLabel.StyledText = "Inventory"
    invLabel.Enabled2 = 1
    invLabel.Enabled3 = 1
    bmd.wait(0.25)
    invLabel.ElementShape2 = 2
    invLabel.Level2 = 1
    invLabel.ExtendHorizontal2 = 2.5
    invLabel.ExtendVertical2 = 1.6
    invLabel.Round2 = 0.4
    invLabel.Red2 = 0
    invLabel.Green2 = 0
    invLabel.Blue2 = 0
    invLabel.Alpha2 = 0.8
    invLabel.Offset2 = { 0, -0.125 }

    invLabel.ElementShape3 = 3
    invLabel.Level3 = 1
    invLabel.ExtendHorizontal3 = 2.5
    invLabel.ExtendVertical3 = 1.6
    invLabel.Round3 = 0.4
    invLabel.Red3 = 1
    invLabel.Green3 = 1
    invLabel.Blue3 = 1
    invLabel.Alpha3 = 1
    invLabel.Offset3 = { 0, -0.125 }

    invbg.TopLeftAlpha = 0
end

local objects = {}

-- Create Key Location
local Key = comp:AddTool("Background")
Key:SetAttrs({ TOOLS_Name = "Table", TOOLB_Locked = false })
Key.TileColor = { 64, 34, 6 }
flow:SetPos(Key, setDesk1Coords[1], setDesk1Coords[2])
local keyLocation = flow:GetPosTable(Key)
table.insert(objects, keyLocation)

-- Create 3d Object Location
local Safe = comp:AddTool("Background")
Safe:SetAttrs({ TOOLS_Name = "Safe", TOOLB_Locked = false })
Safe.TileColor = { 194, 190, 186 }
flow:SetPos(Safe, SetSafeCoords[1], SetSafeCoords[2])
local SafeLocation = flow:GetPosTable(Safe)
table.insert(objects, SafeLocation)

-- Create Clue Location
local Clue = comp:AddTool("Background")
Clue:SetAttrs({ TOOLS_Name = "Desk", TOOLB_Locked = false })
Clue.TileColor = { 64, 34, 6 }
flow:SetPos(Clue, setDesk2Coords[1], setDesk2Coords[2])
local ClueLocation = flow:GetPosTable(Clue)
table.insert(objects, ClueLocation)

-- Create Egg Location
local Egg = comp:AddTool("Background")
Egg:SetAttrs({ TOOLS_Name = "Fridge", TOOLB_Locked = false })
Egg.TileColor = { 255, 255, 255 }
flow:SetPos(Egg, SetFridgeCoords[1], SetFridgeCoords[2])
local EggLocation = flow:GetPosTable(Egg)
table.insert(objects, EggLocation)

-- Create Cabinet Location
local Cabinet1 = comp:AddTool("Background")
Cabinet1:SetAttrs({ TOOLS_Name = "Cabinet_1", TOOLB_Locked = false })
Cabinet1.TileColor = { 255, 255, 255 }
flow:SetPos(Cabinet1, SetCabinetCoords1[1], SetCabinetCoords1[2])
local Cabinet1Location = flow:GetPosTable(Cabinet1)
table.insert(objects, Cabinet1Location)
local Cabinet2 = comp:AddTool("Background")
Cabinet2:SetAttrs({ TOOLS_Name = "Cabinet_2", TOOLB_Locked = false })
Cabinet2.TileColor = { 255, 255, 255 }
flow:SetPos(Cabinet2, SetCabinetCoords2[1], SetCabinetCoords2[2])
local Cabinet2Location = flow:GetPosTable(Cabinet2)
table.insert(objects, Cabinet2Location)
local Cabinet3 = comp:AddTool("Background")
Cabinet3:SetAttrs({ TOOLS_Name = "Cabinet_3", TOOLB_Locked = false })
Cabinet3.TileColor = { 255, 255, 255 }
flow:SetPos(Cabinet3, SetCabinetCoords3[1], SetCabinetCoords3[2])
local Cabinet3Location = flow:GetPosTable(Cabinet3)
table.insert(objects, Cabinet3Location)

-- Create Counter Location
local Counter1 = comp:AddTool("Background")
Counter1:SetAttrs({ TOOLS_Name = "Counter_1", TOOLB_Locked = false })
Counter1.TileColor = { 255, 255, 255 }
flow:SetPos(Counter1, SetCounterCoords1[1], SetCounterCoords1[2])
local Counter1Location = flow:GetPosTable(Counter1)
table.insert(objects, Counter1Location)
local Counter2 = comp:AddTool("Background")
Counter2:SetAttrs({ TOOLS_Name = "Counter_2", TOOLB_Locked = false })
Counter2.TileColor = { 255, 255, 255 }
flow:SetPos(Counter2, SetCounterCoords2[1], SetCounterCoords2[2])
local Counter2Location = flow:GetPosTable(Counter2)
table.insert(objects, Counter2Location)
local Counter3 = comp:AddTool("Background")
Counter3:SetAttrs({ TOOLS_Name = "Counter_3", TOOLB_Locked = false })
Counter3.TileColor = { 255, 255, 255 }
flow:SetPos(Counter3, SetCounterCoords3[1], SetCounterCoords3[2])
local Counter3Location = flow:GetPosTable(Counter3)
table.insert(objects, Counter3Location)

-- Create Couch Location
local Couch1 = comp:AddTool("Background")
Couch1:SetAttrs({ TOOLS_Name = "Couch_1", TOOLB_Locked = false })
Couch1.TileColor = { 255, 255, 255 }
flow:SetPos(Couch1, SetCouchCoords1[1], SetCouchCoords1[2])
local Couch1Location = flow:GetPosTable(Couch1)
table.insert(objects, Couch1Location)
local Couch2 = comp:AddTool("Background")
Couch2:SetAttrs({ TOOLS_Name = "Couch_2", TOOLB_Locked = false })
Couch2.TileColor = { 255, 255, 255 }
flow:SetPos(Couch2, SetCouchCoords2[1], SetCouchCoords2[2])
local Couch2Location = flow:GetPosTable(Couch2)
table.insert(objects, Couch2Location)
local Couch3 = comp:AddTool("Background")
Couch3:SetAttrs({ TOOLS_Name = "Couch_3", TOOLB_Locked = false })
Couch3.TileColor = { 255, 255, 255 }
flow:SetPos(Couch3, SetCouchCoords3[1], SetCouchCoords3[2])
local Couch3Location = flow:GetPosTable(Couch3)
table.insert(objects, Couch3Location)

-- Create TV Location
local TV1 = comp:AddTool("Background")
TV1:SetAttrs({ TOOLS_Name = "TV_1", TOOLB_Locked = false })
TV1.TileColor = { 255, 255, 255 }
flow:SetPos(TV1, SetTVCoords1[1], SetTVCoords1[2])
local TV1Location = flow:GetPosTable(TV1)
table.insert(objects, TV1Location)
local TV2 = comp:AddTool("Background")
TV2:SetAttrs({ TOOLS_Name = "TV_2", TOOLB_Locked = false })
TV2.TileColor = { 255, 255, 255 }
flow:SetPos(TV2, SetTVCoords2[1], SetTVCoords2[2])
local TV2Location = flow:GetPosTable(TV2)
table.insert(objects, TV2Location)
local TV3 = comp:AddTool("Background")
TV3:SetAttrs({ TOOLS_Name = "TV_3", TOOLB_Locked = false })
TV3.TileColor = { 255, 255, 255 }
flow:SetPos(TV3, SetTVCoords3[1], SetTVCoords3[2])
local TV3Location = flow:GetPosTable(TV3)
table.insert(objects, TV3Location)

-- Create Bed Location
local Bed1 = comp:AddTool("Background")
Bed1:SetAttrs({ TOOLS_Name = "Bed_1", TOOLB_Locked = false })
Bed1.TileColor = { 255, 255, 255 }
flow:SetPos(Bed1, SetBedCoords1[1], SetBedCoords1[2])
local Bed1Location = flow:GetPosTable(Bed1)
table.insert(objects, Bed1Location)
local Bed2 = comp:AddTool("Background")
Bed2:SetAttrs({ TOOLS_Name = "Bed_2", TOOLB_Locked = false })
Bed2.TileColor = { 255, 255, 255 }
flow:SetPos(Bed2, SetBedCoords2[1], SetBedCoords2[2])
local Bed2Location = flow:GetPosTable(Bed2)
table.insert(objects, Bed2Location)
local Bed3 = comp:AddTool("Background")
Bed3:SetAttrs({ TOOLS_Name = "Bed_3", TOOLB_Locked = false })
Bed3.TileColor = { 255, 255, 255 }
flow:SetPos(Bed3, SetBedCoords3[1], SetBedCoords3[2])
local Bed3Location = flow:GetPosTable(Bed3)
table.insert(objects, Bed3Location)

-- Create Office Table Location
local MTable1 = comp:AddTool("Background")
MTable1:SetAttrs({ TOOLS_Name = "Meeting_Table_1", TOOLB_Locked = false })
MTable1.TileColor = { 255, 255, 255 }
flow:SetPos(MTable1, SetMeetingTableCoords1[1], SetMeetingTableCoords1[2])
local MTable1Location = flow:GetPosTable(MTable1)
table.insert(objects, MTable1Location)
local MTable2 = comp:AddTool("Background")
MTable2:SetAttrs({ TOOLS_Name = "Meeting_Table_2", TOOLB_Locked = false })
MTable2.TileColor = { 255, 255, 255 }
flow:SetPos(MTable2, SetMeetingTableCoords2[1], SetMeetingTableCoords2[2])
local MTable2Location = flow:GetPosTable(MTable2)
table.insert(objects, MTable2Location)
local MTable3 = comp:AddTool("Background")
MTable3:SetAttrs({ TOOLS_Name = "Meeting_Table_3", TOOLB_Locked = false })
MTable3.TileColor = { 255, 255, 255 }
flow:SetPos(MTable3, SetMeetingTableCoords3[1], SetMeetingTableCoords3[2])
local MTable3Location = flow:GetPosTable(MTable3)
table.insert(objects, MTable3Location)
local MTable4 = comp:AddTool("Background")
MTable4:SetAttrs({ TOOLS_Name = "Meeting_Table_4", TOOLB_Locked = false })
MTable4.TileColor = { 255, 255, 255 }
flow:SetPos(MTable4, SetMeetingTableCoords4[1], SetMeetingTableCoords4[2])
local MTable4Location = flow:GetPosTable(MTable4)
table.insert(objects, MTable4Location)

-- Create Character
local Character = comp:AddTool("AlphaDivide")
if Character then
    Character:SetAttrs({ TOOLS_Name = "Character", TOOLB_Locked = false })
    flow:SetPos(Character, 0, 9)
    x, y = flow:GetPos(Character)
end

comp:SetActiveTool(Character)

local Buttons_CSS = [[
    QPushButton {
        color:rgb(255,255,255);
        padding:0px;
        margin:3px;
        border: 1px solid rgb(125,125,125);
        background-color: rgb(31,31,31);
    }
    QPushButton:hover {
        font-weight: bold;
        border: 1px solid rgb(31,31,31);
        background-color: rgb(125,125,125);
    }
    QPushButton:pressed
    {
        background-color: rgb(0,0,0);
    }
]]

local function textBox(size, dialog, fontsize, next, img, loop)
    if not next then
        next = "Next"
    end
    Dwin = disp:AddWindow({
        ID = 'RPG_Dialog',
        TargetID = 'RPG_Dialog',
        WindowTitle = 'Dialog',
        WindowFlags = {
            SplashScreen = true,
        },
        Spacing = 0,
        ui:VGroup {
            ID = 'root',
            Alignment = { AlignCenter = true },
            ui:Stack {
                ID = 'IMGs',
                Hidden = true,
                Weight = 0,
                Spacing = 0,
                ui:Button { ID = 'tvCode', Icon = ui:Icon({ File = tvCode }), IconSize = { size[1] / 1.15, size[2] / 1.15 }, Flat = true, Hidden = true, Weight = 0 },
                ui:Button { ID = 'couchCode', Icon = ui:Icon({ File = couchCode }), IconSize = { size[1] / 1.15, size[2] / 1.15 }, Flat = true, Hidden = true, Weight = 0 },
                ui:Button { ID = 'drawerCode', Icon = ui:Icon({ File = drawerCode }), IconSize = { size[1] / 1.15, size[2] / 1.15 }, Flat = true, Hidden = true, Weight = 0 },
                ui:Button { ID = 'safeCode', Icon = ui:Icon({ File = safeCode }), IconSize = { size[1] / 1.25, size[2] / 1.25 }, Flat = true, Hidden = true, Weight = 0 },
                ui:Group {
                    ID = 'Codes',
                    ui:Label { Weight = 0, ID = 'Code', Geometry = { 30, 30, 100, 100 }, Text = dialog, Hidden = true, StyleSheet = [[color: white; font-size:]] .. fontsize },
                }
            },
            ui:HGroup {
                ui:TextEdit { ID = 'dialog', Text = dialog, WordWrap = true, FrameStyle = 0, ReadOnly = true, Weight = 0.75, StyleSheet = [[font-size:]] .. fontsize },
                ui:VGroup {
                    Weight = 0.25,
                    ui:Label { Weight = 0.85, FrameStyle = 0, ID = 'Gap' },
                    ui:Button { ID = 'Music', Text = "Play BG Music", Weight = 0.15, Hidden = true, StyleSheet = Buttons_CSS },
                    ui:Button { ID = 'Next', Text = next, Weight = 0.15, StyleSheet = Buttons_CSS }
                },
            }
        },
        ui:Label { ID = "SplashBorder", StyleSheet = "border: 1px solid white;" },
    })

    if img == 'tvCode' then
        Dwin:GetItems().tvCode.Hidden = false
        Dwin:GetItems().Code.Geometry = { 280, 220, 30, 30 }
    elseif img == 'couchCode' then
        Dwin:GetItems().couchCode.Hidden = false
        Dwin:GetItems().Code.Geometry = { 120, 175, 30, 30 }
    elseif img == 'drawerCode' then
        Dwin:GetItems().drawerCode.Hidden = false
        Dwin:GetItems().Code.Geometry = { 300, 220, 30, 30 }
    elseif img == 'safeCode' then
        Dwin:GetItems().safeCode.Hidden = false
        Dwin:GetItems().Code.Geometry = { 480, 275, 30, 30 }
    end

    if img then
        Dwin:GetItems().dialog.Hidden = true
        Dwin:GetItems().Code.Hidden = false
        Dwin:GetItems().IMGs.Hidden = false
    end

    if loop then
        Dwin:GetItems().Music.Hidden = false
    end

    Dwin:RecalcLayout()

    Dwin:GetItems().RPG_Dialog:Resize(size)
    Dwin:GetItems().SplashBorder:Resize(size)
    Dwin:GetItems().SplashBorder:Lower()

    function Dwin.On.Next.Clicked(ev)
        if loop then
            disp:ExitLoop()
        else
            Dwin:Hide()
        end
    end

    function Dwin.On.Music.Clicked(ev)
        bmd.openurl("https://www.youtube.com/watch?v=Ba2q8bDTRTU")
    end

    Dwin:Show()
    if loop then
        disp:RunLoop()
        Dwin:Hide()
    end
    return Dwin
end

win = disp:AddWindow({
    ID = 'RPG_Controls',
    TargetID = 'RPG_Controls',
    WindowTitle = 'Controller',
    Geometry = { 50, 750, 250, 300 },
    WindowFlags = {
        SplashScreen = true,
    },
    Margin = 0,
    Spacing = 0,
    ui:VGroup {
        ID = 'root',
        ui:VGroup {
            Alignment = { AlignCenter = true },
            ui:Button { ID = "UP", Text = "UP", StyleSheet = Buttons_CSS },
            ui:HGroup {
                ui:Button { ID = "LEFT", Text = "LEFT", StyleSheet = Buttons_CSS },
                ui:Button { ID = "RIGHT", Text = "RIGHT", StyleSheet = Buttons_CSS },
            },
            ui:Button { ID = "DOWN", Text = "DOWN", StyleSheet = Buttons_CSS },
        },
        ui:VGroup {
            Alignment = { AlignCenter = true },
            ui:Button { ID = "Check", Text = "Interact", StyleSheet = Buttons_CSS },
            ui:VGap(1),
            ui:Button { ID = "Exit", Text = "Exit Game", StyleSheet = Buttons_CSS }
        },
        ui:Label { Text = "Click Here to use Keyboard Controls\n(if not working)", Weight = 1, Alignment = { AlignCenter = true }, StyleSheet = [[font-size: 20px]], WordWrap = true },
    },
    ui:Label { ID = "SplashBorder", StyleSheet = "border: 2px solid yellow; box-shadow: 0px 0px 3px black" },
})

win:GetItems().SplashBorder:Resize({ 250, 300 })
win:GetItems().SplashBorder:Lower()

local function isAdjacent(x, y, targetX, targetY)
    return (x == targetX and (y - 1 == targetY or y + 1 == targetY)) or
        (y == targetY and (x - 1 == targetX or x + 1 == targetX))
end

local function easterEgg()
    easterEggObtained = true
    textBox({ 500, 400 }, "Easter Egg!", '30px')
end

local eggCounter = 0
local function easterEggCount()
    eggCounter = eggCounter + 1
    if eggCounter == 5 then
        easterEgg()
        eggCounter = 0
    else
        textBox({ 500, 400 }, "There's lots of fake food...", '30px')
    end
end

local function obtainNecklace()
    objectObtained = true
    -- comp:SetActiveTool(MediaOut)
    comp:SetActiveTool(nil)
    comp:Paste(amuletData)
    local amulet = comp["PendantMacro"]
    flow:SetPos(amulet, 46, -2)
    MediaOut:ConnectInput("Input", amulet)
    comp:SetActiveTool(amulet)
    textBox({ 500, 400 },
        "You found an amulet!\nI wonder what you can do with this...\n(Use the inspector to move the amulet around)",
        '30px')
end

local function keyAlreadyObtained()
    textBox({ 500, 400 }, "There's Nothing Else Here...", '30px')
end

local function authTableCode()
    size = { 400, 600 }
    PadLock = disp:AddWindow({
        ID = 'RPG_padlock',
        TargetID = 'RPG_padlock',
        WindowTitle = 'Padlock',
        WindowFlags = {
            SplashScreen = true,
        },
        Spacing = 0,
        ui:VGroup {
            ID = 'root',
            ui:Label { Text = 'Input Code', Weight = 0.2, Alignment = { AlignCenter = true }, StyleSheet = [[text-align: center; font-size:40px;]] },
            ui:HGroup {
                Weight = 0.16666,
                ui:LineEdit { ID = 'codePreview', ReadOnly = true, Alignment = { AlignCenter = true }, Weight = 1, StyleSheet = [[text-align: center; font-size:40px;]] },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Butt1', Text = '1', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt2', Text = '2', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt3', Text = '3', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Butt4', Text = '4', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt5', Text = '5', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt6', Text = '6', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Butt7', Text = '7', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt8', Text = '8', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt9', Text = '9', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Label { FrameStyle = 0, Weight = 0.333 },
                ui:Button { ID = 'Butt0', Text = '0', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Label { FrameStyle = 0, Weight = 0.333 },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Cancel', Text = 'Cancel', Flat = false, Checkable = false, Weight = 0.5, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Enter', Text = 'Check', Flat = false, Checkable = false, Weight = 0.5, StyleSheet = Buttons_CSS },
            },
        },
        ui:Label { ID = "SplashBorder", StyleSheet = "border: 1px solid white;" },
    })

    PadLock:GetItems().RPG_padlock:Resize(size)
    PadLock:GetItems().SplashBorder:Resize(size)
    PadLock:GetItems().SplashBorder:Lower()

    PadLock:RecalcLayout()

    local correctCode = "7211"

    function PadLock.On.Butt1.Clicked()
        local num = '1'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt2.Clicked()
        local num = '2'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt3.Clicked()
        local num = '3'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt4.Clicked()
        local num = '4'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt5.Clicked()
        local num = '5'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt6.Clicked()
        local num = '6'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt7.Clicked()
        local num = '7'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt8.Clicked()
        local num = '8'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt9.Clicked()
        local num = '9'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt0.Clicked()
        local num = '0'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    local canceled
    function PadLock.On.Enter.Clicked(ev)
        local code = tonumber(PadLock:GetItems().codePreview.Text)
        if code == tonumber(correctCode) then
            canceled = false
            disp:ExitLoop()
        end
        PadLock:GetItems().codePreview.Text = ''
    end

    function PadLock.On.Cancel.Clicked(ev)
        canceled = true
        disp:ExitLoop()
    end

    PadLock:Show()
    disp:RunLoop()
    PadLock:Hide()
    if canceled then
        return true
    else
        return false
    end
end

local function obtainKey()
    if key then
        keyAlreadyObtained()
        return
    end
    local canceled = authTableCode()
    if canceled then
        return
    end
    key = true

    local amulet = comp["PendantMacro"]
    amulet:Delete()

    KeyitmBase = comp:AddTool("sRectangle")
    KeyitmNotch = comp:AddTool("sRectangle")
    KeyitmTooth1 = comp:AddTool("sRectangle")
    KeyitmTooth2 = comp:AddTool("sDuplicate")
    KeyitmMerge1 = comp:AddTool("sMerge")
    KeyitmMerge2 = comp:AddTool("sMerge")
    KeyitmRender = comp:AddTool("sRender")

    KeyitmBase:SetAttrs({ TOOLS_Name = "Key_Base", TOOLB_Locked = false })
    KeyitmNotch:SetAttrs({ TOOLS_Name = "Key_Notch", TOOLB_Locked = false })
    KeyitmTooth1:SetAttrs({ TOOLS_Name = "Key_Tooth1", TOOLB_Locked = false })
    KeyitmTooth2:SetAttrs({ TOOLS_Name = "Key_Tooth2", TOOLB_Locked = false })

    flow:SetPos(KeyitmBase, 46, -4)
    flow:SetPos(KeyitmNotch, 46, -3)
    flow:SetPos(KeyitmTooth1, 46, -2)
    flow:SetPos(KeyitmTooth2, 46, -1)

    flow:SetPos(KeyitmMerge1, 47, -2)
    flow:SetPos(KeyitmMerge2, 47, -3)
    flow:SetPos(KeyitmRender, 47, -1)

    KeyitmBase.Translate.Y = -0.18
    KeyitmBase.Width = 0.39
    KeyitmBase.Height = 0.044

    KeyitmTooth1.Translate.Y = -0.18 / 1.25
    KeyitmTooth1.Translate.X = 0.175
    KeyitmTooth1.Width = 0.035
    KeyitmTooth1.Height = 0.07

    KeyitmNotch.Translate.Y = -0.18 / 1.2
    KeyitmNotch.Translate.X = 0.09
    KeyitmNotch.Width = 0.2
    KeyitmNotch.Height = 0.035

    KeyitmTooth2.Copies = 2
    KeyitmTooth2.XOffset = -0.088

    invMrg:ConnectInput("Layer2.Foreground", KeyitmRender)
    KeyitmRender:ConnectInput("Input", KeyitmMerge1)
    KeyitmMerge1:ConnectInput("Input1", KeyitmMerge2)
    KeyitmMerge2:ConnectInput("Input1", KeyitmBase)
    KeyitmMerge2:ConnectInput("Input2", KeyitmNotch)
    KeyitmMerge1:ConnectInput("Input2", KeyitmTooth2)
    KeyitmTooth2:ConnectInput("Input", KeyitmTooth1)
    MediaOut:ConnectInput("Input", invMrg)

    comp:SetActiveTool(Character)
    textBox({ 500, 400 }, "You Found a key in the lockbox!", '30px')
end

local function obtainClue()
    clueObtained = true
    textBox({ 500, 400 },
        "To leave this place, you need 4 numbers.\nOne is Familiar\nTwo are Entertained\n& One is Hungry\n\nOrder Matters Not. Find Them.",
        '30px')
end

local function obtainNum1(location)
    code_1 = true
    textBox({ 700, 700 }, tostring(code1), '30px', nil, location)
    -- Display Code via image
end

local function obtainNum2(location)
    code_2 = true
    textBox({ 700, 700 }, tostring(code2), '30px', nil, location)
    -- Display Code via image
end

local function obtainNum3(location)
    code_3 = true
    textBox({ 700, 700 }, tostring(code3), '30px', nil, location)
    -- Display Code via image
end

local function obtainNum4(location)
    code_4 = true
    textBox({ 700, 700 }, tostring(code4), '30px', nil, location)
    -- Display Code via image
end

local function obtainedAllCodes()
    textBox({ 500, 400 },
        "You already have all the codes.\n" .. code1 .. code2 .. code3 .. code4 .. "\nWhere do they go?",
        '30px')
end

local codeCount = 0
local function obtainCodeCount(location)
    if clueObtained then
        codeCount = codeCount + 1
        if codeCount == 1 then
            obtainNum1(location)
        elseif codeCount == 2 then
            obtainNum2(location)
        elseif codeCount == 3 then
            obtainNum3(location)
        elseif codeCount == 4 then
            obtainNum4(location)
            codeObtained = true
        else
            obtainedAllCodes()
        end
    end
end

local function openBedDoor()
    if bedroomDooropen then
        return
    end
    flow:SetPos(Door3, SetThirddoorCoords[1], SetThirddoorCoords[2] - 1)
    bmd.wait(0.25)
    flow:SetPos(Door3, SetThirddoorCoords[1] - 1, SetThirddoorCoords[2] - 1)
    bedroomDooropen = true
end

local function openOfficeDoor()
    if officeDooropen then
        return
    end
    if key then
        KeyitmRender:Delete()
        Door2:SetAttrs({ TOOLB_Locked = false })
        bmd.wait(0.25)
        flow:SetPos(Door2, SetSeconddoorCoords[1], SetSeconddoorCoords[2] + 1)
        bmd.wait(0.25)
        flow:SetPos(Door2, SetSeconddoorCoords[1] - 1, SetSeconddoorCoords[2] + 1)
        officeDooropen = true
        textBox({ 500, 400 }, "You used the key to unlock the door!", '30px')
    else
        textBox({ 500, 400 }, "It Seems Like This Door Needs a Key!", '30px')
    end
end

local function authExitCode()
    size = { 400, 600 }
    PadLock = disp:AddWindow({
        ID = 'RPG_padlock',
        TargetID = 'RPG_padlock',
        WindowTitle = 'Padlock',
        WindowFlags = {
            SplashScreen = true,
        },
        Spacing = 0,
        ui:VGroup {
            ID = 'root',
            ui:Label { Text = 'Input Code', Weight = 0.2, Alignment = { AlignCenter = true }, StyleSheet = [[text-align: center; font-size:40px;]] },
            ui:HGroup {
                Weight = 0.16666,
                ui:LineEdit { ID = 'codePreview', ReadOnly = true, Alignment = { AlignCenter = true }, Weight = 1, StyleSheet = [[text-align: center; font-size:40px;]] },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Butt1', Text = '1', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt2', Text = '2', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt3', Text = '3', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Butt4', Text = '4', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt5', Text = '5', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt6', Text = '6', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Butt7', Text = '7', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt8', Text = '8', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Butt9', Text = '9', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Label { FrameStyle = 0, Weight = 0.333 },
                ui:Button { ID = 'Butt0', Text = '0', Flat = false, Checkable = false, Weight = 0.333, StyleSheet = Buttons_CSS },
                ui:Label { FrameStyle = 0, Weight = 0.333 },
            },
            ui:HGroup {
                Weight = 0.16666,
                ui:Button { ID = 'Cancel', Text = 'Cancel', Flat = false, Checkable = false, Weight = 0.5, StyleSheet = Buttons_CSS },
                ui:Button { ID = 'Enter', Text = 'Check', Flat = false, Checkable = false, Weight = 0.5, StyleSheet = Buttons_CSS },
            },
        },
        ui:Label { ID = "SplashBorder", StyleSheet = "border: 1px solid white;" },
    })

    PadLock:GetItems().RPG_padlock:Resize(size)
    PadLock:GetItems().SplashBorder:Resize(size)
    PadLock:GetItems().SplashBorder:Lower()

    PadLock:RecalcLayout()

    local correctCode = tostring(code1) .. tostring(code2) .. tostring(code3) .. tostring(code4)

    function PadLock.On.Butt1.Clicked()
        local num = '1'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt2.Clicked()
        local num = '2'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt3.Clicked()
        local num = '3'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt4.Clicked()
        local num = '4'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt5.Clicked()
        local num = '5'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt6.Clicked()
        local num = '6'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt7.Clicked()
        local num = '7'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt8.Clicked()
        local num = '8'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt9.Clicked()
        local num = '9'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    function PadLock.On.Butt0.Clicked()
        local num = '0'
        PadLock:GetItems().codePreview.Text = PadLock:GetItems().codePreview.Text .. num
    end

    local canceled
    function PadLock.On.Enter.Clicked(ev)
        local code = tonumber(PadLock:GetItems().codePreview.Text)
        if code == tonumber(correctCode) then
            canceled = false
            disp:ExitLoop()
        end
        PadLock:GetItems().codePreview.Text = ''
    end

    function PadLock.On.Cancel.Clicked(ev)
        canceled = true
        disp:ExitLoop()
    end

    PadLock:Show()
    disp:RunLoop()
    PadLock:Hide()
    if canceled == true then
        return true
    else
        return false
    end
end

local function interactWithDoor()
    if doorOpen then
        return
    end
    if codeObtained then
        local canceled = authExitCode()
        if canceled then
            return
        end
        Door:SetAttrs({ TOOLB_Locked = false })
        bmd.wait(0.25)
        flow:SetPos(Door, SetdoorCoords[1], SetdoorCoords[2] + 1)
        bmd.wait(0.25)
        flow:SetPos(Door, SetdoorCoords[1] - 1, SetdoorCoords[2] + 1)
        doorOpen = true
    else
        textBox({ 500, 400 }, "It Seems Like This Door Needs a Code!", '30px')
    end
end

local function emptyInteraction()
    textBox({ 500, 400 }, "There's nothing here...", '30px')
end

local function soonInteraction()
    textBox({ 500, 400 }, "There's nothing here you need yet", '30px')
end

function win.On.Check.Clicked(ev)
    local x, y = flow:GetPos(Character)

    if isAdjacent(x, y, door3Location[1], door3Location[2]) then
        openBedDoor()
    elseif not objectObtained and isAdjacent(x, y, SafeLocation[1], SafeLocation[2]) then
        obtainNecklace()
    elseif isAdjacent(x, y, keyLocation[1], keyLocation[2]) then
        if objectObtained then
            obtainKey()
        else
            textBox({ 500, 400 }, "There's a lockbox... it needs a code.", '30px')
        end
    elseif isAdjacent(x, y, door2Location[1], door2Location[2]) then
        openOfficeDoor()
    elseif isAdjacent(x, y, ClueLocation[1], ClueLocation[2]) then
        obtainClue()
    elseif (objectObtained and isAdjacent(x, y, SafeLocation[1], SafeLocation[2])) then
        if clueObtained then
            obtainCodeCount('safeCode')
        else
            soonInteraction()
        end
    elseif isAdjacent(x, y, TV1Location[1], TV1Location[2])
        or isAdjacent(x, y, TV2Location[1], TV2Location[2])
        or isAdjacent(x, y, TV3Location[1], TV3Location[2]) then
        if clueObtained then
            obtainCodeCount('tvCode')
        else
            soonInteraction()
        end
    elseif isAdjacent(x, y, Couch1Location[1], Couch1Location[2])
        or isAdjacent(x, y, Couch2Location[1], Couch2Location[2])
        or isAdjacent(x, y, Couch3Location[1], Couch3Location[2]) then
        if clueObtained then
            obtainCodeCount('couchCode')
        else
            soonInteraction()
        end
    elseif isAdjacent(x, y, Counter1Location[1], Counter1Location[2])
        or isAdjacent(x, y, Counter2Location[1], Counter2Location[2])
        or isAdjacent(x, y, Counter3Location[1], Counter3Location[2]) then
        if clueObtained then
            obtainCodeCount('drawerCode')
        else
            soonInteraction()
        end
    elseif isAdjacent(x, y, EggLocation[1], EggLocation[2]) then
        easterEggCount()
    elseif isAdjacent(x, y, door1Location[1], door1Location[2]) then
        interactWithDoor()
    else
        for _, object in ipairs(objects) do
            if isAdjacent(x, y, object[1], object[2]) then
                emptyInteraction()
            end
        end
    end
end

local function isBlocked(x, y)
    x = round(x)
    y = round(y)

    for _, wall in ipairs(wallCoords) do
        if x == round(wall[1]) and y == round(wall[2]) then
            return true
        end
    end

    for _, object in ipairs(objects) do
        if x == round(object[1]) and y == round(object[2]) then
            return true
        end
    end

    for _, _ in ipairs(doors) do
        if not doorOpen and x == round(door1Location[1]) and y == round(door1Location[2]) then
            return true
        end
        if not bedroomDooropen and x == round(door3Location[1]) and y == round(door3Location[2]) then
            return true
        end
        if not officeDooropen and x == round(door2Location[1]) and y == round(door2Location[2]) then
            return true
        end
    end

    return false
end

local function moveCharacter(deltaX, deltaY)
    local x, y = flow:GetPos(Character)
    local newX, newY = x + deltaX, y + deltaY

    if not isBlocked(newX, newY) then
        flow:SetPos(Character, newX, newY)
    end
    if round(newY) > 10 then
        print('Game Won!')
        local foundText = easterEggObtained and "Found 1/1 Secrets" or "Found 0/1 Secrets"

        local countdownTimer = ui:Timer {
            ID = "CountdownTimer",
            Interval = 1000,
            SingleShot = false
        }

        local step = 5
        local tbox

        local function showNextMessage()
            if tbox then
                tbox:Hide()
            end

            if step == 0 then
                countdownTimer:Stop()
                disp:ExitLoop("main")
                return
            end

            local sizes = {
                [5] = { 500, 400, "30px" },
                [4] = { 400, 225, "25px" },
                [3] = { 300, 185, "15px" },
                [2] = { 250, 125, "10px" },
                [1] = { 150, 85, "5px" },
            }
            local w, h, fontSize = table.unpack(sizes[step])

            local msg = ("You Escaped!\n%s\n\n%d"):format(foundText, step)
            tbox = textBox({ w, h }, msg, fontSize, '', nil, false)

            step = step - 1
        end

        function disp.On.Timeout(ev)
            if ev.who == countdownTimer.ID then
                showNextMessage()
            end
        end

        countdownTimer:Start()
        showNextMessage()
    end
end

-- Event handlers for movement
function win.On.UP.Clicked(ev)
    moveCharacter(0, -1)
end

function win.On.DOWN.Clicked(ev)
    moveCharacter(0, 1)
end

function win.On.LEFT.Clicked(ev)
    moveCharacter(-1, 0)
end

function win.On.RIGHT.Clicked(ev)
    moveCharacter(1, 0)
end

function win.On.Exit.Clicked(ev)
    disp:ExitLoop('main')
end

-- Create Hotkeys
app:AddConfig("RPG_Controls", {
    Target {
        ID = "RPG_Controls",
    },

    Hotkeys {
        Target = "RPG_Controls",
        Defaults = true,

        ESCAPE = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {}) ]] }',

        W = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().UP, 'Clicked', {}) ]] }",
        UP = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().UP, 'Clicked', {}) ]] }",
        S = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().DOWN, 'Clicked', {}) ]] }",
        DOWN = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().DOWN, 'Clicked', {}) ]] }",
        A = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().LEFT, 'Clicked', {}) ]] }",
        LEFT = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().LEFT, 'Clicked', {}) ]] }",
        D = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().RIGHT, 'Clicked', {}) ]] }",
        RIGHT = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().RIGHT, 'Clicked', {}) ]] }",
        RETURN = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().Check, 'Clicked', {}) ]] }",
        E = "Execute{ cmd = [[app.UIManager:QueueEvent(obj:GetItems().Check, 'Clicked', {}) ]] }",
    },
})

-- windowlist = comp:GetFrameList()
-- for i, window in pairs(windowlist) do
--     window:ViewOn(MediaOut, 2)
-- end

win:RecalcLayout()
win:Show()

textBox(
    { 500, 400 },
    "How to Play\nWasd/Arrow Keys - Move\nE/Enter - Interact\nEsc - Quit Game\n\nAfter Clicking Next on Message Boxes, Click back on Controls to re-enable Hotkeys",
    "30px", nil, nil, true
)

local step = 1

local checkTimer = ui:Timer {
    ID = "CheckTimer",
    Interval = 100,    -- checks 10x per second
    SingleShot = false -- keeps firing until we manually stop
}

checkTimer:Start()

Dwin = nil
function disp.On.Timeout(ev)
    if ev.who == checkTimer.ID then
        if step == 1 then
            if not Dwin then
                Dwin = textBox(
                    { 500, 400 },
                    "Your Goal is to Escape the Building! Find all the clues and make your way through puzzles to get the escape code!",
                    "30px", nil, nil, true
                )
                checkTimer:Stop()
                step = 2
            end
            -- elseif step == 2 then
            --     bmd.openurl("https://www.youtube.com/watch?v=Ba2q8bDTRTU")
            --     checkTimer:Stop()
            --     step = 3
        end
    end
end

disp:RunLoop('main')
win:Hide()

comp:EndUndo(true)
comp:Undo()

app:RemoveConfig('RPG_Controls')
collectgarbage()
