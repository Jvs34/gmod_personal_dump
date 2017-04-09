local CLASS={}
CLASS.Model="models/player/group"


function CLASS:OnPlayerSpawn(ply) //Called when the player spawns with this model
	ply:StopSpeaking()//always interrupt other sounds
	ply:SetCanTalkDead(false)
	ply:SetCanTalkUnderWater(false)
end

function CLASS:OnTraceDamage(ply,hitgroup,dmginfo) //Called when the player received a trace damage
		local attacker=dmginfo:GetAttacker();
		
				if ( hitgroup == HITGROUP_HEAD ) then
					ply:Speak(true,"/male",TLK_CIT_MALE_HURT_HEAVY,"/female",TLK_CIT_FEMALE_HURT_HEAVY)
				elseif ( hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM ) then
					ply:Speak(true,"/male",TLK_CIT_MALE_HURT_ARM,"/female",TLK_CIT_FEMALE_HURT_ARM)
				elseif ( hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG ) then
					ply:Speak(true,"/male",TLK_CIT_MALE_HURT_LEG,"/female",TLK_CIT_FEMALE_HURT_LEG)
				elseif ( hitgroup == HITGROUP_CHEST ) then
					ply:Speak(true,"/male",TLK_CIT_MALE_HURT_GENERIC,"/female",TLK_CIT_FEMALE_HURT_GENERIC)
				elseif ( hitgroup == HITGROUP_STOMACH ) then
					ply:Speak(true,"/male",TLK_CIT_MALE_HURT_GUT,"/female",TLK_CIT_FEMALE_HURT_GUT)
				else
					ply:Speak(true,"/male",TLK_CIT_MALE_HURT_GENERIC,"/female",TLK_CIT_FEMALE_HURT_GENERIC)
				end
end

function CLASS:OnNormalDamage(ply, inflictor, attacker, amount, dmginfo) //Called on normal damages
			if amount>=ply:Health() && ply:Armor()< amount/2 then return end
			if(dmginfo:GetDamage()<=10)then
				ply:Speak(true,"/male",TLK_CIT_MALE_HURT_GENERIC,"/female",TLK_CIT_FEMALE_HURT_GENERIC)
			else
				ply:Speak(true,"/male",TLK_CIT_MALE_HURT_HEAVY,"/female",TLK_CIT_FEMALE_HURT_HEAVY)
			end
end

function CLASS:OnWeaponReload(ply,canreload) //called when the player reloads
	if canreload then ply:Speak(true,"/male",TLK_CIT_MALE_RELOAD,"/female",TLK_CIT_FEMALE_RELOAD) end
end

function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) //called when the player listens
		if(concept==TLK_CONCEPT_DIE)then
		player:Speak(true,"/male",TLK_CIT_MALE_SQUAD_MEMBER_DEAD,"/female",TLK_CIT_FEMALE_SQUAD_MEMBER_DEAD)
		elseif(concept==TLK_CONCEPT_DANGERSOUND_DEFAULT || concept==TLK_CONCEPT_DANGERSOUND_GRENADE)then
		player:Speak(true,"/male",TLK_CIT_MALE_DANGER,"/female",TLK_CIT_FEMALE_DANGER)
		end
end

function CLASS:OnPlayerKillNPC(npcvictim,ply,weapon) //called when the player kills an npc
		if(npcvictim:GetClass()=="npc_strider")then
		ply:Speak(true,"/male",TLK_CIT_MALE_CHEER,"/female",TLK_CIT_MALE_CHEER)
		else
		ply:Speak(true,"/male",TLK_CIT_MALE_NPCKILLED,"/female",TLK_CIT_FEMALE_NPCKILLED)
		end
end

function CLASS:OnPlayerKillPlayer(ply,victim)
	ply:Speak(true,"/male",TLK_CIT_MALE_NPCKILLED,"/female",TLK_CIT_FEMALE_NPCKILLED)
end

function CLASS:OnPlayerDeath(ply,weapon, attacker) //ugh
	ply:StopSpeaking()//always interrupt other sounds
	ply:Speak(true,"/male",TLK_CIT_MALE_HURT_HEAVY,"/female",TLK_CIT_FEMALE_HURT_HEAVY)
	ply:SpeakSilent(TLK_CONCEPT_DIE)//silent sound,so others can hear that we died.
end

/*function CLASS:OnPlayerUse(ply, entity) //called when the player +use something,eg:useful for valve entities
	//done
end*/

/*function CLASS:OnPlayerFootStep(ply, pos, foot, sound, volume) //called when the player ... walks
	//done
end*/

function CLASS:OnPlayerPickupWeapon(ply,weapon)
	ply:Speak(true,"/male",TLK_CIT_MALE_WEP_PICKUP,"/female",TLK_CIT_FEMALE_WEP_PICKUP)
end


function CLASS:OnPlayerChatter(ply,number)
	if number==1 then
		ply:Speak(true,"/male",TLK_CIT_MALE_QUESTION,"/female",TLK_CIT_FEMALE_QUESTION)
			timer.Simple(SoundDuration(ply.LastSound),function()
				if !IsValid(ply)then return end
				local foundcandidate=false;
				local foundent=nil;
				
				for i,v in pairs(ents.FindInSphere(ply:GetShootPos(),768)) do
					if(!foundcandidate)then
						if(IsValid(v) && v:IsNPC() && v:GetClass()=="npc_citizen")then
							foundcandidate=true;
							foundent=v;
						end
					end
				end
				if(foundcandidate && IsValid(foundent))then
					foundent:Fire("SpeakIdleResponse")
				end
			end) //SearchResponseCitizen(ply)
	elseif number==2 then
		ply:Speak(true,"/male",TLK_CIT_MALE_ANSWER,"/female",TLK_CIT_FEMALE_ANSWER)
	elseif number==3 then
		ply:Speak(true,"/male",TLK_CIT_MALE_SQUAD_FOLLOWME,"/female",TLK_CIT_FEMALE_SQUAD_FOLLOWME)
	elseif number==4 then
		ply:Speak(true,"/male",TLK_CIT_MALE_IDLE,"/female",TLK_CIT_FEMALE_IDLE)
	elseif number==5 then
		ply:Speak(true,"/male",TLK_CIT_MALE_SQUAD_JOIN,"/female",TLK_CIT_FEMALE_SQUAD_JOIN)
	end
end


TDS_RegisterClass(CLASS,"Citizen/Rebel Models");