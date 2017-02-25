local function VehDmgFix( ent, inflictor, attacker, amount, dmginfo )
	if ( dmginfo:GetInflictor():IsVehicle() && dmginfo:GetDamage() < 1) then
		if dmginfo:GetAmmoType() == 18 then 
			dmginfo:SetDamage(15)
		elseif(dmginfo:GetAmmoType() == 20) then
			dmginfo:SetDamage(3)
		end
	end
end
hook.Add( "EntityTakeDamage", "VehDmgFix", VehDmgFix )
