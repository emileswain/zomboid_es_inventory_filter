require "ISUI/ISButton"

function ISButton:enableToggle(canToggle, state)
    self.canToggle = canToggle or false
    self.isChecked = state or false
end

local original_ISButton_onMouseUp = ISButton.onMouseUp
function ISButton:onMouseUp(x,y)    
    if self.canToggle == true then
        self.isChecked = not self.isChecked
    end
    original_ISButton_onMouseUp(self, x, y)
end

local original_ISButton_render = ISButton.render
function ISButton:render()
    if self.canToggle == true then
        if self.isChecked then
            self.textColor = {r=1.0, g=0.0, b=0.0, a=1.0};
        else           
            self.textColor = {r=1.0, g=1.0, b=1.0, a=1.0};
        end
    end
    original_ISButton_render(self)
end