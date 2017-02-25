
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "ai_translations.lua" )

SWEP.Weight				= 0			// Decides whether we should switch from/to this
SWEP.AutoSwitchTo		= true		// Auto switch to if we pick it up
SWEP.AutoSwitchFrom		= true		// Auto switch from if you pick up a better weapon

/*---------------------------------------------------------
   Name: OnDrop
   Desc: Weapon was dropped
---------------------------------------------------------*/
function SWEP:OnDrop()

	if ( ValidEntity( self.Weapon ) ) then
		// self.Weapon:Remove()
	end

end

/*---------------------------------------------------------
   Name: GetCapabilities
   Desc: For NPCs, returns what they should try to do with it.
---------------------------------------------------------*/
function SWEP:GetCapabilities()

	return CAP_WEAPON_MELEE_ATTACK1 | CAP_INNATE_MELEE_ATTACK1

end


	local ActIndex = {}
		ActIndex[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2

	function SWEP:SetWeaponHoldType( t )

		local index 								= ActIndex[ t ]
			
		if (index == nil) then
			return
		end

		self.ActivityTranslate 							= {}
		self.ActivityTranslate [ ACT_HL2MP_IDLE ] 			= index
		self.ActivityTranslate [ ACT_HL2MP_WALK ] 			= index + 1
		self.ActivityTranslate [ ACT_HL2MP_RUN ] 				= index + 2
		self.ActivityTranslate [ ACT_HL2MP_IDLE_CROUCH ] 		= index + 3
		self.ActivityTranslate [ ACT_HL2MP_WALK_CROUCH ] 		= index + 4
		self.ActivityTranslate [ ACT_HL2MP_GESTURE_RANGE_ATTACK ] 	= index + 5
		self.ActivityTranslate [ ACT_HL2MP_GESTURE_RELOAD ] 		= index + 6
		self.ActivityTranslate [ ACT_HL2MP_JUMP ] 			= index + 7
		self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 			= index + 8
	
		self:SetupWeaponHoldTypeForAI( t )
	end