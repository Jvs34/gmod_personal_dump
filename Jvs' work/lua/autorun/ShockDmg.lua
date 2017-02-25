//Shock damage does the double dmg underwater!

local function ShockDmg( ent, inflictor, attacker, amount, dmginfo )
	if(dmginfo:IsDamageType(DMG_SHOCK) && ent:WaterLevel()>0)then
				dmginfo:ScaleDamage(2)
	end 
end

hook.Add( "EntityTakeDamage", "ShockDmg", ShockDmg )