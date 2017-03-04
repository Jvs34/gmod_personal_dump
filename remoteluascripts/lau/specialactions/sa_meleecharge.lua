
sound.Add( {
	name = "sa_meleecharge.baseimpact",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 0.1,
	sound = {
		"^physics/metal/metal_sheet_impact_hard2.wav",
		"^physics/metal/metal_sheet_impact_hard6.wav",
		"^physics/metal/metal_sheet_impact_hard7.wav",
		"^physics/metal/metal_sheet_impact_hard8.wav",
	},
	pitch = {
		120,
		120,
	},
})

sound.Add( {
	name = "sa_meleecharge.hitworld",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 0.1,
	sound = {
		"^physics/concrete/boulder_impact_hard1.wav",
		"^physics/concrete/boulder_impact_hard2.wav",
		"^physics/concrete/boulder_impact_hard3.wav",
		"^physics/concrete/boulder_impact_hard4.wav",
	},
})

sound.Add( {
	name = "sa_meleecharge.hitflesh",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 0.1,
	sound = {
		"^physics/body/body_medium_break2.wav",
		"^physics/body/body_medium_break3.wav",
		"^physics/body/body_medium_break4.wav",
	},
})

local newsa=SA:New("Melee charge","sa_meleecharge","AAAAAAAAAAGH")
newsa.FlinchID = 115

function newsa:ResetVars(entity,owner)
	entity:AliasNetworkVar("ActionInt1","MaxCharge")
	
	entity:AliasNetworkVar("ActionFloat1","MaxChargeTime")
	entity:AliasNetworkVar("ActionFloat2","Charge")
	entity:AliasNetworkVar("ActionFloat3","ChargeSpeed")
	
	entity:AliasNetworkVar("ActionBool1","Charging")
	entity:AliasNetworkVar("ActionBool2","ClampMouseYaw")
	
	entity:AliasNetworkVar("ActionAngle1","LastMouseMovement")
	
	entity:SetCharge( 100 )
	entity:SetChargeSpeed( 750 )
	entity:SetMaxCharge( 100 )
	entity:SetMaxChargeTime( 1.5 )	--I guess this could be seen as the time the charge is going to be completely drained
	entity:SetCharging( false )
	entity:SetClampMouseYaw( true )
	entity:SetLastMouseMovement( Angle(0,0,0) )
	
end

function newsa:Initialize(entity,owner)
	self:InitModel(entity,owner)
end

function newsa:Deinitialize(entity,owner)
	if IsValid( entity.CLModel ) then
		entity.CLModel:Remove()
	end
	self:EndCharge( entity , owner )
end

function newsa:InitModel(entity,owner)
	if not CLIENT then return end
	if not IsValid( entity.CLModel ) then
		entity.CLModel = ClientsideModel( "models/props_wasteland/laundry_washer001a.mdl" )
		entity.CLModel:SetNoDraw( true )
		
		local mat = Matrix()
		mat:Scale( Vector( 0.2 , 0.2 ,0.025 ) ) 
		entity.CLModel:EnableMatrix( "RenderMultiply" , mat )
		
	end
end

function newsa:Think(entity,owner,mv)
	local ft = entity:TickRate()
	
	if entity:GetCharging() then

		local drainrate = entity:GetMaxCharge() / ( entity:GetMaxChargeTime() / ft )
		
		entity:SetCharge( entity:GetCharge() - drainrate )
		
		if entity:GetCharge() <= 0 then
			self:EndCharge( entity , owner )
		end
		
	else
	
		local rechargetime = entity:GetMaxChargeTime() * 5
		
		local rechargerate = entity:GetMaxCharge() / ( rechargetime / ft )
		
		
		
		if entity:GetCharge() < entity:GetMaxCharge() then
			local clampedchargerate = math.Clamp( entity:GetCharge() + rechargerate , 0 , entity:GetMaxCharge() )
			entity:SetCharge( clampedchargerate )
		end
		
		--reload the charge here, it should take MaxChargeTime * 5 seconds to fully recharge
		
	end
end


function newsa:AllClientThink(entity,owner,isclientowner)
end


function newsa:Attack(entity,owner,mv)

	if not entity:GetCharging() and entity:GetCharge() >= 100 then
		
		self:StartCharge( entity , owner )
		
	end
	
	--entity:SetCharging( entity:IsKeyDown() )
end


function newsa:StartCommand(entity,owner,commanddata)
	
	if entity:GetCharging() then
		
		if entity:GetClampMouseYaw() and entity:GetLastMouseMovement() ~= angle_zero then
			
			--get the mouse movement from last frame, if it exists, then approach the yaw by 45 per FrameTime()
			
			local lastang = entity:GetLastMouseMovement()
			local newang = commanddata:GetViewAngles()
			
			newang.y = math.ApproachAngle( lastang.y, newang.y, 45 * FrameTime() ) 
			
			commanddata:SetViewAngles( newang )
		end
		
		--prevent IN_JUMP and IN_DUCK from being pressed
		
		if bit.band( commanddata:GetButtons() , IN_JUMP ) > 0 then
			commanddata:SetButtons( bit.bxor( commanddata:GetButtons() , IN_JUMP ) )
		end
		
		if bit.band( commanddata:GetButtons() , IN_DUCK ) > 0 then
			commanddata:SetButtons( bit.bxor( commanddata:GetButtons() , IN_DUCK ) )
		end
		
		owner:StartSprinting()
		entity:SetLastMouseMovement( commanddata:GetViewAngles() )
	end
	
end

function newsa:Move(entity,owner,movedata)

	if entity:GetCharging() then
		
		movedata:SetForwardSpeed( owner:GetRunSpeed() + entity:GetChargeSpeed() )
		movedata:SetMaxClientSpeed( owner:GetRunSpeed() + entity:GetChargeSpeed() )
		movedata:SetMaxSpeed( owner:GetRunSpeed() + entity:GetChargeSpeed() )
		movedata:SetSideSpeed( 0 )
		movedata:SetUpSpeed( 0 )

	end
	
end

function newsa:FinishMove( entity, owner , movedata )
	if entity:GetCharging() then
		--[[
		if movedata:GetVelocity():Length() < 300 then
			self:EndCharge( entity , owner )
			return
		end
		]]
		
		
		owner:LagCompensation( true )
		
		local dir = owner:EyeAngles():Forward()
		
		local tr	=	{}
		tr.filter	=	owner
		tr.mask		=	MASK_PLAYERSOLID
		tr.start	=	owner:EyePos()
		tr.endpos	=	tr.start +  dir * 25	--avoid using aimvector, as garry's shitty context menu stuff interferes
		tr.mins		=	Vector( owner:OBBMins().x , owner:OBBMins().x , owner:OBBMins().x ) / 2
		tr.maxs		=	tr.mins * -1
		
		local result = util.TraceHull( tr )
		
		if result.Hit or result.HitWorld then
			
			local dmg = DamageInfo()
			dmg:SetAttacker( owner )
			dmg:SetInflictor( entity )
			dmg:SetDamageType( DMG_CRUSH )
			dmg:SetDamage( 100 )
			dmg:SetDamagePosition( result.HitPos )
			dmg:SetDamageForce( dir * 50000 )
			
			--owner:EmitSound( "sa_meleecharge.baseimpact" , nil , nil , nil , CHAN_WEAPON )
			if IsValid( result.Entity ) then
			
				result.Entity:DispatchTraceAttack( dmg , result )
				owner:EmitSound( "DemoCharge.HitFlesh"--[["sa_meleecharge.hitflesh"]] , nil , nil , nil , CHAN_VOICE2 )
			else
				owner:EmitSound( "DemoCharge.HitWorld"--[["sa_meleecharge.hitworld"]] , nil , nil , nil , CHAN_VOICE2 )
			end
			
			self:EndCharge( entity , owner ) --prematurely end the charge here
			
			--play the impact flinch on the player
			owner:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM , self.FlinchID )
			
			util.ScreenShake( owner:GetPos() , 25.0, 150.0, 1.0, 750 )
			
		end
		
		owner:LagCompensation( false )
	end
end

function newsa:StartCharge( entity , owner )
	entity:SetCharging( true )
	entity:SetLastMouseMovement( angle_zero )
	
	entity.ScreamingSound = CreateSound( entity , "DemoCharge.Charging" )
	entity.ScreamingSound:Play()
	if SERVER then
		local playercol = owner:GetPlayerColor()
		playercol = Color( playercol.x * 255, playercol.y * 255, playercol.z * 255) 
		entity.Trails = {
			util.SpriteTrail( owner , 0 , color_white , false,12,0,5,1,"trails/smoke.vmt" ),
		}
		entity.Trails[1]:FollowBone( owner , 2 )
	end
	--play the screaming sounds based on the player model gender, or type, like combine , zombie and shit
	--also for now add some trails on each bone for the player with the color tied to the player color
	
	--[[
		entity.ScreamingSound = CreateSound( owner , "EmptySound" )
		entity.ScreamingSound:Play()
	]]
end

function newsa:EndCharge( entity , owner )
	entity:SetCharging( false )
	
	entity:SetCharge( 0 )
	if entity.ScreamingSound then
		entity.ScreamingSound:Stop()
		entity.ScreamingSound = nil
	end
	if SERVER then
		if entity.Trails then
			for i, v in pairs( entity.Trails ) do
				if IsValid( v ) then
					v:Remove()
				end
			end
		end
	end
	--stop our own sounds from the player or entity
end

function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
end


function newsa:DrawWorldModel(entity,owner)
end


function newsa:PrePlayerDraw(entity,owner)
end


newsa.OffsetVec = Vector(6,0,2.2)
newsa.OffsetAng = Angle(0,0,-20)

function newsa:DrawShield( entity , owner , target )
	self:InitModel( entity , owner )
	
	local bone=target:LookupBone("ValveBiped.Bip01_L_Forearm")
	if not bone then return end
	
	local matrix = target:GetBoneMatrix(bone)
	if not matrix then return end
	
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	
	pos,ang=LocalToWorld(self.OffsetVec,self.OffsetAng,pos,ang)
	entity.CLModel:SetRenderOrigin(pos)
	entity.CLModel:SetRenderAngles(ang)
	entity.CLModel:SetupBones()
	entity.CLModel:DrawModel()
end

function newsa:PostPlayerDraw(entity,owner)
	self:DrawShield( entity , owner , owner )
end



function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)
	if IsValid( owner:GetHands() ) then
		self:DrawShield( entity , owner , viewmodel )
	end
end


function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)

end

function newsa:HUDDraw(entity,owner)
	--this should be smoothed in some way but I'll be damned if I can care right now
	local fuel=(entity:GetCharge())
	local x=ScrW()/2
	local y=ScrH()-(ScrH()/10)
	local maxw=ScrW()/4
	local maxh=ScrH()/25
	surface.SetDrawColor( 0,0,255,255 )
	surface.DrawRect( x-(maxw/2), y, maxw, maxh )
	
	surface.SetDrawColor( 0,250,255,255 )
	surface.DrawRect( x-(maxw/2), y, (maxw *fuel)/entity:GetMaxCharge(), maxh )
end



function newsa:PlayerUse(entity,owner,useentity)
end

function newsa:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
end

function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
	if dmginfo:IsDamageType( DMG_BLAST ) then
		dmginfo:ScaleDamage( 0.6 )
	end
	
	if dmginfo:IsDamageType( DMG_DIRECT ) or dmginfo:IsDamageType( DMG_BURN ) then
		dmginfo:ScaleDamage( 0.5 )
	end
end

function newsa:CalcMainActivity(entity,owner,velocity)
	if entity:GetCharging() and owner:OnGround() then
		local vel=velocity:Length2D()
		owner.SA_CalcIdeal = ACT_HL2MP_RUN_CHARGING
		owner.SA_CalcSeqOverride = -1
	end
end



function newsa:DoAnimationEvent(entity,owner,event,data)
	if data == self.FlinchID then
		local seq = owner:LookupSequence( "flinch_phys_01" )
		
		if not seq then return end
		
		owner:AddVCDSequenceToGestureSlot( GESTURE_SLOT_GRENADE , seq , 0 , true )
	end
end

function newsa:BuildHandsPosition(entity,owner,handsent)
	
end

function newsa:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	
end