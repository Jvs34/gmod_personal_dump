local CLASS={}
CLASS.Model="models/player/gordon.mdl"

local ADD_TO_QUEUE=true;
local DONT_ADD_TO_QUEUE=false;
local RESTORE_AFTER_30_SECONDS=30;
local RESTORE_AFTER_5_MINUTES=300;


local function SetSuitUpdate(ply,TABB,message,seconds,bool)
		if !table.HasValue(ply.DamageTable,message) then
			ply:Speaktable(TABB,bool);
			table.insert(ply.DamageTable,message);
			timer.Simple(seconds, function() 
				if !IsValid(ply)then return end
				for	i,v in pairs (ply.DamageTable) do
					if v==message then table.remove(ply.DamageTable,i)end
				end
			end)
		end
end

function CLASS:OnPlayerSpawn(ply) //Called when the player spawns with this model
	ply:SetCanTalkDead(true)
	ply:StopSpeaking()
	ply:SetCanTalkUnderWater(true)
	if ! ply.DamageTable then
	ply.DamageTable={}
	end
end


function CLASS:OnNormalDamage(ply, inflictor, attacker, amount, dmginfo) //Called on normal damages
	if ! ply.DamageTable then
	ply.DamageTable={}
	end
local HealthPrev=ply:Health();
local trivial;	
local major;
local critical;
local tookpoison=false;
local damagetype=dmginfo:GetDamageType();
local lastdamage=amount;
local currplyhealth=ply:Health()-amount;

trivial = (currplyhealth > 75 || lastdamage < 5);	//ain't hurt.
major = (lastdamage > 25); 		 					//That's gotta hurt
critical = (currplyhealth < 30); 					//OH MY GOD
	if lastdamage<=0 then return end
	if dmginfo:IsDamageType(DMG_CRUSH) && major then 
		SetSuitUpdate(ply,TLK_HEV_DMG5,"MAJOR FRACTURE",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
	elseif dmginfo:IsDamageType(DMG_FALL) || dmginfo:IsDamageType(DMG_CRUSH) || dmginfo:IsDamageType(DMG_CLUB)then
			if major then
				SetSuitUpdate(ply,TLK_HEV_DMG6,"MAJOR FRACTURE",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
			else
				SetSuitUpdate(ply,TLK_HEV_DMG5,"MINOR FRACTURE",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
			end
	elseif dmginfo:IsDamageType(DMG_BULLET) then
		if major then
			SetSuitUpdate(ply,TLK_HEV_DMG2,"INTERNAL BLEEDING",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
			SetSuitUpdate(ply,TLK_HEV_HEAL1,"BLEEDING STOPPED",RESTORE_AFTER_30_SECONDS,ADD_TO_QUEUE)
		else	
			SetSuitUpdate(ply,TLK_HEV_DMG7,"BLOOD LOSS",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
		end
	elseif dmginfo:IsDamageType(DMG_SLASH) then
		if (major) then
			SetSuitUpdate(ply,TLK_HEV_DMG4,"MAJOR LACERATION",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
		else
			SetSuitUpdate(ply,TLK_HEV_DMG0,"MINOR LACERATION",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
		end
	elseif dmginfo:IsDamageType(DMG_SONIC) then
		if major then
			SetSuitUpdate(ply,TLK_HEV_DMG2,"INTERNAL BLEEDING",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
		end
	elseif dmginfo:IsDamageType(DMG_POISON) || dmginfo:IsDamageType(DMG_PARALIZE) then
			SetSuitUpdate(ply,TLK_HEV_DMG3,"POISON",RESTORE_AFTER_30_SECONDS,ADD_TO_QUEUE)
			SetSuitUpdate(ply,TLK_HEV_HEAL4,"ANTITOXIN",RESTORE_AFTER_30_SECONDS,ADD_TO_QUEUE)
			tookpoison=true;
	elseif dmginfo:IsDamageType(DMG_ACID) then
			SetSuitUpdate(ply,TLK_HEV_DET1,"BIOHAZARD",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
	elseif dmginfo:IsDamageType(DMG_NERVEGAS) then
			SetSuitUpdate(ply,TLK_HEV_DET0,"NERVEGAS",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
	elseif dmginfo:IsDamageType(DMG_RADIATION) then
			SetSuitUpdate(ply,TLK_HEV_DET2,"RADIATION",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
	elseif dmginfo:IsDamageType(DMG_SHOCK) then
			SetSuitUpdate(ply,TLK_HEV_DMG_SHOCK,"SHOCK",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
	elseif dmginfo:IsDamageType(DMG_BURN) then
			SetSuitUpdate(ply,TLK_HEV_DMG_HEAT,"HEAT",RESTORE_AFTER_30_SECONDS,DONT_ADD_TO_QUEUE)
	end
	
	if !trivial && major && HealthPrev >= 75 && !tookpoison then
		SetSuitUpdate(ply,TLK_HEV_MED1,"AUTOMEDIC_ON",RESTORE_AFTER_5_MINUTES,ADD_TO_QUEUE)
		SetSuitUpdate(ply,TLK_HEV_HEAL7,"MORPHINE",RESTORE_AFTER_5_MINUTES,ADD_TO_QUEUE)
	end
	
	if (!trivial && critical && HealthPrev < 75 && !tookpoison)then
		if currplyhealth<6 then
		SetSuitUpdate(ply,TLK_HEV_HLTH3,"NEARDEATH",RESTORE_AFTER_30_SECONDS,ADD_TO_QUEUE)
		elseif currplyhealth<20 then
		SetSuitUpdate(ply,TLK_HEV_HLTH2,"HEALTHCRITICAL",RESTORE_AFTER_30_SECONDS,ADD_TO_QUEUE)
		end
		
		if math.random(0,3)==0 && HealthPrev < 50 then
		SetSuitUpdate(ply,TLK_HEV_DMG8,"SEEKMEDICALATTENTION",RESTORE_AFTER_30_SECONDS,ADD_TO_QUEUE)
		end
	end
end

function CLASS:OnWeaponReload(ply,canreload) //called when the player reloads
	if !canreload then ply:Speaktable(TLK_HEV_AMMODEPLETED) end
end

function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) //called when the player listens
		if(concept==TLK_CONCEPT_DANGERSOUND_DEFAULT || concept==TLK_CONCEPT_DANGERSOUND_GRENADE)then
		SetSuitUpdate(player,{"hl1/fvox/evacuate_area.wav"},"DANGER",RESTORE_AFTER_30_SECONDS)
		end
end


function CLASS:OnPlayerDeath(ply,weapon, attacker) //ugh
	ply:StopSpeaking()//always interrupt other sounds
	if math.random(1,2) == 1 then
	ply:Speaktable(TLK_HEV_USERDEAD0)
	else
	ply:Speaktable(TLK_HEV_USERDEAD1)
	end
	ply:SpeakSilent(TLK_CONCEPT_DIE)//silent sound,so others can hear that we died.
	ply.needreload=false;
	if ply.DamageTable then table.Empty(ply.DamageTable) end
end


TDS_RegisterClass(CLASS,"The holy gordon freeman model");