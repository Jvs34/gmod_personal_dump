local CLASS={}
CLASS.Model="models/player/kleiner.mdl"
	/*
	Let's get started.
	This new system might be cooler and all for a lua scripter,but it slowdown the server
	alot with at least 20 classes files.
	So:to improve performances for the server,if you don't use some hooks in this file,just
	comment it out,for istance,you don't use the OnPlayerThink,right? comment it out
	so the server will not call it.	
	*/
function CLASS:OnPlayerThink(ply) 
	//Called when the player thinks
end

function CLASS:OnPlayerSpawn(ply) 
	//Called when the player spawns with this model
end

function CLASS:OnTraceDamage(ply,hitgroup,dmginfo) 
	//Called when the player received a trace damage
end

function CLASS:OnNormalDamage(ply, inflictor, attacker, amount, dmginfo) 
	//Called on normal damages
end

function CLASS:OnWeaponReload(ply,canreload) 
	//called when the player reloads
end

function CLASS:OnPlayerListenToSound(player,emitter,sound,concept) 
	//called when the player listens
end

function CLASS:OnPlayerKillNPC(npcvictim,ply,weapon) 
	//called when the player kills an npc
end

function CLASS:OnPlayerKillPlayer(ply,victim)
	//called when the player kills an another player
end

function CLASS:OnPlayerDeath(ply,weapon, attacker) 
	//called on player death
end

function CLASS:OnPlayerUse(ply, entity) 
	//called when the player +use something,eg:useful for valve entities
end

function CLASS:OnPlayerFootStep(ply, pos, foot, sound, volume) 
	//called when the player ... walks
	//i must warn you that this functions overrides the default OnPlayerfootstep,if you want normal
	//footsteps and not custom ones just comment this entire function
end

function CLASS:OnPlayerPickupWeapon(ply,weapon)
	//called when the player pickups a weapon
end

function CLASS:OnPlayerChatter(ply,number)
	//called when the player used the command "tds_chatter x",where x stands for any number you may want to specify in this command
	//this is called only when the player is valid,alive,can speak the parameter "number" is actually a number > 0 and <.
end

TDS_RegisterClass(CLASS,"Default Player Model");