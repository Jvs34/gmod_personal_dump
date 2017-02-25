SWEP.AutoSwitchTo= true
SWEP.AutoSwitchFrom= true
SWEP.DrawAmmo= true
SWEP.PrintName= "Duke Nukem 3D Pipebomb"
SWEP.Author= "Jvs"
SWEP.DrawCrosshair= true
SWEP.ViewModelFOV= 54
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.CSM1=nil;
SWEP.CSM2=nil;
if CLIENT then
SWEP.WepSelectIcon		= surface.GetTextureID( "dukenukem3d/PbombHUD" )
end
SWEP.Category= "Half Life 2" 
SWEP.Slot= 4
SWEP.SlotPos= 5
SWEP.Weight= 5
SWEP.Spawnable = true
SWEP.AdminSpawnable  = true
 
SWEP.ViewModel= "models/weapons/v_animhands.mdl"
SWEP.WorldModel="models/Nirrti/Pipebomb/pipebomb.mdl"
SWEP.DontDrawCSM=false;

SWEP.WeaponModel={}
SWEP.WeaponModel[1]={
    Model="models/Nirrti/Pipebomb/pipebomb.mdl",
    Bone="ValveBiped.Bip01_R_Hand",
	OffsetVector=Vector(2.331,3.919,-0.062),
	OffsetAngle=Angle(-1,-87,-27),
    Skin=0,
}

SWEP.WeaponModel[2]={
    Model="models/Nirrti/Pipebomb/detonator.mdl",
    Bone="ValveBiped.Bip01_L_Hand",
	OffsetVector=Vector(1.8509999513626,3.0769999027252,1.2130000591278),
	OffsetAngle=Angle(19,-16,0),
    Skin=0,
}


SWEP.HoldPos=Vector(0,0,0)
SWEP.HoldAng=Angle(-1,-87,-27)

SWEP.HoldPos2=Vector(-0.5,0.5,0)
SWEP.HoldAng2=Vector(0,0,0)

SWEP.Primary.ClipSize= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Ammo = false
SWEP.Primary.Automatic= false


SWEP.Secondary.ClipSize= -1
SWEP.Secondary.DefaultClip= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

SWEP.HasDetonatorDeployed=false;
SWEP.CurrentAnim=nil;
 
function SWEP:ViewModelDrawn()
self:DrawClientSideWeapon();
end

function SWEP:CreateCSM()
	if !self.CSM1 || !IsValid(self.CSM1)then
		self.CSM1 = ClientsideModel( self.WeaponModel[1].Model, RENDER_GROUP_OPAQUE_ENTITY )
		self.CSM1:SetNoDraw( true )
	end
	if !self.CSM2 || !IsValid(self.CSM2)then
		self.CSM2 = ClientsideModel( self.WeaponModel[2].Model, RENDER_GROUP_OPAQUE_ENTITY )
		self.CSM2:SetNoDraw( true )
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
	if !IsValid(self:GetOwner()) then
		self:DrawModel();
		return 
	end
	if ( !self.m_hHands ) then
		self.m_hHands = self:GetOwner():LookupAttachment( "anim_attachment_RH" );
		self.m_hHands1 = self:GetOwner():LookupAttachment( "anim_attachment_LH" );
	end

	local hand = self:GetOwner():GetAttachment( self.m_hHands );
	if !hand then return end
	local offset = hand.Ang:Right() * self.HoldPos.x + hand.Ang:Forward() * self.HoldPos.y + hand.Ang:Up() * self.HoldPos.z;

	hand.Ang:RotateAroundAxis( hand.Ang:Right(),self.HoldAng.x );
	hand.Ang:RotateAroundAxis( hand.Ang:Forward(),self.HoldAng.y );
	hand.Ang:RotateAroundAxis( hand.Ang:Up(),self.HoldAng.z );

	self.CSM1:SetRenderOrigin( hand.Pos + offset )
	self.CSM1:SetRenderAngles( hand.Ang )
	if !self.HasDetonatorDeployed then
		self.CSM1:DrawModel();
	end
	
	hand = self:GetOwner():GetAttachment( self.m_hHands1 );
	
	offset = hand.Ang:Right() * self.HoldPos2.x + hand.Ang:Forward() * self.HoldPos2.y + hand.Ang:Up() * self.HoldPos2.z;

	hand.Ang:RotateAroundAxis( hand.Ang:Right(),self.HoldAng2.x );
	hand.Ang:RotateAroundAxis( hand.Ang:Forward(),self.HoldAng2.y );
	hand.Ang:RotateAroundAxis( hand.Ang:Up(),self.HoldAng2.z );

	self.CSM2:SetRenderOrigin( hand.Pos + offset )
	self.CSM2:SetRenderAngles( hand.Ang )

	self.CSM2:DrawModel();
end


function SWEP:DrawWorldModelTranslucent()
	self:DrawWorldModel()
end

function SWEP:DrawClientSideWeapon()
	if !self.CSM1 || !IsValid(self.CSM1) || self.DontDrawCSM then return end
	if !self.CSM2 || !IsValid(self.CSM2) || self.DontDrawCSM then return end
	local vm = self.Owner:GetViewModel()
	local matrix = vm:GetBoneMatrix(vm:LookupBone(self.WeaponModel[1].Bone))
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngle()
	self.CSM1:SetRenderOrigin(self:CalculateOffset(pos,ang,self.WeaponModel[1].OffsetVector))
	ang:RotateAroundAxis(ang:Forward(),self.WeaponModel[1].OffsetAngle.y)
	ang:RotateAroundAxis(ang:Up(),self.WeaponModel[1].OffsetAngle.p)
	ang:RotateAroundAxis(ang:Right(),self.WeaponModel[1].OffsetAngle.r)
	self.CSM1:SetRenderAngles(ang)
	if !self.WeaponModel[1].Useless then
		self.CSM1:DrawModel();
	end
	
	matrix = vm:GetBoneMatrix(vm:LookupBone(self.WeaponModel[2].Bone))
	pos = matrix:GetTranslation()
	ang = matrix:GetAngle()
	self.CSM2:SetRenderOrigin(self:CalculateOffset(pos,ang,self.WeaponModel[2].OffsetVector))
	ang:RotateAroundAxis(ang:Forward(),self.WeaponModel[2].OffsetAngle.y)
	ang:RotateAroundAxis(ang:Up(),self.WeaponModel[2].OffsetAngle.p)
	ang:RotateAroundAxis(ang:Right(),self.WeaponModel[2].OffsetAngle.r)
	self.CSM2:SetRenderAngles(ang)
	if !self.WeaponModel[2].Useless then
		self.CSM2:DrawModel();
	end
end



SWEP.ACT_VM_DEPLOY={
[1]={
['ValveBiped.Bip01_R_UpperArm']=Angle(-11,1,39),
['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
['ValveBiped.Bip01_R_Forearm']=Angle(-3,-27,-13),
['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
Duration=0.4
},
[2]={
['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
['ValveBiped.Bip01_R_Forearm']=Angle(-3,-27,-13),
['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
Duration=0.1,
CallBack="ANIMATION_FINISHED"
},
}

SWEP.ACT_VM_PRE_THROW={
[1]={ --holds the pipebomb
['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
['ValveBiped.Bip01_R_Forearm']=Angle(-3,-27,-13),
['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
Duration=0.3,
},
[2]={--puts down to launch
	['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
	['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
	['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
	['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
	['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
	['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
	['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
	['ValveBiped.Bip01_R_Forearm']=Angle(13,-13,67),
	['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
	['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
	['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
	['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
	['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
	CallBack="PIPEBOMB_PRETHROW",
	Duration=0.1
}

}

SWEP.ACT_VM_PRE_THROW_LOOP={
[1]={--puts down to launch
	['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
	['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
	['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
	['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
	['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
	['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
	['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
	['ValveBiped.Bip01_R_Forearm']=Angle(13,-13,67),
	['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
	['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
	['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
	['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
	['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
	Duration=0.1
},
[2]={--puts down to launch
	['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
	['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
	['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
	['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
	['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
	['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
	['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
	['ValveBiped.Bip01_R_Forearm']=Angle(13,-13,67),
	['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
	['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
	['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
	['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
	['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
	CallBack="PIPEBOMB_PRETHROW_LOOP",
	Duration=0.1
}

}

SWEP.ACT_VM_THROW={
[1]={--puts down to launch

	['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
	['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
	['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
	['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
	['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
	['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
	['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
	['ValveBiped.Bip01_R_Forearm']=Angle(13,-13,67),
	['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
	['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
	['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
	['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
	['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
	Duration=0.1,
	DontDrawCSM=true,
},

[2]={--actually launch the pipebomb
['ValveBiped.Bip01_R_UpperArm']=Angle(-11,-31,39),
['ValveBiped.Bip01_R_Finger12']=Angle(0,-15,0),
['ValveBiped.Bip01_R_Finger2']=Angle(0,33,0),
['ValveBiped.Bip01_R_Finger4']=Angle(0,33,0),
['ValveBiped.Bip01_R_Finger3']=Angle(0,35,0),
['ValveBiped.Bip01_R_Finger22']=Angle(0,13,0),
['ValveBiped.Bip01_R_Finger01']=Angle(0,-29,0),
['ValveBiped.Bip01_R_Finger1']=Angle(0,17,0),
['ValveBiped.Bip01_R_Finger41']=Angle(0,23,0),
['ValveBiped.Bip01_R_Finger21']=Angle(0,-11,0),
['ValveBiped.Bip01_R_Forearm']=Angle(5,-27,67),
['ValveBiped.Bip01_R_Finger02']=Angle(0,-25,0),
['ValveBiped.Bip01_R_Finger0']=Angle(-13,7,0),
['ValveBiped.Bip01_R_Finger11']=Angle(0,33,0),
['ValveBiped.Bip01_R_Finger32']=Angle(0,11,0),
['ValveBiped.Bip01_R_Finger42']=Angle(0,1,0),
['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
CallBack="PIPEBOMB_THROW",
DontDrawCSM=true,
Duration=0.3
},
[3]={
['ValveBiped.Bip01_R_UpperArm']=Angle(-11,1,39),
['ValveBiped.Bip01_R_Finger12']=Angle(0,-48,0),
['ValveBiped.Bip01_R_Finger2']=Angle(0,-10,0),
['ValveBiped.Bip01_R_Finger4']=Angle(0,10,0),
['ValveBiped.Bip01_R_Finger22']=Angle(0,-37,0),
['ValveBiped.Bip01_R_Finger1']=Angle(0,-7,0),
['ValveBiped.Bip01_R_Finger21']=Angle(0,-9,0),
['ValveBiped.Bip01_R_Forearm']=Angle(-3,-27,-13),
['ValveBiped.Bip01_R_Finger0']=Angle(-20,10,0),
['ValveBiped.Bip01_R_Finger11']=Angle(0,-14,0),
['ValveBiped.Bip01_R_Finger32']=Angle(0,-16,0),
['ValveBiped.Bip01_R_Finger31']=Angle(0,-2,0),
['ValveBiped.Bip01_R_Hand']=Angle(-27,19,-1),
CallBack="PIPEBOMB_THROW_HOLSTER",
Duration=0.1
}

}
SWEP.ACT_VM_DETONATOR_DRAW={
[1]={--the detonator is offscreen,it will rise
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-7,-1,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
Duration=0.3,
},
[2]={--the detonator is onscreen now.
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-6,-61,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
Duration=0.1,
CallBack="PIPEBOMB_DETONATOR_DRAWN"
}
}

SWEP.ACT_VM_DETONATOR_HOLSTER={
[1]={--the detonator is onscreen now.
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-6,-61,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
Duration=0.3,
},
[2]={--the detonator is offscreen,it will rise
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-7,-1,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),

Duration=0.1,
CallBack="PIPEBOMB_DETONATOR_HOLSTERED"
},

}

SWEP.ACT_VM_DETONATOR_IDLE={
[1]={--the detonator is onscreen now.
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-6,-61,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
Duration=0.1
},FrameLoop=1
}

SWEP.ACT_VM_DETONATOR_ACTIVATE={
[1]={--the detonator is onscreen now.
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-6,-61,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
Duration=0.05
},
[2]={--the detonator has been pressed
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger0']=Angle(-21,-9,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-6,-61,27),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
CallBack="PIPEBOMB_DETONATOR_CLICK",
Duration=0.2,
},
[3]={
['ValveBiped.Bip01_L_Finger1']=Angle(-19,-39,-21),
['ValveBiped.Bip01_L_Finger0']=Angle(15,3,0),
['ValveBiped.Bip01_L_Hand']=Angle(67,0,0),
['ValveBiped.Bip01_L_Finger32']=Angle(0,-33,0),
['ValveBiped.Bip01_L_Finger31']=Angle(0,-19,0),
['ValveBiped.Bip01_L_Clavicle']=Angle(0,-39,0),
['ValveBiped.Bip01_L_Finger21']=Angle(0,-26,0),
['ValveBiped.Bip01_R_Finger0']=Angle(1,0,0),
['ValveBiped.Bip01_L_Finger11']=Angle(0,-35,0),
['ValveBiped.Bip01_L_Forearm']=Angle(-6,-61,27),
['ValveBiped.Bip01_L_UpperArm']=Angle(-33,-35,-1),
['ValveBiped.Bip01_L_Finger2']=Angle(-12,-37,-13),
['ValveBiped.Bip01_L_Finger4']=Angle(-3,-37,0),
['ValveBiped.Bip01_L_Finger22']=Angle(0,-38,0),
['ValveBiped.Bip01_L_Finger12']=Angle(0,-34,0),
['ValveBiped.Bip01_L_Finger3']=Angle(-12,-27,0),
Duration=0.1,
CallBack="PIPEBOMB_DETONATOR_CLICK_FINISHED"
}
}

SWEP.AnimationFrame=1;
SWEP.AnimTime=CurTime();

local function GetNextFrame(self)
local nextframe=self.Weap.AnimationFrame
if nextframe+1> #self.Weap.CurrentAnim then
if self.Weap.CurrentAnim.FrameLoop then
nextframe=self.Weap.CurrentAnim.FrameLoop
end
else
nextframe=nextframe+1;
end

return nextframe;
end

local function AdvanceFrame(self)
if CurTime()<self.Weap.AnimTime then return end
self.Weap.AnimationFrame=GetNextFrame(self);
local callback=self.Weap.CurrentAnim[self.Weap.AnimationFrame].CallBack
if callback then
self.Weap:HandleCustomAnimationEvent(callback)
end
self.Weap.AnimTime=CurTime()+self.Weap.CurrentAnim[self.Weap.AnimationFrame].Duration;
end



local function BuildBPositions(self)
	local Weap=self.Weap
	if !Weap.CurrentAnim then return end
	if !IsValid(LocalPlayer():GetActiveWeapon()) || LocalPlayer():GetActiveWeapon()!=self.Weap then return end
	for i,v in pairs(Weap.CurrentAnim[Weap.AnimationFrame])do

		if type(v)=="Angle" then
			local b = self:LookupBone(i)
			if b then
			local m = self:GetBoneMatrix(b)
			if m then

			//allright,so we need to interpolate to the next frame,so we can just use less frames and less choppy animations

			local ang=Angle(v.p,v.y,v.r);//fuuuu-,basically,this was the bug i was looking for,it was returning the original vector,not a copy of it
			 //and it was screwing up the animation
			//we need to get the rotation shit of the next frame of the same viewmodel bone

			local nextframe=GetNextFrame(self);
			local nextframeangle=Weap.CurrentAnim[nextframe][i] or Angle(0,0,0)

			//the angle table values are: p,y,r

			local frac=math.TimeFraction(Weap.AnimTime-(Weap.CurrentAnim[Weap.AnimationFrame].Duration or 0 ),Weap.AnimTime, CurTime() )
			ang.p=Lerp(frac,v.p,nextframeangle.p)
			ang.y=Lerp(frac,v.y,nextframeangle.y)
			ang.r=Lerp(frac,v.r,nextframeangle.r)
			
			m:Rotate(ang)
			self:SetBoneMatrix(b,m)
		end
		end
	end

	end
	Weap.DontDrawCSM=(Weap.CurrentAnim[Weap.AnimationFrame].DontDrawCSM) and true or false
	//AdvanceFrame(self);
end





function SWEP:Initialize()
self:SetWeaponHoldType("slam")
if IsValid(self.Owner) then
self:SendWeaponAH(self.ACT_VM_DEPLOY)
self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
end
	if CLIENT then
		self:CreateCSM();
	end
	if SERVER then
		self.Pipebombs={}
		self.ThrowCharge=0;//max is 10
	end
end

local RandomGibModels={
"models/props_c17/canisterchunk01i.mdl",
"models/props_c17/canisterchunk01f.mdl",
}


function SWEP:Precache()
	for i,v in pairs(RandomGibModels)do
		util.PrecacheModel(v)
	end
end 

function SWEP:Deploy()
self:SendWeaponAH((self.HasDetonatorDeployed) and self.ACT_VM_DETONATOR_DRAW or self.ACT_VM_DEPLOY)
self:StupidSPFix("Deploy")
self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
return true;
end

function SWEP:StupidSPFix(FunctName)
if SERVER && SinglePlayer() then
self:CallOnClient(FunctName,"")
end
end



function SWEP:Holster()
local canholster=CurTime()>self:GetNextPrimaryFire();
if canholster then
if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
self.Owner:GetViewModel().BuildBonePositions=nil;
end
end
self.HasDetonatorDeployed=false;
if SERVER then
self.ThrowCharge=0;
end
return canholster;
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
if SERVER then
			for i,v in pairs(self.Pipebombs)do
				if IsValid(v) then
					v:Remove();
				end
			end
			self.Pipebombs={}
end

end


function SWEP:PrimaryAttack()
    self:StupidSPFix("PrimaryAttack")
	if self.HasDetonatorDeployed then
		self:SendWeaponAH(self.ACT_VM_DETONATOR_ACTIVATE)
		
		
		
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	else
    self:SendWeaponAH(self.ACT_VM_PRE_THROW)
    self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
    self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:ThrowPipebomb()
	if CLIENT then return end
    local    vecEye = self.Owner:EyePos();
    local    vForward, vRight;
    vForward = self.Owner:GetForward();
    vRight = self.Owner:GetRight();
	vUp =self.Owner:GetUp();
    local vecSrc = vecEye + vForward * 18.0 + vRight * 8 + vUp*-5;
    vecSrc = self:CheckThrowPosition( self.Owner, vecEye, vecSrc );
    local vecThrow;
    vecThrow = self.Owner:GetVelocity();
    local angPipe=self.Owner:EyeAngles();
    local throwspeeddamnit=Lerp(self.ThrowCharge/10,400,900)
	vecThrow = vecThrow + vForward * throwspeeddamnit;
    local Pipebomb = ents.Create("dukenukempipebomb");
    if !Pipebomb || !IsValid(Pipebomb) then return end
    Pipebomb:SetPos( vecSrc );
    Pipebomb:SetAngles( angPipe );
    Pipebomb:SetOwner( self.Owner );
    Pipebomb:Spawn()
    Pipebomb:Activate()
    Pipebomb:GetPhysicsObject():SetVelocity( vecThrow );
	Pipebomb:GetPhysicsObject():AddAngleVelocity( Angle(0,1000,0) );
	table.insert(self.Pipebombs,Pipebomb)
	self.ThrowCharge=0;
end

function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )

    local tr;

    tr = {}
    tr.start = vecEye
    tr.endpos = vecSrc
    tr.mins = Vector(6,6,6)*-1
    tr.maxs = Vector(6,6,6)
    tr.mask = MASK_PLAYERSOLID
    tr.filter = pPlayer
    tr.collision = pPlayer:GetCollisionGroup()
    local trace = util.TraceHull( tr );

    if ( trace.Hit ) then
        vecSrc = tr.endpos;
    end

    return vecSrc

end

//shared!
function SWEP:HandleCustomAnimationEvent(AnimationEvent)


	if AnimationEvent == "PIPEBOMB_PRETHROW" then
		self:SendWeaponAH(self.ACT_VM_PRE_THROW_LOOP)
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	elseif AnimationEvent == "PIPEBOMB_PRETHROW_LOOP" then
		
		if SERVER then
			if self.ThrowCharge < 10 then
				self.ThrowCharge=self.ThrowCharge+0.5
			end

		end
		
		if self.Owner:KeyDown(IN_ATTACK) then
			self:SendWeaponAH(self.ACT_VM_PRE_THROW_LOOP)
			self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
			self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
			return 
		end
		
		self:SendWeaponAH(self.ACT_VM_THROW)
		self:ThrowPipebomb();
		self.Owner:DoAttackEvent()
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
		
		
	elseif AnimationEvent == "PIPEBOMB_THROW_HOLSTER" then
		self:SendWeaponAH(self.ACT_VM_DETONATOR_DRAW)
		self.HasDetonatorDeployed=true;
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	elseif AnimationEvent == "PIPEBOMB_DETONATOR_DRAWN" then
		
		self:SendWeaponAH(self.ACT_VM_DETONATOR_IDLE)
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	elseif AnimationEvent == "PIPEBOMB_DETONATOR_CLICK" then
		if CLIENT then
		//self:EmitSound("Buttons.snd34")
		end
		if SERVER then
			for i,v in pairs(self.Pipebombs)do
				if IsValid(v) then
					v:Explode();
				end
			end
			self.Pipebombs={}
		end
	elseif AnimationEvent == "PIPEBOMB_DETONATOR_CLICK_FINISHED" then
		self:SendWeaponAH(self.ACT_VM_DETONATOR_HOLSTER)
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
		self.HasDetonatorDeployed=false;
	elseif AnimationEvent == "PIPEBOMB_DETONATOR_HOLSTERED" then
		
		self:SendWeaponAH(self.ACT_VM_DEPLOY)
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	end
end




function SWEP:Think()
self:SSAnimThink();//this function will handle server side animation callbacks
if CLIENT && IsValid(self.Owner:GetViewModel())then
self.Owner:GetViewModel().Weap=self;
self.Owner:GetViewModel().BuildBonePositions=BuildBPositions
end
end

function SWEP:SSAnimThink()
if !self.CurrentAnim then return end

if CurTime()<self.AnimTime then return end
self.AnimationFrame=self:GetNextFrame();
local callback=self.CurrentAnim[self.AnimationFrame].CallBack
if callback then
self:HandleCustomAnimationEvent(callback)
end
self.AnimTime=CurTime()+(self.CurrentAnim[self.AnimationFrame].Duration or 0);
end

function SWEP:GetNextFrame()
local nextframe=self.AnimationFrame
if nextframe+1> #self.CurrentAnim then
if self.CurrentAnim.FrameLoop then
nextframe=self.CurrentAnim.FrameLoop
end
else
nextframe=nextframe+1;
end

return nextframe;
end


function SWEP:SendWeaponAH(ANIM)
if !ANIM then return end
//HAX,shouldn't the animation itself set the AnimTime on animation switching?
self.AnimTime=CurTime()+ANIM[1].Duration;
self.CurrentAnim=ANIM;
self.AnimationFrame=1;

end

function SWEP:GetAHDuration()
if !self.CurrentAnim then return end
//this is fucking ugly,i hate to do this everytime a swep needs the duration,can't i just set a variable to something like... AnimDuration?
local ahtime=0;
for i,v in pairs(self.CurrentAnim)do
if type(v)!="table" then continue; end
ahtime=ahtime+(v.Duration or 0)
end
return ahtime;
end

hook.Add("EntityTakeDamage","MultplyPipebombDamageForce",function( ent, inflictor, attacker, amount, dmginfo )
 
	if IsValid(ent) and IsValid(inflictor) && inflictor.IsPipebomb then
		if string.find(ent:GetClass(),"ragdoll")then
		dmginfo:SetDamageForce(dmginfo:GetDamageForce()*50)     
		else
		dmginfo:SetDamageForce(dmginfo:GetDamageForce()*10)     
		end

	end
 
end)

local e={}
e.RenderGroup = RENDERGROUP_TRANSLUCENT
e.Type             = "anim"
e.Base             = "base_anim"
e.PrintName        = "PipeBombv"
e.Author            = "Jvs"
e.Information        = ""
e.Category        = "Other"
e.Spawnable            = false
e.AdminSpawnable        = false
e.Detonated=false;
e.IsPipebomb=true;
function e:Initialize()
    if(SERVER)then
    self:SetModel( "models/Nirrti/Pipebomb/pipebomb.mdl" )
    self:SetMoveType( MOVETYPE_VPHYSICS );
    self:PhysicsInit( SOLID_VPHYSICS );
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
    self:PhysWake()
	end

	
end

function e:OnTakeDamage(dmgfo)
    if !self.Detonated && dmgfo:GetDamage()>1 then
        self:Explode();
    end
end
function e:Explode()
    if self.Detonated then return end
    self.Detonated=true;
	local attacker=IsValid(self:GetOwner()) and self:GetOwner() or self
    util.BlastDamage( self,attacker,self:GetPos(),260,140 );
    util.ScreenShake( self:GetPos(), 25, 150.0, 1.0, 500 );
    local speed = self:GetPhysicsObject():GetVelocity()
    local effectdata = EffectData()
    effectdata:SetScale(127)
    effectdata:SetOrigin( self:GetPos())
    effectdata:SetMagnitude(128)
	local effectstring=(self:WaterLevel()>2) and "WaterSurfaceExplosion" or "HelicopterMegaBomb"
    util.Effect( effectstring, effectdata )
	local eff=EffectData();
	eff:SetOrigin(self:GetPos())
	for i=0,7 do
		util.Effect( "pipebombgib", eff )
	end
	//"BaseExplosionEffect.Sound"
	if self:WaterLevel()<2 then self:EmitSound("dukenukem3d/pipebomb/Pexplode.wav",100,100) end

    self:Remove();
end

function e:Touch(entity)
end
function e:PhysicsCollide( data, physobj )
 
	// Play sound on bounce
	if (data.Speed > 50 && data.DeltaTime > 0.2 ) then
		
		if data.HitEntity:IsWorld() then
			self:EmitSound( "dukenukem3d/pipebomb/Pbounce.wav")
			//self:EmitSound( "physics/metal/metal_barrel_impact_hard7.wav",100,255 )
			local phob=self:GetPhysicsObject();
			phob:AddVelocity( (data.HitNormal*-1) *(data.Speed/2.3))
		end
	end
	

 
end
scripted_ents.Register(e,"dukenukempipebomb",true)

local effect={}


function effect:Init(data)
	self.NextDeath = CurTime() + 2
	local model=table.Random(RandomGibModels)
	if !model then
		model=RandomGibModels[1]
	end
	self:SetModel(model)
	self:SetPos(data:GetOrigin())
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetCollisionBounds(Vector(-50,-50,-50), Vector(50,50,50))
	self:CreateShadow()
	self:DrawShadow(true)
	self:SetModelScale(Vector(1.5,1.5,1.5))
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():SetVelocity(Vector(0, 0, 200) + VectorRand() * math.Rand(500,1000))
		self:GetPhysicsObject():AddAngleVelocity(Angle(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200)))
	end
	
end


function effect:Think()
	if !IsValid(self:GetPhysicsObject()) then
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	local diff = self.NextDeath - CurTime()
	

	return diff>0
end

function effect:Render()
self:DrawModel()
end
if CLIENT then
effects.Register(effect,"pipebombgib")
end