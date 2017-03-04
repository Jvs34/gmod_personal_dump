--[[
if not CLIENT then return end

hook.Add( "PlayerTick" , "CopyShit" , function(ply ,mv)
	local ent = ply.CopyShitFrom
	if IsValid( ent ) then
		ply:SetFlexScale( ent:GetFlexScale() )
		for i = 0 , ply:GetFlexNum() do
			local flexval = ent:GetFlexWeight( i )
			ply:SetFlexWeight( i , flexval )
		end
	end
end)

]]

hook.Remove( "PrePlayerDraw", "ff", function( ply )
	local ent = C
	if IsValid( C ) and ply:GetModel() == "models/player/breen.mdl" then
		ply:SetFlexScale( ent:GetFlexScale() )
		for i = 0 , ply:GetFlexNum() do
			local flexval = ent:GetFlexWeight( i )
			ply:SetFlexWeight( i , flexval )
		end
	end

end)