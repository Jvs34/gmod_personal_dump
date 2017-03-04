local SWEP={}

SWEP.Base = "weapon_base"
SWEP.Author			= "Jvs"
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_alyx_gun.mdl"

SWEP.ViewModelFOV		= 54
--[[
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"	"#HL2_AlyxGun"
	"viewmodel"				"models/weapons/W_Alyx_Gun.mdl"
	"playermodel"			"models/weapons/W_Alyx_Gun.mdl"	//FIXME: 
	"anim_prefix"			"alyxgun"
	"bucket"				"1"
	"bucket_position"		"4"

	"clip_size"				"30"
	"clip2_size"			"-1"

	"default_clip"			"30"
	"default_clip2"			"-1"

	"primary_ammo"			"AlyxGun"

	"weight"				"2"
	"item_flags"			"0"
]]
SWEP.Primary={}
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "#HL2_AlyxGun"
SWEP.Slot				= 1
SWEP.SlotPos			= 4
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true
SWEP.Spawnable            = true
SWEP.AdminOnly        = true

SWEP.ShootSound				= "Weapon_Pistol.NPC_Single"
SWEP.ReloadSound				= "Weapon_Pistol.Reload"

if CLIENT then
    
	function SWEP:ViewModelDrawn(vm)
        self:DrawEffects(true,vm)
    end
    
	function SWEP:CreateGun()
		if IsValid(self.Gun) then return end
		--timer.Simple(0,function()
			if not IsValid(self) or IsValid(self.Gun) then return end
			self.Gun=ClientsideModel(self.WorldModel)
			self.Gun:SetNoDraw(true)
			self.Gun:Spawn()
		--end)
	end
	
    function SWEP:DrawWorldModel()
        self:DrawEffects(false)
    end
	
	
	SWEP.InvisMat="engine/occlusionproxy"
	
	function SWEP:DrawHUD()

	end

	
	SWEP.Offsets={
		view={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(0,0,0),
			ang=Angle(0,0,0),
		},
		world={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(0,0,0),
			ang=Angle(0,0,0),
		}
	}
	
	function SWEP:DrawEffects(view_or_world,vm)
		self:CreateGun()
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and vm or self.Owner
		if not IsValid(self.Gun) then return end
		
		local offsets=self.Offsets[(view_or_world) and "view" or "world"]
		
		if not ent:LookupBone(offsets.bone) then return end
		local bone=ent:LookupBone(offsets.bone)
		if not bone then return end
		local bonematrix=ent:GetBoneMatrix(bone)
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld(offsets.pos,offsets.ang, bonematrix:GetTranslation(), bonematrix:GetAngles() )

		
		--self.Gun:SetModel("models/player/breen.mdl")
		--[[
		local m=Matrix()
		m:Translate(pos)
		m:Rotate(ang)
		]]
		--m:Scale(Vector(3,3,3)*5)
		--self.Gun:SetModel("models/weapons/w_alyx_gun.mdl")
		
		
		self.Gun:SetRenderOrigin(pos)
		self.Gun:SetRenderAngles(ang)
		
		self.Gun:SetupBones()
		self.Gun:DrawModel()
		--[[
		self.Gun:EnableMatrix("RenderMultiply",m)
		self.Gun:DrawModel()
		self.Gun:DisableMatrix("RenderMultiply")
		self.Gun:SetupBones()
		]]
		
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

	self:SetWeaponHoldType( "pistol" )

end


function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "FireMode" )
	
end




function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime()+0.3)
	if self:Clip1()<=0 then return end
	self:EmitSound( self.ShootSound )
	
	self.Owner:MuzzleFlash()
	self.Owner:DoAttackEvent()
	self:SetClip1( self:Clip1() - 1 )
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:Reload()
	if self:DefaultReload(ACT_VM_RELOAD) then
		self:EmitSound(self.ReloadSound)
	end
end


function SWEP:SecondaryAttack() end


function SWEP:Think() end

function SWEP:Tick() end



function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	
	return true
end

weapons.Register(SWEP,"weapon_jvs_alyxgun")