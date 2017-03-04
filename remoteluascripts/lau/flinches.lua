local flinchtable={
	[HITGROUP_GENERIC]	= "flinch_02",
	[HITGROUP_HEAD]		= "flinch_head_01",
	[HITGROUP_LEFTARM]	= "flinch_shoulder_l",
	[HITGROUP_RIGHTARM]	= "flinch_shoulder_r",
	[HITGROUP_STOMACH] 	= "flinch_stomach_01",
	[HITGROUP_CHEST] 		= "flinch_phys_01",
	
}
--[[

	HITGROUP_RIGHTARM - (number - 5)
	HITGROUP_CHEST - (number - 2)
	HITGROUP_GENERIC - (number - 0)
	HITGROUP_STOMACH - (number - 3)
	HITGROUP_GEAR - (number - 10)
	HITGROUP_RIGHTLEG - (number - 7)
	HITGROUP_LEFTLEG - (number - 6)
	HITGROUP_HEAD - (number - 1)
	HITGROUP_LEFTARM - (number - 4)


]]

--[[
label	=	flinch_01
activityname	=	ACT_FLINCH

label	=	flinch_02
activityname	=	ACT_FLINCH

label	=	flinch_back_01
activityname	=	ACT_FLINCH_BACK

label	=	flinch_head_01
activityname	=	ACT_FLINCH_HEAD

label	=	flinch_head_02
activityname	=	ACT_FLINCH_HEAD

label	=	flinch_phys_01
activityname	=	ACT_FLINCH_PHYSICS

label	=	flinch_phys_02
activityname	=	ACT_FLINCH_PHYSICS
label	=	flinch_shoulder_l
activityname	=	ACT_FLINCH_SHOULDER_LEFT

label	=	flinch_shoulder_r
activityname	=	ACT_FLINCH_SHOULDER_RIGHT

label	=	flinch_stomach_01
activityname	=	ACT_FLINCH_STOMACH

label	=	flinch_stomach_02
activityname	=	ACT_FLINCH_STOMACH
]]




hook.Add("PlayerTraceAttack","Flinches",function( ply , dmginfo,dir,tr)
	
	
	ply:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_CHEST , tr.HitGroup )
	
end)


hook.Add("DoAnimationEvent","Flinches",function( ply, event, data )
	if event==PLAYERANIMEVENT_FLINCH_CHEST then
		local anim = flinchtable[data] or "flinch_01"
		
		
		if not anim then return end
		
		local seq = ply:LookupSequence( anim )
		
		if not seq then return end
		
		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD , seq , 0 , true )
		return ACT_INVALID
	end
end)

