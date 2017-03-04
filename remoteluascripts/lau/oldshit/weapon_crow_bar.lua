AddCSLuaFile()


SWEP.Category                = "Jvs"

SWEP.Base = "weapon_base"

SWEP.Slot                    = 2
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true
SWEP.DrawAmmo            = false
SWEP.PrintName            = "Crow-bar"
SWEP.Author                = "Jvs"
SWEP.DrawCrosshair        = true
SWEP.ViewModelFOV        = 54

--if your gamemode doesn't support the hands system turn this to false and set the viewmodel to v_crowbar instead
SWEP.UseHands			= true

SWEP.ViewModel            = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl" 
SWEP.Primary={}
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = "none"
SWEP.Primary.Automatic        = true

SWEP.Secondary={}
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false


SWEP.RenderGroup = RENDERGROUP_BOTH

SWEP.ViewModelOffset=Vector(2,7,-9.2)
SWEP.WorldModelOffset=Vector(3,6,-17)

SWEP.Damage=25

SWEP.FlySpeed=700

SWEP.DamageForce=SWEP.Damage*1.2

SWEP.AttackTime=0.40

SWEP.IsCrow_Bar=true

SWEP.CrowMaxStamina=4			--4 seconds of fly time

SWEP.Recharge_Drain=1				--1= drains/recharge every second, 0.5 drains every half and so forth

SWEP.StaminaDrainRate=1			--drain rate per self.DrainEvery

SWEP.StaminaRechargeRate=0.5	--recharge rate per self.DrainEvery

if CLIENT then
	language.Add("weapon_crow_bar","Crow-bar")
	
	killicon.AddAlias( "weapon_crow_bar", "weapon_crowbar" ) -- placeholder
end

function SWEP:ViewModelDrawn()
	if not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) or not self:IsValidCrow() then return end
	local vm = self.Owner:GetViewModel()
	local matrix = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	self.Crow:SetRenderOrigin(self:CalculateOffset(pos,ang,self.ViewModelOffset))
	ang:RotateAroundAxis(ang:Forward(),180)
   
	self.Crow:SetRenderAngles(ang)
	self.Crow:SetupBones()
	self:RenderCrow()
end

function SWEP:IsValidCrow()
	if not IsValid(self.Crow) then
		timer.Simple(0,function()
			if IsValid(self) then
				self:CreateCrow()
			end
		end)
	end
	return IsValid(self.Crow)
end

--This is just for debugging, however if TTT actually supports this then leave it as it is

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {} 
 
	self.AmmoDisplay.Draw = true //draw the display?
 
	self.AmmoDisplay.PrimaryClip = self.dt.CurrentStamina //amount in clip
 
	return self.AmmoDisplay //return the table
end

function SWEP:CalculateOffset(pos,ang,off)
	local selfangle=ang or Angle()
	local selfpos=pos or Vector()
	local offset = selfangle:Right() * off.x + selfangle:Forward() * off.y + selfangle:Up() * off.z
	local pos=selfpos + offset
	return pos
end

function SWEP:DrawWorldModel()
	self:DrawModel()
	self:SetupWorldCrow()
	self:RenderCrow()
end

function SWEP:DrawWorldModelTranslucent()

end


function SWEP:SetupWorldCrow()
	if not IsValid(self:GetOwner()) or not self:IsValidCrow() then return end
	local vm = self
	local matrix = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	self.Crow:SetRenderOrigin(self:CalculateOffset(pos,ang,self.WorldModelOffset))
	ang:RotateAroundAxis(ang:Forward(),180)
   
	self.Crow:SetRenderAngles(ang)
	self.Crow:SetupBones()
	self:RenderCrow()
end



function SWEP:RenderCrow()
	if not IsValid(self.Crow)then return end
	self:UpdateCrowAnim()
	self.Crow:DrawModel()
end


function SWEP:CrowFly(crow)
	if crow:GetSequence()==crow:LookupSequence("Fly01")then return end
	crow:SetSequence("Fly01")
	crow:SetPlaybackRate(1)
end

function SWEP:CrowStance(crow)
	if crow:GetSequence()==crow:LookupSequence("Idle01")then return end
	crow:SetSequence("Idle01")
	crow:SetPlaybackRate(1)
end


function SWEP:CreateCrow()

	if not IsValid(self.Crow) then
		self.Crow = ClientsideModel( "models/Crow.mdl", RENDER_GROUP_OPAQUE_ENTITY )
		self:CrowStance(self.Crow)
		self.Crow:SetNoDraw( true )
		self.Crow:SetModelScale(1.5,0)
	end
	
end


function SWEP:UpdateCrowAnim()
	self.Crow:FrameAdvance( RealFrameTime( ) )
	if self.dt.Flying then
		self:CrowFly(self.Crow)
	else
		self:CrowStance(self.Crow)
	end
end

function SWEP:Initialize()

	self:SetWeaponHoldType("melee")
	
	self.FlapSound = CreateSound( self, "NPC_Crow.Flap" )
	self:ResetVars()
	self.dt.CurrentStamina=self.CrowMaxStamina
	self.dt.NextStaminaDrain=CurTime()+self.StaminaDrainRate
end

function SWEP:SetupDataTables()
	self:DTVar( "Float", 0, "AttackTime")
	self:DTVar( "Bool", 0, "Flying")
	self:DTVar( "Float", 1, "CurrentStamina")
	self:DTVar( "Float", 2, "NextStaminaDrain")
end

function SWEP:ResetVars()
	if not self.dt then return end
	self.dt.AttackTime=CurTime()+self.AttackTime
	self.dt.Flying=false
end

function SWEP:PrimaryAttack()
	if self.dt.AttackTime>CurTime() or self.dt.Flying then return end
	
	--if not IsFirstTimePredicted() then return end
	if SERVER then
		self.Owner:LagCompensation( true )
	end
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 75 )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -16, -16, -16 )
	tracedata.maxs =  Vector( 16, 16, 16 )
	local tr = util.TraceHull( tracedata )

    if (tr.Hit)then
        if not tr.HitWorld and IsValid(tr.Entity) and SERVER then
            --[[
				This actually does an area damage, if you don't want it to
				just comment this and uncomment the other damage function
			]]
			self.Owner:TraceHullAttack( self.Owner:GetShootPos(), tr.HitPos, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), self.Damage, DMG_SLASH , self.DamageForce )
			--[[
			local hitent=tr.Entity
			local dmgnf=DamageInfo()
			dmgnf:SetAttacker(self.Owner)
			dmgnf:SetDamage(self.Damage)
			dmgnf:SetInflictor(self)
			dmgnf:SetDamageType(DMG_SLASH)
			dmgnf:SetDamageForce(self.Owner:GetAimVector() * self.DamageForce * 2)
			hitent:TakeDamageInfo(dmgnf)
			]]
		end
        self:SendWeaponAnim( ACT_VM_HITCENTER )
        self:EmitSound("Weapon_Crowbar.Melee_Hit")
        self:EmitSound("NPC_Crow.Pain")
    else
        self:EmitSound("Weapon_Crowbar.Single")
        self:SendWeaponAnim( ACT_VM_MISSCENTER )
    end
    
    
    self.Owner:DoAttackEvent()
	if SERVER then
		self.Owner:LagCompensation( false )
	end
	self.dt.AttackTime=CurTime()+self.AttackTime
end


function SWEP:SecondaryAttack()

end

function SWEP:Reload()

end

function SWEP:Holster()
	if self.FlapSound then
		self.FlapSound:Stop()
	end
	self:ResetVars()
	return true
end

function SWEP:OnRemove()
	if self.FlapSound then
		self.FlapSound:Stop()
	end
end


function SWEP:Think()
	if not self.dt then return end
	if CLIENT then
        self:CreateCrow()
    end

	local ply=self.Owner
	if not IsValid(self.Owner) then return end
	if ply:KeyDown(IN_ATTACK2) and self:CanFly() and ply:WaterLevel()<=0 and not ply:OnGround() then 
		self.FlapSound:Play()
		self.FlapSound:ChangeVolume(1,0)
		self.dt.Flying=true
		--Should the drain be only serverside due to prediction?
		self:DrainStamina()
	elseif (not ply:KeyDown(IN_ATTACK2) or ply:OnGround() or ply:WaterLevel()>1 or not self:CanFly()) then
		if self.dt.Flying then
			self.dt.AttackTime=CurTime()+self.AttackTime
		end
		self.FlapSound:Stop()
		self.dt.Flying=false
	end
	
	self:RechargeStamina()
end


function SWEP:CanFly()
	return self.dt.CurrentStamina >= self.StaminaDrainRate and self.dt.AttackTime<CurTime()
end

function SWEP:RechargeStamina()
	--to recharge stamina you gotta hold the crow-bar and not attack with it
	
	--just in case to avoid having something like 4.7 in stamina
	if self.dt.CurrentStamina > self.CrowMaxStamina then
		self.dt.CurrentStamina=math.Clamp( self.dt.CurrentStamina, 0, self.CrowMaxStamina )
	end
	
	if self.dt.CurrentStamina < self.CrowMaxStamina and not self.dt.Flying and self.dt.AttackTime<CurTime() and self.dt.NextStaminaDrain<CurTime() then
		self.dt.NextStaminaDrain=CurTime()+self.Recharge_Drain
		self.dt.CurrentStamina=self.dt.CurrentStamina+self.StaminaRechargeRate
	end
end

function SWEP:DrainStamina()
	if self.dt.NextStaminaDrain<CurTime() and self.dt.CurrentStamina > 0 then
		self.dt.NextStaminaDrain=CurTime()+self.Recharge_Drain
		self.dt.CurrentStamina=self.dt.CurrentStamina-self.StaminaDrainRate
	end
end


hook.Add("Move","crow-bar",function(ply,data)
	if not ply:Alive() or ply:WaterLevel()>0 then return end
	local wep=ply:GetActiveWeapon()
	if data:KeyDown(IN_ATTACK2) and not ply:OnGround() and IsValid(wep) and wep.IsCrow_Bar and wep:CanFly() then
		data:SetVelocity(ply:GetAimVector()*wep.FlySpeed)
		return
	end
end)