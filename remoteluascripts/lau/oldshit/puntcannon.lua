if SERVER then
	AddCSLuaFile("shared.lua")
end

local notconventionalregistering=false
if !SWEP then
	SWEP={}
	notconventionalregistering=true
end
SWEP.Base="weapon_base"
SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
    

if ( CLIENT ) then
	
    SWEP.DrawAmmo            = false
    SWEP.PrintName            = "PuntCannon"
    SWEP.Author                = "Jvs"
    SWEP.DrawCrosshair        = true
    SWEP.ViewModelFOV        = 54
    local PHYSCANNON_BEAM_SPRITE
    local PHYSCANNON_CENTER_GLOW
    local MEGACANNON_BEAM_SPRITE
    local MEGACANNON_CENTER_GLOW
    local MEGACANNON_UPGRADE_MUZZLE
    SWEP.Contact        = "jvs_34@yahoo.it"
    //Credits to Andrew Mc Watters for his drawweaponselection from his swep_bases
    // Override this in your SWEP to set the icon in the weapon selection
    SWEP.WepSelectFont            = "TitleFont2"
    SWEP.WepSelectLetter        = "m"

    /*---------------------------------------------------------
        Checks the objects before any action is taken
        This is to make sure that the entities haven't been removed
    ---------------------------------------------------------*/
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		--[[
        // Set us up the texture
        surface.SetDrawColor( color_transparent )
        surface.SetTextColor( 255, 220, 0, alpha )
        surface.SetFont( self.WepSelectFont )
        local w, h = surface.GetTextSize( self.WepSelectLetter )

        // Draw that mother
        surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
                            y + ( tall / 2 ) - ( h / 2 ) )
        surface.DrawText( self.WepSelectLetter )
		]]
        
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
	hook.Add( "RenderScreenspaceEffects", "Puntcannonbeamrender", function()
	cam.Start3D( EyePos(), EyeAngles() )
		for i,v in pairs(ents.FindByClass("weapon_puntcannon")) do
			if !IsValid(v) or !v.dt or !IsValid(v:GetOwner()) or !v.dt.Attached then continue end
			local ent=(v:GetOwner()==LocalPlayer() and !v:GetOwner():ShouldDrawLocalPlayer()) and v:GetOwner():GetViewModel() or v
			if !IsValid(ent) then return end
			local attach=ent:GetAttachment(1).Pos
			render.SetMaterial(PHYSCANNON_CENTER_GLOW)
			render.DrawSprite(v.dt.AttachedTo,16,16,Color(255,255,255,255))
			render.SetMaterial(PHYSCANNON_BEAM_SPRITE)
			render.DrawBeam(attach,v.dt.AttachedTo,8,math.random(1,3),1,Color( 255, 255, 255,255) )
		end
		cam.End3D()
	end )
    //effect register
    local EFFECT={}
    EFFECT.Mat = PHYSCANNON_BEAM_SPRITE
    EFFECT.MegaMat=MEGACANNON_BEAM_SPRITE
    EFFECT.DieT=0.1
    /*---------------------------------------------------------
       Init( data table )
    ---------------------------------------------------------*/
    function EFFECT:Init( data )
        self.EndPos     = data:GetOrigin()
        self.Ent =    data:GetEntity()
        if(!IsValid(self.Ent))then return end
		self.Ent=(self.Ent:GetOwner()==LocalPlayer() and !self.Ent:GetOwner():ShouldDrawLocalPlayer()) and self.Ent:GetOwner():GetViewModel() or self.Ent
        self.Entity:SetRenderBoundsWS( self.Ent:GetAttachment( 1).Pos, self.EndPos )
        self.DieTime = CurTime() + self.DieT
        local effectdata = EffectData()
            effectdata:SetOrigin( self.EndPos )
            effectdata:SetMagnitude( 5 )
            effectdata:SetScale( 1 )
            effectdata:SetRadius( 5 )
        util.Effect( "Sparks", effectdata )
            
        local emitter = ParticleEmitter(self.EndPos )
        local particle = emitter:Add("effects/yellowflare.vtf",self.EndPos)
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

        local dlight = DynamicLight( self:EntIndex() )
        if ( dlight ) then
            dlight.r = 201
            dlight.g = 193
            dlight.b = 80
            dlight.Pos =  self.EndPos
            dlight.Brightness = 4
            dlight.Size =200
            dlight.Decay = 200
            dlight.DieTime = CurTime() + self.DieT
        end
            
    end

    /*---------------------------------------------------------
       THINK
    ---------------------------------------------------------*/
    function EFFECT:Think( )

        if ( CurTime() > self.DieTime and IsValid(self.Ent) ) then return false
        end
        return true

    end

    /*---------------------------------------------------------
       Draw the effect
    ---------------------------------------------------------*/
    function EFFECT:Render( )
        if(!IsValid(self.Ent))then return end
        self.Size=16
        if(self.Ent:IsWeapon())then self.Size=8 end
		render.SetMaterial(self.Mat )
        if !self.Ent:GetAttachment(1) then return end
        render.DrawBeam(self.Ent:GetAttachment(1).Pos,self.EndPos,self.Size,1,0,Color( 255, 255, 255, 255 ) )
                         
    end
    effects.Register(EFFECT,"PuntCannonEffect")
        
    
    SWEP.RenderGroup         = RENDERGROUP_TRANSLUCENT
    function SWEP:ViewModelDrawn()
        self:DrawCannon(true)
    end
    
    function SWEP:DrawWorldModelTranslucent()
        self:DrawModel()
        self:DrawCannon(false)
    end

    function SWEP:DrawWorldModel()
        //self:DrawModel()
        //self:DrawCannon(false)
    end

    function SWEP:DrawCannon(vmwmbool)    
        //vmwmbool is the boolean that controls how we are calling these functions
        local ent=(vmwmbool and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) ) and self.Owner:GetViewModel() or self

        local attachment=ent:GetAttachment(1)
		if !attachment then return end
        local StartPos = attachment.Pos
        local size=(12*self.dt.Charge)/self.MaxCharge
        local sizenocharge=12
        local beamsize=8
        local distance=36
        if(vmwmbool)then
            StartPos=attachment.Ang:Forward()*32 + StartPos
            //size=20
            size=(24*self.dt.Charge)/self.MaxCharge
            sizenocharge=24
            beamsize=16
        end
		local rand=math.random(3,7)
        render.SetMaterial(PHYSCANNON_CENTER_GLOW)
        render.DrawSprite(StartPos,size,size,Color(255,255,255,55+self.dt.Charge))
        render.SetMaterial(PHYSCANNON_BEAM_SPRITE)
            if(vmwmbool)then
                render.DrawBeam( ent:GetAttachment( 4).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,StartPos,beamsize/4,rand,1,Color( 255, 255, 255, self.dt.Charge ) )
                render.DrawBeam( ent:GetAttachment( 7).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,StartPos,beamsize/4,rand,1,Color( 255, 255, 255, self.dt.Charge ) )
                
                render.SetMaterial(PHYSCANNON_CENTER_GLOW)
                render.DrawSprite(ent:GetAttachment( 4).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,2,2,Color(255,255,255,55))
                render.DrawSprite(ent:GetAttachment( 7).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,2,2,Color(255,255,255,55))
                
            else
                render.DrawBeam( ent:GetAttachment(3).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255, self.dt.Charge ) )
                render.DrawBeam( ent:GetAttachment(5).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255, self.dt.Charge ) )
                render.DrawBeam( ent:GetAttachment(7).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255, self.dt.Charge ) )
                
                render.SetMaterial(PHYSCANNON_CENTER_GLOW)
                render.DrawSprite(ent:GetAttachment( 3).Pos,1,1,Color(255,255,255,55))
                render.DrawSprite(ent:GetAttachment( 5).Pos,1,1,Color(255,255,255,55))
                render.DrawSprite(ent:GetAttachment( 7).Pos,1,1,Color(255,255,255,55))
            end
        local dlight = DynamicLight( self:EntIndex() )
        if ( dlight and self.dt.Charge > 0) then
            dlight.r =    201
            dlight.g = 193
            dlight.b = 80
            dlight.Pos = vmwmbool and self.Owner:EyePos() or StartPos
            dlight.Brightness = self.dt.Charge/50
            dlight.Size =self.dt.Charge
            dlight.Decay = self.dt.Charge
            dlight.DieTime = CurTime() + 0.1
        end

        if self.dt.Charge>=self.MaxCharge then
				for i=0,4 do
					render.SetMaterial(MEGACANNON_UPGRADE_MUZZLE)
					local m_uchStartSize    = math.random( 0,1 ) * (i+1)
					local sizenocharge=sizenocharge-2
					render.DrawSprite(StartPos,sizenocharge+m_uchStartSize,sizenocharge+m_uchStartSize,Color(255,255,255,255))
                end
        end
    end
    
    
   
    
end

SWEP.Category                = "Jvs"
SWEP.Slot                    = 0
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = false
SWEP.AdminSpawnable          = true

SWEP.ViewModel            = "models/weapons/v_physcannon.mdl"
SWEP.WorldModel            = "models/weapons/w_physics.mdl" 
SWEP.Primary={}
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = "none"
SWEP.Primary.Automatic        = true

SWEP.Secondary={}
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

SWEP.TraceLength    = 250.0

SWEP.IsPuntCannon=true
SWEP.MaxCharge =200
SWEP.Damage    =20
SWEP.ChargeTime=2
SWEP.CanRepulseNormally=true
SWEP.RepulseForce=4
SWEP.RefireTime=0.5
function SWEP:SetupDataTables()
    self:DTVar( "Int", 0, "Charge" )
	self:DTVar( "Bool", 0, "IsCharged" )
	self:DTVar( "Bool", 1 , "Attached")
	self:DTVar( "Float", 0, "CanAttackTime" )
	self:DTVar( "Float", 1, "NextCharge" )
	self:DTVar( "Vector",0, "AttachedTo")
end

function SWEP:ResetDTVars()
    self.dt.CanAttackTime=CurTime()
    self.dt.IsCharged=false
	self.dt.Charge=0
    self.dt.NextCharge=CurTime()
	self.dt.AttachedTo=Vector(0,0,0)
	self.dt.Attached=false
end				
				
function SWEP:Initialize()

	self:StupidSPFix("Initialize")
	if self.Initialized then return end
	if SERVER and IsValid(self.Owner) then
		self.Owner:StripWeapon("weapon_physcannon")
	end
    if(CLIENT)then
		killicon.AddFont( self:GetClass(), "HL2MPTypeDeath",",", Color( 255, 80, 0, 255 ) )
		language.Add(self:GetClass(),"PuntCannon")
    end
    --self:InstallDataTable()

	self:ResetDTVars()
    self:SetWeaponHoldType("physgun")

	self.ChargeSound = CreateSound( self, "Weapon_PhysCannon.HoldSound" )
	self.Initialized=true
end

function SWEP:Precache()
    util.PrecacheSound("Weapon_PhysCannon.HoldSound")
	util.PrecacheSound("Weapon_PhysCannon.DryFire")
	util.PrecacheSound("Weapon_PhysCannon.Pickup")
	util.PrecacheSound("Weapon_PhysCannon.Launch")
end


function SWEP:Holster( wep )
	self:StupidSPFix("Holster")
	self.ChargeSound:Stop()
    if(self.dt.IsCharged)then self:EmitSound("Weapon_PhysCannon.DryFire")end
	self:ResetDTVars()
        
    return true
end

function SWEP:OnDrop(vec)
	self:StupidSPFix("OnDrop")
	self.ChargeSound:Stop()
    if(self.dt.IsCharged)then self:EmitSound("Weapon_PhysCannon.DryFire")end
	self:ResetDTVars()
end

function SWEP:OnRemove()
	self:StupidSPFix("OnRemove")
    self.ChargeSound:Stop()
end

function SWEP:StupidSPFix(FunctName)
	if SERVER and game.SinglePlayer() then
		self:CallOnClient(FunctName,"")
	end
end



        

function SWEP:Deploy()
	self:StupidSPFix("Deploy")
	if SERVER and IsValid(self.Owner) then
		self.Owner:StripWeapon("weapon_physcannon")
	end
	self.m_WeaponDeploySpeed=1
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:ResetDTVars()
	self.dt.CanAttackTime=self:SequenceDuration()+CurTime()
    return true
end

local function VectorMA2(start,scale,direction)
    --[[
	local dest=Vector()
    dest.x = start.x + scale * direction.x
    dest.y = start.y + scale * direction.y
    dest.z = start.z + scale * direction.z
    return dest
	]]
	return start + scale * direction
end





function SWEP:Repulse(force)
	if force<=0 and self.CanRepulseNormally then
		force=50
	end
	
	local pOwner=self.Owner
    self.Owner:LagCompensation(true)
    local forward=pOwner:GetAimVector()

    // NOTE: Notice we're *not* using the mega tracelength here
    // when you have the mega cannon. Punting has shorter range.
    local start, end1
    start = pOwner:EyePos()
    local flPuntDistance = self.TraceLength
    end1=VectorMA2( start, flPuntDistance, forward)
    //end1=forward*flPuntDistance+start
    local tracedata={}
    tracedata.start = start
    tracedata.endpos = end1
    tracedata.filter = self.Owner
    tracedata.mins = Vector(8,8,8)*-1
    tracedata.maxs = Vector(8,8,8)
     
    local tr = util.TraceHull( tracedata )
    
    local bValid = true
    local pEntity = tr.Entity
    if ( tr.fraction == 1 || (!IsValid(tr.Entity)||!tr.Entity))then
        bValid = false
    elseif ( (pEntity:GetMoveType() != MOVETYPE_VPHYSICS))then
        bValid = false
    end

    // If the entity we've hit is invalid, try a traceline instead
    if ( !bValid )then
        tracedata = {}
        tracedata.start = start
        tracedata.endpos =end1
        tracedata.filter = self.Owner
        tr = util.TraceLine(tracedata)
        if ( tr.fraction == 1 || !tr.Entity)then
            // Play dry-fire sequence
            self:DryFire()
			self.Owner:LagCompensation(false)
            return
        end

        pEntity = tr.Entity
    end
    //check if the entity is not valid or if the GravGunPunt hook disallows us from hitting that entity (prop protection)
    if(!IsValid(pEntity) || !hook.Call("GravGunPunt",GAMEMODE,self.Owner,pEntity))then
        if self.dt.IsCharged or self.CanRepulseNormally then
            if(tr.Hit and !tr.HitSky and !IsValid(pEntity))then
                if tr.HitWorld then
                    local Pos1 = tr.HitPos + tr.HitNormal
                    local Pos2 = tr.HitPos - tr.HitNormal
                    util.Decal("RedGlowFade",Pos1,Pos2)
                end
                self:PuntEffect(tr.HitPos)
            else
            self:DryFire()
			self.Owner:LagCompensation(false)
            return
            end
        else
            self:DryFire()
        end
    else
        if ( pEntity:GetMoveType() != MOVETYPE_VPHYSICS )then
                // Don't let the player zap any NPC's except regular antlions and headcrabs.
            self:PuntNonVPhysics( pEntity, forward, tr )
        else
            self:PuntVPhysics( pEntity, forward, tr )
        end
		
    end
    
    if self.dt.IsCharged or self.CanRepulseNormally then
        self.Owner:SetVelocity(pOwner:GetAimVector()*(self.RepulseForce*-1)*force)
    end
    self.Owner:LagCompensation(false)
end

function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
    if self.dt.CanAttackTime > CurTime() then return end
    self.dt.CanAttackTime=CurTime()+self.RefireTime
	
    if self.dt.Attached then
		--Just drop us from attached mode
		self:EmitSound("Weapon_Physgun.Off")
		self.dt.Attached=false
		return
	end
	
	self:Repulse(self.dt.Charge)
	self.dt.Charge=0
	self.dt.IsCharged=false
	self.dt.NextCharge=CurTime()
	self.ChargeSound:Stop()
end

function SWEP:SecondaryAttack()
	self:StupidSPFix("PrimaryAttack")
	if self.dt.CanAttackTime > CurTime()  then return end
	self.dt.CanAttackTime=CurTime()+self.RefireTime

	if self.dt.IsCharged and !self.dt.Attached then
		--depending on how much charge we've got increase the length of the trace
		--also do lag compensation here so we can avoid hitting players serverside but not clientside
		local trace={}
		self.Owner:LagCompensation(true)
		local trace = {}
		trace.start = self.Owner:EyePos()
		trace.endpos =self.Owner:EyePos()+self.Owner:GetAimVector()*self:GetTraceLengthWithCharge()
		trace.filter = self.Owner
		local tr = util.TraceLine(trace)
		self.Owner:LagCompensation(false)
		if(tr.Hit and !tr.HitSky and !IsValid(tr.Entity) and tr.HitWorld)then
			self.dt.AttachedTo=tr.HitPos
			self.dt.Attached=true
		else
			self:DryFire()
		end
		return
	end
	
	if !self.dt.IsCharged then
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self.ChargeSound:Play()
		self.dt.IsCharged=true
		self.dt.Charge=0
		self.dt.NextCharge=CurTime()
	end
end



function SWEP:Think()
	if !self.Initialized then return end
    local value=self.dt.Charge/self.MaxCharge
	self:SetPoseParameter("active",value)
    if(IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()))then
        self.Owner:GetViewModel():SetPoseParameter("active",value)
    end

    if self.dt.IsCharged and self.dt.NextCharge < CurTime() then
        if(self.dt.Charge<self.MaxCharge)then
			self.dt.Charge=self.dt.Charge+1
			if(self.dt.Charge>=self.MaxCharge)then self:EmitSound("Weapon_PhysCannon.Pickup")end
		end
		self.ChargeSound:ChangePitch(100+self.dt.Charge/1.7)
		self.dt.NextCharge=CurTime()+self.ChargeTime/self.MaxCharge
	end
end

function SWEP:DryFire()
    self.Owner:DoAttackEvent()
    self:EmitSound("Weapon_PhysCannon.DryFire")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:PuntNonVPhysics(pEntity, vecForward,tr)
    local pOwner = self.Owner
    if SERVER then
        local info=DamageInfo()
        local force=1500+(self.dt.Charge*3)
		local forward = vecForward
		
		if( forward.z < 0 )then
            //reflect, but flatten the trajectory out a bit so it's easier to hit standing targets
            forward.z = forward.z*-0.65
        end
        info:SetAttacker( self.Owner )
        info:SetInflictor( self )
        local dmgtodo=self.Damage
        info:SetDamage( dmgtodo +self.dt.Charge/3)
        info:SetDamageType( DMG_CRUSH )
        info:SetDamageForce( vecForward*force*300)    // Scale?
        info:SetDamagePosition( tr.HitPos )
        pEntity:DispatchTraceAttack( info, tr.StartPos, tr.HitPos )
		
        if pEntity:IsPlayer() then
			force=400+(self.dt.Charge*3)
			pEntity:SetVelocity(forward * force + Vector(0,0,300))
        
        end
    end        
    self:PuntEffect(tr.HitPos)
end


function SWEP:PuntVPhysics(pEntity, vecForward,tr)
	self:PuntEffect(tr.HitPos)
    if SERVER then
        local pOwner = self.Owner
        local info=DamageInfo()

        local forward = vecForward

        info:SetAttacker( self.Owner )
        info:SetInflictor( self )
        local dmgtodo=self.Damage
        info:SetDamage( dmgtodo + self.dt.Charge/3)
        info:SetDamageType( DMG_CRUSH )
        pEntity:DispatchTraceAttack( info, tr.StartPos, tr.HitPos )
        
        pEntity:SetPhysicsAttacker(self.Owner)
        local pList={}
        local listCount = pEntity:GetPhysicsObjectCount( )-1
        
    
        pEntity:PhysWake()
        if ( !listCount || listCount<0 )then
            self:DryFire()
            return
        end

        for i = 0,listCount do
            pList[i]=pEntity:GetPhysicsObjectNum( i)
        end

        
        if( forward.z < 0 )then
            //reflect, but flatten the trajectory out a bit so it's easier to hit standing targets
            forward.z = forward.z*-0.65
        end
                
        // NOTE: Do this first to enable motion (if disabled) - so forces will work
        // Tell the object it's been punted
        
            // limit mass to avoid punting REALLY huge things
            local totalMass = 0
            for i = 0,listCount do
            totalMass = pList[i]:GetMass()+totalMass
            
            end
            local maxMass = 250
            if ( pEntity:IsVehicle() )then
                maxMass =maxMass* 2.5    // 625 for vehicles
            end
            
            local mass = math.min(totalMass, maxMass) // max 250kg of additional force
            // Put some spin on the object
            for i = 0,listCount do
                local hitObjectFactor = 0.5
                local otherObjectFactor = 1 - hitObjectFactor
                  // Must be light enough
                local ratio = pList[i]:GetMass() / totalMass
                if ( pList[i] == pEntity:GetPhysicsObject( ))then
                    ratio = ratio+hitObjectFactor
                    ratio = math.min(ratio,1)
                else
                    ratio = ratio*otherObjectFactor
                end
                local fff=15000
                fff=fff+self.dt.Charge*100
                  pList[i]:ApplyForceCenter( forward * fff * ratio )
                  pList[i]:ApplyForceOffset( forward * mass * 600 * ratio, tr.HitPos )
            end
    end
    
    
    
    
end

function SWEP:PuntEffect(endpos)
    local pPlayer=self.Owner
    local effectdata = EffectData()
    local effectdata = EffectData()
    effectdata:SetEntity(self)
	effectdata:SetOrigin( endpos )
    util.Effect( "PuntCannonEffect", effectdata )
    self:EmitSound("Weapon_PhysCannon.Launch")
    pPlayer:ViewPunch( Angle( -6,math.Rand( -2,2 ), 0) )
    self.Owner:DoAttackEvent()
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end





function SWEP:Reload()

end

function SWEP:GetTraceLengthWithCharge()
	return self.TraceLength
end

function SWEP:GetAttachedLength()
	return self.Owner:EyePos():Distance(self.dt.AttachedTo)
end

--This needs to be shared so the client can predict the movement properly and without stuttering (hopefully)
hook.Add("Move","Puntcannonmove",function(ply,data)
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().IsPuntCannon and ply:GetActiveWeapon().dt and ply:GetActiveWeapon().dt.Attached then
		local oldvel=data:GetVelocity()
		if ply:GetActiveWeapon():GetAttachedLength() >= ply:GetActiveWeapon():GetTraceLengthWithCharge() then
			
			local newvel = (oldvel:GetNormalized() + (ply:GetActiveWeapon().dt.AttachedTo - ply:EyePos()):GetNormalized()):GetNormalized()
			data:SetVelocity(oldvel:Length()* newvel)
			return data
		end
		if ply:KeyDown(IN_RELOAD) then
			data:SetVelocity(oldvel+(ply:GetActiveWeapon().dt.AttachedTo - ply:EyePos()):GetNormalized()*150)
		end
	end
end)

if CLIENT then
	--This is a stupid fix to the clientside think/initialize of sweps not being called on other clients but localplayer's
	local wep=nil
	hook.Add("Tick","Fixclientsideswepthink",function()
		for i,v in pairs(player.GetAll()) do
			if IsValid(v) and v~=LocalPlayer() and v:Alive() then
				wep=v:GetActiveWeapon()
				if wep~=NULL and IsValid(wep) and wep.Think  then
					if !wep.Initialized and wep.SetupDataTables then
						wep:SetupDataTables()
						wep:Initialize()
					end
				wep:Think() 
				end
				wep=nil
			end
		end
	end)

	
end

if notconventionalregistering then
	weapons.Register(SWEP,"weapon_puntcannon",true)
	SWEP=nil
end