//Fire extinguisher,a stupid hook to extinguish objects in water.
//Why valve didnt add this to the normal hl2? Meh
//By Jvs
local function FireExting( ent, inflictor, attacker, amount, dmginfo )
	//We have 3 vars for waterlevel
	//0 not in water
	//1 half in water
	//2 not used?
	//3 fully in the water
	
	local InflictClass 	= inflictor:GetClass()
	local AttackClass = attacker:GetClass();

	if (!inflictor:IsValid()) then return end
	if (!attacker:IsValid()) then return end
	if (InflictClass=="entityflame" || AttackClass=="entityflame") then
			if(ent:WaterLevel()==3)then //everything needs to be fully in the water to extinguish
				ent:Extinguish();		//so we have boats taking fire
			end
	end
end

hook.Add( "EntityTakeDamage", "FireExting", FireExting )