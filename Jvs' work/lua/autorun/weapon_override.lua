function PlayerOverride(ply, wep)
     if ply:HasWeapon(wep:GetClass()) && wep:GetClass()!="weapon_frag" && wep:GetClass()!="weapon_rpg" then
		if(wep:Clip1()>=1)then
			ply:GiveAmmo(wep:Clip1(),wep:GetPrimaryAmmoType());
			wep:SetClip1(0);
		end
		return false;
   end
   
 end
 
hook.Add("PlayerCanPickupWeapon", "PlayerOverride", PlayerOverride)
