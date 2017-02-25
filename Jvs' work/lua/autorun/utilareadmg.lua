function util.AreaDamage(wepon,player,pos,Range,Damage,DamageType )
			local DMG=DamageInfo();
			DMG:SetDamage(Damage);
			DMG:SetDamageType(DamageType);
			DMG:SetAttacker(player);
			DMG:SetInflictor(wepon);
local rng;
	local entz=ents.FindInSphere(pos, Range)
		for _,ent in pairs(entz) do
			if(IsValid(ent))then
					rng=pos:Distance( ent:GetPos() )
					DMG:SetDamage(Damage-rng)
					ent:TakeDamageInfo(DMG);
			end
		end
end