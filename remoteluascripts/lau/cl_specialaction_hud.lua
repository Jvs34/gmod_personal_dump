

local PANEL = {}

function PANEL:Init()

end

function PANEL:PerformLayout()

	self:SetSize( 500, 80 )
	self:Center()
	self:AlignBottom( 16 )


end

function PANEL:Spawn()

	self:PerformLayout()

end