
SWEP.Base="weapon_base"
SWEP.AutoSwitchTo= true
SWEP.AutoSwitchFrom= true
SWEP.DrawAmmo= true
SWEP.PrintName= "Melee Arm"
SWEP.Author= "Jvs"
SWEP.DrawCrosshair= true
SWEP.ViewModelFOV= 54
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.CSM=nil;
SWEP.IsMeleeArm=true;
SWEP.Category= "Half Life 2" 
SWEP.Slot= 0
SWEP.SlotPos= 5
SWEP.Weight= 5
SWEP.Spawnable = true
SWEP.AdminSpawnable  = true
 
SWEP.ViewModel= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel="models/weapons/w_crowbar.mdl"
SWEP.DontDrawCSM=false;
SWEP.WeaponModel={
	Model="models/Combine_Helicopter/helicopter_bomb01.mdl",
	Bone="ValveBiped.Bip01_R_Hand",
	OffsetVector=Vector(5,29,35),
	OffsetAngle=Angle(90,180,0),
	BoneMerge=(EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES),
	v={Vector(0,14,0),Vector(0,1,0)},
}

function SWEP:GetViewModelPosition(pos,ang)
	pos = pos-4*ang:Up()
	ang:RotateAroundAxis(ang:Right(), 10)
	return pos,ang
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

SWEP.HoldPos=Vector(43,3,12)
SWEP.HoldAng=Vector(0,-70,0)
SWEP.Primary=SWEP.Primary or {}
SWEP.Primary.ClipSize= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Ammo = false
SWEP.Primary.Automatic= true

SWEP.Secondary=SWEP.Secondary or {}
SWEP.Secondary.ClipSize= -1
SWEP.Secondary.DefaultClip= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false
function SWEP:ViewModelDrawn()
render.SetBlend(1)
self:DrawClientSideWeapon();
end

local FixedModelNames = { -- Broken model path = key, fixed model path = value
	["models/humans/group01/female_06.mdl"] = "models/player/group01/female_06.mdl",
	["models/humans/group01/female_01.mdl"] = "models/player/group01/female_01.mdl",
	["models/alyx.mdl"] = "models/player/alyx.mdl",
	["models/humans/group01/female_07.mdl"] = "models/player/group01/female_07.mdl",
	["models/charple01.mdl"] = "models/player/charple01.mdl",
	["models/humans/group01/female_04.mdl"] = "models/player/group01/female_04.mdl",
	["models/humans/group03/female_06.mdl"] = "models/player/group03/female_06.mdl",
	["models/gasmask.mdl"] = "models/player/gasmask.mdl",
	["models/humans/group01/female_02.mdl"] = "models/player/group01/female_02.mdl",
	["models/gman_high.mdl"] = "models/player/gman_high.mdl",
	["models/humans/group03/male_07.mdl"] = "models/player/group03/male_07.mdl",
	["models/humans/group03/female_03.mdl"] = "models/player/group03/female_03.mdl",
	["models/police.mdl"] = "models/player/police.mdl",
	["models/breen.mdl"] = "models/player/breen.mdl",
	["models/humans/group01/male_01.mdl"] = "models/player/group01/male_01.mdl",
	["models/zombie_soldier.mdl"] = "models/player/zombie_soldier.mdl",
	["models/humans/group01/male_03.mdl"] = "models/player/group01/male_03.mdl",
	["models/humans/group03/female_04.mdl"] = "models/player/group03/female_04.mdl",
	["models/humans/group01/male_02.mdl"] = "models/player/group01/male_02.mdl",
	["models/kleiner.mdl"] = "models/player/kleiner.mdl",
	["models/humans/group03/female_01.mdl"] = "models/player/group03/female_01.mdl",
	["models/humans/group01/male_09.mdl"] = "models/player/group01/male_09.mdl",
	["models/humans/group03/male_04.mdl"] = "models/player/group03/male_04.mdl",
	["models/player/urban.mbl"] = "models/player/urban.mdl", -- It fucking returns the file type wrong as "mbl" D:
	["models/humans/group03/male_01.mdl"] = "models/player/group03/male_01.mdl",
	["models/mossman.mdl"] = "models/player/mossman.mdl",
	["models/humans/group01/male_06.mdl"] = "models/player/group01/male_06.mdl",
	["models/humans/group03/female_02.mdl"] = "models/player/group03/female_02.mdl",
	["models/humans/group01/male_07.mdl"] = "models/player/group01/male_07.mdl",
	["models/humans/group01/female_03.mdl"] = "models/player/group01/female_03.mdl",
	["models/humans/group01/male_08.mdl"] = "models/player/group01/male_08.mdl",
	["models/humans/group01/male_04.mdl"] = "models/player/group01/male_04.mdl",
	["models/humans/group03/female_07.mdl"] = "models/player/group03/female_07.mdl",
	["models/humans/group03/male_02.mdl"] = "models/player/group03/male_02.mdl",
	["models/humans/group03/male_06.mdl"] = "models/player/group03/male_06.mdl",
	["models/barney.mdl"] = "models/player/barney.mdl",
	["models/humans/group03/male_03.mdl"] = "models/player/group03/male_03.mdl",
	["models/humans/group03/male_05.mdl"] = "models/player/group03/male_05.mdl",
	["models/odessa.mdl"] = "models/player/odessa.mdl",
	["models/humans/group03/male_09.mdl"] = "models/player/group03/male_09.mdl",
	["models/humans/group01/male_05.mdl"] = "models/player/group01/male_05.mdl",
	["models/humans/group03/male_08.mdl"] = "models/player/group03/male_08.mdl",
	--Thanks Jvs
	["models/monk.mdl"] = "models/player/monk.mdl",
	["models/eli.mdl"] = "models/player/eli.mdl",
}


--[[
LocalPlayer().BuildBonePositions=function(self)
	local bonename="ValveBiped.Bip01_L_Upperarm"
	local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	if !bm then return end
	if IsValid(self:GetActiveWeapon()) && self:GetActiveWeapon().IsMeleeArm then
		bm:Scale( vector_origin )
	else
		bm:Scale( Vector(1,1,1) )
	end
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
end
]]

local vm_scaledownbones={
"ValveBiped.Bip01_Pelvis",
"ValveBiped.Bip01_Spine",
"ValveBiped.Bip01_Spine1",
"ValveBiped.Bip01_Spine2",
"ValveBiped.Bip01_Spine4",
"ValveBiped.Bip01_Neck1",
"ValveBiped.Bip01_Head1",
"ValveBiped.Bip01_L_Clavicle",
"ValveBiped.Bip01_L_UpperArm",
"ValveBiped.Bip01_L_Forearm",
"ValveBiped.Bip01_L_Hand",
"ValveBiped.Bip01_R_Thigh",
"ValveBiped.Bip01_R_Calf",
"ValveBiped.Bip01_R_Foot",
"ValveBiped.Bip01_R_Toe0",
"ValveBiped.Bip01_L_Thigh",
"ValveBiped.Bip01_L_Calf",
"ValveBiped.Bip01_L_Foot",
"ValveBiped.Bip01_L_Toe0",
"ValveBiped.Bip01_L_Elbow",
"ValveBiped.Bip01_L_Ulna",
"ValveBiped.Bip01_R_Ulna",
"ValveBiped.Bip01_R_Shoulder",
"ValveBiped.Bip01_L_Shoulder",
"ValveBiped.Bip01_R_Trapezius",
"ValveBiped.Bip01_R_Wrist",
"ValveBiped.Bip01_R_Bicep",
"ValveBiped.Bip01_L_Bicep",
"ValveBiped.Bip01_L_Trapezius",
"ValveBiped.Bip01_L_Wrist",
"ValveBiped.Bip01_R_Elbow",
}

function SWEP:CreateCSM()
	local model=string.lower(self.Owner:GetModel());
	if FixedModelNames[model] then
		model=FixedModelNames[model]
	end
	if string.find(model,"gman") then
		model="models/player/alyx.mdl"
	end
	self.WeaponModel.Model=model
	if !self.CSM || !IsValid(self.CSM)then
		self.CSM = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
		self.CSM:SetNoDraw( true )
		if self.WeaponModel.Scale then
		self.CSM:SetModelScale(self.WeaponModel.Scale)
		end
		self.CSM.BuildBonePositions=function(self)
			for i,v in pairs(vm_scaledownbones) do
				local bonename=v
				local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
				if !bm then continue end
				bm:Translate(Vector(-100,0,0))
				bm:Scale( Vector(0.001,0.001,0.001) )
				self:SetBoneMatrix(self:LookupBone(bonename), bm )
			end
		end
		
		if self.WeaponModel.BoneMerge && self:IsCarriedByLocalPlayer( ) then
			self.CSM:SetParent(self.Owner:GetViewModel())
			self.CSM:AddEffects(self.WeaponModel.BoneMerge)
			self.CSM:SetNoDraw( true )
		end
	end

end

function SWEP:CalculateOffset(pos,ang,off)
	local selfangle=ang// or Angle()
	local selfpos=pos// or Vector()
	local offset = selfangle:Right() * off.x + selfangle:Forward() * off.y + selfangle:Up() * off.z;
	local pos=selfpos + offset
	return pos
end

function SWEP:DrawWorldModel()
if self.DontDrawCSM then return end
if !IsValid(self:GetOwner()) then
self:DrawModel();
return 
end
if ( !self.m_hHands ) then
self.m_hHands = self:GetOwner():LookupAttachment( "anim_attachment_RH" );
end

if !IsValid(self.MeleeHand) then
self:CreateClientSideArm();
return
end

local hand = self:GetOwner():GetAttachment( self.m_hHands );
if !hand then return end
local offset = hand.Ang:Right() * self.HoldPos.x + hand.Ang:Forward() * self.HoldPos.y + hand.Ang:Up() * self.HoldPos.z;

hand.Ang:RotateAroundAxis( hand.Ang:Right(),self.HoldAng.x );
hand.Ang:RotateAroundAxis( hand.Ang:Forward(),self.HoldAng.y );
hand.Ang:RotateAroundAxis( hand.Ang:Up(),self.HoldAng.z );

self.MeleeHand:SetRenderOrigin( hand.Pos + offset )
self.MeleeHand:SetRenderAngles( hand.Ang )

render.EnableClipping(true)


local vm = self.Owner;
local matrix = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_L_Forearm"))
self.NextBleedEffect=self.NextBleedEffect or CurTime();
if matrix && self.NextBleedEffect < CurTime() then
	local pos = matrix:GetTranslation()
		
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "BloodImpact", effectdata )
	self.NextBleedEffect=CurTime()+0.4
end

local p, a = LocalToWorld(self.WeaponModel.v[1], self.WeaponModel.v[2]:Angle(),self.MeleeHand:GetRenderOrigin(),self.MeleeHand:GetRenderAngles())
local dir = a:Forward()
render.PushCustomClipPlane(dir, dir:Dot(p))
self.MeleeHand:DrawModel();
render.PopCustomClipPlane()
render.EnableClipping(false)
end


function SWEP:DrawWorldModelTranslucent()
self:DrawWorldModel()
end

function SWEP:DrawClientSideWeapon()
if !self.CSM || !IsValid(self.CSM) || self.DontDrawCSM then return end
self.CSM:DrawModel();
if !IsValid(self.MeleeHand) then
self:CreateClientSideArm();
return
end

local vm = self.Owner:GetViewModel()
local matrix = vm:GetBoneMatrix(vm:LookupBone(self.WeaponModel.Bone))
local pos = matrix:GetTranslation()
local ang = matrix:GetAngle()
self.MeleeHand:SetRenderOrigin(self:CalculateOffset(pos,ang,self.WeaponModel.OffsetVector))
ang:RotateAroundAxis(ang:Forward(),self.WeaponModel.OffsetAngle.y)
ang:RotateAroundAxis(ang:Up(),self.WeaponModel.OffsetAngle.p)
ang:RotateAroundAxis(ang:Right(),self.WeaponModel.OffsetAngle.r)
self.MeleeHand:SetRenderAngles(ang)

render.EnableClipping(true)
local p, a = LocalToWorld(self.WeaponModel.v[1], self.WeaponModel.v[2]:Angle(),self.MeleeHand:GetRenderOrigin(),self.MeleeHand:GetRenderAngles())
local dir = a:Forward()
render.PushCustomClipPlane(dir, dir:Dot(p))
self.MeleeHand:DrawModel();
render.PopCustomClipPlane()
render.EnableClipping(false)

end

local BB2=function(self)
			local bonename="ValveBiped.Bip01_L_Forearm"
			local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
			if !bm then return end
			if IsValid(self:GetActiveWeapon()) && self:GetActiveWeapon().IsMeleeArm then
				bm:Scale( vector_origin )
			else
				bm:Scale( Vector(1,1,1) )
			end
			self:SetBoneMatrix(self:LookupBone(bonename), bm )
		end

function SWEP:CreateClientSideArm()
	timer.Simple(0,function()
		self:CreateCSM();
		if IsValid(self.Owner) then
		if self.Owner.BuildBonePositions then
			local oldbb=self.Owner.BuildBonePositions
			self.Owner.BuildBonePositions=function(...) oldbb(...) BB2(...) end
		else
		self.Owner.BuildBonePositions=BB2;
		end
		end
		self.MeleeHand = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
		self.MeleeHand:SetNoDraw( true )
		self.MeleeHand.BuildBonePositions=function(self)
			
			for i=0,self:GetBoneCount()-1 do
				local bonename=self:GetBoneName(i)
				local bm = self:GetBoneMatrix( bonename )
				if !bm || (string.find(string.lower(bonename),"forearm") || string.find(string.lower(bonename),"hand") || string.find(string.lower(bonename),"finger")) && !string.find(string.lower(bonename),"bip01_r_") then continue end
				bm:Scale( vector_origin )
				self:SetBoneMatrix(self:LookupBone(bonename), bm )
			end
			
		end
	end)
end


function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:EmitSound("Flesh.Break")
	return true
end

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
	if CLIENT then
		self:CreateCSM();
		if IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
			self.Owner:GetViewModel().Weap=self;
			self.Owner:GetViewModel().BuildBonePositions=BuildBHeliPositions
		end
	end
	self.CanAttack=CurTime()+self:SequenceDuration();
	self.Pullback=false;
	self.Redraw=false;
end


function SWEP:StupidSPFix(FunctName)
if SERVER && SinglePlayer() then
self:CallOnClient(FunctName,"")
end
end



function SWEP:Holster()
if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
self.Owner:GetViewModel().BuildBonePositions=nil;
end
	self.CanAttack=CurTime();
return true;
end

function SWEP:OnDrop()
if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
self.Owner:GetViewModel().BuildBonePositions=nil;
end
end

function SWEP:OnRemove()
if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
self.Owner:GetViewModel().BuildBonePositions=nil;
end
end


function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 75 )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -16, -16, -16 )
	tracedata.maxs =  Vector( 36, 36, 36 )
    local tr = util.TraceHull( tracedata )
    if (tr.Hit)then
        if !tr.HitWorld && IsValid(tr.Entity) && SERVER then
            self.Owner:TraceHullAttack( self.Owner:GetShootPos(), tr.HitPos, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), 25, DMG_SLASH, 0.75 );
        end
        self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
        self.Weapon:EmitSound("Flesh.ImpactHard")
    else
        self.Weapon:EmitSound("Weapon_Crowbar.Single")
        self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
    end
    
    
    self.Owner:DoAttackEvent()
	self:SetNextPrimaryFire(CurTime()+0.5)
end
--self:SendWeaponAnim(ACT_VM_THROW)
function SWEP:SecondaryAttack()end

function SWEP:Think()
	if CLIENT && IsValid(self.Owner:GetViewModel())then
		self.Owner:GetViewModel().Weap=self;
		self.Owner:GetViewModel().BuildBonePositions=BuildBHeliPositions
	end
	if SERVER then
		self.NextBleed=self.NextBleed or CurTime()
		if self.NextBleed <CurTime() then
			self.Owner:TakeDamage( 2, self.Owner, self.Owner)
			self.NextBleed=CurTime()+3;
		end
	end
end

