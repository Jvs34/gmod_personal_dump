--[[
	Zero point energy physics manipulator
	This is a revamped gravity gun,and it will probably look like a normal one.
	It will have custom sounds for the holding idle.
	It can be powered up to the super gravity gun state,it will do more damage and will pick up ragdolls.
	Pressing R when you got a prop picked up will allow you to use a physgun like beam and with PRIMARYFIRE you will extend the beam,and with SECONDARYFIRE you
	will retract it,when you press again R it will drop the entity.

]]
SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.DrawAmmo            = true
SWEP.PrintName            = "Zero Point Energy Physgun"
SWEP.Author                = "Jvs"
SWEP.DrawCrosshair        = true
SWEP.ViewModelFOV        = 54
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.Category                = "Half Life 2" 
SWEP.Slot                    = 0
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true
SWEP.TraceLength	=250;
SWEP.MaxMass=250;
SWEP.ViewModel            = "models/weapons/v_physcannon.mdl"
SWEP.WorldModel            ="models/weapons/w_physics.mdl"

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = false
SWEP.Primary.Automatic        = true

SWEP.Damage=5;
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = true
local OBJECT_FOUND=1;
local OBJECT_NOT_FOUND=2;
local OBJECT_BEING_DETACHED=3;
local DEFAULT_MAX_ANGULAR = 360.0 * 10.0;
local REDUCED_CARRY_MASS = 1.0;
local MASS_SPEED_SCALE	=60
local MAX_MASS			=40
// when looking level, hold bottom of object 8 inches below eye level
local PLAYER_HOLD_LEVEL_EYES=-8

// when looking down, hold bottom of object 0 inches from feet
local PLAYER_HOLD_DOWN_FEET=2

// when looking up, hold bottom of object 24 inches above eye level
local PLAYER_HOLD_UP_EYES=24

// use a +/-30 degree range for the entire range of motion of pitch
local PLAYER_LOOK_PITCH_RANGE=30

// player can reach down 2ft below his feet (otherwise he'll hold the object above the bottom)
local PLAYER_REACH_DOWN_DISTANCE=24

if CLIENT then
    local PHYSCANNON_BEAM_SPRITE
    local PHYSCANNON_CENTER_GLOW
    local MEGACANNON_BEAM_SPRITE
    local MEGACANNON_CENTER_GLOW
    local MEGACANNON_UPGRADE_MUZZLE
    //Credits to Andrew Mc Watters for his drawweaponselection from his swep_bases
    // Override this in your SWEP to set the icon in the weapon selection
    SWEP.WepSelectFont            = "TitleFont2"
    SWEP.WepSelectLetter        = "m"

    /*---------------------------------------------------------
        Checks the objects before any action is taken
        This is to make sure that the entities haven't been removed
    ---------------------------------------------------------*/
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

        // Set us up the texture
        surface.SetDrawColor( color_transparent )
        if(self.dt.SuperCharged)then
        surface.SetTextColor( 0, 12, 255, alpha )
        else
        surface.SetTextColor( 255, 220, 0, alpha )
        end
        surface.SetFont( self.WepSelectFont )
        local w, h = surface.GetTextSize( self.WepSelectLetter )

        // Draw that mother
        surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
                            y + ( tall / 2 ) - ( h / 2 ) )
        surface.DrawText( self.WepSelectLetter )

        
    end
    
    PHYSCANNON_BEAM_SPRITE=CreateMaterial("sprites/orangelightnew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/orangelight1",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    PHYSCANNON_CENTER_GLOW =CreateMaterial("sprites/orangecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/orangecore1",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    
    MEGACANNON_BEAM_SPRITE =CreateMaterial("sprites/physcannon_bluelightnew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/lgtning",//"sprites/physcannon_bluelight1b",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    
    MEGACANNON_CENTER_GLOW =CreateMaterial("sprites/physcannon_bluecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/physcannon_bluecore1b",//"effects/fluttercore"
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    
    MEGACANNON_UPGRADE_MUZZLE=CreateMaterial("effects/strider_muzzlenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "effects/strider_muzzle",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
        }
    )        
local EFFECT={}
EFFECT.Mat = PHYSCANNON_BEAM_SPRITE
EFFECT.MegaMat=MEGACANNON_BEAM_SPRITE
EFFECT.DieT=0.1

function EFFECT:Init( data )
self.IsSuperPuntEffect=(data:GetScale()==1) and true or false;
self.EndPos     = data:GetOrigin()
self.Ent =    data:GetEntity();
if(!IsValid(self.Ent))then return end
self.Entity:SetRenderBoundsWS( self.Ent:GetAttachment( 1).Pos, self.EndPos )
self.DieTime = CurTime() + self.DieT
local effectdata = EffectData()
effectdata:SetOrigin( self.EndPos )
effectdata:SetMagnitude( 1 )
effectdata:SetScale( 1 )
effectdata:SetRadius( 1 )
util.Effect( "Sparks", effectdata )

local emitter = ParticleEmitter(self.EndPos )
local particle = emitter:Add( (self.IsSuperPuntEffect==true) and "effects/blueflare1.vtf" or "effects/yellowflare.vtf",self.EndPos)
particle:SetVelocity(Vector(0,0,0))
particle:SetLifeTime(0)
particle:SetDieTime(self.DieT)
particle:SetStartAlpha(255)
particle:SetEndAlpha(255)
particle:SetStartSize(math.random( 24, 32 ))
particle:SetEndSize(0)
particle:SetRoll( math.random( 0, 360 ))
particle:SetRollDelta( 0.0 )
particle:SetColor( 255, 255, 255 )
particle:VelocityDecay( false )        
emitter:Finish()    
self.Size=16
if(self.Ent:IsWeapon())then self.Size=8 end
end

function EFFECT:Think( )
        if ( CurTime() > self.DieTime && IsValid(self.Ent) ) then return false end
        return true
end
function EFFECT:Render( )
if(!IsValid(self.Ent))then return end
render.SetMaterial( (self.IsSuperPuntEffect==true) and self.MegaMat or self.Mat )
if !self.Ent:GetAttachment( 1) then return end
render.DrawBeam( self.Ent:GetAttachment( 1).Pos,self.EndPos,self.Size,1,0,Color( 255, 255, 255, 255 ) )
end
effects.Register(EFFECT,"zep_punteffect")
 
end

local ZP_PHYSGUN_MODE=true;
local ZP_PHYSCANNON_MODE=false;

local function VectorMA2(start,scale,direction)
    local dest=Vector();
    dest.x = start.x + scale * direction.x;
    dest.y = start.y + scale * direction.y;
    dest.z = start.z + scale * direction.z;
    return dest;
end

local function SimpleSpline( value )
	local valueSquared = value * value;

	// Nice little ease-in, ease-out spline-like curve
	return (3 * valueSquared - 2 * valueSquared * value);
end

// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
local function SimpleSplineRemapVal( val,A, B,C,D)
	if ( A == B ) then
		return val >= B and D or C;
	end
	local cVal = (val - A) / (B - A);
	return C + (D - C) * SimpleSpline( cVal );
end



function SWEP:Initialize()
	self:SetWeaponHoldType("physgun")
    if IsValid(self.Owner) then
        self:Deploy()
    end
	if SERVER then
		self:CreateShadowController();
		self:CreateEffectsController();
	else
	
	end
end

function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "Mode")
	self:DTVar("Entity", 0, "HoldEntity")
end

function SWEP:IsActive()
	return IsValid(self.dt.HoldEntity)
end

function SWEP:CreateShadowController()
	self:RemoveShadowController()
	self.ShadowController=ents.Create("zep_controller")
	if !IsValid(self.ShadowController) then return end
	self.ShadowController:Setup(self)
	--self.ShadowController:SetPos(self:GetPos())
	self.ShadowController:Spawn()
	--self.ShadowController:SetParent(self)
	
	--there's no need to set the position of the controller,it has no physics,and traces will be fired from the player's shoot pos
end

function SWEP:CreateEffectsController()
	self:RemoveEffectsController()
	self.EffectsController=ents.Create("zee_controller")
	if !IsValid(self.EffectsController) then return end
	self.EffectsController:Setup(self)
	self.EffectsController:SetPos(self:GetPos())
	self.EffectsController:Spawn()
	self.EffectsController:SetParent(self)
end

function SWEP:RemoveShadowController()
	if IsValid(self.ShadowController) then
		self.ShadowController:Remove()
	end
end

function SWEP:RemoveEffectsController()
	if IsValid(self.EffectsController) then
		self.EffectsController:Remove()
	end
end

function SWEP:DrawHUD()

end
    
function SWEP:ViewModelDrawn()
end
    
function SWEP:DrawWorldModel()	
	self:DrawModel();
end
    
    
function SWEP:DrawWorldModelTranslucent()
	self:DrawWorldModel()	
end
  





function SWEP:Deploy()
self:StupidSPFix("Deploy")
self:SendWeaponAnim(ACT_VM_DEPLOY)
self:SetNextAttackTime(self:SequenceDuration())
return true;
end

function SWEP:StupidSPFix(FunctName)
    if SERVER && SinglePlayer() then
    self:CallOnClient(FunctName,"")
    end
end



function SWEP:Holster()
	return !self:IsActive();
end

function SWEP:OnDrop()
end

function SWEP:OnRemove()
	if SERVER then
		self:RemoveShadowController()
		self:RemoveEffectsController()
	end
end

function SWEP:SetNextAttackTime(delay)
self:SetNextPrimaryFire(CurTime()+delay)
self:SetNextSecondaryFire(CurTime()+delay)
end

function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
	if !IsFirstTimePredicted() then return end
	if( self:IsActive() ) then
		local pOwner=self.Owner
		// Punch the object being held!!
		local forward;
		forward=pOwner:GetAimVector();

		// Validate the item is within punt range
		local pHeld = self.ShadowController:GetAttached();
		
		if ( IsValid(pHeld) )then
			local heldDist = ( pHeld:GetPos() - pOwner:GetPos() ):Length();

			if ( heldDist > self.TraceLength )then
				// We can't punt this yet
				self:DryFire();
				return;
			end
		end

		self:LaunchObject( forward, 1500 );

		
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
		return;
	end
	
    self:Repulse();
    self:SetNextAttackTime(0.5)
end

function SWEP:DetachObject(playSound,wasLaunched )
if SERVER then

	local pOwner = self.Owner;

	local pObject = self.ShadowController:GetAttached();

	self.ShadowController:DetachEntity( wasLaunched );

	if ( IsValid(pObject) )then
		--This is a temporary hack
		if IsValid(pObject:GetPhysicsObject()) then
			pObject:GetPhysicsObject():AddGameFlag(FVPHYSICS_WAS_THROWN)
		end
		--Pickup_OnPhysGunDrop( pObject, pOwner, wasLaunched ? LAUNCHED_BY_CANNON : DROPPED_BY_CANNON );
	end

	// Stop our looping sound
	--[[
	if ( GetMotorSound() )
	{
		(CSoundEnvelopeController::GetController()).SoundChangeVolume( GetMotorSound(), 0.0, 1.0 );
		(CSoundEnvelopeController::GetController()).SoundChangePitch( GetMotorSound(), 50, 1.0 );
	}
	]]
	
	if ( pObject && self.m_bResetOwnerEntity == true )then
		pObject:SetOwner( NULL );
	end
	self.dt.HoldEntity=NULL;

end	
	if ( playSound==true || playSound==nil )then
		//Play the detach sound
		--WeaponSound( MELEE_MISS );
		self:EmitSound("Weapon_PhysCannon.Drop")
	end

end

function SWEP:LaunchObject(vecDir,flForce )
	local pObject = self.ShadowController:GetAttached();

	// FIRE!!!
	if IsValid( pObject ) then
		self:DetachObject( false, true );
		// Launch
		self:ApplyVelocityBasedForce( pObject, vecDir );
		// Don't allow the gun to regrab a thrown object!!
		self:SetNextAttackTime(0.5);
		local	center = pObject:GetPos();
		//Do repulse effect
		self:PuntEffect(pObject:GetPos())
		self.dt.HoldEntity=NULL;
		--m_bActive = false;
	end

	// Stop our looping sound
	--[[
	if ( GetMotorSound() )
	{
		(CSoundEnvelopeController::GetController()).SoundChangeVolume( GetMotorSound(), 0.0, 1.0 );
		(CSoundEnvelopeController::GetController()).SoundChangePitch( GetMotorSound(), 50, 1.0 );
	}
	]]
	//Close the elements and suppress checking for a bit
	--m_nChangeState = ELEMENT_STATE_CLOSED;
	--m_flElementDebounce = gpGlobals->curtime + 0.1;
	--m_flCheckSuppressTime = gpGlobals->curtime + 0.25;
end

function SWEP:ApplyVelocityBasedForce(pEntity,forward )
if SERVER then
	local pPhysicsObject = pEntity:GetPhysicsObject();
	if (!pPhysicsObject)then
		return;
	end
	local flForceMax = 1500;
	local flForce = flForceMax;

	local mass = pPhysicsObject:GetMass();
	if (mass > 100)then
		mass = math.min(mass, 1000);
		local flForceMin = 700;
		flForce = SimpleSplineRemapVal(mass, 100, 600, flForceMax, flForceMin);
	end

	local vVel = forward * flForce;
	// FIXME: Josh needs to put a real value in for PHYSGUN_FORCE_PUNTED
	--local aVel =Vector(0,0,0) --Pickup_PhysGunLaunchAngularImpulse( pEntity, PHYSGUN_FORCE_PUNTED );
		
	pPhysicsObject:AddVelocity(vVel);
	--pPhysicsObject:AddAngleVelocity(aVel );
end

end

function SWEP:Repulse()
    
    local pOwner=self.Owner;
    
    local forward=pOwner:GetAimVector( );

    // NOTE: Notice we're *not* using the mega tracelength here
    // when you have the mega cannon. Punting has shorter range.
    local start, end1;
    start = pOwner:EyePos();
    local flPuntDistance = self.TraceLength;
    end1=VectorMA2( start, flPuntDistance, forward);
    //end1=forward*flPuntDistance+start
    local tracedata={};
    tracedata.start = start
    tracedata.endpos = end1
    tracedata.filter = self.Owner
    tracedata.mins = Vector(8,8,8)*-1
    tracedata.maxs = Vector(8,8,8)
     
    local tr = util.TraceHull( tracedata )
    
    local bValid = true;
    local pEntity = tr.Entity;
    if ( tr.Fraction == 1 || (!IsValid(tr.Entity)||!tr.Entity))then
        bValid = false;
    elseif ( (pEntity:GetMoveType() != MOVETYPE_VPHYSICS))then
        bValid = false;
    end

    // If the entity we've hit is invalid, try a traceline instead
    if ( !bValid )then
        tracedata = {}
        tracedata.start = start
        tracedata.endpos =end1
        tracedata.filter = self.Owner
        tr = util.TraceLine(tracedata)
        if ( tr.Fraction == 1 || !tr.Entity)then
            // Play dry-fire sequence
            self:DryFire();
            return;
        end

        pEntity = tr.Entity;
    end
    //check if the entity is not valid or if the GravGunPunt hook disallows us from hitting that entity (prop protection)
    if(!IsValid(pEntity) || !hook.Call("GravGunPunt",GAMEMODE,self.Owner,pEntity))then
        if(self.Charge)then
            if(tr.Hit && !tr.HitSky && !IsValid(pEntity))then
                self:PuntEffect(tr.HitPos);
            else
            self:DryFire();
            return;
            end
        else
            self:DryFire();
        end
    else
        pOwner:LagCompensation( true );
        if ( pEntity:GetMoveType() != MOVETYPE_VPHYSICS )then
                // Don't let the player zap any NPC's except regular antlions and headcrabs.
            self:PuntNonVPhysics( pEntity, forward, tr );
        else
            self:PuntVPhysics( pEntity, forward, tr );
        end
    end
end

function SWEP:DryFire()
    self.Owner:DoAttackEvent()
    self:EmitSound((self.dt.SuperCharged)and "Weapon_MegaPhysCannon.DryFire" or"Weapon_PhysCannon.DryFire")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:PuntNonVPhysics(pEntity, vecForward,tr)
    local pOwner = self.Owner;
	local force=1500
    if SERVER then
        local info=DamageInfo();
        
        
        info:SetAttacker( self.Owner );
        info:SetInflictor( self );
        local dmgtodo=self.Damage;
        info:SetDamage( dmgtodo);
        info:SetDamageType( DMG_CRUSH );
        info:SetDamageForce( vecForward*force*300);    // Scale?
        info:SetDamagePosition( tr.HitPos );
        pEntity:DispatchTraceAttack( info, tr.StartPos, tr.HitPos );
	end
    if pEntity:IsPlayer() then
		force=400
		pEntity:SetVelocity(vecForward * force + Vector(0,0,2) * 150)
    end
    pOwner:LagCompensation( false);
    self:PuntEffect(tr.HitPos);
end


function SWEP:PuntVPhysics(pEntity, vecForward,tr)
    
        local pOwner = self.Owner;
        local info=DamageInfo();

        local forward = vecForward;

        info:SetAttacker( self.Owner );
        info:SetInflictor( self );
        local dmgtodo=self.Damage
        info:SetDamage( dmgtodo);
        info:SetDamageType( DMG_CRUSH );
	if SERVER then
        pEntity:DispatchTraceAttack( info, tr.StartPos, tr.HitPos );
	end
		pOwner:LagCompensation( false);
        self:PuntEffect(tr.HitPos);
        if SERVER then
		pEntity:SetPhysicsAttacker(self.Owner);
		end
        local pList={};
        local listCount = pEntity:GetPhysicsObjectCount( )-1;
        
    
        pEntity:PhysWake();
        if ( !listCount || listCount<0 )then
            self:DryFire();
            return;
        end

        for i = 0,listCount do
            pList[i]=pEntity:GetPhysicsObjectNum( i)
        end

        
        if( forward.z < 0 )then
            //reflect, but flatten the trajectory out a bit so it's easier to hit standing targets
            forward.z = forward.z*-0.65;
        end
                
        // NOTE: Do this first to enable motion (if disabled) - so forces will work
        // Tell the object it's been punted
        
            // limit mass to avoid punting REALLY huge things
            local totalMass = 0;
            for i = 0,listCount do
            totalMass = pList[i]:GetMass()+totalMass;
            
            end
            local maxMass = self.MaxMass;
            if ( pEntity:IsVehicle() )then
                maxMass =maxMass* 2.5;    // 625 for vehicles
            end
            
            local mass = math.min(totalMass, maxMass); // max 250kg of additional force
            // Put some spin on the object
    if SERVER then 
		for i = 0,listCount do
                local hitObjectFactor = 0.5;
                local otherObjectFactor = 1 - hitObjectFactor;
                  // Must be light enough
                local ratio = pList[i]:GetMass() / totalMass;
                if ( pList[i] == pEntity:GetPhysicsObject( ))then
                    ratio = ratio+hitObjectFactor;
                    ratio = math.min(ratio,1);
                else
                    ratio = ratio*otherObjectFactor;
                end
                local fff=15000
                pList[i]:ApplyForceCenter( forward * fff * ratio );
                pList[i]:ApplyForceOffset( forward * mass * 600 * ratio, tr.HitPos );
            end
    end
    
    
    
    
end

function SWEP:PuntEffect(endpos)
    local pPlayer=self.Owner;
    local effectdata = EffectData()
    local view;
    if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
        local effectdata = EffectData()
        if ( view:IsPlayer() && view==self.Owner) then
			if CLIENT && self.Owner==LocalPlayer() && !LocalPlayer():ShouldDrawLocalPlayer() then
				effectdata:SetEntity(self.Owner:GetViewModel())
			else
				effectdata:SetEntity(self)
				if SinglePlayer() then
					effectdata:SetEntity(self.Owner:GetViewModel())
				end
			end
        else
            effectdata:SetEntity(self)
        end
        effectdata:SetOrigin( endpos )
        effectdata:SetScale((self.dt.SuperCharged)and 1 or 0)
    util.Effect( "zep_punteffect", effectdata )
    self:EmitSound((self.dt.SuperCharged) and "Weapon_MegaPhysCannon.Launch" or "Weapon_PhysCannon.Launch")
    pPlayer:ViewPunch( Angle( -6,math.Rand( -2,2 ), 0) );
    self.Owner:DoAttackEvent()
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end

function SWEP:SecondaryAttack()
	self:StupidSPFix("SecondaryAttack")
	if !IsFirstTimePredicted() then return end
	local pOwner = self.Owner;

	if ( self:IsActive() && ( pOwner:KeyDown(IN_ATTACK2) ) ) then
		// Drop the held object
		self:SetNextAttackTime(0.5)
		self:DetachObject();

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	else
		// Otherwise pick it up
		local result = self:FindObject();
		if result==OBJECT_FOUND then
			--WeaponSound( SPECIAL1 );
			self:EmitSound("Weapon_PhysCannon.Pickup")
			--ErrorNoHalt("FOUND SHIT\n")
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
			self:SetNextAttackTime(0.5)
		elseif result==OBJECT_NOT_FOUND then
			self:SetNextAttackTime(0.1)
			--ErrorNoHalt("DIDN'T FIND SHIT\n")
			--self:CloseElements();
		elseif result==OBJECT_BEING_DETACHED then
			self:SetNextAttackTime(0.01)
			--ErrorNoHalt("CAN'T DO SHIT\n")
		end

	end
end

local function PhysGetEntityMass(pEntity)
local pList={};
local listCount = pEntity:GetPhysicsObjectCount( )-1;
for i = 0,listCount do
pList[i]=pEntity:GetPhysicsObjectNum( i)
end        
local totalMass = 0;
for i = 0,listCount do
totalMass = pList[i]:GetMass()+totalMass;
end
	return totalMass
end

function SWEP:FindObject()
	local pPlayer=self.Owner
	

	local forward=pPlayer:GetAimVector();

	// Setup our positions
	local	start = pPlayer:EyePos();
	local	testLength = self.TraceLength * 4.0;
	local	endt = start + forward * testLength;

	// Try to find an object by looking straight ahead
	local tracedata = {}
	tracedata.start = start
	tracedata.endpos=endt
	tracedata.filter = {self,self.Owner}
	tracedata.mask	= MASK_SHOT|CONTENTS_GRATE
	local tr = util.TraceLine(tracedata)
		
	// Try again with a hull trace
	if ( ( tr.Fraction == 1.0 ) || !IsValid(tr.Entity)  || ( tr.Entity:IsWorld() ) ) then
		local tracedata = {}
		tracedata.start = start
		tracedata.endpos = endt
		tracedata.filter = {self,self.Owner}
		tracedata.mins =  -Vector(4,4,4)
		tracedata.maxs =  Vector(4,4,4)
		tracedata.mask	= MASK_SHOT|CONTENTS_GRATE
		tr = util.TraceHull( tracedata )
	end
	--
	local pEntity = tr.Entity ;
	local bAttach = false;
	local bPull = false;

	// If we hit something, pick it up or pull it
	if ( ( tr.Fraction != 1 ) && ( tr.Entity ) && ( tr.Entity:IsWorld() == false ) ) then
	
		// Attempt to attach if within range
		if ( tr.Fraction <= 0.25 )then
			bAttach = true;
		elseif ( tr.Fraction > 0.25 ) then
			bPull = true;
		end
	end
	
	// Find anything within a general cone in front
	local pConeEntity = nil;

	if (!bAttach && !bPull)then
		pConeEntity = self:FindObjectInCone( start, forward, 0.97 );
	end
	
	if ( pConeEntity )then
		pEntity = pConeEntity;
		// If the object is near, grab it. Else, pull it a bit.
		if ( pEntity:GetPos():LengthSqr( start ) <= (testLength * testLength) )then
			bAttach = true;
		else
			bPull = true;
		end
	end

	if (SERVER && !hook.Call("GravGunPickupAllowed",GAMEMODE,self.Owner,pEntity or NULL) )then
		// Make a noise to signify we can't pick this up
		if ( !self.m_flLastDenySoundPlayed ) then
			self.m_flLastDenySoundPlayed = true;
			--WeaponSound( SPECIAL3 );
			ErrorNoHalt("NOPE\n")
		end

		return OBJECT_NOT_FOUND;
	end
	

	// Check to see if the object is constrained + needs to be ripped off...
	local pOwner = self.Owner;
	--if ( !Pickup_OnAttemptPhysGunPickup( pEntity, pOwner, PICKED_UP_BY_CANNON ) ) then
	--	return OBJECT_BEING_DETACHED;
	--end
	if ( bAttach ) then
		return self:AttachObject( pEntity, tr.endpos ) and OBJECT_FOUND or OBJECT_NOT_FOUND;
	end

	if ( !bPull ) then
		return OBJECT_NOT_FOUND;
	end
	
	// FIXME: This needs to be run through the CanPickupObject logic
	local pObj = pEntity:GetPhysicsObject();
	if ( !pObj ) then
		return OBJECT_NOT_FOUND;
	end
	
	// If we're too far, simply start to pull the object towards us
	local	pullDir = start - pEntity:GetPos();
	pullDir:Normalize( )
	pullDir = 4000 * pullDir;
	
	local mass = PhysGetEntityMass( pEntity );
	if ( mass < 50.0 )then
		pullDir =pullDir*( (mass + 0.5) * (1/50.0));
	end

	// Nudge it towards us
	if SERVER then
		pObj:ApplyForceCenter( pullDir );
	end
	return OBJECT_NOT_FOUND;
end




function SWEP:FindObjectInCone( vecOrigin,vecDir,flCone )

	// Find the nearest physics-based item in a cone in front of me.
	local list;
	local flNearestDist = self.TraceLength + 1.0;
	local mins = vecOrigin - Vector( flNearestDist, flNearestDist, flNearestDist );
	local maxs = vecOrigin + Vector( flNearestDist, flNearestDist, flNearestDist );

	local pNearest = nil;
	local list=ents.FindInBox( mins,  maxs )
	for i,v in pairs(list) do
		if ( !v:GetPhysicsObject() )then continue;end

		// Closer than other objects
		local los = ( v:GetPos() - vecOrigin );
		local flDist = los:Length();
		if( flDist >= flNearestDist ) then continue; end

		// Cull to the cone
		if ( los:DotProduct(vecDir) <= flCone ) then continue; end

		// Make sure it isn't occluded!
		local tracedata = {}
		tracedata.start = vecOrigin
		tracedata.endpos= v:GetPos()
		tracedata.filter = {self,self.Owner}
		tracedata.mask	= MASK_SHOT|CONTENTS_GRATE
		local tr = util.TraceLine(tracedata)

		if( tr.Entity == v )then
			flNearestDist = flDist;
			pNearest = v;
		end
	end

	return pNearest;
end
--i love you blackops,you just saved me a lot of time porting this function
function SWEP:CanPlayerPickupObject( pObject, massLimit, sizeLimit )
    if ( pObject == NULL ) then
        return false;
    elseif pObject:GetMoveType() != MOVETYPE_VPHYSICS then
        return false;
    end
     
    local count = pObject:GetPhysicsObjectCount();
     
    if ( !count ) then
        return false;
    end
     
    local objectMass = 0;
    local checkEnable = false;
         
    for i=0,count-1 do
        local pList = pObject:GetPhysicsObjectNum( i );
        objectMass = objectMass + pList:GetMass();
        if ( pList:HasGameFlag( FVPHYSICS_NO_PLAYER_PICKUP ) ) then
            return false;
        --[[elseif ( pList:IsHinged() ) then -- Not possible now
            return false;]]
        elseif ( !pList:IsMoveable() ) then
            checkEnable = true;
        end
    end
     
    if ( massLimit > 0 && objectMass > massLimit ) then
        return false;
    elseif ( checkEnable && !pObject:HasSpawnFlags( 64 ) ) then
        return false;
    end
     
    if ( sizeLimit > 0 ) then       
        local maxs = pObject:OBBMaxs();
        local mins = pObject:OBBMins();
        local sizez = maxs.z - mins.z;
        local sizey = maxs.y - mins.y;
        local sizex = maxs.x - mins.x;
        if ( sizex > sizeLimit || sizey > sizeLimit || sizez > sizeLimit ) then
            return false;
        end
    end
	return true;
end
 

function SWEP:CanPickupObject(pTarget )
if SERVER then
	if !IsValid(pTarget) then
		return false;
	end
	

	if ( pTarget:IsEFlagSet( EFL_NO_PHYSCANNON_INTERACTION ) )then
		
		return false;
	end
	
	local pOwner = self.Owner;
	
	if ( pOwner && pOwner:GetGroundEntity() == pTarget ) then
		
		return false;
	end
	
	--hey,fuck off isflesh,we want to pickup everything
	--if ( pTarget->VPhysicsIsFlesh( ) )
	--	return false;

	local pObj = pTarget:GetPhysicsObject();	

	if ( pObj && pObj:HasGameFlag(FVPHYSICS_PLAYER_HELD)) then
		
		return false;
	end
	
	if ( pTarget:GetClass()=="prop_combine_ball" ) then
		return self:CanPlayerPickupObject( pTarget, 0, 0 );
	end
	
	return self:CanPlayerPickupObject( pTarget, self.MaxMass, 0 );
else
	return false;
end
	
end


function SWEP:AttachObject(pObject,vPosition )

	if ( self:IsActive() ) then
		return false;
	end
	
	if ( !self:CanPickupObject( pObject ) ) then
		
		return false;
	end
	self.ShadowController:SetIgnorePitch( false );
	self.ShadowController:SetAngleAlignment( 0 );

	local pPhysics = pObject:GetPhysicsObject();

	// Must be valid
	if ( !pPhysics ) then
		return false;
	end
	
	local pOwner = self.Owner;

	m_bActive = true;
	if( pOwner )then
		// NOTE: This can change the mass; so it must be done before max speed setting
		--Physgun_OnPhysGunPickup( pObject, pOwner, PICKED_UP_BY_CANNON );
		hook.Call("GravGunOnPickedUp",GAMEMODE,self.Owner,pObject) --todo,make it behave like the original physcannon
	end

	// NOTE :This must happen after OnPhysGunPickup because that can change the mass
	self.ShadowController:AttachEntity( pOwner, pObject, pPhysics, false, vPosition, false );
	self.dt.HoldEntity = pObject;
	self.m_attachedPositionObjectSpace = self.ShadowController.m_attachedPositionObjectSpace;
	self.m_attachedAnglesPlayerSpace = self.ShadowController.m_attachedAnglesPlayerSpace;

	self.m_bResetOwnerEntity = false;

	if ( !IsValid(self.dt.HoldEntity:GetOwner()))then
		self.dt.HoldEntity:SetOwner( pOwner );
		self.m_bResetOwnerEntity = true;
	end

	// Don't drop again for a slight delay, in case they were pulling objects near them
	self:SetNextAttackTime(0.4)
	
	--DoEffect( EFFECT_HOLDING );
	--OpenElements();
	--[[
	if ( GetMotorSound() ) then
		(CSoundEnvelopeController::GetController()).Play( GetMotorSound(), 0.0, 50 );
		(CSoundEnvelopeController::GetController()).SoundChangePitch( GetMotorSound(), 100, 0.5f );
		(CSoundEnvelopeController::GetController()).SoundChangeVolume( GetMotorSound(), 0.8, 0.5f );
	end
	]]


	return true;
end


function SWEP:GetPlayer()
	return self.Owner or self:GetOwner();
end

function SWEP:Think()
	if !self.dt then return end
	
	if(SERVER && self:IsActive() )then
		self:UpdateObject();
	end
	if self.dt.Mode == ZP_PHYSGUN_MODE then

	else
	
	end
end

function SWEP:UpdateObject( )
	local pPlayer = self.Owner;
	
	local flError = 12;
	if ( !self.ShadowController:UpdateObject( pPlayer, flError ) )then
		self:DetachObject();
		return;
	end
end




local ENT={}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Shadow Controller"
ENT.Author            = "Jvs"
ENT.Information        = "You shouldn't even being able to spawn this"
ENT.Category        = "Other"
ENT.Spawnable            = false
ENT.AdminSpawnable        = false

function ENT:Setup(owner)
	self.Owner=owner
	self:SetOwner(owner)
end

function ENT:TransformAnglesToPlayerSpace(anglesIn,pPlayer )
	--[[
	if ( self.m_bIgnoreRelativePitch )then
		local test;
		local angleTest = pPlayer:EyeAngles();
		angleTest.x = 0;
		AngleMatrix( angleTest, test );
		return TransformAnglesToLocalSpace( anglesIn, test );
	end
	return TransformAnglesToLocalSpace( anglesIn, pPlayer:EntityToWorldTransform() );
	]]
	return Angle(0,0,0)
end

function ENT:AttachEntity(pPlayer,pEntity,pPhys,bIsMegaPhysCannon,vGrabPosition,bUseGrabPosition )
	// play the impact sound of the object hitting the player
	// used as feedback to let the player know he picked up the object
	if SERVER then
		--PhysicsImpactSound( pPlayer, pPhys, CHAN_STATIC, pPhys->GetMaterialIndex(), pPlayer->VPhysicsGetObject()->GetMaterialIndex(), 1.0, 64 );
	end
	local position;
	local angles;
	position=pPhys:GetPos();
	angles=pPhys:GetAngles();
	// If it has a preferred orientation, use that instead.
if SERVER then
	--Pickup_GetPreferredCarryAngles( pEntity, pPlayer, pPlayer->EntityToWorldTransform(), angles );
end

	// Carried entities can never block LOS
	--m_bCarriedEntityBlocksLOS = pEntity->BlocksLOS();
	--pEntity->SetBlocksLOS( false );
	--what
	pPhys:Wake();
	
	pPhys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
	self:SetTargetPosition( position, angles );
	self.m_attachedEntity = pEntity;
	local pList={};
	local count = pEntity:GetPhysicsObjectCount( )-1;
	self.m_flLoadWeight = 0;
	local damping = 10;
	local flFactor = count / 7.5;
	if ( flFactor < 1.0 )then
		flFactor = 1.0;
	end
	for i = 0,count do
        pList[i]=pEntity:GetPhysicsObjectNum( i)
    end
	
	for i=0,count do
		local mass = pList[i]:GetMass();
		self.m_savedRotDamping[i]=pList[i]:GetDamping( );
			
		self.m_flLoadWeight=self.m_flLoadWeight+ mass;
		self.m_savedMass[i] = mass;

		// reduce the mass to prevent the player from adding crazy amounts of energy to the system
		pList[i]:SetMass( REDUCED_CARRY_MASS / flFactor );
		pList[i]:SetDamping( 0, damping );
	end
	
	// Give extra mass to the phys object we're actually picking up
	pPhys:SetMass( REDUCED_CARRY_MASS );
	pPhys:EnableDrag( false );

	self.m_errorTime = -1.0; // 1 seconds until error starts accumulating
	self.m_error = 0;
	self.m_contactAmount = 0;

	self.m_attachedAnglesPlayerSpace = self:TransformAnglesToPlayerSpace( angles, pPlayer );
	--CONVERT THIS SHIT TOO
	self.m_attachedPositionObjectSpace=pEntity:WorldToLocal( pEntity:GetPos() )--VectorITransform( pEntity:GetPos(), pEntity->EntityToWorldTransform(), self.m_attachedPositionObjectSpace );

if SERVER then
	// If it's a prop, see if it has desired carry angles
	local pProp = pEntity;
	local carryangles=hook.Call("GetPreferredCarryAngles",GAMEMODE,pEntity,false)
	if ( carryangles )then
		self.m_bHasPreferredCarryAngles = carryangles;
	else
		self.m_bHasPreferredCarryAngles = false;
	end
else

	self.m_bHasPreferredCarryAngles = false;
end

end


function ENT:UpdateObject( pPlayer, flError )
	
	local pEntity = self:GetAttached();
	if ( !IsValid(pEntity) ) then
		return false;
	end
	
	if ( self:ComputeError() > flError ) then
		return false;
	end
	
	if ( pPlayer:GetGroundEntity() == pEntity )then
		return false;
	end
	
	if (!IsValid(pEntity:GetPhysicsObject()) ) then
		return false;   
	end
	//Adrian: Oops, our object became motion disabled, let go!
	local pPhys = pEntity:GetPhysicsObject();
	if ( pPhys && pPhys:IsMoveable() == false )then
		return false;
	end
	if ( self.m_frameCount == CurTime() )then
		return true;
	end
	self.m_frameCount = CurTime();
	local forward, right, up;
	local playerAngles = pPlayer:EyeAngles();

	local pitch = playerAngles.p;
	
	playerAngles.x = math.Clamp( pitch, -75, 75 );
	forward=playerAngles:Forward()
	right=playerAngles:Right()
	up=playerAngles:Up()
	
	// Now clamp a sphere of object radius at end to the player's bbox
	local radial =pEntity:OBBMins() --Vector(0,0,0) --physcollision->CollideGetExtent( pPhys->GetCollide(), vec3_origin, pEntity->GetAbsAngles(), -forward );
	local player2d = pPlayer:OBBMaxs();
	local playerRadius = player2d:Length2D();
	local flDot = forward:DotProduct(radial);

	local radius = playerRadius + math.abs( flDot );

	local distance = 24 + ( radius * 2.0 );

	local start = pPlayer:EyePos();
	local endf = start + ( forward * distance );


		
	local tr;
	local tracedata = {}
	tracedata.start = start
	tracedata.endpos =endf
	tracedata.filter = {pPlayer,pEntity}
	tr = util.TraceLine(tracedata)

	if ( tr.Fraction < 0.5 )then
		endf = start + forward * (radius*0.5);
	elseif ( tr.Fraction <= 1.0 )then
		endf= start + forward * ( distance - radius );
	end

	local playerMins, playerMaxs, nearest;
	playerMins,playerMaxs=pPlayer:WorldSpaceAABB();
	local playerLine = pPlayer:GetPos();
	nearest=pPlayer:NearestPoint(endf)
	--CalcClosestPointOnLine( endf, playerLine+Vector(0,0,playerMins.z), playerLine+Vector(0,0,playerMaxs.z), nearest, NULL );

	local delta = endf - nearest;
	local len = (delta):Length();
	--[[
	if ( len < radius )then
		endf = nearest + radius * delta;
	end
	]]
	local angles =self:TransformAnglesFromPlayerSpace( self.m_attachedAnglesPlayerSpace, pPlayer );

	//Show overlays of radius
	if ( LOLOLDEBUG==nil )then

		debugoverlay.Box( endf, Vector( 2,2,2 )*-1, Vector(2,2,2),0.5,Color(0, 255, 0), true );

		--debugoverlay.Box( self:GetAttached():GetPos(),	Vector( radius+5, radius+5, radius+5)*-1, Vector( radius+5, radius+5, radius+5 ),0.5,Color(255, 0, 0),	true);
	end

if SERVER then
	// If it has a preferred orientation, update to ensure we're still oriented correctly.
	--Pickup_GetPreferredCarryAngles( pEntity, pPlayer, pPlayer->EntityToWorldTransform(), angles );


	// We may be holding a prop that has preferred carry angles
	
	if ( self.m_bHasPreferredCarryAngles )then
		angles:RotateAroundAxis(angles:Up(),self.m_bHasPreferredCarryAngles.p)
		angles:RotateAroundAxis(angles:Forward(),self.m_bHasPreferredCarryAngles.y)
		angles:RotateAroundAxis(angles:Right(),self.m_bHasPreferredCarryAngles.r)
	end
	
end

	local offset=self.m_attachedPositionObjectSpace*1;
	offset:Rotate( angles);
	self:SetTargetPosition( endf - offset, angles );

	return true;
end

function ENT:Draw()
end

function ENT:GetLoadWeight()return self.m_flLoadWeight end
function ENT:SetAngleAlignment(alignAngleCosine ) self.m_angleAlignment = alignAngleCosine end
function ENT:SetIgnorePitch(bIgnore ) self.m_bIgnoreRelativePitch = bIgnore end
function ENT:GetAttached() return self.m_attachedEntity end

function ENT:SetTargetPosition( target,targetOrientation )
	self.m_shadow.pos = target;
	self.m_shadow.angle = targetOrientation;

	self.m_timeToArrive = 0.001;

	local pAttached = self:GetAttached();
	if ( IsValid(pAttached) ) then
		local pObj = pAttached:GetPhysicsObject();
		
		if IsValid(pObj)then
			pObj:Wake();
		else
			self:DetachEntity( false );
		end
	end
end

function ENT:ComputeError()
	if ( self.m_errorTime <= 0 )then
		return 0;
	end
	
	local pAttached = self:GetAttached();
	if ( pAttached )then
		local pos;
		local pObj = pAttached:GetPhysicsObject();
		
		if ( pObj )then
			pos=pObj:GetPos();

			local errorf = (self.m_shadow.pos - pos):Length();
			if ( self.m_errorTime > 0 ) then
				if ( self.m_errorTime > 1 )then
					self.m_errorTime = 1;
				end
				local speed = errorf / self.m_errorTime;
				if ( speed > self.m_shadow.maxSpeed )then
					errorf =errorf* 0.5;
				end
				self.m_error = (1-self.m_errorTime) * self.m_error + errorf * self.m_errorTime;
			end
		else
			ErrorNoHalt( "Object attached to Physcannon has no physics object\n" );
			self:DetachEntity( false );
			return 9999; // force detach
		end
	end
	
	if ( pAttached:IsEFlagSet( EFL_IS_BEING_LIFTED_BY_BARNACLE ) )then
		self.m_error =self.m_error * 3.0;
	end

	self.m_errorTime = 0;

	return self.m_error;
end

function ENT:Initialize()
	self:DrawShadow(false)
	if SERVER then
		self.m_shadow={}
		self.m_shadow.dampFactor = 1;
		self.m_shadow.teleportDistance = 0;
		self.m_errorTime = 0;
		self.m_error = 0;
		// make this controller really stiff!
		self.m_shadow.maxSpeed = 10000--1000;
		self.m_shadow.maxAngular =10000 --DEFAULT_MAX_ANGULAR;
		self.m_shadow.maxspeeddamp = 10000--self.m_shadow.maxSpeed*2;
		self.m_shadow.maxangulardamp =10000-- self.m_shadow.maxAngular;
		self.m_attachedEntity = NULL;
		self.m_vecPreferredCarryAngles = Angle(0,0,0);
		self.m_bHasPreferredCarryAngles = false;
		self.m_savedRotDamping={}
		self.m_savedMass={}
	end
end

function ENT:TransformAnglesFromPlayerSpace(anglesIn,pPlayer )
	--[[
	if ( self.m_bIgnoreRelativePitch )then
		local test;
		local angleTest = pPlayer->EyeAngles();
		angleTest.x = 0;
		AngleMatrix( angleTest, test );
		return TransformAnglesToWorldSpace( anglesIn, test );
	end
	return TransformAnglesToWorldSpace( anglesIn, pPlayer->EntityToWorldTransform() );
	]]
	local newang=anglesIn*1;
	--newang:RotateAroundAxis(anglesIn:Forward(),pPlayer:EyeAngles().p)
	--newang:RotateAroundAxis(anglesIn:Right(),pPlayer:EyeAngles().r)
	--newang:RotateAroundAxis(anglesIn:Up(),pPlayer:EyeAngles().r)
	
	
	return newang --pPlayer:EyeAngles() --lol
end


function ENT:ComputeMaxSpeed( pEntity,pPhysics )
if !CLIENT then return end
	self.m_shadow.maxSpeed = 1000;
	self.m_shadow.maxAngular = DEFAULT_MAX_ANGULAR;

	// Compute total mass...
	local flMass = PhysGetEntityMass( pEntity );
	local flMaxMass = self.MaxMass;
	if ( flMass <= flMaxMass ) then
		return;
	end
	local flLerpFactor = math.Clamp( flMass, flMaxMass, 500.0 );
	flLerpFactor = SimpleSplineRemapVal( flLerpFactor, flMaxMass, 500.0, 0.0, 1.0 );

	local invMass = pPhysics:GetInvMass();
	local invInertia = pPhysics:GetInvInertia():Length();

	local invMaxMass = 1.0 / MAX_MASS;
	local ratio = invMaxMass / invMass;
	invMass = invMaxMass;
	invInertia =invInertia* ratio;

	local maxSpeed = invMass * MASS_SPEED_SCALE * 200;
	local maxAngular = invInertia * MASS_SPEED_SCALE * 360;

	self.m_shadow.maxSpeed = Lerp( flLerpFactor, self.m_shadow.maxSpeed, maxSpeed );
	self.m_shadow.maxAngular = Lerp( flLerpFactor, self.m_shadow.maxAngular, maxAngular );
end



local function ClampPhysicsVelocity( pPhys, linearLimit,angularLimit )
	local vel;
	local angVel;
	vel=pPhys:GetVelocity();
	angVel=pPhys:GetAngleVelocity();
	local speed = vel:Length() - linearLimit;
	local angSpeed = angVel:Length() - angularLimit;
	speed = speed < 0 and 0 or speed*-1;
	angSpeed = angSpeed < 0 and 0 or angSpeed*-1;
	vel =vel* speed;
	angVel =angVel* angSpeed;
	pPhys:AddVelocity(vel);
	pPhys:AddVelocity(angVel );
end

function ENT:DetachEntity( bClearVelocity )
	local pEntity = self:GetAttached();
	if ( IsValid(pEntity) )then
		// Restore the LS blocking state
		local pList={};
		local count = pEntity:GetPhysicsObjectCount( )-1;

		for i = 0,count do
			pList[i]=pEntity:GetPhysicsObjectNum( i)
		end
		for i=0,count do
			local pPhys = pList[i];
			if ( !IsValid(pPhys) )then
				continue;
			end
			// on the odd chance that it's gone to sleep while under anti-gravity
			pPhys:EnableDrag( true );
			pPhys:Wake();
			pPhys:SetMass( self.m_savedMass[i] );
			pPhys:SetDamping( NULL, self.m_savedRotDamping[i] );
			pPhys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
			--if ( bClearVelocity )then
				pPhys:SetVelocity(Vector(0,0,0))
			--else
if SERVER then
			--	ClampPhysicsVelocity( pPhys, 250 * 1.5, 2.0 * 360.0 );
end
			--end

		end
	end

	self.m_attachedEntity = NULL;
end

function ENT:Think()
	 if SERVER then
		if IsValid(self:GetAttached()) then
			local phys=self:GetAttached():GetPhysicsObject()
			if IsValid(phys) then
				self:PhysicsSimulate(phys,0.0001)
			end
		end
		self:NextThink(CurTime())
		return true
	 end
end

function ENT:OnRemove()
	self:DetachEntity( false );
end

local function FixCases(tab)
	local newtab=table.Copy(tab)
	for i,v in pairs(tab) do
		newtab[string.lower(i)]=v;
	end
	return newtab;
end

function ENT:PhysicsSimulate(pObject,deltaTime )
	local shadowParams = self.m_shadow;
	self.m_contactAmount = math.Approach( 1.0, self.m_contactAmount, deltaTime*2.0 );
	--shadowParams.maxAngular = self.m_shadow.maxAngular * self.m_contactAmount * self.m_contactAmount * self.m_contactAmount;
if SERVER then



	shadowParams.secondstoarrive=self.m_timeToArrive
	shadowParams.deltatime=deltaTime
	shadowParams=FixCases(shadowParams)
	pObject:ComputeShadowControl( shadowParams );
end
	
	// Slide along the current contact points to fix bouncing problems
	--[[
	local velocity;
	local angVel;
	pObject:GetVelocity( &velocity, &angVel );
	pObject:SetVelocityInstantaneous( &velocity, NULL );
	]]
	self.m_errorTime =self.m_errorTime+deltaTime;

end

scripted_ents.Register(ENT,"zep_controller",true)

ENT={}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Effect Controller"
ENT.Author            = "Jvs"
ENT.Information        = "You shouldn't even being able to spawn this"
ENT.Category        = "Other"
ENT.Spawnable            = false
ENT.AdminSpawnable        = false

function ENT:Setup(owner)
	self.Owner=owner
	self:SetOwner(owner)
end

function ENT:Draw()
end

function ENT:Initialize()
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	if CLIENT then
		self:SetRenderBounds(self:GetOwner():GetRenderBounds()) --Vector( -16, -16, -16 ), Vector( 16, 16, 16 )
	end
	self:DrawShadow(false)
	
end

function ENT:Think()
end


scripted_ents.Register(ENT,"zee_controller",true)
