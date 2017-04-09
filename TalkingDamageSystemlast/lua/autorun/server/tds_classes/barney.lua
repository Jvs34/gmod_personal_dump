local CLASS={}
CLASS.Model="models/player/barney.mdl"

/*function CLASS:OnPlayerThink(ply) 
	//Called when the player thinks
end*/

function CLASS:OnPlayerSpawn(ply)
	ply:SetCanTalkDead(false)
	ply:StopSpeaking()//always interrupt other sounds
	ply.TalkTimer=CurTime()+0.3
	ply:SetCanTalkUnderWater(false)
	
end

/*function CLASS:OnTraceDamage(ply,hitgroup,dmginfo) 
	//Called when the player received a trace damage
end*/

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
	if major then 
	ply:Speak(false,CLASS.Model,TLK_BARNEY_HURT_HEAVY)
	else
	ply:Speak(false,CLASS.Model,TLK_BARNEY_HURT)
	end
		if major && critical then
				ply:Speaktable({GetRandomSound(TLK_BARNEY_WOUNDED)},true)
		end
end

/*function CLASS:OnWeaponReload(ply,canreload) 
	//called when the player reloads
end*/

function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) 
		if(concept==TLK_CONCEPT_DANGERSOUND_DEFAULT || concept==TLK_CONCEPT_DANGERSOUND_GRENADE)then
		player:Speak(false,CLASS.Model,TLK_BARNEY_DANGER)
		end
end

function CLASS:OnPlayerKillNPC(npcvictim,ply,weapon) 
	ply:Speak(false,CLASS.Model,TLK_BARNEY_NPC_KILL)
end

function CLASS:OnPlayerKillPlayer(ply,victim)
	ply:Speak(false,CLASS.Model,TLK_BARNEY_NPC_KILL)
end

function CLASS:OnPlayerDeath(ply,weapon, attacker) 
	ply:StopSpeaking()//always interrupt other sounds
	ply:Speak(false,CLASS.Model,TLK_BARNEY_DIE)
end

/*function CLASS:OnPlayerUse(ply, entity) 
	//called when the player +use something,eg:useful for valve entities
end*/

//you may tell me,"THIS IS SILLY!",well,barney is actually using metropolice suit,so he should play these sounds
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

function CLASS:OnPlayerPickupWeapon(ply,weapon)
	ply:Speak(false,CLASS.Model,TLK_BARNEY_WEAPON_PICKUP)
end

TDS_RegisterClass(CLASS,"The Good Ol' Barney");