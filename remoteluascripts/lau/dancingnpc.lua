local ENT={}
ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:Initialize()
	if CLIENT then return end
	local model,shit=table.Random(player_manager.AllValidModels())

	self:SetModel( model );
	self:SetHealth(100)
	--self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)
end

function ENT:BehaveAct()
	--self:StartActivity( ACT_HL2MP_IDLE_SCARED )							-- walk anims
end



--[[
function ENT:Think()
	
	self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)
	self:NextThink(CurTime()+1)
end
]]

function ENT:PlaySequenceAndWait2( name, speed , lesstime )
	lesstime= lesstime or 0
	local len = self:SetSequence( name )
	speed = speed or 1
	
	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed  )

	-- wait for it to finish
	coroutine.wait( (len / speed) - lesstime )

end



function ENT:RunBehaviour()

	while ( true ) do

		-- walk somewhere random
		--self:StartActivity( ACT_VICTORY_DANCE )
		--self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)
		self:PlaySequenceAndWait2( "taunt_dance" , 1 , 1 )							-- Sit on the floor
		
		--self:PlaySequenceAndWait( "taunt_cheer" , 1,1)
		--self:PlaySequenceAndWait( "taunt_muscle" , 1,1)							-- Sit on the floor
		--self:PlaySequenceAndWait( "taunt_persistence" , 1)							-- Sit on the floor
	
		
		coroutine.yield()

	end


end

function ENT:OnInjured( damageinfo )
	local ent=damageinfo:GetAttacker()
	ent:TakeDamageInfo(damageinfo)
	
	--self.loco:Jump()
	damageinfo:SetDamage(0)
	self:EmitSound("citadel.br_no")
		
end

function ENT:OnKilled( damageinfo )
	self:BecomeRagdoll( damageinfo )
	self:EmitSound("citadel.br_youneedme")
end

scripted_ents.Register(ENT,"npc_dancing_npc",true)