require('ISUI/ISInventoryPage')
require('ISUI/ISInventoryPane')
require('ESInvFilterPanel')

-- **************************************************************************
-- Dev Resources
-- Used https://undeniable.info/pz/wiki/itemlist.php?pn=2 for finding types
-- https://github.com/MrBounty/PZ-Mod---Doc/blob/main/Items%20variables.md more types
-- **************************************************************************

-- **************************************************************************
-- ## ESInvFilters
-- Filter methods, Seperated to support overriding by other mods.
-- TODO when refactoring ESInvFilterPanel, also refactor this mess.
-- **************************************************************************
if not ESInvFilters then ESInvFilters = {} end

-- listItem is ISInventoryPage.itemslist[n]
-- item is ISInventoryPage.itemslist[n].items[1]
-- I pass both in case listItem has some data you want for filtering on.
ESInvFilters.checkIsWeapon = function(listItem, item)
    return instanceof(item, "Weapon") or instanceof(item, "WeaponPart")
end

ESInvFilters.checkIsClothing = function(listItem, item)
    return instanceof(item, "Clothing")
end

ESInvFilters.checkIsFood = function(listItem, item)
    return instanceof(item, "Food")
end

ESInvFilters.checkIsLiterature = function(listItem, item)
    return instanceof(item, "Literature")
end

--  TODO remove/tidy up when done.
-- -- if self.filterPanel ~= nil then
--     if instanceof(item, "Normal") then 
--         add = false
--     elseif instanceof(item, "Key") then 
--         add = false
--     elseif instanceof(item, "Map") then 
--         add = false
--     elseif instanceof(item, "Map") then 
--         add = false
--     elseif instanceof(item, "Moveable") then 
--         add = false
--     elseif instanceof(item, "Radio") then 
--         add = false
--     -- 
--     elseif instanceof(item, "Food") then 
--         add = false
--     elseif instanceof(item, "Clothing") then 
--         add = false
--     elseif instanceof(item, "Container") or instanceof(item, "Drainable") then 
--         add = false
    
--     elseif instanceof(item, "Weapon") or instanceof(item, "WeaponPart") then 
--         add = false
--     elseif instanceof(item, "Literature") then 
--         add = false
--     end 
-- end

-- **************************************************************************
-- Intercept the ISInventoryPage:createChildren method to add 
-- a new row of buttons to the inventoryPage header.
-- **************************************************************************
local original_ISInventoryPage_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    print("Embedding ESInvFilterPanel")

    original_ISInventoryPage_createChildren(self)
    self.filterPanel = ESInvFilterPanel:new(self, self.OnFilterUpdated)
    self.filterPanel:initialise()
    self:addChild(self.filterPanel)
    self.filterPanel:show()

    -- Align to the left of the transferAll button.
    self.filterPanel:setX(self.transferAll:getX() - self.filterPanel.width - 20)
    self.filterPanel:setY(self.transferAll:getY())

    self.filterPanel:bringToTop();

    -- Give the inventoryPane reference to the filterPanel
    -- This is so inventoryPane can access the filter state
    self.inventoryPane.filterPanel = self.filterPanel
    
end


function ISInventoryPage:OnFilterUpdated(from)
    self:dirtyUI()
end


-- --**************************************************************************
-- Intercept the ISInventoryPane:refreshContainer method to filter out items.
-- Checks to see if the ESInvFilterPanel component has been added, if so then filter.
-- TODO decouple frpm filterPanel
-- --**************************************************************************
local original_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    original_refreshContainer(self)

    if self.filterPanel ~= nil then

        -- first check is any flag is checked, if none are checked, then don't filter
        local doFilter = false        
        for k, v in pairs(self.filterPanel.filterFlags) do
            print('refreshContainer() '.. k .. " : ".. tostring(self.filterPanel.filterFlags[k]))
            if self.filterPanel.filterFlags[k] == true then 
                doFilter = true
            end
        end

        -- break out if no filters selected.
        if doFilter == false then 
            print("refreshContainer() No Filters selected, Skipping")
            return
        end

        -- Filter items.
        a = {}
        -- bit of a weird one, the itemsList isn't a list of items but rather a list of 
        -- tables, where each table contains an items property, that is a list of items.
        -- So to actually get the item itself you have to do 
        -- local item = self.itemslist[1].items[1]
        -- Also, Lua starts array index at 1, fcking assess.
        -- So i think self.itemslist is basically a DTO to manage the listview rendering
        -- possibilities within ISInventoryPane.
        print("refreshContainer() Start Filtering")
        for k, listItem in ipairs(self.itemslist) do
            local item = listItem.items[1]
            local add = false;
            local itemCat =  item:getDisplayCategory()
            local itemType =  item:getType()

            if listItem.equipped or listItem.inHotbar then
                add = true
            else          
                -- TODO convert to Factory methods.     
                --Display clothing
                if self.filterPanel.filterFlags[ESInvFilterPanel.FLAGS.C] then
                    if ESInvFilters.checkIsClothing(listItem, item) then add = true end
                end

                --Display Weapons
                if self.filterPanel.filterFlags[ESInvFilterPanel.FLAGS.W] then 
                    if ESInvFilters.checkIsWeapon(listItem, item) then add = true end
                end

                --Display Food
                if self.filterPanel.filterFlags[ESInvFilterPanel.FLAGS.F] then 
                    -- if instanceof(item, "Food") then add = true end
                    if ESInvFilters.checkIsFood(listItem, item) then add = true end
                 end

                 --Display Literature
                if self.filterPanel.filterFlags[ESInvFilterPanel.FLAGS.L] then 
                    -- if instanceof(item, "Literature") then add = true end
                    if ESInvFilters.checkIsLiterature(listItem, item) then add = true end
                 end

            end
            -- print ("refreshContainer() item: category: " .. itemCat)
            -- print ("refreshContainer() item: type: ".. itemType)
            -- print ("refreshContainer() add ".. tostring(add))
            if add == true then
                table.insert(a, listItem)
            end
        end
        -- print("refreshContainer() End Filtering")
        self.itemslist = a
    end
end