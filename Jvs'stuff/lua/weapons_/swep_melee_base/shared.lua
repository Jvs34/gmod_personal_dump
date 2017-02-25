--SWEP={}
SWEP.Base="weapon_base"
SWEP.AutoSwitchTo= true
SWEP.AutoSwitchFrom= true
SWEP.DrawAmmo= true
SWEP.PrintName= "Melee Base"
SWEP.Author= "Jvs"
SWEP.DrawCrosshair= true
SWEP.ViewModelFOV= 54
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.CSM=nil;
SWEP.Category= "Half Life 2" 
SWEP.Slot= 0
SWEP.SlotPos= 5
SWEP.Weight= 5
SWEP.Spawnable = true
SWEP.AdminSpawnable  = true
 
SWEP.ViewModel= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel="models/weapons/w_crowbar.mdl"

SWEP.Primary={}
SWEP.Primary.ClipSize= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Ammo = false
SWEP.Primary.Automatic= true

SWEP.Secondary={}
SWEP.Secondary.ClipSize= -1
SWEP.Secondary.DefaultClip= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

SWEP.WeaponModel={
Model="models/props_mining/pickaxe01.mdl",
Vec=Vector(1.5,3.5,5),
Ang=Angle(0,180,0),
Vec2=Vector(0.5,0.2,-5),
Ang2=Angle(0,0,0),
Scale=Vector(1,1,1)/1.5
}

SWEP.WeaponModel_forestaxe={
Model="models/props_forest/axe.mdl",
Vec=Vector(1.5,3.5,-4),
Ang=Angle(0,90,0),
Vec2=Vector(0.5,0.5,5),
Ang2=Angle(0,-90,0),
}

SWEP.DefaultModel={
Model="models/weapons/w_crowbar.mdl",
Vec=Vector(1.2,3,-1),
Ang=Angle(145,-2,85),
Vec2=Vector(0.5,1,5),
Ang2=Angle(10,0,-95),
}
if CLIENT then
	Model(SWEP.WeaponModel)
	Model(SWEP.DefaultModel)
end
SWEP.Damage=25;
SWEP.DamageForce=SWEP.Damage;
SWEP.ImpactSound=Sound("Weapon_Crowbar.Melee_Hit")
SWEP.AttackTime=0.40
function SWEP:GetViewModelPosition(pos,ang)
	pos = pos-4*ang:Up()
	ang:RotateAroundAxis(ang:Right(), 10)
	return pos,ang
	--return Vector(0,0,0),Angle(0,0,0)
end

--totally not stolen from Kilburn
hook.Add("PreDrawViewModel", "MeleeArmDrawPre", function(vm, pl, weapon)
	if weapon.PreDrawViewModel then
		weapon:PreDrawViewModel()
	end
end)

function SWEP:PreDrawViewModel()
	render.SetBlend(0)
end


function SWEP:ViewModelDrawn()
render.SetBlend(1)
self:CreateModels();
if IsValid(self.Hands)then
	self.Hands:DrawModel();
end

self:DrawClientSideWeapon(false);
end

local fingerposing={		
		["ValveBiped.Bip01_R_Finger0"]	= Angle(-13,16,0),
		["ValveBiped.Bip01_R_Finger01"]	= Angle(0,23,0),
		["ValveBiped.Bip01_R_Finger02"]=Angle(0,54,0),
		
		["ValveBiped.Bip01_R_Finger1"]=Angle(-4,-23,15),
		["ValveBiped.Bip01_R_Finger11"]=Angle(0,-53,0),
		["ValveBiped.Bip01_R_Finger12"]=Angle(0,-41,0),
		
		["ValveBiped.Bip01_R_Finger2"]=Angle(0,-23,0),
		["ValveBiped.Bip01_R_Finger21"]=Angle(0,-45,0),
		["ValveBiped.Bip01_R_Finger22"]=Angle(0,-66,0),
		
		["ValveBiped.Bip01_R_Finger3"]=Angle(1,-13,-9),
		["ValveBiped.Bip01_R_Finger31"]=Angle(0,-29,0),
		["ValveBiped.Bip01_R_Finger32"]=Angle(0,-59,0),
		
		["ValveBiped.Bip01_R_Finger4"]=Angle(-5,-9,-7),
		["ValveBiped.Bip01_R_Finger41"]=Angle(0,-24,0),
		["ValveBiped.Bip01_R_Finger42"]=Angle(0,-25,0),
}

--util.IsValidModel( "models/props_forest/axe.mdl" ) 
function SWEP:CreateCSM()
	if !IsValid(self.CSM) then
		if !util.IsValidModel( self.WeaponModel.Model ) then
			self.WeaponModel=self.DefaultModel
		end
		
		self.CSM = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
		self.CSM:SetNoDraw( true )
		if self.WeaponModel.Scale then
		self.CSM:SetModelScale(self.WeaponModel.Scale)
		end
	end
	
	if !IsValid(self.Hands) && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()) then
		self.Hands = ClientsideModel( "models/weapons/v_hands.mdl", RENDER_GROUP_OPAQUE_ENTITY )
		self.Hands:SetNoDraw( true )
		self.Hands:SetParent(self.Owner:GetViewModel())
		self.Hands:AddEffects((EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES))
		self.Hands.BuildBonePositions=function(self)
			for i,v in pairs(fingerposing) do
				local bm = self:GetBoneMatrix( self:LookupBone(i) )
				if !bm then continue end
				bm:Rotate(v)
				self:SetBoneMatrix(self:LookupBone(i), bm )
			end
		end
	end
end

function SWEP:CalculateOffset(pos,ang,off)
	return (ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z) + pos
end

function SWEP:DrawWorldModel()
	self:CreateModels();
	if !IsValid(self:GetOwner()) && IsValid(self.CSM) then
		self.CSM:SetRenderOrigin( self:GetPos() )
		self.CSM:SetRenderAngles( self:GetAngles() )
		self.CSM:DrawModel();
	return 
	end
	self:DrawClientSideWeapon(true)
end


function SWEP:DrawWorldModelTranslucent()
self:DrawWorldModel()
end

function SWEP:DrawClientSideWeapon(IsWorldModel)
	if !IsValid(self.CSM) then return end
	if ( !self.m_hHands ) then
		self.m_hHands = self:GetOwner():LookupAttachment( "anim_attachment_RH" );
	end
	local pos=Vector(0,0,0);
	local ang=Angle(0,0,0);
	local offset=Vector(0,0,0);
	local hand = self:GetOwner():GetAttachment( self.m_hHands );
	if !hand then return end
	if IsWorldModel then
	--offset = hand.Ang:Right() * self.WeaponModel.Vec.x + hand.Ang:Forward() * self.WeaponModel.Vec.y + hand.Ang:Up() * self.WeaponModel.Vec.z;
	ang=hand.Ang
	pos=self:CalculateOffset(hand.Pos,hand.Ang,self.WeaponModel.Vec2)
	ang:RotateAroundAxis( ang:Up(),	self.WeaponModel.Ang2.p );
	ang:RotateAroundAxis( ang:Forward(),	self.WeaponModel.Ang2.y );
	ang:RotateAroundAxis( ang:Right(),	self.WeaponModel.Ang2.r );
	--now to convert this stuff to worldmodel correctly
	else
		local vm = self.Owner:GetViewModel()
        local matrix = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
        pos = matrix:GetTranslation()
        ang = matrix:GetAngle()
		pos=self:CalculateOffset(pos,ang,self.WeaponModel.Vec)
	ang:RotateAroundAxis( ang:Up(),	self.WeaponModel.Ang.p );
	ang:RotateAroundAxis( ang:Forward(),	self.WeaponModel.Ang.y );
	ang:RotateAroundAxis( ang:Right(),	self.WeaponModel.Ang.r );
	end
	self.CSM:SetRenderOrigin( pos )
	self.CSM:SetRenderAngles( ang )
        
	self.CSM:DrawModel();
end

function SWEP:CreateModels()
	if !IsValid(self.CSM) || !IsValid(self.Hands) then return end
	timer.Simple(0,function()
		self:CreateCSM();
	end)
end


function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.CanAttack=CurTime()+self.AttackTime;
	return true
end

function SWEP:Initialize()
	if !self.WeaponModel then
		self.WeaponModel=self.DefaultModel;
	end
	self:SetWeaponHoldType("melee")
	print(Model(self.WeaponModel.Model))
	if CLIENT then
		self:CreateCSM();
	end
	self.CanAttack=CurTime()+self:SequenceDuration();
end


function SWEP:StupidSPFix(FunctName)
if SERVER && SinglePlayer() then
self:CallOnClient(FunctName,"")
end
end



function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
	if !IsFirstTimePredicted() then return end
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 75 )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -16, -16, -16 )
	tracedata.maxs =  Vector( 16, 16, 16 )
	if SERVER then
		self.Owner:LagCompensation( true )
	end
	local tr = util.TraceHull( tracedata )
	if SERVER then
		self.Owner:LagCompensation( false )
	end
    if (tr.Hit)then
        if !tr.HitWorld && IsValid(tr.Entity) && SERVER then
            self.Owner:TraceHullAttack( self.Owner:GetShootPos(), tr.HitPos, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), self.Damage, DMG_SLASH,self.DamageForce );
        end
        self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
        self.Weapon:EmitSound(self.ImpactSound)
    else
        self.Weapon:EmitSound("Weapon_Crowbar.Single")
        self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
    end
    
    
    self.Owner:DoAttackEvent()
	self:SetNextPrimaryFire(CurTime()+self.AttackTime)
end
--self:SendWeaponAnim(ACT_VM_THROW)
function SWEP:SecondaryAttack()end

function SWEP:Think()
end

