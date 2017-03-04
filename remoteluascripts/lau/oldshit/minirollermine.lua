local SWEP={}
SWEP.Base="weapon_base"
SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.DrawAmmo            = true
SWEP.PrintName            = "Mini Rollermine"
SWEP.Author                = "Jvs"
SWEP.DrawCrosshair        = true
SWEP.ViewModelFOV        = 54
SWEP.Spawnable                 = false
SWEP.AdminSpawnable          = true
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.CSM=nil;

    
function SWEP:ViewModelDrawn()
        self:DrawClientSideWeapon();
end
    
function SWEP:CreateCSM()
	if self.WeaponModel.Useless then return end
	if !self.CSM || !IsValid(self.CSM)then
            self.CSM = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
            self.CSM:SetNoDraw( true )
			if self.WeaponModel.Scale then
			self.CSM:SetModelScale(self.WeaponModel.Scale)
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
            self.CSM:SetRenderOrigin( self:GetPos() )
			self.CSM:SetRenderAngles( self:GetAngles() )
			self.CSM:DrawModel();
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



local function BuildBHeliPositions(self)
    local Weap=self.Weap
    if !IsValid(LocalPlayer():GetActiveWeapon()) || LocalPlayer():GetActiveWeapon()!=self.Weap then return end
	local bonename="ValveBiped.cube3"
	local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	if !bm then return end
	bm:Scale( Vector(0.009, 0.009, 0.009) ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
	
end

    

SWEP.Category                = "Half Life 2" 
SWEP.Slot                    = 4
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true
 
SWEP.ViewModel            = "models/weapons/v_bugbait.mdl"
SWEP.WorldModel            ="models/hunter/misc/sphere025x025.mdl"
SWEP.DontDrawCSM=false;
SWEP.WeaponModel={
    Model="models/Roller.mdl",
    Bone="ValveBiped.cube3",
	OffsetVector=Vector(0.60600000619888,0.079000003635883,-0.10800000280142),
	OffsetAngle=Angle(17,75,-180),

	Scale=Vector(1,1,1)/5,
    Skin=0,
}


SWEP.HoldPos=Vector(-0.5,0.5,1)
SWEP.HoldAng=Vector(0,0,0)
SWEP.Primary={}
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = false
SWEP.Primary.Automatic        = true

SWEP.Secondary={}
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
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
    if SERVER && game.SinglePlayer() then
    self:CallOnClient(FunctName,"")
    end
end



function SWEP:Holster()
    if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().BuildBonePositions=nil;
    end
	self.CanAttack=CurTime();
	self.Pullback=false;
	self.Redraw=false;
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
	if self.Pullback || self.Redraw || self.CanAttack > CurTime() then return end
	if IsFirstTimePredicted( ) then
		self:SendWeaponAnim(ACT_VM_HAULBACK)
	end
	if !IsFirstTimePredicted() then
		return
	end
	self.Pullback=true;
	self.CanAttack=CurTime()+self:SequenceDuration()+0.2;
end
--self:SendWeaponAnim(ACT_VM_THROW)
function SWEP:SecondaryAttack()end

function SWEP:Think()
	if CLIENT && IsValid(self.Owner:GetViewModel())then
		self.Owner:GetViewModel().Weap=self;
		self.Owner:GetViewModel().BuildBonePositions=BuildBHeliPositions
	end
	
	if self.Pullback && !self.Owner:KeyDown(IN_ATTACK) && self.CanAttack < CurTime() then
		self.Owner:DoAttackEvent()
		if IsFirstTimePredicted( ) then
			self:SendWeaponAnim(ACT_VM_THROW)
		end
		self:ThrowHelibomb()
		self.Pullback=false;
		self.CanAttack=CurTime()+self:SequenceDuration()+0.5;
		self.Redraw=true;
	end
	
	if self.Redraw && !self.Pullback && self.CanAttack < CurTime() then
		if IsFirstTimePredicted( ) then
			self:SendWeaponAnim(ACT_VM_DRAW)
		end
		self.CanAttack=CurTime()+self:SequenceDuration()+0.5;
		self.Redraw=false;
	end
	

end


function SWEP:ThrowHelibomb()
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
    local throwspeeddamnit=900
	vecThrow = vecThrow + vForward * throwspeeddamnit;
    local Helibomb = ents.Create("minirollermine");
    if !Helibomb || !IsValid(Helibomb) then return end
    Helibomb:SetPos( vecSrc );
    Helibomb:SetAngles( angPipe );
    Helibomb:SetOwner( self.Owner );
    Helibomb:Spawn()
    Helibomb:Activate()
    Helibomb:GetPhysicsObject():SetVelocity( vecThrow );
	Helibomb:GetPhysicsObject():AddAngleVelocity( Angle(0,1000,0) );
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



local e={}
e.RenderGroup = RENDERGROUP_TRANSLUCENT
e.Type             = "anim"
e.Base             = "base_anim"
e.PrintName        = "MiniRollermine"
e.Author            = "Jvs"
e.Information        = ""
e.Category        = "Other"
e.Spawnable            = false
e.AdminSpawnable        = false
e.Detonated=false;
e.BOMB_LIFETIME=4
e.LifeTime=nil;
e.Scale=2.6
e.Jumped=false;
function e:Initialize()
    if(SERVER)then
    self:SetModel( "models/Roller_Spikes.mdl" )
	self.Entity:PhysicsInitSphere(self.Scale,"metal")
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
    self:PhysWake()

	
	// Set collision bounds exactly
	self.Entity:SetCollisionBounds( Vector( -self.Scale, -self.Scale, -self.Scale ), Vector(self.Scale, self.Scale,self.Scale) )
	else
		self:SetModelScale(Vector(1,1,1)/5)
		self.RollSound = CreateSound( self, "npc/roller/mine/rmine_movefast_loop1.wav" )
		self.RollSound:PlayEx(1, 100)
		self:EmitSound("npc/roller/mine/rmine_blades_in"..math.random(1,3)..".wav",100,math.random(110,120))
		self:EmitSound("npc/roller/mine/rmine_taunt1.wav",100,math.random(110,120))
		
	end
	self.LifeTime=CurTime()+self.BOMB_LIFETIME;
	
end

function e:Draw()
    self:DrawModel();
end

function e:Think()
	if CLIENT then
		local volume=math.Clamp(self:GetVelocity():Length()/100,0.1,0.7)
		local pitch=math.Clamp( self:GetVelocity():Length() / 50, 0 , 1); --math.Clamp(self:GetVelocity():Length()/50,100,130)
		self.RollSound:ChangeVolume(volume);
		self.RollSound:ChangePitch(pitch*90);
		
	end
	
    if self.LifeTime < CurTime() && !self.Jumped then
		self:Jump(true)
		
    end
	
	if self.LifeTime < CurTime() && self.Jumped &&!self.Detonated then
        self:Detonate(true);
    end
	
	self:NextThink( CurTime())
    return true
end

function e:Jump(fromthink)
        if SERVER then
			self:GetPhysicsObject():AddVelocity(Vector(0,0,300))
		end
		if (fromthink and CLIENT) or SERVER then
			self:EmitSound("npc/roller/mine/rmine_predetonate.wav",150,math.random(110,120))
		end
		self.Jumped=true;
		self.LifeTime=CurTime()+0.5
end

function e:PhysicsCollide( data,physobj )
	local ent=data.HitEntity
	if IsValid(ent) && (ent:IsPlayer() || ent:IsNPC()) && !self.Jumped && !self.Detonated then
		self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav",100,math.random(110,120))
		if SERVER then
			self:GetPhysicsObject():SetVelocity((data.HitNormal*-1)*500)
			
			local dmginfo=DamageInfo();
			dmginfo:SetAttacker(self:GetOwner() or self)
			dmginfo:SetDamageForce(data.OurOldVelocity)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(15)
			dmginfo:SetDamageType(DMG_SHOCK)
			ent:TakeDamageInfo(dmginfo)
		end
		self.LifeTime=CurTime()+0.3
	end
end

function e:OnTakeDamage(dmgfo)
	if !self.Detonated && !self.Jumped then
		self:Jump()
	end
end

function e:OnRemove()
	if CLIENT then
		self.RollSound:Stop()
	end
end

function e:Detonate(fromthink)
    if self.Detonated then return end
    self.Detonated=true;
	local attacker=IsValid(self:GetOwner()) and self:GetOwner() or self
    --util.BlastDamage( self,attacker,self:GetPos(),150,10 );
    if (fromthink and CLIENT) or SERVER then
		util.ScreenShake( self:GetPos(), 25, 150.0, 1.0, 350 );
		local effectdata = EffectData()
		effectdata:SetScale(128)
		effectdata:SetOrigin( self:GetPos())
		effectdata:SetMagnitude(128)
		local effectstring=(self:WaterLevel()>2) and "WaterSurfaceExplosion" or "HelicopterMegaBomb"
		util.Effect( effectstring, effectdata )
		if self:WaterLevel()<1 then self:EmitSound("BaseExplosionEffect.Sound") end
	end
	if SERVER then
		self:Remove();
	end
end

function e:Spark(entity)

end

function e:Touch(entity)
	self:Spark(entity)
end
scripted_ents.Register(e,"minirollermine",true)
weapons.Register(SWEP,"weapon_mini_rollermine",true)
 
 