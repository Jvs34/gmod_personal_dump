--SWEP={}
SWEP.Base="weapon_base"
SWEP.AutoSwitchTo= true
SWEP.AutoSwitchFrom= true
SWEP.DrawAmmo= true
SWEP.PrintName= "Tau Cannon"
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
 
SWEP.ViewModel= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel="models/weapons/w_shotgun.mdl"

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
Model="models/buggy.mdl",
Vec=Vector(1.2,3,-1),
Ang=Angle(145,-2,85),
}

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


--util.IsValidModel( "models/props_forest/axe.mdl" ) 
function SWEP:CreateCSM()
	if !IsValid(self.CSM) then
		self.CSM = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
		self.CSM:SetNoDraw( true )
		if self.WeaponModel.Scale then
		self.CSM:SetModelScale(self.WeaponModel.Scale)
		end
		self.CSM:SetBodygroup(1,1)
		self.CSM.BuildBonePositions=function(self)
			local bonename=nil;
			for i=0,self:GetBoneCount()-1 do
				bonename=string.lower(self:GetBoneName(i))
				if !string.find(bonename,"gun") then
					local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
					if !bm then continue end
					bm:Scale( Vector(0.009,0.009,0.009) ) -- Deflates the bone
					self:SetBoneMatrix(self:LookupBone(bonename), bm )
				end
			end
		end
	end
	
	if !IsValid(self.Hands) && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()) then
		self.Hands = ClientsideModel( "models/weapons/v_hands.mdl", RENDER_GROUP_OPAQUE_ENTITY )
		self.Hands:SetNoDraw( true )
		self.Hands:SetParent(self.Owner:GetViewModel())
		self.Hands:AddEffects((EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES))

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
	pos=self:CalculateOffset(hand.Pos,hand.Ang,self.WeaponModel.Vec)
	ang:RotateAroundAxis( ang:Up(),	self.WeaponModel.Ang.p );
	ang:RotateAroundAxis( ang:Forward(),	self.WeaponModel.Ang.y );
	ang:RotateAroundAxis( ang:Right(),	self.WeaponModel.Ang.r );
	--now to convert this stuff to worldmodel correctly
	pos=self:CalculateOffset(pos,ang,Vector(0,6,-3))
	local ang2=Angle(-10,-110,180);
	ang:RotateAroundAxis( ang:Up(),	ang2.p );
	ang:RotateAroundAxis( ang:Forward(),	ang2.y );
	ang:RotateAroundAxis( ang:Right(),	ang2.r );
	
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
	self:SetWeaponHoldType("shotgun")
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
    
    self:SendWeaponAnim( ACT_SHOTGUN_PUMP );
    self.Owner:DoAttackEvent()
	self:SetNextPrimaryFire(CurTime()+self.AttackTime)
end
function SWEP:SecondaryAttack()end

function SWEP:Think()
end

