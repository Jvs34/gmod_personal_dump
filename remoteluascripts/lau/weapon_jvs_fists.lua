local SWEP={}


SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.Category                = "Jvs"
SWEP.Spawnable            = true
SWEP.AdminOnly        = true
SWEP.Base = "weapon_base"
SWEP.Author			= "Jvs"

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel			= ""

SWEP.ViewModelFOV		= 50
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Jvs fists"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.Range = 75


sound.Add( {
	name = "weapon_jvs_fists.crit",
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 0.1,
	sound = "^ambient/energy/zap5.wav",
	pitch = {
		120,
		120,
	},
})


SWEP.AnimData = {
	CRIT = 51,
	LEFT = 52,
	RIGHT = 53,
}

SWEP.SeqAnimData = {
	[SWEP.AnimData.CRIT] = "range_knife",
	[SWEP.AnimData.LEFT] = "range_fists_l",
	[SWEP.AnimData.RIGHT] = "range_fists_r",
}

if CLIENT then
	SWEP.UsePlayerHands = CreateClientConVar( "cl_jvsfists_useplayerhands", 0, true, true )
end

function SWEP:Initialize()
	self:SetHoldType("fist")
	self:SetNextMeleeAttack(-1)
	self:SetPlaybackSlow( 1 )
end 

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextMeleeAttack")
	self:NetworkVar("Float",1,"NextIdle")
	self:NetworkVar("Float",2,"PlaybackSlow")
	self:NetworkVar("Bool",0,"Crit")
	self:NetworkVar("Bool",1,"Blocking")
end

function SWEP:PreDrawViewModel( vm, wep, ply )
	if not IsValid(vm) then return end
	vm:SetMaterial( "engine/occlusionproxy" )

end

function SWEP:DrawViewModel( vm )

end

function SWEP:DoDrawCrosshair( x, y )
	
	--return true
end

function SWEP:PostDrawViewModel( vm, wep, ply )
	if not IsValid(vm) then return end
	vm:SetMaterial()
	if not self.UseHands then
		if not IsValid(self.PlayerHands) then return end
		self.PlayerHands:AddEffects( EF_BONEMERGE )
		self.PlayerHands:SetParent( vm )
		self.PlayerHands:DrawModel()
	end
	
end


function SWEP:Deploy()
	self:SendVMAnim("fists_draw")
	self:SetNextMeleeAttack(-1)
	self:SetNextIdle(CurTime()+1)
	self:SetNextPrimaryFire(CurTime() + 0.5 * self:GetPlaybackSlow() )
	self:SetNextSecondaryFire(CurTime() + 0.5 * self:GetPlaybackSlow() )
	return true
end

--[[
0	=	idle
1	=	reference
2	=	seq_admire
3	=	fists_draw
4	=	fists_right
5	=	fists_left
6	=	fists_uppercut
7	=	fists_holster
8	=	fists_idle_01
9	=	fists_idle_02

]]


--[[
function SWEP:HandlePlayerHands()
	self.UseHands = not self.UsePlayerHands:GetBool()
	
	if not self.UseHands then
		if not IsValid(self.PlayerHands) then
			self.PlayerHands=ClientsideModel(self.Owner:GetModel())
			self.PlayerHands:SetNoDraw(true)
			self.PlayerHands:SetOwner(self.Owner)
			self.PlayerHands:SetLOD(0)
			self.PlayerHands:SetBodyGroups(self.Owner:GetBodyGroups())
			self.PlayerHands.GetPlayerColor=function(self) 
				if IsValid(self:GetOwner()) then 
					return self:GetOwner():GetPlayerColor() 
				end 
			end
			
			self.PlayerHands:AddCallback("BuildBonePositions",function (self)
				if not IsValid(self:GetParent()) then return end
				
				for i=0, self:GetBoneCount()-1 do
					local thismatrix=self:GetBoneMatrix(i)
					local bonename=self:GetBoneName(i)
					if not thismatrix then continue end
					
					local parentbone=self:GetParent():LookupBone(bonename)
					--check if our parent has the same bones as us, if that bone doesn't exist, shrink it
					if not parentbone then
						thismatrix:SetScale(vector_origin)
						--thismatrix:SetTranslation(self:GetParent():GetPos() + Vector(0,-100,0))
						self:SetBoneMatrix(i,thismatrix)
					end
				end
			end)
			
		end
		
	else
		if IsValid(self.PlayerHands) then
			self.PlayerHands:Remove()
			self.PlayerHands=nil
		end
	end

end
]]

function SWEP:Think()
	
	--[[
	if CLIENT then
		self:HandlePlayerHands()
	end
	]]

	if self:GetNextMeleeAttack()~=-1 and self:GetNextMeleeAttack() < CurTime() then
		self:MeleeAttack()
	end
	
	if self:GetNextIdle()~=-1 and self:GetNextIdle() < CurTime() then
		self:SendVMAnim( "fists_idle_01" )
		self:SetNextIdle(-1)
	end
	
	--[[
	if self:GetNextIdle() == -1 and self:GetNextMeleeAttack() == -1 then
		self:SetBlocking( self.Owner:KeyDown( IN_RELOAD ) )
		if self:GetBlocking() then
			self:SendWMAnim( "fist_block" )
		end
	end
	]]
	
end

function SWEP:PrimaryAttack()
	self:SendMeleeAttack(true)
end

function SWEP:SecondaryAttack()
	self:SendMeleeAttack(false)
end

function SWEP:SendMeleeAttack(left_right)
	if self:GetNextMeleeAttack()~=-1 then return end

	local crit=util.SharedRandom("jvs_fists_crit",1,10) >= 8	--8
	
	
	if crit then
		self:SendVMAnim( "fists_uppercut" )
		--self:SendWMAnim( "range_knife" )
		self.Owner:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , self.AnimData.CRIT , false )
	else
		self:SendVMAnim( left_right and "fists_left" or "fists_right" )
		self.Owner:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , left_right and self.AnimData.LEFT or self.AnimData.RIGHT ,  false )
		--self:SendWMAnim( left_right and "range_fists_l" or "range_fists_r" )
	end
	
	
	
	self:EmitSound("Weapon_Crowbar.Single")
	
	if crit then
		--self:EmitSound( "weapon_jvs_fists.crit" , nil , nil , nil , CHAN_ITEM )
	end
	
	--self.Owner:DoAttackEvent()
	--self.Owner:AnimSetGesturePlaybackRate( GESTURE_SLOT_ATTACK_AND_RELOAD , 0.5 )
	
	
	self:SetNextPrimaryFire(CurTime() + 0.5 * self:GetPlaybackSlow() )
	self:SetNextSecondaryFire(CurTime() + 0.5 * self:GetPlaybackSlow() )
	self:SetNextMeleeAttack(CurTime() + 0.15 * self:GetPlaybackSlow() )
	self:SetCrit(crit)
	self:SetNextIdle(-1)
end


local function ImpactEffects( tr,dmgtype )
	local e = EffectData()
	e:SetOrigin( tr.HitPos )
	e:SetStart( tr.StartPos )
	e:SetSurfaceProp( tr.SurfaceProps ) -- <3 garry :D
	e:SetDamageType( dmgtype or DMG_BULLET )
	e:SetHitBox( tr.HitBox )
	if CLIENT then
		e:SetEntity( tr.Entity )
	else
		e:SetEntIndex( tr.Entity:EntIndex() )
	end
	util.Effect( "Impact", e )
end

local function ImpactRagdolls(tr,dmgtype)
	local e = EffectData()
	e:SetStart( tr.StartPos )
	e:SetOrigin( tr.HitPos )
	e:SetDamageType( dmgtype or DMG_BULLET )
	
	util.Effect( "RagdollImpact", e )
end


function SWEP:MeleeAttack()
	

	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * self.Range )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -8, -8, -8 )
	tracedata.maxs =  Vector( 8, 8, 8 )
	
	self.Owner:LagCompensation( true )
	
	local tr = util.TraceHull( tracedata )
	
	
	
	if tr.Hit then
	
		local dmg=DamageInfo()
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamage( 10 + util.SharedRandom("jvs_fists",2,10) )

		local uppercut = vector_origin
		
		if self:GetCrit() then
			dmg:ScaleDamage(3)
			uppercut = Vector(0,0,30000) --if it's a crit, add an uppercut force
		end
		
		dmg:SetDamageForce( uppercut + self.Owner:GetAimVector() * dmg:GetDamage() * 500 )
		
		
		

		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetDamageType(DMG_CRUSH)
		
		if tr.Entity then
			local blocking = false
			
			if tr.Entity:IsPlayer() then
				--local theirweapon = self:IsUsingSameWeapon( tr.Entity )
				
				--TODO: check if we're actually facing him when he's blocking
				--[[
				if IsValid( theirweapon ) and theirweapon:GetBlocking() then
					blocking = true
				end
				]]
				
				if tr.Entity:EyePos():Distance(tr.HitPos) < 30 and ( not blocking or self:GetCrit() ) then
					--tr.Entity:AnimRestartGesture( GESTURE_SLOT_FLINCH, ACT_FLINCH_HEAD , true )
					if SERVER then
						local kick = 10
						if self:GetCrit() then kick = 50 end
						tr.Entity:ViewPunch( Angle( kick * -1 , 0 , 0 ) )
					end
				end
			end
			
			if not blocking then
				tr.Entity:DispatchTraceAttack(dmg, tr)
			end
			util.ScreenShake( tr.HitPos , 3 , dmg:GetDamage() , 0.25 , 150 )

		end
		
		if tr.HitWorld and IsFirstTimePredicted() then
			ImpactEffects(tr,dmg:GetDamageType())
			util.Decal( "impact.sand", tracedata.start, tracedata.endpos )
		end
		
		
		ImpactRagdolls(tr,dmg:GetDamageType())
		
		self:EmitSound("Weapon_Crowbar.Melee_Hit")
    end
	
	self.Owner:LagCompensation( false ) --had to move this down below as we still need to access the enemy eyepos from witin an attack!
	
	self:SetNextMeleeAttack(-1)
	self:SetNextIdle( CurTime() + 0.2 * self:GetPlaybackSlow())
	self:SetCrit( false )
end

function SWEP:IsUsingSameWeapon( ply )
	if ply:GetActiveWeapon()~= NULL and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() == self:GetClass() then
		return ply:GetActiveWeapon()
	end
end

local function IsUsingFists( ply )
	return ply:GetActiveWeapon()~= NULL and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() == "weapon_jvs_fists"
end

function SWEP:SendVMAnim( seqstr )
	local vm=self.Owner:GetViewModel()
	if IsValid(vm) then
		local seq=vm:LookupSequence( seqstr )
		vm:SendViewModelMatchingSequence(seq)
		vm:SetPlaybackRate( 1 / self:GetPlaybackSlow() )
	end
end

function SWEP:SendWMAnim( seqstr )
	local seq=self.Owner:LookupSequence( seqstr )
	self.Owner:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD , seq , 0 , true )
	if self.Owner.AnimSetGesturePlaybackRate then
		self.Owner:AnimSetGesturePlaybackRate( GESTURE_SLOT_ATTACK_AND_RELOAD , 1 / self:GetPlaybackSlow() )
	end
end

function SWEP:Holster()
    return true
end

function SWEP:OnDrop()
	if SERVER then
		self:Remove()
	end
end

function SWEP:OnRemove()
	if CLIENT then
		if IsValid(self.PlayerHands) then
			self.PlayerHands:Remove()
			self.PlayerHands=nil
		end
	end
end

hook.Add( "DoAnimationEvent" , "weapon_jvs_fists" , function(ply,event,data)
	if event == PLAYERANIMEVENT_CUSTOM_SEQUENCE and IsUsingFists( ply ) then
		local fists = ply:GetActiveWeapon()
		fists:SendWMAnim( fists.SeqAnimData[data] )
		return ACT_INVALID
	end
end)
weapons.Register(SWEP,"weapon_jvs_fists",true)