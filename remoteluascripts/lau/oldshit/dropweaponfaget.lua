concommand.Add("fagetdrop", function(ply)
	if !IsValid(ply) then return end
	local wep=ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	ply:DropWeapon(wep)
end)


concommand.Add("omgwhat", function(ply)
	if !IsValid(ply) then return end
	local wep=ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	wep:SetClip1(35)
	wep:SetNextPrimaryFire(0)
end)