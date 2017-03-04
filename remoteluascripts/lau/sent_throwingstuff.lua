
local ClassName="sent_throwingstuff"
local ENT={}


ENT.Base             = "base_anim"

ENT.Editable			= false
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT


function ENT:SetupDataTables()

	--self:NetworkVar( "Float", 0, "Timer")

end


if SERVER then
	concommand.Add("give_sentthrower", function(ply,command,args)
		if not IsValid(ply) or not ply:Alive() then return end
		
		if not IsValid(ply.__StuffThrower) then
			local en=ents.Create("sent_throwingstuff")
			en:SetPos(ply:GetPos())
			en:SetParent(ply)
			en:SetOwner(ply)
			en:Spawn()
			ply:DeleteOnRemove( en )
			ply.__StuffThrower=en
		else
			--it's already valid, change the throwing stuff type
		
		end
		
	end)

end


--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()

	if ( SERVER ) then
		self:DrawShadow(false)
		
	end
	--self.HissSound = CreateSound( self, "Weapon_FlareGun.Burn" )
	
end


if ( CLIENT ) then
	
	function ENT:Draw()

	end

end




function ENT:Think()
	--we simulate the think hook not getting called clientside for other clients here
	--
	if CLIENT and LocalPlayer()~=self:GetOwner() then return end
	
	if self:GetOwner():KeyReleased(IN_GRENADE1) then
		self:GetOwner():EmitSound("citadel.br_no")
		--self:GetOwner():DoAnimationEvent(PLAYERANIMEVENT_RELOAD)
		--self:GetOwner():AnimRestartGesture( GESTURE_SLOT_GRENADE, ACT_GMOD_GESTURE_ITEM_THROW, true )
		--self:GetOwner():DoAttackEvent()
	end
end

function ENT:OnRemove()

end





scripted_ents.Register(ENT,ClassName,true)