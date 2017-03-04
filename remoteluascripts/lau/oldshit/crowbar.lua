if SERVER then
	AddCSLuaFile("shared.lua")
end

local notconventionalregistering=false
if not SWEP then
	SWEP={}
	notconventionalregistering=true
end
SWEP.Category                = "Jvs"
SWEP.Base ="weapon_base"
SWEP.Slot                    = 2
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = false
SWEP.AdminSpawnable          = true
SWEP.DrawAmmo            = false
SWEP.PrintName            = "Crow-bar"
SWEP.Author                = "Jvs"
SWEP.DrawCrosshair        = true
SWEP.ViewModelFOV        = 54

SWEP.ViewModel            = "models/weapons/v_crowbar.mdl"
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
SWEP.DamageForce=SWEP.Damage*5
SWEP.AttackTime=0.40
SWEP.IsCrow_Bar=true
SWEP.QuackTime=0.30
function SWEP:ViewModelDrawn()
	if not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) or not IsValid(self.Crow) then return end
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

function SWEP:CalculateOffset(pos,ang,off)
	local selfangle=ang// or Angle()
	local selfpos=pos// or Vector()
	local offset = selfangle:Right() * off.x + selfangle:Forward() * off.y + selfangle:Up() * off.z
	local pos=selfpos + offset
	return pos
end

function SWEP:DrawWorldModel()
	self:DrawModel()
	self:SetupWorldCrow()
	self:RenderCrow()
end

function SWEP:DrawWorldModelTranslucent() end

SWEP.Crowbaroffset=Vector(0,0,0)
function SWEP:SetupWorldCrow()
	if not IsValid(self:GetOwner()) or not IsValid(self.Crow) then return end
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

	if not IsValid(self.Crow)then
		self.Crow = ClientsideModel( "models/Crow.mdl", RENDER_GROUP_OPAQUE_ENTITY )
		self:CrowStance(self.Crow)
		self.Crow:SetNoDraw( true )
		self.Crow:SetModelScale(Vector(1.5,1.5,1.5))
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

	self:StupidSPFix("Initialize")
	self:SetWeaponHoldType("melee")
	if(CLIENT)then
		language.Add(self:GetClass(),"Crow-bar")
    end
	
	self.FlapSound = CreateSound( self, "NPC_Crow.Flap" )
	self:ResetVars()
	self.Initialized=true
	
end

function SWEP:SetupDataTables()
	if not IsValid(self) then return end
	self:DTVar( "Float", 0, "AttackTime")
	self:DTVar( "Bool", 0, "Flying")
	self:DTVar( "Float", 1, "NextQuack") --crows don't quack you idiot
end

function SWEP:ResetVars()
	if not self.dt then return end
	self.dt.AttackTime=CurTime()+self.AttackTime
	self.dt.Flying=false
	self.dt.NextQuack=CurTime()+self.QuackTime
end

function SWEP:StupidSPFix(FunctName)
	if SERVER and game.SinglePlayer() then
		self:CallOnClient(FunctName,"")
	end
end

function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
	if self.dt.AttackTime>CurTime() or self.dt.Flying then 
		if self.dt.Flying and self.dt.NextQuack < CurTime() then
			self:EmitSound("NPC_Crow.Pain")
			self.dt.NextQuack=CurTime()+self.QuackTime
		end
	return 
	end
	
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
        if not tr.HitWorld && IsValid(tr.Entity) && SERVER then
            self.Owner:TraceHullAttack( self.Owner:GetShootPos(), tr.HitPos, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), self.Damage, DMG_SLASH,self.DamageForce )
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
	if not self.Initialized or not self.dt then return end
	if CLIENT then
        self:CreateCrow()
    end

	local ply=self.Owner
	if not IsValid(self.Owner) then return end
	if ply:KeyDown(IN_ATTACK2) and ply:WaterLevel()<=0 and not ply:OnGround() then 
		if SERVER or  (CLIENT and LocalPlayer()==self:GetOwner()) then 
			self.FlapSound:Play()
			self.dt.Flying=true
		end
	elseif (not ply:KeyDown(IN_ATTACK2) or ply:OnGround() or ply:WaterLevel()>1) then
		if self.dt.Flying then
			self.dt.AttackTime=CurTime()+self.AttackTime
		end
		if SERVER or  (CLIENT and LocalPlayer()==self:GetOwner()) then 
			self.FlapSound:Stop()
			self.dt.Flying=false
		end
	end
end

hook.Add("Move","crow-bar",function(ply,data)
	if not ply:Alive() or ply:WaterLevel()>0 then return end
	if data:KeyDown(IN_ATTACK2) and not ply:OnGround() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass()=="weapon_crow_bar" then
		data:SetVelocity(ply:GetAimVector()*700)
		return
	end
end)


if CLIENT then
	--This is a stupid fix to the clientside think/initialize of sweps not being called on other clients but localplayer's
	local wep=nil
	hook.Add("Tick","Fixclientsideswepthink",function()
		for i,v in pairs(player.GetAll()) do
			if IsValid(v) and v~=LocalPlayer() and v:Alive() then
				wep=v:GetActiveWeapon()
				if wep~=NULL and IsValid(wep) and wep.Think  then
					if not wep.Initialized and wep.SetupDataTables then
						wep:SetupDataTables()
						wep:Initialize()
					end
				wep:Think() 
				end
				wep=nil
			end
		end
	end)

	
end

if notconventionalregistering then
	weapons.Register(SWEP,"weapon_crow_bar",true)
	SWEP=nil
end