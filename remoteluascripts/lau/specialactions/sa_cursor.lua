if not SA then return end

local newsa=SA:New("Cursor test!","sa_cursor","Cursor test???")

function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.cursor=ClientsideModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		entity.cursor:SetNoDraw(true)
	end
end

function newsa:Deinitialize(entity,owner)
	if CLIENT then
		if IsValid(entity.cursor) then
			entity.cursor:Remove()
		end
	end
end


function newsa:Think(entity,owner,mv)
	local cmd=owner:GetCurrentCommand()
	--entity:SetActionInt1(cmd:GetMouseX())
	--entity:SetActionInt2(cmd:GetMouseY())
end


function newsa:AllClientThink(entity,owner,isclientowner)
end


function newsa:Attack(entity,owner,mv) 
end


function newsa:SetupMove(entity,owner,movedata,commanddata)
end

function newsa:Move(entity,owner,movedata)
end


function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
end

if CLIENT then
	newsa.MouseCursor = CreateMaterial("sa_mousecursor", "UnlitGeneric", {
		["$basetexture"] = "vgui/mouse",
		["$vertexcolor"] = "1",
		["$vertexalpha"] = "1",
		["$translucent"] = "1",
		["$ignorez"] = "1",
		["$no_fullbright"] = "1",
	})
end

function newsa:DrawWorldModel(entity,owner)
	
	local pos=owner:GetShootPos() + owner:GetAimVector()*30
	local ang=(pos-owner:GetShootPos()):GetNormal():Angle()
	
	cam.Start3D2D(pos,ang, 0.5)
		
		surface.SetDrawColor(255,255,255,255)
		
		surface.SetMaterial(self.MouseCursor)
		surface.DrawTexturedRect(0, 0, 16, 16)
	cam.End3D2D()

end


function newsa:PrePlayerDraw(entity,owner)
end

function newsa:PostPlayerDraw(entity,owner)
end



function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)
end


function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
end

function newsa:HUDDraw(entity,owner)
end

function newsa:ResetVars(entity,owner)
	entity:SetActionInt1(0)
	entity:SetActionInt2(0)
	
end

function newsa:PlayerUse(entity,owner,useentity)
end

function newsa:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
end

function newsa:CalcMainActivity(entity,owner,velocity)

end


function newsa:DoAnimationEvent(entity,owner,event,data)
end

function newsa:BuildHandsPosition(entity,owner,handsent)
	
end

function newsa:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	
end