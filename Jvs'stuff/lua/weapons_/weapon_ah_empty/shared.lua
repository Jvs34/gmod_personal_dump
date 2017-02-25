SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.DrawAmmo            = true
SWEP.PrintName            = "Base Animation Hands"
SWEP.Author                = "Jvs"
SWEP.DrawCrosshair        = true
SWEP.ViewModelFOV        = 54
    SWEP.RenderGroup = RENDERGROUP_BOTH
    SWEP.CSM=nil;

    function SWEP:DrawHUD()
    end
    
    function SWEP:ViewModelDrawn()
        self:DrawClientSideWeapon();
    end
    
    function SWEP:CreateCSM()
        if self.WeaponModel.Useless then return end
        if !self.CSM || !IsValid(self.CSM)then
            self.CSM = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
            self.CSM:SetNoDraw( true )
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

        local hand = self:GetOwner():GetAttachment( self.m_hHands );
        if !hand then return end
        local offset = hand.Ang:Right() * self.HoldPos.x + hand.Ang:Forward() * self.HoldPos.y + hand.Ang:Up() * self.HoldPos.z;

        hand.Ang:RotateAroundAxis( hand.Ang:Right(),    self.HoldAng.x );
        hand.Ang:RotateAroundAxis( hand.Ang:Forward(),    self.HoldAng.y );
        hand.Ang:RotateAroundAxis( hand.Ang:Up(),        self.HoldAng.z );

        self.CSM:SetRenderOrigin( hand.Pos + offset )
        self.CSM:SetRenderAngles( hand.Ang )
        
        self.CSM:DrawModel();
    end
    
    
    function SWEP:DrawWorldModelTranslucent()
        self:DrawWorldModel()
    end
    
    function SWEP:DrawClientSideWeapon()
        if !self.CSM || !IsValid(self.CSM) || self.DontDrawCSM then return end
        local vm = self.Owner:GetViewModel()
        local matrix = vm:GetBoneMatrix(vm:LookupBone(self.WeaponModel.Bone))
        local pos = matrix:GetTranslation()
        local ang = matrix:GetAngle()
        self.CSM:SetRenderOrigin(self:CalculateOffset(pos,ang,self.WeaponModel.OffsetVector))
        ang:RotateAroundAxis(ang:Forward(),self.WeaponModel.OffsetAngle.y)
        ang:RotateAroundAxis(ang:Up(),self.WeaponModel.OffsetAngle.p)
        ang:RotateAroundAxis(ang:Right(),self.WeaponModel.OffsetAngle.r)
        self.CSM:SetRenderAngles(ang)
        if !self.WeaponModel.Useless then
            self.CSM:DrawModel();
        end
    end

SWEP.CurrentAnim=nil;

SWEP.ACT_VM_DEPLOY={
    [1]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.7
    },
    [2]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.3,
        CallBack="ANIMATION_FINISHED"
    },
}

SWEP.AnimationFrame=1;
SWEP.AnimTime=CurTime();

local function GetNextFrame(self)
    /*what i need to do here is:
    increase animationframe
    check if animationframe is > #CurrentAnim then
        check if the currentanim got a FrameLoop
            set the animationframe to that frameloop
        otherwise set the animationframe to the end of the animation
    
    */
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
        
        //the for cycle here will see:
        //i,the bonename,or whatever is in the [frame] primary table,something like "ValveBiped.Bip01_Shit_like_that"
        //v,the content inside the [i],so Angle(p,y,r)
        
        if type(v)=="Angle" then
            if self==LocalPlayer() && string.find(string.lower(i),"r_upper") then continue end
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

                    //if nextframeangle then
                        local frac=math.TimeFraction(Weap.AnimTime-Weap.CurrentAnim[Weap.AnimationFrame].Duration,Weap.AnimTime, CurTime() )
                        ang.p=Lerp(frac,v.p,nextframeangle.p)
                        ang.y=Lerp(frac,v.y,nextframeangle.y)
                        ang.r=Lerp(frac,v.r,nextframeangle.r)
                    //end
                    
                    m:Rotate(ang)
                    self:SetBoneMatrix(b,m)
                end
            end
        end
        
    end
    Weap.DontDrawCSM=(Weap.CurrentAnim[Weap.AnimationFrame].DontDrawCSM) and true or false
    //AdvanceFrame(self);
end

    

SWEP.Category                = "Half Life 2" 
SWEP.Slot                    = 4
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true
 
SWEP.ViewModel            = "models/weapons/v_animhands.mdl"
SWEP.WorldModel            ="models/props_junk/PopCan01a.mdl"
SWEP.DontDrawCSM=false;
SWEP.WeaponModel={
    Model="models/props_junk/PopCan01a.mdl",
    Bone="ValveBiped.Bip01_R_Hand",
    OffsetVector=Vector(2,4,0),
    OffsetAngle=Angle(90,180,00),
    Skin=0,
}


SWEP.HoldPos=Vector(0,0,0)
SWEP.HoldAng=Vector(0,0,0)

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = false
SWEP.Primary.Automatic        = true


SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

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
end


function SWEP:Deploy()
self:SendWeaponAH(self.ACT_VM_DEPLOY)
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
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

//shared!
function SWEP:HandleCustomAnimationEvent(AnimationEvent)

end



function SWEP:Think()
    self:SSAnimThink();    //this function will handle server side animation callbacks
    if CLIENT && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().Weap=self;
        self.Owner:GetViewModel().BuildBonePositions=BuildBPositions
        /*
        self.Owner.Weap=self;
        self.Owner.BuildBonePositions=BuildBPositions
        */
    end
end

function SWEP:SSAnimThink()
    if !self.CurrentAnim then return end
    if self.Owner:InVehicle() then return end
    if CurTime()<self.AnimTime then return end
    self.AnimationFrame=self:GetNextFrame();
    local callback=self.CurrentAnim[self.AnimationFrame].CallBack
    if callback then
        self:HandleCustomAnimationEvent(callback)
    end
    self.AnimTime=CurTime()+self.CurrentAnim[self.AnimationFrame].Duration;
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
        ahtime=ahtime+v.Duration
    end
    return ahtime;
end

 
 