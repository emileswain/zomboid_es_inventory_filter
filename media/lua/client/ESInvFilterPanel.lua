require "ESInvFilterBtnExt"
require "ISUI/ISPanel"
require "ISUI/ISInventoryPane"
require "ISUI/ISInventoryPage"

-- Reference material
-- https://github.com/blind-coder/pz-bcUtils/blob/master/media/lua/client/bcUtils_genericTA.lua
-- https://github.com/MrBounty/PZ-Mod---Doc/blob/main/Useful%20links.md
-- https://www.lua.org/pil/contents.html
-- https://github.com/MrBounty/PZ-UI_API/blob/main/UI%20API/media/lua/client/ISUI/ISSimpleButton.lua

ESInvFilterPanel = ISPanel:derive("ESInvFilterPanel");

-- TODO refactor to not be rubbish
ESInvFilterPanel.FLAGS = {X = "X", F = "F", C = "C", W = "W", L = "L"}

-- **************************************************************************
-- Manages a row of toggleable buttons (@see QuickFilterBtnExt.lua) that when
-- pressed update the self.filterFlags state.
-- TODO refactor to just be UIRow and decouple filter logic. Or use native UI
-- elements if you can find them.
-- **************************************************************************
function ESInvFilterPanel:new(onClickTarget, onClicked)
    print("new ESInvFilterPanel()")
    local o = {}
    o = ISPanel:new(0, 0, 100, 100)
    setmetatable(o, self)
    self.__index = self
    o.viewVisible = false
    o.btns = {}
    o.filterFlags = {}
    o.isGlobal= false -- ESInvFilterPanel is typically attached to inventory Pane, isGlobal is used for displaying detached.
    o.onClicked = onClicked or nil
    o.onClickTarget = onClickTarget or nil
    return o;
end

function ESInvFilterPanel:show()
    if self.viewVisible == true then
         return;
    end
    self.viewVisible = true
    self:setVisible(true)
    if self.isGloabl then 
        self:addToUIManager()
    end
end

function ESInvFilterPanel:hide()
    if self.viewVisible == false then
       return;
    end
    self.viewVisible = false
    self:setVisible(false)
    if self.isGloabl then 
        self:removeFromUIManager()
    end
end

function ESInvFilterPanel:toggleVisibility()

    if  self.viewVisible then
        self:hide()
    else
        self:show()
    end
end

function ESInvFilterPanel:initialise()
    ISPanel.initialise(self);
end

function ESInvFilterPanel:makeButton(label)
    local btn = ISButton:new(0, 0, 20, 20, label, self, self.onToggle)
    btn:initialise()
    btn:enableToggle( true, false)
    btn:setOnClick(self.onToggle, label)

    self.filterFlags[label] = false

    return btn
end

-- TODO decouple filter logic for essentially what is a row of independent buttons.
function ESInvFilterPanel:onToggle(button, who)
    -- print(' button Press ' .. who .. " checked: " .. button.isChecked)
    -- getPlayer():Say('ESInvFilterPanel() filter by : ' ..who .. " state : " .. tostring(button.isChecked))
    -- print('ESInvFilterPanel() filter by : ' ..who .. " state : " .. tostring(button.isChecked))
    if who == ESInvFilterPanel.FLAGS.X then 
        -- reset the other buttons.
        local btns = self.children;
        for k, v in pairs(btns) do
            -- print("reseting buttons ".. v.title)
            if v.title ~= ESInvFilterPanel.FLAGS.X then
                v.isChecked = false
                v:update()
                self.filterFlags[v.title] = false
            end
        end
    else
        self.filterFlags[button.title] = button.isChecked
        -- print("ESInvFilterPanel:onToggle() btn: ".. button.title .. " set to: ".. tostring(self.filterFlags[button.title]))
    end

    if self.onClicked ~= nil then
        self.onClicked(self.onClickTarget)
    end
end

-- **************************************************************************
-- TODO refactor v==X condition. it shouldn't care.
-- **************************************************************************
function ESInvFilterPanel:createChildren() -- Use to make the elements
    ISPanel.createChildren(self);

    -- Loop through defined flag table and add btns to match.
    for k, v in pairs(ESInvFilterPanel.FLAGS) do
        local btn = self:makeButton(v)
        self:addChild(btn)
        if(v == "X") then
            btn:enableToggle(false, false)
        end
    end    
end

-- **************************************************************************
-- Lays out buttons in a row.
-- **************************************************************************
function ESInvFilterPanel:prerender()
    ISPanel.prerender(self);
    
    -- if global insance, then position in center of screen.
    if self.isGlobal then
        local sW = getCore():getScreenWidth() -- Get the screen resolution
        local sH = getCore():getScreenHeight() -- Get the screen resolution
        self:setX(sW/2 - self.width /2)
        self:setY(sH/2 - self.height /2)
    end

    -- Aligne all the buttons from left to right with spacing.
    local btns = self.children;
    local cX = 0; cY = 0; spacing = 3
    for k, v in pairs(btns) do
       v:setX(cX)
       v:setY(3)
        cX = v.x + v.width + spacing
    end

    self:setWidth(cX)
    self:setHeight(6 + 20)

end

-- function ESInvFilterPanel:render() -- Use to render text and other
-- end

-- **************************************************************************
-- Display an instance of the Button row independently from the InventoryPane
-- mainly for testing. 
-- TODO disable.
-- **************************************************************************
function onCustomUIKeyPressed(key)
    if key == 20 then --Q or T
        getPlayer():Say('display Inventory Filter')
        if ZZTopToggleContainer == nil then
            ZZTopToggleContainer = ESInvFilterPanel:new()
            ZZTopToggleContainer.isGlobal = true
            ZZTopToggleContainer:initialise()
            ZZTopToggleContainer:show()
        else
            ZZTopToggleContainer:toggleVisibility()
        end
    end
end
Events.OnCustomUIKeyPressed.Add(onCustomUIKeyPressed)




