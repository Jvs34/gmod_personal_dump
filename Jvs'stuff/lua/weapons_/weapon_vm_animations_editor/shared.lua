if (SERVER) then
    SWEP.AutoSwitchTo        = true
    SWEP.AutoSwitchFrom        = true
end


if ( CLIENT ) then
    SWEP.DrawAmmo            = true
    SWEP.PrintName            = "VM ANIMEDITOR"
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
        local selfangle=ang-- or Angle()
        local selfpos=pos-- or Vector()
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
end
SWEP.CurrentAnim={
	[1]={
		['ValveBiped.Bip01_R_UpperArm']=Angle(35,-34,0),




	Duration=0
	},
}
--[[
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),

]]
SWEP.AnimationFrame=1;
SWEP.AnimTime=CurTime();

local function BuildBPositions(self)
    local Weap=self.Weap
    if !Weap.CurrentAnim then return end
    if !IsValid(LocalPlayer():GetActiveWeapon()) || LocalPlayer():GetActiveWeapon()!=self.Weap then return end
    local animationframe=(Weap.IsEditorOpened and Weap.CurrentAnim[Weap.EditingFrame])and Weap.EditingFrame or Weap.AnimationFrame
	
	for i,v in pairs(Weap.CurrentAnim[animationframe])do
        
        --the for cycle here will see:
        --i,the bonename,or whatever is in the [frame] primary table,something like "ValveBiped.Bip01_Shit_like_that"
        --v,the content inside the [i],so Angle(p,y,r)
        
        if type(v)=="Angle" then
            if self==LocalPlayer() then continue end
            local b = self:LookupBone(i)
            if b then
            local m = self:GetBoneMatrix(b)
                if m then
                    
                    --allright,so we need to interpolate to the next frame,so we can just use less frames and less choppy animations
                    
                    local ang=m:GetAngle();--fuuuu-,basically,this was the bug i was looking for,it was returning the original vector,not a copy of it
                                                 --and it was screwing up the animation
                    --we need to get the rotation shit of the next frame of the same viewmodel bone

                    local nextframe=Weap:GetNextFrame();
                    local nextframeangle=Weap.CurrentAnim[nextframe][i] or ang

                    --the angle table values are: p,y,r,also,don't interpolate when the editor is opened
					if !Weap.IsEditorOpened then 
						local frac=math.TimeFraction(Weap.AnimTime-Weap.CurrentAnim[animationframe].Duration,Weap.AnimTime, CurTime() )
						ang.p=Lerp(frac,ang.p,nextframeangle.p)
						ang.y=Lerp(frac,ang.y,nextframeangle.y)
						ang.r=Lerp(frac,ang.r,nextframeangle.r)
                    end
                    m:SetAngle(ang)
                    self:SetBoneMatrix(b,m)
                end
            end
        end
        
    end
    Weap.DontDrawCSM=(Weap.CurrentAnim[Weap.AnimationFrame].DontDrawCSM) and true or false
end

    

SWEP.Category                = "Half Life 2" 
SWEP.Slot                    = 4
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true
 
SWEP.ViewModel            = "models/weapons/v_hands.mdl"
SWEP.WorldModel            ="models/props_c17/canister01a.mdl"
SWEP.DontDrawCSM=false;
SWEP.WeaponModel={
    Model="models/props_c17/canister01a.mdl",
    Bone="ValveBiped.Bip01_R_Hand",
	OffsetVector=Vector(3.9990000724792,6.5130000114441,-7.7360000610352),
	OffsetAngle=Angle(0,0,0),

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
	
	if CLIENT then
		self:CreateCSM()
		self:CreateAnimEditor()
		self:DeployEditor()
		if (not file.IsDir("ah_animations")) then
			file.CreateDir("ah_animations")
		end
	end

	
	if IsValid(self.Owner) then
		self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
		self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
	end
end 

function SWEP:Deploy()
self:StupidSPFix("Deploy")
if CLIENT then
	self:DeployEditor()
end
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
			self:HolsterEditor()
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
	if CLIENT then
		self:HolsterEditor()
	end
    if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().BuildBonePositions=nil;
    end
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

--shared!
function SWEP:HandleCustomAnimationEvent(AnimationEvent)

end

function SWEP:Think()
    self:SSAnimThink();    --this function will handle animation callbacks
    if CLIENT && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().Weap=self;
        self.Owner:GetViewModel().BuildBonePositions=BuildBPositions
    end
end

function SWEP:SSAnimThink()
	
    if !self.CurrentAnim then return end
    if self.IsEditorOpened then return end
	
    if CurTime()<self.AnimTime then return end
    self.AnimationFrame=self:GetNextFrame();
    local callback=self.CurrentAnim[self.AnimationFrame].CallBack
    if callback then
        self:HandleCustomAnimationEvent(callback)
    end
    self.AnimTime=CurTime()+self.CurrentAnim[self.AnimationFrame].Duration;
end

function SWEP:GetNextFrame()
	if self.IsEditorOpened then return self.EditingFrame end
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
    --HAX,shouldn't the animation itself set the AnimTime on animation switching?
    self.AnimTime=CurTime()+ANIM[1].Duration;
    self.CurrentAnim=ANIM;
    self.AnimationFrame=1;

end

function SWEP:GetAHDuration()
    if !self.CurrentAnim then return end
    --this is fucking ugly,i hate to do this everytime a swep needs the duration,can't i just set a variable to something like... AnimDuration?
    local ahtime=0;
    for i,v in pairs(self.CurrentAnim)do
        if type(v)!="table" || !v.Duration then continue; end
        ahtime=ahtime+v.Duration
    end
    return ahtime;
end

SWEP.AnimEditorElements={}
SWEP.EditingFrame=1;
SWEP.IsEditorOpened=false;
SWEP.EditingBone=1

function SWEP:HolsterEditor()
local tb=self.AnimEditorElements
	tb.MainFrame:SetVisible(false)
	self.IsEditorOpened=false;
end

function SWEP:DeployEditor()
local tb=self.AnimEditorElements
	tb.MainFrame:SetVisible(true)
	self.IsEditorOpened=true;
end

function SWEP:PrintFrame()
	local stringtoreturn="";
	for indx,frame in pairs(self.CurrentAnim) do
		for i,angl in pairs(frame) do
			if type(angl)=="Angle" then
				//if math.Round(angl.p) == 0 and math.Round(angl.y)==0 and math.Round(angl.r)==0 then continue end
				print("['"..i.."']".."=Angle("..angl.p..","..angl.y..","..angl.r.."),")
			end
		end
	end
end

function SWEP:PrintOffsetsInfo()
	local stringtoreturn="";
	print("OffsetVector=Vector("..self.WeaponModel.OffsetVector.x..","..self.WeaponModel.OffsetVector.y..","..self.WeaponModel.OffsetVector.z..")")
	print("OffsetAngle=Angle("..self.WeaponModel.OffsetAngle.p..","..self.WeaponModel.OffsetAngle.y..","..self.WeaponModel.OffsetAngle.r..")")
    
end

function SWEP:CreateAnimEditor()
	local tb=self.AnimEditorElements
	tb.MainFrame=vgui.Create( "DFrame")
	tb.MainFrame:SetPos( 25, 50 )
	tb.MainFrame:SetSize( 350, 500 )
	tb.MainFrame:SetTitle( "Viewmodels Animation Editor" )
	tb.MainFrame:SetVisible(false)
	tb.MainFrame:SetScreenLock(true)
	tb.MainFrame:ShowCloseButton(false)
	
	tb.BonesLists = vgui.Create("DListView")
	tb.BonesLists:SetParent(tb.MainFrame)
	tb.BonesLists:SetPos(5,25)
	tb.BonesLists:SetSize(130,tb.MainFrame:GetTall()-30)
	tb.BonesLists:SetMultiSelect(false)
	tb.BonesLists:AddColumn("Bones") -- Add column
	
	tb.printbutton = vgui.Create( "DButton")
	tb.printbutton:SetParent(tb.MainFrame)
	tb.printbutton:SetSize( 100, 20 )
	tb.printbutton:SetPos( 140,25)
	tb.printbutton:SetText( "Print frame" )
	function tb.printbutton:DoClick ()
		LocalPlayer():GetActiveWeapon():PrintFrame()
	end
	
	tb.printbutton = vgui.Create( "DButton")
	tb.printbutton:SetParent(tb.MainFrame)
	tb.printbutton:SetSize( 100, 20 )
	tb.printbutton:SetPos( 240,25)
	tb.printbutton:SetText( "Print weapon" )
	function tb.printbutton:DoClick ()
		LocalPlayer():GetActiveWeapon():PrintOffsetsInfo()
	end
	
	tb.anglepslider = vgui.Create( "DNumSlider")
	tb.anglepslider:SetParent(tb.MainFrame)
	tb.anglepslider:SetPos( 140,50 )
	tb.anglepslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.anglepslider:SetText( "Bone Angle Pitch" )
	tb.anglepslider:SetMin( -180 ) 
	tb.anglepslider:SetMax( 180 )
	tb.anglepslider:SetDecimals( 0 )
	
	tb.angleyslider = vgui.Create( "DNumSlider")
	tb.angleyslider:SetParent(tb.MainFrame)
	tb.angleyslider:SetPos( 140,100 )
	tb.angleyslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.angleyslider:SetText( "Bone Angle Yaw" )
	tb.angleyslider:SetMin( -180 ) 
	tb.angleyslider:SetMax( 180 )
	tb.angleyslider:SetDecimals( 0 )
	
	tb.anglerslider = vgui.Create( "DNumSlider")
	tb.anglerslider:SetParent(tb.MainFrame)
	tb.anglerslider:SetPos( 140,150 )
	tb.anglerslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.anglerslider:SetText( "Bone Angle Rotation" )
	tb.anglerslider:SetMin( -180 ) 
	tb.anglerslider:SetMax( 180 )
	tb.anglerslider:SetDecimals( 0 )
	
	tb.renderposxslider = vgui.Create( "DNumSlider")
	tb.renderposxslider:SetParent(tb.MainFrame)
	tb.renderposxslider:SetPos( 140,200 )
	tb.renderposxslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.renderposxslider:SetText( "Weapon X Offset" )
	tb.renderposxslider:SetMin( -40 ) 
	tb.renderposxslider:SetMax( 40 )
	tb.renderposxslider:SetDecimals( 3 )
	tb.renderposxslider:SetValue(self.WeaponModel.OffsetVector.x)
	
	tb.renderposyslider = vgui.Create( "DNumSlider")
	tb.renderposyslider:SetParent(tb.MainFrame)
	tb.renderposyslider:SetPos( 140,250 )
	tb.renderposyslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.renderposyslider:SetText( "Weapon Y Offset" )
	tb.renderposyslider:SetMin( -40 ) 
	tb.renderposyslider:SetMax( 40 )
	tb.renderposyslider:SetDecimals( 3 )
	tb.renderposyslider:SetValue(self.WeaponModel.OffsetVector.y)
	
	tb.renderposzslider = vgui.Create( "DNumSlider")
	tb.renderposzslider:SetParent(tb.MainFrame)
	tb.renderposzslider:SetPos( 140,300 )
	tb.renderposzslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.renderposzslider:SetText( "Weapon Z Offset" )
	tb.renderposzslider:SetMin( -40 ) 
	tb.renderposzslider:SetMax( 40 )
	tb.renderposzslider:SetDecimals( 3 )
	tb.renderposzslider:SetValue(self.WeaponModel.OffsetVector.z)
	
	tb.weaponanglepslider = vgui.Create( "DNumSlider")
	tb.weaponanglepslider:SetParent(tb.MainFrame)
	tb.weaponanglepslider:SetPos( 140,350 )
	tb.weaponanglepslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.weaponanglepslider:SetText( "Weapon Angle Pitch" )
	tb.weaponanglepslider:SetMin( -180 ) 
	tb.weaponanglepslider:SetMax( 180 )
	tb.weaponanglepslider:SetDecimals( 0 )
	tb.weaponanglepslider:SetValue(self.WeaponModel.OffsetAngle.p)
	
	tb.weaponangleyslider = vgui.Create( "DNumSlider")
	tb.weaponangleyslider:SetParent(tb.MainFrame)
	tb.weaponangleyslider:SetPos( 140,400 )
	tb.weaponangleyslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.weaponangleyslider:SetText( "Weapon Angle Yaw" )
	tb.weaponangleyslider:SetMin( -180 ) 
	tb.weaponangleyslider:SetMax( 180 )
	tb.weaponangleyslider:SetDecimals( 0 )
	tb.weaponangleyslider:SetValue(self.WeaponModel.OffsetAngle.y)
	
	tb.weaponanglerslider = vgui.Create( "DNumSlider")
	tb.weaponanglerslider:SetParent(tb.MainFrame)
	tb.weaponanglerslider:SetPos( 140,450 )
	tb.weaponanglerslider:SetWide( tb.MainFrame:GetWide()-tb.BonesLists:GetWide()-25)
	tb.weaponanglerslider:SetText( "Weapon Angle Rotation" )
	tb.weaponanglerslider:SetMin( -180 ) 
	tb.weaponanglerslider:SetMax( 180 )
	tb.weaponanglerslider:SetDecimals( 0 )
	tb.weaponanglerslider:SetValue(self.WeaponModel.OffsetAngle.r)
	
	if !IsValid(LocalPlayer():GetViewModel())then return end
	local str="";
	local line
	for i=0,LocalPlayer():GetViewModel():GetBoneCount()-1 do
		str=LocalPlayer():GetViewModel():GetBoneName(i)
		str=str:gsub( "ValveBiped.Bip01", "" )
		if str=="" then continue end
		line=tb.BonesLists:AddLine(str)
		line.Bone=LocalPlayer():GetViewModel():GetBoneName(i)
		line.BoneId=i
		if !LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(i)] then
			LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(i)]=Angle(0,0,0)
		end
	end
	
	function tb.BonesLists:OnRowSelected(line)
		RunConsoleCommand("Say" , tb.BonesLists:GetLine(line).Bone)
			--Save the value of the sliders here
			--and set new ones
		if LocalPlayer():GetActiveWeapon().EditingBone !=tb.BonesLists:GetLine(line).BoneId then
			LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(LocalPlayer():GetActiveWeapon().EditingBone)].p=tb.anglepslider:GetValue()
			LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(LocalPlayer():GetActiveWeapon().EditingBone)].y=tb.angleyslider:GetValue()
			LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(LocalPlayer():GetActiveWeapon().EditingBone)].r=tb.anglerslider:GetValue()
			
			LocalPlayer():GetActiveWeapon().EditingBone=tb.BonesLists:GetLine(line).BoneId
			tb.anglepslider:SetValue(LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][tb.BonesLists:GetLine(line).Bone].p)
			tb.angleyslider:SetValue(LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][tb.BonesLists:GetLine(line).Bone].y)
			tb.anglerslider:SetValue(LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][tb.BonesLists:GetLine(line).Bone].r)
		end
	end
	
	function tb.anglepslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(LocalPlayer():GetActiveWeapon().EditingBone)].p=value
	end   
	function tb.angleyslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(LocalPlayer():GetActiveWeapon().EditingBone)].y=value
	end 	
	function tb.anglerslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().CurrentAnim[LocalPlayer():GetActiveWeapon().EditingFrame][LocalPlayer():GetViewModel():GetBoneName(LocalPlayer():GetActiveWeapon().EditingBone)].r=value
	end
	
	function tb.renderposxslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().WeaponModel.OffsetVector.x=value
	end   
	function tb.renderposyslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().WeaponModel.OffsetVector.y=value
	end 	
	function tb.renderposzslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().WeaponModel.OffsetVector.z=value
	end
	
	function tb.weaponanglepslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().WeaponModel.OffsetAngle.p=value
	end   
	function tb.weaponangleyslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().WeaponModel.OffsetAngle.y=value
	end 	
	function tb.weaponanglerslider:OnValueChanged(value)
		LocalPlayer():GetActiveWeapon().WeaponModel.OffsetAngle.r=value
	end
end