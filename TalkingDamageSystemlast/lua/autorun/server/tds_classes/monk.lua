local CLASS={}
CLASS.Model="models/player/monk.mdl"

function CLASS:OnPlayerSpawn(ply) 
	ply:SetCanTalkDead(false)
	ply:StopSpeaking()
	ply:SetCanTalkUnderWater(false)
end

function CLASS:OnNormalDamage(ply, inflictor, attacker, amount, dmginfo) 
			if amount>=ply:Health() && ply:Armor()< amount/2 then return end
			if(dmginfo:GetDamage()<=25)then
				ply:Speak(false,CLASS.Model,TLK_MONK_HURT)
			else
				ply:Speak(false,CLASS.Model,TLK_MONK_HURT_HEAVY)
			end
end



function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) 
		if(concept==TLK_CONCEPT_DIE)then
		player:Speak(false,CLASS.Model,TLK_MONK_BROTHER_DEAD)
		elseif(concept==TLK_CONCEPT_DANGERSOUND_DEFAULT || concept==TLK_CONCEPT_DANGERSOUND_GRENADE)then
		player:Speak(false,CLASS.Model,TLK_MONK_DANGER)
		end
end

function CLASS:OnPlayerKillNPC(npcvictim,ply,weapon) 
	if string.find(npcvictim:GetClass(),"zombie")then //not zombi,because with zombi we could specify npc_zombine,and that's not an human
	ply:Speak(false,CLASS.Model,TLK_MONK_ZOMBIE_KILL)
	else
	ply:Speak(false,CLASS.Model,TLK_MONK_NPC_KILL)
	end
end

function CLASS:OnPlayerKillPlayer(ply,victim)
	if string.find(npcvictim:GetClass(),"zombie")then //not zombi,because with zombi we could specify npc_zombine,and that's not an human
	ply:Speak(false,CLASS.Model,TLK_MONK_ZOMBIE_KILL)
	else
	ply:Speak(false,CLASS.Model,TLK_MONK_NPC_KILL)
	end
end

function CLASS:OnPlayerDeath(ply,weapon, attacker) 
	ply:StopSpeaking()//always interrupt other sounds
	ply:Speak(false,CLASS.Model,TLK_MONK_DIE)
end


TDS_RegisterClass(CLASS,"Father Grigori Model");