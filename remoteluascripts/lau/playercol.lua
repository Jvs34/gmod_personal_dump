if CLIENT then return end
hook.Add("PlayerTick","Playercolorshit",function(ply,mv)
	if not ply.ColorShit or not ply.SetPlayerColor or not ply.SetWeaponColor then return end
	--local ler=Lerp(ply:GetVelocity():Length()/ply:GetWalkSpeed(),0,255)/255
	--local vec=Vector(ler,ler,ler)
	--local vec=Vector(512,0,512)
	local vec=Vector(math.random(0,255)/255,math.random(0,255)/255,math.random(0,255)/255)
	ply:SetPlayerColor(vec)
	ply:SetWeaponColor(vec)
end)