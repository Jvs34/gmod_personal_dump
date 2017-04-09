local CLASS={}
CLASS.Model="models/player/combine"

local function SpeakCombine(pl,concept)
		local tab={
		GetRandomSound(TLK_COMBINE_RADIO_ON),
		GetRandomSound(concept),
		GetRandomSound(TLK_COMBINE_RADIO_OFF),
		}
		pl:Speaktable(tab)
end

local function IsPlayerInSniperMode(player)
	if (player:GetActiveWeapon()!=NULL && string.find(player:GetActiveWeapon():GetClass(),"sniper") )|| player:GetFOV()<=30 then
		return true
	else 
		return false;
	end
end


function CLASS:OnPlayerSpawn(ply) //Called when the player spawns with this model
	ply:StopSpeaking()//always interrupt other sounds
	ply:SetCanTalkUnderWater(true)
	ply:SetCanTalkDead(false)
	if !ply.RandomCombineName then
	ply.RandomCombineName={
		GetRandomSound(TLK_COMBINE_NAMES),
		GetRandomSound(TLK_COMBINE_NUMBERS)
	}
	end
end

function CLASS:OnNormalDamage(ply, inflictor, attacker, amount, dmginfo) //Called on normal damages
	local HealthPrev=ply:Health();
	local trivial;	
	local major;
	local critical;
	local tookpoison=false;
	local damagetype=dmginfo:GetDamageType();
	local lastdamage=dmginfo:GetDamage();
	local currenthealth=ply:Health()-dmginfo:GetDamage();
	if amount>=ply:Health() && ply:Armor()< amount/2 then return end
	trivial = (currenthealth > 75 || lastdamage < 5);	//ain't hurt.
	major = (lastdamage > 25); 		 					//That's gotta hurt
	critical = (currenthealth < 30); 					//OH MY GOD
	if lastdamage<=0 then return end
	ply:Speak(false,CLASS.Model,TLK_COMBINE_HURT_GENERIC)
		if major && critical && ply.RandomCombineName then
				local tab={
				GetRandomSound(TLK_COMBINE_RADIO_ON),
				ply.RandomCombineName[1],
				ply.RandomCombineName[2],
				GetRandomSound(TLK_COMBINE_REQ_MEDIC),
				GetRandomSound(TLK_COMBINE_RADIO_OFF)
				}
				ply:Speaktable(tab,true)
		
		end
end

function CLASS:OnWeaponReload(ply,canreload) //called when the player reloads
	if canreload then
	ply:Speak(false,CLASS.Model,TLK_COMBINE_RELOAD)
	end
end

function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) //called when the player listens
		if( concept==TLK_CONCEPT_DANGERSOUND_GRENADE)then
			if IsPlayerInSniperMode(player)then
				SpeakCombine(player,TLK_COMBINE_DANGER_GRENADE_SNIPER)
			else
				SpeakCombine(player,TLK_COMBINE_DANGER_GRENADE)
			end
		elseif concept==TLK_CONCEPT_DANGERSOUND_DEFAULT then
		SpeakCombine(player,TLK_COMBINE_DANGER)
		elseif concept== TLK_CONCEPT_DIE then
			if emitter:IsPlayer() && emitter.RandomCombineName && string.find(player:GetModel(),self.Model) then
			local tab={
			GetRandomSound(TLK_COMBINE_RADIO_ON),
			emitter.RandomCombineName[1],
			emitter.RandomCombineName[2],
			"npc/combine_soldier/vo/onedown.wav",
			"npc/combine_soldier/vo/onedown.wav",
			GetRandomSound(TLK_COMBINE_RADIO_OFF)
			}
			player:Speaktable(tab)
			end
		end
end

function CLASS:OnPlayerKillNPC(npcvictim,ply,weapon) //called when the player kills an npc
		if IsPlayerInSniperMode(ply) then
		ply:Speak(false,CLASS.Model,TLK_COMBINE_NPCKILLED_SNIPER)
		else
		ply:Speak(false,CLASS.Model,TLK_COMBINE_NPCKILLED)
		end
end

function CLASS:OnPlayerKillPlayer(ply,victim)
		if IsPlayerInSniperMode(ply) then
		ply:Speak(false,CLASS.Model,TLK_COMBINE_NPCKILLED_SNIPER)
		else
		ply:Speak(false,CLASS.Model,TLK_COMBINE_NPCKILLED)
		end
end

function CLASS:OnPlayerDeath(ply,weapon, attacker) //ugh
	ply:SetCanTalkUnderWater(true)
	ply:StopSpeaking()//always interrupt other sounds
	ply:Speak(false,CLASS.Model,TLK_COMBINE_DIE)
	ply.needreload=false;
end


function CLASS:OnPlayerFootStep(ply, pos, foot, sound, volume) //called when the player ... walks
	if foot==0 && ply:KeyDown(IN_SPEED) && !ply:Crouching() then
		ply:EmitSound("NPC_CombineS.RunFootstepRight")
	elseif ply:KeyDown(IN_SPEED)  && !ply:Crouching() then
		ply:EmitSound("NPC_CombineS.RunFootstepLeft")
	elseif foot==0 then
		ply:EmitSound("NPC_CombineS.FootStepRight")
	else
		ply:EmitSound("NPC_CombineS.FootStepLeft")
	end
	
end

/*function CLASS:OnPlayerPickupWeapon(ply,weapon)
	//done
end*/

TDS_RegisterClass(CLASS,"Every Combine model");