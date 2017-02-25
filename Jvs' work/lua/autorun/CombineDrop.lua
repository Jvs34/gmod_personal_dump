//Combine drop,a stupid hook to make the combine drop healthvial,just like in the real hl2.
//Made by Jvs
local function CombainDrop( ent, inflictor, attacker, amount, dmginfo ) 
		if !IsValid(ent) then return end
		local Cls=ent:GetClass();
		
		if Cls=="npc_combine_s" || Cls=="npc_metropolice" && dmginfo:IsDamageType(DMG_DISSOLVE) then
			ent.LastDmgTaken=DMG_DISSOLVE;
		end
end
hook.Add("EntityTakeDamage", "CombainDrop", CombainDrop)


local function CombineDrop( ent, attacker, inflictor )
	//A npc,when he just die,has 2 or 3 seconds of "life" before being deleted by the engine
	if(!IsValid(ent))then return end
	local Cls=ent:GetClass();
	local ran=math.random(0,2);//we have 3 chanches here,0,drop a thing,1 and 2,nothing.
		
	if (Cls=="npc_combine_s" || Cls=="npc_metropolice" && ent.LastDmgTaken != DMG_DISSOLVE) then
		if(ran==0)then
		DropItem(ent,"item_healthvial") 
		end
	elseif(Cls=="npc_rollermine")then
		DropItem(ent,"item_battery") //always drop a suit battery as a rollermine.even tought you explode
	end
	
end

hook.Add( "OnNPCKilled", "CombineDrop", CombineDrop )
//A convenient stupid function to drop something instead of writing 500 times the same thing.
function DropItem(ent,str)
	local Pos=ent:GetPos();
	local itm = ents.Create(str)  
	itm:SetPos(Pos)  
	itm:Spawn()  
	itm:Activate() 
end
/*
local function PlayerCanPickupstick( player, entity )

	if ( entity:GetClass() == "weapon_stunstick" && player:HasWeapon(entity:GetClass())) then
		entity:Remove()
		player:SetArmor( player:Armor() + 7 )
		player:EmitSound( "ItemBattery.Touch" )
		return false
	end
	return true
end
hook.Add( "PlayerCanPickupWeapon", "PlayerCanPickupstick", PlayerCanPickupstick )
*/