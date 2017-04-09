local CLASS={}
CLASS.Model="models/player/police.mdl"


function CLASS:OnPlayerSpawn(ply) 
	ply:StopSpeaking()//always interrupt other sounds
	ply:SetCanTalkUnderWater(true)
	ply:SetCanTalkDead(false)
	/*
	if !ply.RandomPoliceName then
	ply.RandomPoliceName={
		GetRandomSound(TLK_POLICE_NAMES),
		GetRandomSound(TLK_POLICE_NUMBERS)
	}
	end*/
end


function CLASS:OnNormalDamage(ply, inflictor, attacker, amount, dmginfo) 
	local HealthPrev=ply:Health();
	local trivial;	
	local major;
	local critical;
	local damagetype=dmginfo:GetDamageType();
	local lastdamage=dmginfo:GetDamage();
	local currenthealth=ply:Health()-dmginfo:GetDamage();
	if amount>=ply:Health() && ply:Armor()< amount/2 then return end
	trivial = (currenthealth > 75 || lastdamage < 5);	//ain't hurt.
	major = (lastdamage > 25); 		 					//That's gotta hurt
	critical = (currenthealth < 30); 					//OH MY GOD
	if lastdamage<=0 then return end
	ply:Speak(false,CLASS.Model,TLK_POLICE_PAIN)
	
	if !major && HealthPrev >=95 && IsValid(attacker) then
		ply:Speaktable(TLK_POLICE_PAIN_LIGHT,true)
	end
	
	if !trivial && major && HealthPrev >= 75 && IsValid(attacker) then
		ply:Speaktable(GetRandomSound(TLK_POLICE_RANDOM_PAIN_HEAVY),true)
	end
	
	if !trivial && critical && HealthPrev < 75 && IsValid(attacker)  then
		ply:Speaktable(GetRandomSound(TLK_POLICE_RANDOM_HEAVY_DMG),true)
	end
end

function CLASS:OnWeaponReload(ply,canreload)
	if canreload then
	ply:Speaktable(TLK_POLICE_RELOADING)
	else
	ply:Speaktable(TLK_POLICE_NOAMMOLEFT)
	end
end

function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) 
		if( concept==TLK_CONCEPT_DANGERSOUND_GRENADE)then
			player:Speaktable(GetRandomSound(TLK_POLICE_RANDOM_DANGER_GRENADE),true)
		elseif concept==TLK_CONCEPT_DANGERSOUND_DEFAULT then
			player:Speaktable(GetRandomSound(TLK_POLICE_RANDOM_DANGER),true)
		end
end

function CLASS:OnPlayerKillNPC(npcvictim,ply,weapon) 
	ply:Speaktable(GetRandomSound(TLK_POLICE_RANDOM_KILL),false)
end

function CLASS:OnPlayerKillPlayer(ply,victim)
	ply:Speaktable(GetRandomSound(TLK_POLICE_RANDOM_KILL),false)
end

function CLASS:OnPlayerDeath(ply,weapon, attacker)
	ply:SetCanTalkUnderWater(true)
	ply:StopSpeaking()//always interrupt other sounds
	ply:Speak(false,CLASS.Model,TLK_POLICE_DIE)
	ply.needreload=false;
end


function CLASS:OnPlayerFootStep(ply, pos, foot, sound, volume) //called when the player ... walks
	if foot==0 && ply:KeyDown(IN_SPEED) && !ply:Crouching() then
		ply:EmitSound("NPC_MetroPolice.RunFootstepRight")
	elseif ply:KeyDown(IN_SPEED)  && !ply:Crouching() then
		ply:EmitSound("NPC_MetroPolice.RunFootstepLeft")
	elseif foot==0 then
		ply:EmitSound("Tile.StepRight")
	else
		ply:EmitSound("Tile.StepLeft")
	end
end


TDS_RegisterClass(CLASS,"Default Player Model");