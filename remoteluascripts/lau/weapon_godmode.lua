local SWEP={}

SWEP.Base="weapon_base"

SWEP.Author			= "Jvs"

SWEP.Spawnable			= true
SWEP.AdminOnly			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/player/breen.mdl"
SWEP.WorldModel			= "models/player/breen.mdl"

SWEP.ViewModelFOV		= 90
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "God mode"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.GodMode		= true

local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]			= ACT_HL2MP_IDLE_DUEL,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER,
	[ "magic" ]		=	 ACT_HL2MP_IDLE_MAGIC
}
	
if CLIENT then

    local da_centerglow = CreateMaterial("sprites/physcannon_bluecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/physcannon_bluecore1b",//"effects/fluttercore"
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
	local da_beam =CreateMaterial("sprites/physcannon_bluelightnew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/lgtning",//"sprites/physcannon_bluelight1b",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    //effect register
    local EFFECT={}
    EFFECT.Mat = da_beam
    EFFECT.DieT=0.1
    /*---------------------------------------------------------
       Init( data table )
    ---------------------------------------------------------*/
    function EFFECT:Init( data )
		self.Size=12
        self.EndPos     = data:GetOrigin()
        self.Ent =    data:GetEntity()
        if not IsValid(self.Ent) then return end
		self:SetRenderBoundsWS( self.Ent:GetPos(), self.EndPos )
        self.DieTime = CurTime() + self.DieT
        self.StartTime = CurTime()
        local effectdata = EffectData()
            effectdata:SetOrigin( self.EndPos )
            effectdata:SetMagnitude( 5 )
            effectdata:SetScale( 1 )
            effectdata:SetRadius( 5 )
        util.Effect( "Sparks", effectdata )
            
        local emitter = ParticleEmitter(self.EndPos )
        local particle = emitter:Add("effects/blueflare1.vtf",self.EndPos)
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
            dlight.r = 100
            dlight.g = 100
            dlight.b = 255
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
        if(not IsValid(self.Ent))then return end
		local ent=(self.Ent:ShouldDrawLocalPlayer()) and self.Ent or self.Ent:GetViewModel()
		if self.Ent~=LocalPlayer() then
			ent=self.Ent
		end
		if not IsValid(ent) then return end
		local attachment=ent:GetAttachment(ent:LookupAttachment( "anim_attachment_RH" ))
		if !attachment then return end
		
		local size=Lerp(math.TimeFraction(self.StartTime,self.DieTime, CurTime() ),self.Size,self.Size/4)
		render.SetMaterial(self.Mat )
		
		
		render.DrawBeam(attachment.Pos,self.EndPos,size,1,0,Color( 255, 255, 255, 255 ) )
        render.SetMaterial(da_centerglow)
		render.DrawSprite(self.EndPos,size-2,size-2,color_white)
		               
    end
    effects.Register(EFFECT,"GodModePunting")
	
	
	
	local EFFECT={}
    function EFFECT:Init( data )
		self.Size=12
        self.EndPos     = data:GetOrigin()
        self.Ent =    data:GetEntity()
        
		if not IsValid(self.Ent) or not IsValid(self.Ent:GetActiveWeapon()) then return end
		self.HeldEnt=self.Ent:GetActiveWeapon():GetHeldEntity()
		
		if not IsValid(self.HeldEnt) then return end
		
		
            
    end

    /*---------------------------------------------------------
       THINK
    ---------------------------------------------------------*/
    function EFFECT:Think( )

        if ( IsValid(self.Ent) and IsValid(self.HeldEnt)) then 
			self:SetRenderBoundsWS( self.Ent:GetPos(), self.HeldEnt:GetPos() )
			return false
		end
        return true

    end

    /*---------------------------------------------------------
       Draw the effect
    ---------------------------------------------------------*/
    function EFFECT:Render( )
        if not IsValid(self.Ent) or not IsValid(self.HeldEnt) then return end
		local ent=(self.Ent:ShouldDrawLocalPlayer()) and self.Ent or self.Ent:GetViewModel()
		if not IsValid(ent) then return end
		local attachment=ent:GetAttachment(ent:LookupAttachment( "anim_attachment_RH" ))
		if !attachment then return end
		
		local size=12 + math.sin(CurTime())*2
        
		self.EndPos=self.HeldEnt:OBBCenter()
		
		render.SetMaterial(self.Mat )
		
		
		render.DrawBeam(attachment.Pos,self.EndPos,size,1,0,Color( 255, 255, 255, 255 ) )
        render.SetMaterial(da_centerglow)
		render.DrawSprite(self.EndPos,size-2,size-2,color_white)
		               
    end
    effects.Register(EFFECT,"GodModePhysgunning")
	
	
	
	
	
	

	SWEP.RenderGroup         = RENDERGROUP_TRANSLUCENT
    function SWEP:ViewModelDrawn()
        self:DrawEffects(true)
    end
	
    function SWEP:DrawWorldModel()
        --self:DrawEffects(false)
    end
	
	function SWEP:DrawWorldModelTranslucent()
		self:DrawEffects(false)    
	end
	
	local transparent_blue=Color(0,9,100,255)
	local mat2=Material("models/debug/debugwhite")

	
	function SWEP:DrawEffects(view_or_world)
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and self.Owner:GetViewModel() or self.Owner
		local attachment=ent:GetAttachment(ent:LookupAttachment( "anim_attachment_RH" ))
		if !attachment then return end
		local pos=attachment.Pos
		local ang=attachment.Ang 
		pos = pos-3*ang:Right()
		pos = pos+2*ang:Forward()
		local extrasize=math.sin(CurTime())*2
        
		if self:GetNextAttack()>self:GetAttackedWhen() and self:GetNextAttack()>CurTime() then
			extrasize=Lerp(math.TimeFraction(self:GetAttackedWhen(),self:GetAttackedWhen()+0.1, CurTime() ),8,0)
		end
		
		
		render.SetMaterial(da_centerglow)
		render.DrawSprite(pos,16+extrasize,16+extrasize,color_white)
		--render.SetMaterial(da_centerglow)
		--render.DrawSphere(pos, 5,10,10, transparent_blue )
		if not view_or_world then
			self.Owner:RemoveAllDecals()
		end
	end
	
		
	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( "engine/occlusionproxy" )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()

	end
	
	function SWEP:GetViewModelPosition(pos,ang)
		pos = pos-60*ang:Up()
		pos = pos+3*ang:Right()
		pos = pos-12*ang:Forward()
		return pos,ang
		--ang:RotateAroundAxis(ang:Right(), 10)
		
	end
end
	
--[[---------------------------------------------------------
   Name: SetWeaponHoldType
   Desc: Sets up the translation table, to translate from normal 
			standing idle pose, to holding weapon pose.
-----------------------------------------------------------]]
function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ActIndex[ t ]
	
	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal)\n" )
		t = "normal"
		index = ActIndex[ t ]
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM_IDLE ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= index+9
	
	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end

	self:SetupWeaponHoldTypeForAI( t )

end

function SWEP:Initialize()

	self:SetWeaponHoldType( "magic" )
	self:SetNextAttack(CurTime())
	self:SetAttackedWhen(CurTime())
	self:SetHeldEntity(NULL)
	self:SetAttackMode(false)

end


function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "NextAttack")
	self:NetworkVar( "Float", 1, "AttackedWhen")
	self:NetworkVar( "Bool", 0, "Repulse")
	self:NetworkVar( "Bool", 1, "AttackMode")
	self:NetworkVar( "Entity", 0, "HeldEntity")
end





function SWEP:PrimaryAttack()
	if self:GetNextAttack()>CurTime() or IsValid(self:GetHeldEntity()) then return end
	
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 1024 )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -4, -4, -4 )
	tracedata.maxs =  Vector( 4, 4, 4 )
	
	self.Owner:LagCompensation(true)
	local tr = util.TraceHull( tracedata )
	self.Owner:LagCompensation(false)
	
	if tr.Hit then
		self:SetRepulse(true)
		local effectdata = EffectData()
		effectdata:SetEntity(self.Owner)
		effectdata:SetOrigin( tr.HitPos )
		util.Effect( "GodModePunting", effectdata )
		
		if SERVER then
			self.Owner:TraceHullAttack( self.Owner:GetShootPos(), tr.HitPos, Vector( -16, -16, -16 ), Vector( 16, 16, 16 ), 50, DMG_DISSOLVE , 500 )
		end
		self:EmitSound("Weapon_MegaPhysCannon.Launch")
		self:SetNextAttack(CurTime()+0.5)
		self:SetAttackedWhen(CurTime())
		
	end
end

function SWEP:Reload()
	if not IsValid(self:GetHeldEntity()) then return end
	if SERVER then
		self:DropEntity()
	end
end

function SWEP:SecondaryAttack()
	--[[
	if self:GetNextAttack()>CurTime() or IsValid(self:GetHeldEntity()) then return end
	if SERVER then
		local tracedata = {}
		tracedata.start = self.Owner:GetShootPos()
		tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 1024 )
		tracedata.filter = self.Owner
		tracedata.mins =  Vector( -16, -16, -16 )
		tracedata.maxs =  Vector( 16, 16, 16 )
		local tr = util.TraceHull( tracedata )
		

	
		
		if tr.Hit and IsValid(tr.Entity) and not IsValid(tr.Entity:GetOwner()) then
			local ent=tr.Entity
			if IsValid(ent:GetPhysicsObject()) then 
				ent:SetOwner(self.Owner)
				self:SetHeldEntity(ent)
				
				local effectdata = EffectData()
				effectdata:SetEntity(self.Owner)
				util.Effect( "GodModePhysgunning", effectdata )
			end
		end
	end
	self:SetNextAttack(CurTime()+0.5)
	]]
end


function SWEP:DropEntity()

	if SERVER and IsValid(self:GetHeldEntity():GetPhysicsObject()) then
		self:GetHeldEntity():GetPhysicsObject():EnableMotion( true )
		self:GetHeldEntity():GetPhysicsObject():Wake()
	end
	self:GetHeldEntity():SetOwner(NULL)
	
	self:SetHeldEntity(NULL)
end

function SWEP:Tick()
	if not self.dt then return end
	if IsValid(self:GetHeldEntity()) then
		local tracedata = {}
		tracedata.start = self.Owner:GetShootPos()
		tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 1024 )
		tracedata.filter = {self.Owner,self:GetHeldEntity()}
		tracedata.mins =  Vector( -16, -16, -16 )
		tracedata.maxs =  Vector( 16, 16, 16 )
		local tr = util.TraceHull( tracedata )
		
		--[[
		self:GetHeldEntity():SetNetworkOrigin( tr.HitPos )
		
		if SERVER and IsValid(self:GetHeldEntity():GetPhysicsObject()) then
			self:GetHeldEntity():GetPhysicsObject():EnableMotion( true )
			self:GetHeldEntity():GetPhysicsObject():SetPos( tr.HitPos )
			self:GetHeldEntity():GetPhysicsObject():Wake()
			self:GetHeldEntity():GetPhysicsObject():EnableMotion( false )
		end
		]]
	end

	
end

function SWEP:Think()
	if not self.dt then return end
	if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetViewModel()) then
		local vm = self.Owner:GetViewModel()
		vm:ResetSequence( vm:LookupSequence( "idle_magic" ) )
	end

end

function SWEP:Holster( wep )
	if SERVER and IsValid(self.Owner) then
		self.Owner:SetBloodColor(BLOOD_COLOR_RED)
		if IsValid(self:GetHeldEntity()) then 
			self:DropEntity() 
		end
	end
	return true
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "idle_magic" ) )
	if SERVER and IsValid(self.Owner) then
		self.Owner:SetBloodColor(-1)
	end
	self:SetNextAttack(CurTime()+1)
	self:SetAttackedWhen(CurTime())
		
	return true
end


if SERVER then
	hook.Add("EntityTakeDamage","godmode",function( ent, dmginfo )
		if IsValid(ent) and ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon().GodMode then
			dmginfo:ScaleDamage(0.5)
			dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(),DMG_DISSOLVE))
			if IsValid(dmginfo:GetAttacker()) then
				if dmginfo:GetAttacker():IsPlayer() and IsValid(dmginfo:GetAttacker():GetActiveWeapon()) and dmginfo:GetAttacker():GetActiveWeapon().GodMode then
				
				else
					dmginfo:GetAttacker():TakeDamageInfo(dmginfo)
				end
			end
			local wep=ent:GetActiveWeapon()
			dmginfo:SetDamage(0)
			dmginfo:SetDamageForce(Vector(0,0,0))
			if dmginfo:IsDamageType(DMG_BULLET) then
				ent:EmitSound("FX_RicochetSound.Ricochet")
			end
		end
	end)
end



hook.Add("Move","godmodemove",function(ply,data)
	local wep=ply:GetActiveWeapon()

	if IsValid(wep) and wep.GodMode then
		if wep:GetRepulse() then
			ply:SetGroundEntity(NULL)
			--
			data:SetVelocity(ply:GetVelocity()+ply:GetAimVector()*-4*100)
			wep:SetRepulse(false)
			
			return
		end
	end
end)

weapons.Register(SWEP,"weapon_godmode",true)