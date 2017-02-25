//A function to convert dead citizens to zombies.
//Why not the black headcrab?Because he just set the target life to 1,and can't kill it.
//By Jvs
local function ZombifyDeath( ent, attacker, inflictor )
	//A npc,when he just die,has 2 or 3 seconds of "life" before being deleted by the engine
	if(!IsValid(ent))then return end
	local Cls=ent:GetClass();
	
	if (Cls=="npc_citizen" && (string.find(inflictor:GetClass(),"npc_headcrab") || string.find(attacker:GetClass(),"npc_headcrab") ) ) then
		attacker:SetHealth(0);
		inflictor:SetHealth(0);
			if(inflictor:GetClass()=="npc_headcrab" ||attacker:GetClass()=="npc_headcrab")then
				local zomb=ents.Create("npc_zombie");
				zomb:SetPos(ent:GetPos());
				zomb:Spawn();
			elseif(inflictor:GetClass()=="npc_headcrab_fast" ||attacker:GetClass()=="npc_headcrab_fast")then
				local zomb=ents.Create("npc_fastzombie");
				zomb:SetPos(ent:GetPos());
				zomb:Spawn();
			end
	end
	
end

hook.Add( "OnNPCKilled", "ZombifyDeath", ZombifyDeath )