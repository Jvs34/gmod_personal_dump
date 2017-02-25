//Crate fixer,a fix for when a crate breaks and you can't touch the ammo/content of the crate (beside weapons)
//It even fix the battery the Cscanners drops
//By Jvs
local function CrateFixer()
	for _, pl in pairs(player.GetAll()) do
		if(pl:Alive())then
				for k,ent in pairs(ents.FindInSphere(pl:GetPos(), 200)) do
					if(ent:IsValid() && string.find(ent:GetClass(),"item_") && ent:GetCollisionGroup()==11) then
						if string.find(ent:GetClass(),"ammo")then
						ent:SetCollisionGroup(COLLISION_GROUP_NONE);
						else
						ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
						end
					elseif ent:IsValid() && string.find(ent:GetClass(),"item_") && ent:GetCollisionGroup()==20 then
						ent:SetCollisionGroup(COLLISION_GROUP_NONE);
					end
				end	
		end
	end
end
hook.Add("Think","CrateFixer",CrateFixer)