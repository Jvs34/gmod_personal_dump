//-------------------------------------------------
//Script made entirely by Jvs,a nice talking style|
//when you get hurt,just like the rebel npcs does |
//-------------------------------------------------

//-------------------------------------------------
//Let's the player advice anyone that he just seen an enemy. 
//-------------------------------------------------

local NpcSeenClearTime=60;//Let's clear the NpcSeen table every NpcSeenClearTime seconds

function ClearNpcTable()
		for _, ply in pairs( player.GetAll() ) do
			if string.find(ply:GetModel(),"/player/group")then
			table.Empty(ply.NpcSeen)
			end
		end
end

timer.Create( "NpcClearTime", NpcSeenClearTime, 0, ClearNpcTable )

function NpcAdvice()
	for _, ply in pairs(player.GetAll()) do
		if(string.find(ply:GetModel(),"/player/group") && ply:Alive())then
				local ConeEnts = ents.FindInCone(ply:GetPos(),ply:GetAimVector(),2000,90);
				local snd;
				for i, pEnt in ipairs(ConeEnts) do
					if pEnt:IsNPC() && !table.HasValue( ply.NpcSeen,pEnt:GetClass() ) then
						if(string.find(pEnt:GetClass(),"npc_combine_s"))then//combine!
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_COMBINE,"/female",TLK_CIT_FEMALE_SEEN_COMBINE)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"zombi"))then//ZOmbieeeees
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_ZOMBIE,"/female",TLK_CIT_FEMALE_SEEN_ZOMBIE)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"npc_strider"))then //fucking bullseye...
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_STRIDER,"/female",TLK_CIT_FEMALE_SEEN_STRIDER) then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"gunship"))then//GUNSHEEEP
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_GUNSHIP,"/female",TLK_CIT_FEMALE_SEEN_GUNSHIP)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"dropship"))then//DROPSHEEEP
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_DROPSHIP,"/female",TLK_CIT_FEMALE_SEEN_DROPSHIP)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"headcrab"))then//HADCRABS!oh wait..
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_HEADCRAB,"/female",TLK_CIT_FEMALE_SEEN_HEADCRAB)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"scanner"))then//Scanners!
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_SCANNER,"/female",TLK_CIT_FEMALE_SEEN_SCANNER)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"police"))then//CIVIL PROTECTION!
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_POLICE,"/female",TLK_CIT_FEMALE_SEEN_POLICE)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						elseif(string.find(pEnt:GetClass(),"hack"))then//HAAAAAAAAX!*monitor right to the face*
							if ply:Speak(true,"/male",TLK_CIT_MALE_SEEN_MANHACK,"/female",TLK_CIT_FEMALE_SEEN_MANHACK)then
							table.insert(ply.NpcSeen,pEnt:GetClass());
							end
						else
							table.insert(ply.NpcSeen,pEnt:GetClass());
						end

					end	
				
				end
			
		end
	end
end

hook.Add("Think","NpcAdvice",NpcAdvice)

//-------------------------------------------------
//This hooks gets only called for bullets. 
//-------------------------------------------------

function HitLocation( ply, hitgroup, dmginfo ) 
	if(!string.find(ply:GetModel(),"/player/group"))then return end
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
hook.Add( "ScalePlayerDamage", "HitLocation", HitLocation )

//-------------------------------------------------
//Hooking PlayerSpawn is stupid,oh well.
//-------------------------------------------------

function PlayerDMGTimer(ply)
	ply.TalkTimer=CurTime()+0.5;//the 0.5 prevents the player from speaking when equipping the spawn loadout weapons.
end
hook.Add("PlayerSpawn", "PlayerDMGTimer", PlayerDMGTimer);

//-------------------------------------------------
//Well,we just init the player vars here.
//-------------------------------------------------

function DMGPlayerInitialSpawn(pl)
pl.TalkTimer=CurTime();
pl.NpcSeen = {}

end 
hook.Add("PlayerInitialSpawn", "DMGPlayerInitialSpawn", DMGPlayerInitialSpawn);

//-------------------------------------------------
//Let's make the player shout a dramatic "NOOOOOO" when he just die.
//-------------------------------------------------

local function PlayerDeathDMG(ply) //noone likes to die
if(!string.find(ply:GetModel(),"/player/group"))then return end
	ply:StopSpeaking()//always interrupt other sounds
	ply:Speak(true,"/male",TLK_CIT_MALE_HURT_HEAVY,"/female",TLK_CIT_FEMALE_HURT_HEAVY)
	ply:SpeakSilent(TLK_CONCEPT_DIE)//silent sound,so others can hear that we died.
	table.Empty(ply.NpcSeen)
	ply.needreload=false;
end
hook.Add("PlayerDeath", "PlayerDeathDMG", PlayerDeathDMG);

//-------------------------------------------------
//i just killed a npc,cheers!
//-------------------------------------------------

function OnNPCKilledDMG( ent, attacker, inflictor )
if(ent:GetClass()== "npc_turret_floor")then return end //fucking turrets.. always ruining my hooks!
if(attacker:GetModel()==nil)then return end
if(!string.find(attacker:GetModel(),"/player/group"))then return end
	local snd;
	if(IsValid(attacker) && attacker:IsPlayer())then
	
		if(ent:GetClass()=="npc_strider")then
		attacker:Speak(true,"/male",TLK_CIT_MALE_CHEER,"/female",TLK_CIT_MALE_CHEER)
		else
		attacker:Speak(true,"/male",TLK_CIT_MALE_NPCKILLED,"/female",TLK_CIT_FEMALE_NPCKILLED)
		end
	end
end
hook.Add("OnNPCKilled", "OnNPCKilledDMG", OnNPCKilledDMG);

//-------------------------------------------------
//like the rebels in hl2,we just cheers when we pickup a new weapon
//-------------------------------------------------
	

function PlayerCanPickupWeaponDMG( player, entity )
if(!string.find(player:GetModel(),"/player/group"))then return end
			if !player:HasWeapon(entity:GetClass())then
				player:Speak(true,"/male",TLK_CIT_MALE_WEP_PICKUP,"/female",TLK_CIT_FEMALE_WEP_PICKUP)
			end
end
hook.Add("PlayerCanPickupWeapon", "PlayerCanPickupWeaponDMG", PlayerCanPickupWeaponDMG);

//-------------------------------------------------
//The player took a damage that isn't a bullet damage (little lie,it does call this hooks,but i need other type of damages)
//-------------------------------------------------

function PlayerTakeDMG( ent, inflictor, attacker, amount, dmginfo ) 
if(ent:GetModel()==nil)then return end
if(attacker:GetModel()==nil)then return end
if !ent:IsPlayer() then return end
	if(!string.find(ent:GetModel(),"/player/group"))then return end
 //if i'm a player,and i didn't receive a bullet in my body then do this,because the ScaleplayerDamage does the rest
  //why these are two different hooks?Because this is for the whole damages,and the other one is just for bullets.
			if(dmginfo:GetDamage()<=10)then
				ent:Speak(true,"/male",TLK_CIT_MALE_HURT_GENERIC,"/female",TLK_CIT_FEMALE_HURT_GENERIC)
				else
				ent:Speak(true,"/male",TLK_CIT_MALE_HURT_HEAVY,"/female",TLK_CIT_FEMALE_HURT_HEAVY)
				end
end
hook.Add("EntityTakeDamage", "PlayerTakeDMG", PlayerTakeDMG)

//-------------------------------------------------
//The player is reloading,let's inform everyone.
//-------------------------------------------------

function PlReloading()
	for _, ply in pairs(player.GetAll()) do
		if(string.find(ply:GetModel(),"/player/group") && ply:Alive() && ply:GetActiveWeapon() != NULL )then
			if(ply:GetActiveWeapon():Clip1()>0)then
				ply.needreload=true;
			elseif(ply:GetActiveWeapon():Clip1()==0 && ply.needreload==true && ply:GetActiveWeapon():GetClass() != "weapon_physcannon")then
				if(ply:GetActiveWeapon():Clip1()==0 && ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) == 0)then
				//missing,"UH-OH"
				ply.needreload=false;
				else
				ply:Speak(true,"/male",TLK_CIT_MALE_RELOAD,"/female",TLK_CIT_FEMALE_RELOAD)
				ply.needreload=false;
				end
			end
		end
	end
end
hook.Add( "Think", "PlReloading", PlReloading )

//-------------------------------------------------
//The player listened to a sound.
//-------------------------------------------------

function OnPlayerListenToSound_citizen_module(player,emitter,sound,concept)
	
	timer.Simple(SoundDuration(sound)+1, function() 
		if(concept==TLK_CONCEPT_DIE)then
		player:Speak(true,"/male",TLK_CIT_MALE_SQUAD_MEMBER_DEAD,"/female",TLK_CIT_FEMALE_SQUAD_MEMBER_DEAD)
		elseif(concept==TLK_CONCEPT_QUESTION)then
		player:Speak(true,"/male",TLK_CIT_MALE_ANSWER,"/female",TLK_CIT_FEMALE_ANSWER)
		end
	end)
end

//-------------------------------------------------
//The player wants to speak a concept via command,let's allow it.
//-------------------------------------------------

function CitModuleSpeak( player, command, arguments )
	local sentencespeak = arguments[1]
	if !sentencespeak then return end
	if(sentencespeak == "question")then
	
		player:Speak(true,"/male",TLK_CIT_MALE_QUESTION,"/female",TLK_CIT_FEMALE_QUESTION)
	
	elseif(sentencespeak == "followme")then
	
		player:Speak(true,"/male",TLK_CIT_MALE_SQUAD_FOLLOWME,"/female",TLK_CIT_FEMALE_SQUAD_FOLLOWME)
	
	elseif(sentencespeak == "traitor")then
	
		player:Speak(true,"/male",TLK_CIT_MALE_SQUAD_TRAITOR,"/female",TLK_CIT_FEMALE_SQUAD_TRAITOR)

	elseif(sentencespeak == "tookposition")then
		
		player:Speak(true,"/male",TLK_CIT_MALE_SQUAD_POSITION,"/female",LK_CIT_FEMALE_SQUAD_POSITION)
	
	elseif(sentencespeak == "waiting")then
		
		player:Speak(true,"/male",TLK_CIT_MALE_IDLE,"/female",TLK_CIT_FEMALE_IDLE)
	
	elseif(sentencespeak == "cheer")then
		
		player:Speak(true,"/male",TLK_CIT_MALE_CHEER,"/female",TLK_CIT_FEMALE_CHEER)
	
	end
end

function CitizenAutoComplete( cmdname, args )

	local rettable = { "question", "followme","traitor","tookposition","waiting","cheer"}
	for i = 1, #rettable do
		rettable[i] = cmdname .. args .. rettable[i]
	end
	return rettable
	
end

concommand.Add( "speak_citizen", CitModuleSpeak,CitizenAutoComplete)