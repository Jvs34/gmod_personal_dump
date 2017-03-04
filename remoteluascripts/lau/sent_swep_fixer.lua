if SERVER then 
	return 
end

--[[
lua_run_cl print(Entity(229):SetTable(weapons.Get("weapon_grapplehook"))) 
Entity(229):InstallDataTable() 
Entity(229):SetupDataTables() 
Entity(229):Initialize()
]]

local function FixEntity( ent )
	local enttab=ent:GetTable()
	
	if enttab.__FixedAlready then return end
	
	
	if not enttab.Weapon and not enttab.Entity then
		--wait a minute, this isn't a scripted entity, or it doesn't needs our treatment
		return
	end
	
	if enttab.BaseClass then 
		return 
	end
	
	if ent:IsWeapon() then
		enttab=weapons.Get(ent:GetClass())
	else
		enttab=scripted_ents.Get(ent:GetClass())
	end
	
	if not enttab then
		--make it return an error or something idk
		return
	end
	
	if not ent.InstallDataTable then 
		return 
	end
	
	ent:SetTable( enttab )
	ent:InstallDataTable()
	
	if ent.SetupDataTables then
		ent:SetupDataTables() 
	end
	
	print("Fixing ", ent )
	
	if ent.Initialize then
		ent:Initialize()
	end
	
	ent.__FixedAlready=true
end

hook.Add("NetworkEntityCreated","fixents",function( ent )
	if IsValid(ent) and not ent.__FixedAlready then
		FixEntity(ent)
	end
end)


hook.Add( "NotifyShouldTransmit" , "fixents" , function( ent , shouldtransmit )
	if IsValid(ent) and shouldtransmit and not ent.__FixedAlready then
		FixEntity(ent)
	end
end)