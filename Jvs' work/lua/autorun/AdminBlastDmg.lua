//A stupid hook to convert the blast damage to dissolve damage,make everyone else half deaf,but not the admin
//Made by Jvs
local function AdminBlastDmg( ent, inflictor, attacker, amount, dmginfo )

	local InflictClass 	= inflictor:GetClass()
	local AttackClass = attacker:GetClass();

	if (!inflictor:IsValid()) then return end
	if (!attacker:IsValid()) then return end
	
	if (ent:IsPlayer() && ent:IsAdmin()) then
			if(dmginfo:IsDamageType(DMG_BLAST))then
						dmginfo:SetDamageType(DMG_DISSOLVE);
			end 
	end
	
end

hook.Add( "EntityTakeDamage", "AdminBlastDmg", AdminBlastDmg )