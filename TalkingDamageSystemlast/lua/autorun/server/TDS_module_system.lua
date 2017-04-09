include("autorun/sh_tds_concepts.lua")
TDS_includefolder( "autorun/server/tds_sounds")
local CLASSES_TABLE={}

local NULL_FUNCTION=function()end

function TDS_RegisterClass(classtable,classname)
	classtable.Description=classname;
	table.insert(CLASSES_TABLE,classtable);
	print("TDS: Registered class",classname)
end

local function TDS_AddPlayerHooks(ply,module)
	ply.OnPlayerListenToSound=module.OnPlayerListenToSound or NULL_FUNCTION
	ply.OnTraceDamage=module.OnTraceDamage or NULL_FUNCTION
	ply.OnPlayerSpawn=module.OnPlayerSpawn or NULL_FUNCTION
	ply.OnNormalDamage=module.OnNormalDamage or NULL_FUNCTION
	ply.OnPlayerThink=module.OnPlayerThink or NULL_FUNCTION
	ply.OnWeaponReload=module.OnWeaponReload or NULL_FUNCTION
	ply.OnPlayerPickupWeapon=module.OnPlayerPickupWeapon or NULL_FUNCTION
	ply.OnPlayerDeath=module.OnPlayerDeath or NULL_FUNCTION
	ply.OnPlayerKillPlayer=module.OnPlayerKillPlayer or NULL_FUNCTION
	ply.OnPlayerKillNPC=module.OnPlayerKillNPC or NULL_FUNCTION
	ply.OnPlayerUse=module.OnPlayerUse or NULL_FUNCTION
	ply.OnPlayerFootStep=module.OnPlayerFootStep or NULL_FUNCTION
	ply.OnPlayerChatter=module.OnPlayerChatter or NULL_FUNCTION
	if(ply.OnPlayerFootStep == NULL_FUNCTION)then
		ply:SetNWBool("overridefootsteps",false)
	else
		ply:SetNWBool("overridefootsteps",true)
	end
end

local function TDS_ResetPlayerHooks(ply)
	ply.OnPlayerListenToSound=NULL_FUNCTION
	ply.OnTraceDamage=NULL_FUNCTION
	ply.OnPlayerSpawn=NULL_FUNCTION
	ply.OnNormalDamage=NULL_FUNCTION
	ply.OnPlayerThink=NULL_FUNCTION
	ply.OnWeaponReload=NULL_FUNCTION
	ply.OnPlayerPickupWeapon=NULL_FUNCTION
	ply.OnPlayerDeath=NULL_FUNCTION
	ply.OnPlayerKillPlayer=NULL_FUNCTION
	ply.OnPlayerKillNPC=NULL_FUNCTION
	ply.OnPlayerUse=NULL_FUNCTION
	ply.OnPlayerFootStep=NULL_FUNCTION
	ply.OnPlayerChatter=NULL_FUNCTION
end


local function TDS_ClientGetClasses( player, command, arguments )
	for _, v in pairs(CLASSES_TABLE) do
		player:ChatPrint("Model: "..v.Model.." Description: "..v.Description)
	end
end
concommand.Add( "tds_getclasses", TDS_ClientGetClasses)

function TDS_IsPlayerUsingModel(ply,model)
	if util.IsValidModel(ply:GetModel()) && string.find(ply:GetModel(),model) then return true end
	return false;
end

local function TDS_ModuleSystem1(player,emitter,sound,concept)
	player:OnPlayerListenToSound(player,emitter,sound,concept)
end
hook.Add( "OnPlayerListenToSound", "TDS_ModuleSystem1", TDS_ModuleSystem1 )

local function TDS_ModuleSystem2( player, hitgroup, dmginfo ) 
		player:OnTraceDamage(player, hitgroup, dmginfo)
end
hook.Add( "ScalePlayerDamage", "TDS_ModuleSystem2", TDS_ModuleSystem2 )


local function TDS_ModuleSystem3(player)
	TDS_ResetPlayerHooks(player)//ALWAYS set every function to NULL_FUNCTION,so if we don't have a module
								//for a specific model,we call function()end that does nothing
	timer.Simple(0.1,function()	//sigh,timer because the model does not get applied before the spawn
		local hooksadded=false;
		for k, entry in pairs(CLASSES_TABLE) do
			if TDS_IsPlayerUsingModel(player,entry.Model) && !hooksadded then
				TDS_AddPlayerHooks(player,entry)
				hooksadded=true;
				break;
			end
		end
		player:OnPlayerSpawn(player)
	end)
end
hook.Add("PlayerSpawn", "TDS_ModuleSystem3", TDS_ModuleSystem3);

local function TDS_ModuleSystemInitialSpawn(player)
	TDS_ResetPlayerHooks(player)//ALWAYS set every function to NULL_FUNCTION,so if we don't have a module
								//for a specific model,we call function()end that does nothing
end
hook.Add("PlayerInitialSpawn", "TDS_ModuleSystemInitialSpawn", TDS_ModuleSystemInitialSpawn);

local function TDS_ModuleSystem4(player, inflictor, attacker, amount, dmginfo)
		if player:IsPlayer() then
		player:OnNormalDamage(player, inflictor, attacker, amount, dmginfo)
		end
end
hook.Add("EntityTakeDamage", "TDS_ModuleSystem4", TDS_ModuleSystem4)

local function TDS_ModuleSystem5()
		for _, ply in pairs(player.GetAll()) do
			if IsValid(ply) && ply:Alive() then
				ply:OnPlayerThink(ply)
				if(ply:GetActiveWeapon() != NULL )then
					if(ply:GetActiveWeapon():Clip1()>0)then
						ply.needreload=true;
					elseif(ply:GetActiveWeapon():Clip1()==0 && ply.needreload==true && ply:GetActiveWeapon():GetClass() != "weapon_physcannon")then
						if(ply:GetActiveWeapon():Clip1()==0 && ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) == 0)then
						ply.needreload=false;
						ply:OnWeaponReload(ply,false)
						else
						ply.needreload=false;
						ply:OnWeaponReload(ply,true)
						end
					end
				end
			end
		end
end
hook.Add("Think", "TDS_ModuleSystem5", TDS_ModuleSystem5)

local function TDS_ModuleSystem6( player, entity )
		if !player:HasWeapon(entity:GetClass()) then
		player:OnPlayerPickupWeapon(player,entity)
		end
end
hook.Add("PlayerCanPickupWeapon","TDS_ModuleSystem6", TDS_ModuleSystem6);

local function TDS_ModuleSystem7(player,weapon,attacker)
		player:OnPlayerDeath(player,weapon,attacker)
			if IsValid(attacker) && attacker:IsPlayer() && attacker != player then
						attacker:OnPlayerKillPlayer(attacker,player)
			end
end
hook.Add("PlayerDeath", "TDS_ModuleSystem7", TDS_ModuleSystem7);


local function TDS_ModuleSystem8( ent, attacker, inflictor )
	if IsValid(attacker) && attacker:IsPlayer() then
		attacker:OnPlayerKillNPC(ent,attacker,inflictor)
	end
end
hook.Add("OnNPCKilled", "TDS_ModuleSystem8", TDS_ModuleSystem8);

local function TDS_ModuleSystem9( player,entity )
				player:OnPlayerUse(player, entity)
end
hook.Add( "PlayerUse", "TDS_ModuleSystem9",TDS_ModuleSystem9)

local function TDS_ModuleSystem10( player, pos, foot, sound, volume, rf ) 
		if player.OnPlayerFootStep != NULL_FUNCTION && player:Alive() then
			player:OnPlayerFootStep(player, pos, foot, sound, volume)
			return true
		end
end
hook.Add("PlayerFootstep","TDS_ModuleSystem10",TDS_ModuleSystem10)

local function TDS_ModuleSystem11( player,command,args ) 
	if IsValid(player) && player:Alive() && player:CanSpeak() && player.OnPlayerChatter != NULL_FUNCTION then
		local number=tonumber(args[1])
		if type(number)!="number" then return end
		player:OnPlayerChatter(player,number);
	end
end
concommand.Add("tds_chatter",TDS_ModuleSystem11)


TDS_includefolder( "autorun/server/tds_classes")