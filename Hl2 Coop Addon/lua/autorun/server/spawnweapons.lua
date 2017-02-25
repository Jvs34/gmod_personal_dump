local function CreateCoopWeapons()
	for k, Entity in pairs( ents.GetAll() ) do
		if(Entity && IsValid(Entity) && Entity:GetClass()=="npc_alyx")then
			if(Entity:GetKeyValues().additionalequipment=="weapon_alyxgun")then
				Entity:Give("swep_alyxgun")
				Entity:SetKeyValue("additionalequipment","swep_alyxgun")
			end
		end
		if(Entity && IsValid(Entity) && Entity:GetClass()=="func_tank")then
				local wep=ents.Create("swep_pulsemg");
				wep:SetPos(Entity:GetPos()+Vector(0,0,60))
				wep:Spawn()
				wep:Activate();
		end
	end		
	if game.GetMap()=="d3_c17_07" then
		local wep=ents.Create("swep_alyxgun");
		wep:SetPos(Vector(7998,1682,65))
		wep:Spawn()
		wep:Activate();
	elseif game.GetMap()=="d1_eli_01" then
		local wep=ents.Create("swep_alyxgun");
		wep:SetPos(Vector(524.9368,2022.3551,-2705.8079))
		wep:Spawn()
		wep:Activate();
	end
end
hook.Add( "InitPostEntity", "CreateCoopWeapons",CreateCoopWeapons )