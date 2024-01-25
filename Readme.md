# Project Zomboid filter
## version
1.0.3

## Steam deck
Haven't tested steam deck. May not work with joy pad. May update in future.

## Description
Attaches a row of buttons that filter the inventory. 

Buttons toggle and are inclusive. Selecting `F` & `W` will filter items and show both Food and Weapons.
Click X to reset all filters.

X - Resets filters
F - Filter food items
C - Filter clothing
W - Filter weapons
L - Filter Literature


## Mod Dev notes

### ESInvFilterBtnExt.lua
Override UIButton to support toggle state. Makes the buttons text red when selected.

overrides  `ISButton:onMouseUp()` and `ISButton:render()`

### ESInvFilterPanel.lua
Implements a new row of buttons.

A new panel that implements the filter buttons and manages the filter state.
is instantiated by `ISInventoryPage:createChildren()` override in `ESInvFilter_Core.lua`


### ESInvFilter_Core.lua
Overrides the ISInventoryPage and ISInventoryPane methods required to introduce the new row of filter buttons and apply the filter logic to the Pane. 

#### ESInvFilters{}
Implements filter methods to support overides or more complex filters.
```
ESInvFilters.checkIsWeapon = function(listItem, item)
    return instanceof(item, "Weapon") or instanceof(item, "WeaponPart")
end
```
Override to make more complex filters.

#### Overrides ISInventoryPage:createChildren()
Creates an instance of ESInvFilterPanel and aligns it next to the transferALL btn. Doesn't account for other mods buttons. 


#### Overrides ISInventoryPane:refreshContainer()

Overrides the `ISInventoryPane:refreshContainer()` method and calls the original first before filtering the items.

The critical element to this override is how the ISInventoryPane relys on its internal property `itemslist`. This `itemslist` is cruicial to this mod working as what this mod does is filter this list and reassign the filtered list to the `ISInventoryPane.itemslist`.

After `ISInventoryPane:refreshContainer()` is complete, the `ISInventoryPane:prerender()` and `ISInventoryPane:render()` methods are run, which displays the new list whilst maintaining the current item functionality. 

Note: I originally thought to override the player inventory.getItems() etc, but this ultimately felt like a terrible idea. 
