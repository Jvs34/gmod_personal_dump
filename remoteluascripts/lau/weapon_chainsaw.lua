local SWEP={}
SWEP.Base = "weapon_base"

SWEP.Author			= "Jvs"

SWEP.Spawnable            = true
SWEP.AdminOnly        = true

SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_physcannon.mdl"
SWEP.WorldModel			= "models/weapons/w_physics.mdl"

SWEP.ViewModelFOV		= 54
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Jvs' chainsaw"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
	
if CLIENT then
	multimodel.Register("ChainSaw", {
		{
			transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
			children = {
				--[[
				{
					model = "models/weapons/w_physics.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
					skin=0,
					color=Color(255,0,255,255),
				},
				]]
				{--gunbody
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
					skin=0,
					color=Color(255,0,255,255),
					children={
					--
						{
							model = "models/props_c17/trappropeller_engine.mdl",
							transform = {Vector(6,-1,0), Angle(-90,180,0), Vector(1,1,1)/3.5},
						},
						--
						{
							model = "models/props_junk/PopCan01a.mdl",
							transform = {Vector(6,5,-1.2), Angle(0,0,80), Vector(1,1,1)/2},
						},
						{
							model = "models/props_c17/TrapPropeller_Lever.mdl",
							transform = {Vector(6,7,-1.5), Angle(0,0,-10), Vector(1,1,1)/1.5},
						},
						{
							model = "models/props_junk/PopCan01a.mdl",
							transform = {Vector(0,0,-2.5), Angle(60,0,0), Vector(1,1,1)/1.5},
						},
						{
							model = "models/props_junk/propane_tank001a.mdl",
							transform = {Vector(10,-4,5), Angle(0,-45,-135), Vector(1,1,1)/2.5},
						},
						{
							model = "models/props_c17/cashregister01a.mdl",
							transform = {Vector(9,1,1), Angle(0,-90,90), Vector(1,1,1)/2},
						},
						{
							model = "models/props_phx/construct/wood/wood_boardx1.mdl",
							transform = {Vector(18,3,0), Angle(0,0,90), Vector(0.5,0.3,0.4)},
						},
						{
							model = "models/props_phx/construct/wood/wood_boardx1.mdl",
							transform = {Vector(18,-2,0), Angle(0,0,90), Vector(0.5,0.3,0.4)},
						},
					
					}
				},
				{	--wheel part
					transform = {Vector(25,0,0), Angle(0,0,90), Vector(1,1,1)/2},
					skin=0,
					color=Color(255,0,255,255),
					Think=function(self, time, ent)
						if not ent.GetSpinning then return end
						if ent:GetSpinning() then
							self.transform[2].p = math.NormalizeAngle(time*1500)
						else
							if ent:GetLastSpinTime() > CurTime() or ent:GetLastSpinTime2() < CurTime() then return end 
							local value=Lerp(math.TimeFraction(ent:GetLastSpinTime(),ent:GetLastSpinTime2(), time ),500,0)
							self.transform[2].p = math.NormalizeAngle(time*value)
						end
					end,
					children={
						{
							model = "models/props_junk/sawblade001a.mdl",
							transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1.5)},
						},
						{
							model = "models/props_junk/sawblade001a.mdl",
							transform = {Vector(0,0,3), Angle(0,0,0), Vector(0.95,0.95,1.5)},
						},
						{
							model = "models/props_junk/sawblade001a.mdl",
							transform = {Vector(0,0,-3), Angle(0,0,0), Vector(0.95,0.95,1.5)},
						},
						{
							model = "models/props_phx/wheels/magnetic_small.mdl",
							transform = {Vector(0,0,-3.75), Angle(0,0,0), Vector(1.05,1,1.05)*1.7},
						},

						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(0,0,-6.5), Angle(0,0,0), Vector(2,2,0.12)},
						},
					}
				},
				
				
			}
		}
	})	


	function SWEP:ViewModelDrawn()
        self:DrawEffects(true)
    end
	
    function SWEP:DrawWorldModel()
	   self:DrawEffects(false)
    end
	
	
	SWEP.InvisMat="engine/occlusionproxy"

	
	function SWEP:DrawHUD()

	end
	
	local voffset=Vector(-3.5,0,10)
	local vang=Angle(-6,-10,-80)
	
	local woffset=Vector(3,-0.5,-3)
	local wang=Angle(5,10,200)
	
	function SWEP:DrawEffects(view_or_world)
		if not self.mm then
			self.mm=multimodel.CreateInstance("ChainSaw")
		end
		
		local ent=(view_or_world) and self.Owner:GetViewModel() or self

		if view_or_world then
			local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_L_Hand"))
			if not matrix then return end
			local pos = matrix:GetTranslation()
			if not pos then return end
			local ang = matrix:GetAngles()
			if not ang then return end
			pos,ang=LocalToWorld(voffset,vang,pos,ang)
			multimodel.DoFrameAdvance(self.mm, CurTime(), self)
			multimodel.Draw(self.mm,self,{origin=pos,angles=ang})
		else
			self:SetMaterial( self.InvisMat )
			self:DrawModel()
			self:SetMaterial()

			local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
			if not matrix then return end
			local pos = matrix:GetTranslation()
			if not pos then return end
			local ang = matrix:GetAngles()
			if not ang then return end
			pos,ang=LocalToWorld(woffset,wang,pos,ang)
			multimodel.DoFrameAdvance(self.mm, CurTime(), self)
			multimodel.Draw(self.mm,self,{origin=pos,angles=ang})
		end
	end
	
		
	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( self.InvisMat )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()

	end
	

end
	

function SWEP:Initialize()

	self:SetWeaponHoldType( "physgun" )

	self.ActiveSound=CreateSound(self,"Town.d1_town_01_electric_loop")
end


function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Spinning" )
	self:NetworkVar( "Float",0, "LastSpinTime")
	self:NetworkVar( "Float",1, "LastSpinTime2")
	
	if SERVER then
		self:SetSpinning(false)
	end
end

function SWEP:PrimaryAttack()
	if SERVER then
		self.Owner:LagCompensation( true )
	end
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 75 )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -4, -4, -4 )
	tracedata.maxs =  Vector( 4, 4, 4 )
	local tr = util.TraceHull( tracedata )

    if (tr.Hit)then
		local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( 0, 0, 0 )
		bullet.Tracer = 0
		bullet.Force = 1
		bullet.Damage = 0
		bullet.AmmoType = "Pistol"
		self.Owner:FireBullets( bullet, true )
	
        if not tr.HitWorld and IsValid(tr.Entity) and SERVER then
			self.Owner:TraceHullAttack( self.Owner:GetShootPos(), tr.HitPos, Vector( 4, 4, 4 )*-1, Vector( 4, 4, 4 ), 5, DMG_SLASH , 1 )
		end
        if tr.HitWorld then
			self:EmitSound("Npc_Manhack.Grind")
		else
			self:EmitSound("NPC_Manhack.Slice")
		end
    end
    
    
    --self.Owner:DoAttackEvent()
	if SERVER then
		self.Owner:LagCompensation( false )
	end
	self:SetLastSpinTime(CurTime())
	self:SetLastSpinTime2(CurTime()+5)
	self:SetNextPrimaryFire(CurTime()+0.1)
end

function SWEP:Reload()

end

function SWEP:DoImpactEffect( tr, dmgtype )
	if tr.HitWorld then
		return true
	end
end

function SWEP:SecondaryAttack() end


function SWEP:Think() 
	if self.Owner:KeyDown(IN_ATTACK) then
		self:SetSpinning(true)
	else
		self:SetSpinning(false)
	end
	
	if self:GetSpinning() then
		self.ActiveSound:PlayEx(10,80)
	else
		self.ActiveSound:Stop()
	end
end


function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	return true
end

weapons.Register(SWEP,"weapon_chainsaw",true)
