local SWEP={}


SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.Category                = "Jvs"
SWEP.Spawnable            = true
SWEP.AdminOnly        = true
SWEP.Base = "weapon_base"
SWEP.Author			= "Jvs"

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"

SWEP.ViewModelFOV		= 54
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Joystick"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.STATE_IDLE			= 1
SWEP.STATE_PULLBACK		= 2
SWEP.STATE_THROWING		= 3
SWEP.STATE_DRINKING		= 4





if CLIENT then


	multimodel.Register("wep_joystick", {
		--[[
		{
					model = "models/weapons/w_slam.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
					color=Color(255,255,255,120),
		},
		]]
		{
		transform = {Vector(0,0,-1), Angle(0,0,0), Vector(1,1,1)*0.8},
		children={
				
				{
					model = "models/hunter/misc/roundthing1.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(0.6,0.5,0.3)/15},
					material=Material("phoenix_storms/gear"),
				},
				{
					model = "models/hunter/tubes/circle2x2.mdl",
					transform = {Vector(0.45,-3,0.47), Angle(0,0,0), Vector(1,1,6.45)/20},
					material=Material("phoenix_storms/gear"),
				},
				{
					model = "models/hunter/tubes/circle2x2.mdl",
					transform = {Vector(0.45,3,0.47), Angle(0,0,0), Vector(1,1,6.45)/20},
					material=Material("phoenix_storms/gear"),
				},
				
				{
					model = "models/hunter/blocks/cube025x075x025.mdl",
					transform = {Vector(0.85,-1.85,0.3), Angle(0,0,0), Vector(1,1,1)/15},
					color=Color(50,50,50,255)
				},
				{
					model = "models/hunter/blocks/cube025x075x025.mdl",
					transform = {Vector(1.65,-3.45,0.3), Angle(0,-90,0), Vector(1,1,1)/15},
					color=Color(50,50,50,255)
				},
				
				{
					model = "models/props_c17/clock01.mdl",
					transform = {Vector(-0.3,3,1), Angle(0,0,0), Vector(1,1,1)/20},
					material=Material("phoenix_storms/gear"),
					color=Color(0,0,255,255)
				},
				
				{
					model = "models/props_c17/clock01.mdl",
					transform = {Vector(1.3,3,1), Angle(0,0,0), Vector(1,1,1)/20},
					material=Material("phoenix_storms/gear"),
					color=Color(255,255,0,255)
				},
				
				{
					model = "models/props_c17/clock01.mdl",
					transform = {Vector(0.5,4,1), Angle(0,0,0), Vector(1,1,1)/20},
					material=Material("phoenix_storms/gear"),
					color=Color(255,0,0,255)
				},
				
				{
					model = "models/props_c17/clock01.mdl",
					transform = {Vector(0.5,2,1), Angle(0,0,0), Vector(1,1,1)/20},
					material=Material("phoenix_storms/gear"),
					color=Color(0,255,0,255)
				},
				
				
				
				{
					model = "models/hunter/misc/shell2x2e.mdl",
					transform = {Vector(-1.1,-2.45,0.5), Angle(67.5,0,90), Vector(0.6,0.6,1.5)/30},
					material=Material("phoenix_storms/gear"),
					color=Color(80,80,80,255)
				},
				
				{
					model = "models/hunter/misc/shell2x2e.mdl",
					transform = {Vector(-1.1,2.45,0.5), Angle(-67.5,0,-90), Vector(0.6,0.6,1.5)/30},
					material=Material("phoenix_storms/gear"),
					color=Color(80,80,80,255)
				},
				
				{
					model = "models/props_junk/PopCan01a.mdl",
					transform = {Vector(0.6,-0.7,0.9), Angle(0,45,90), Vector(1,1,1.5)/12},
					material=Material("phoenix_storms/gear"),
					color=Color(80,80,80,255)
				},
				{
					model = "models/props_junk/PopCan01a.mdl",
					transform = {Vector(0.6,0.7,0.9), Angle(0,45,90), Vector(1,1,1.5)/12},
					material=Material("phoenix_storms/gear"),
					color=Color(80,80,80,255)
				},
				
				{
				transform = {Vector(4.05,0,-0.2), Angle(0,0,0), Vector(1,1,1)/3},
				children={
						{
							model = "models/props_phx/construct/metal_angle360.mdl",
							transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(1,1,1)/30},
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(1.5,1.5,1)/10},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(3,3,0.4)/10},
							material="models/shiny",
							color=Color(239,239,239)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(4,4,0.2)/10},
							material="models/shiny",
							color=Color(239,239,239)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-28,0,2), Angle(-90,0,0), Vector(4,4,0.1)/10},
							material="models/shiny",
							color=Color(239,239,239)
						},	
					}
				}
		}
		}
	})

	SWEP.Offsets={
		view={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(5.5,-4.5,-2),
			ang=Angle(-90,45,0),
		},
		world={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(3.5,-5,-1),
			ang=Angle(-110,0,0),
		}
	}

	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( "engine/occlusionproxy" )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()
		return true
	end
	
	function SWEP:ViewModelDrawn(vm)
        self:DrawEffects(true,vm)
    end
    

	
	function SWEP:DrawEffects(view_or_world,vm)
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and vm or self.Owner
		if not self.Joystick then 
			self.Joystick=multimodel.CreateInstance("wep_joystick")
		end
		local offsets=self.Offsets[(view_or_world) and "view" or "world"]
		
		if not ent:LookupBone(offsets.bone) then return end
		
		local bonematrix=ent:GetBoneMatrix(ent:LookupBone(offsets.bone))
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld(offsets.pos,offsets.ang, bonematrix:GetTranslation(), bonematrix:GetAngles() )
		
		multimodel.Draw(self.Joystick,self,{origin=pos,angles=ang})
		
	end
	
    function SWEP:DrawWorldModel()
        self:DrawEffects(false)
    end
end


function SWEP:Initialize()
	self:SetWeaponHoldType("357")
end 

function SWEP:SetupDataTables()

end



function SWEP:Deploy()
	self:SendWeaponAnim(ACT_SLAM_TRIPMINE_DRAW)
	self:SetNextPrimaryFire(CurTime()+0.30)
	self:SetNextSecondaryFire(CurTime()+1)
	return true
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
end

function SWEP:SecondaryAttack()
end

function SWEP:ModifyEs(es)
	if string.find(es.SoundName,"vo/") then
		es.DSP=58
		PrintTable(es)
	end
end



function SWEP:Holster()
    return true
end

function SWEP:OnDrop()

end

function SWEP:OnRemove()
end

	--[[
	SoundName	=	)weapons/357/357_fire3.wav
	SoundTime	=	0
	Flags	=	0
	Entity	=	Player(2)
	DSP	=	0
	Channel	=	1
	SoundLevel	=	140
	Volume	=	0.9296875
	Pitch	=	91
	]]
	--es.SoundName = "vo/citadel/br_no.wav"


hook.Add("EntityEmitSound","Megaphone",function(es)
	
	if IsValid(es.Entity) and es.Entity:IsPlayer() and
		IsValid(es.Entity:GetActiveWeapon()) and es.Entity:GetActiveWeapon():GetClass()=="weapon_megaphone" then
		es.Entity:GetActiveWeapon():ModifyEs(es)
		return true,es
	end

end)


weapons.Register(SWEP,"weapon_megaphone",true)