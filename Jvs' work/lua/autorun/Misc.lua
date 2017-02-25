//Some of my functions,someone are stupid
//By jvs


function ASD(ply)
	//author:CptFuzzies
	if ( ply:GetActiveWeapon() == NULL ) then return end

	ply:DropWeapon( ply:GetActiveWeapon() )
	
end
concommand.Add( "drop", ASD )

	local function EntInfoADV( player, command, arguments )
	
		local tr = player:GetEyeTrace()
		if ( ValidEntity( tr.Entity ) ) then
		
			Msg("Class: ", tr.Entity:GetClass(), "\n")
			Msg("Model: ", tr.Entity:GetModel(), "\n")
			Msg("Skin: ", tr.Entity:GetSkin(), "\n")
			Msg("Entity: ", tr.Entity, "\n")
			Msg("Pos: ", tr.Entity:GetPos(), "\n")
			Msg("Offset: ",tr.HitPos-tr.Entity:GetPos(), "\n")
			
		end
	
	end

	concommand.Add( "ent_printinfoadv", EntInfoADV )



function ASD2(ply)

	if ( ply:GetActiveWeapon() == NULL or !ply:IsAdmin()) then return end
	ply:GetActiveWeapon().SUPERMODE=true;
end
concommand.Add( "supermode", ASD2 )

function ASD3(ply)
	if(!ply:IsAdmin()) then return end
		local tr = ply:GetEyeTrace()
		ply:StripWeapons();
		ply:Spectate( OBS_MODE_CHASE );
		ply:SpectateEntity( tr.Entity );
		ply:SetMoveType( MOVETYPE_OBSERVER );
end
concommand.Add( "specta", ASD3 )

local function SpectateAdm( player, command, arguments )

	local Impulse = arguments[1]
	if ( !Impulse || !player:IsAdmin() ) then return end
		for _, v in pairs( ents.FindByClass( Impulse ) ) do
			if IsValid(v)  then
			print(table.ToString(v:GetKeyValues(),"This ent "..v:GetClass().." has these keyvalues" , true))
	
					player:StripWeapons();
					player:Spectate( OBS_MODE_CHASE );
					player:SpectateEntity( v );
					player:SetMoveType( MOVETYPE_OBSERVER );
			end
		end

end
concommand.Add( "spectat", SpectateAdm )

local function SpectateAFF( player, command, arguments )

	local Impulse = arguments[1]
	if ( !Impulse ) then return end
		for _, v in pairs( ents.GetAll() ) do
			if v:GetModel()!=nil && string.find(v:GetModel(),Impulse)then print(v,v:GetModel()) end
		end

end
concommand.Add( "searchmodelff", SpectateAFF )


local function CrateIt( player, command, arguments )

	local Crate = arguments[1]
	local Num = arguments[2]
	if ( !Crate ) then return end
	if ( !Num ) then return end
	if (!player:IsAdmin()) then return end
			
		local launcher = ents.Create("item_item_crate")  
		launcher:SetPos(player:EyePos() + (player:GetAimVector() * 64))  
		launcher:SetKeyValue("ItemClass", Crate)
		launcher:SetKeyValue("ItemCount", Num)  
		launcher:Spawn()  
		launcher:Activate() 

end
concommand.Add( "crate", CrateIt )

local function map_clear( pl )
	//author:CptFuzzies
	if ( pl && pl:IsValid() && !pl:IsAdmin() ) then return end

	game.CleanUpMap()
	if ( GAMEMODE.IsSandboxDerived ) then
		if ( SERVER ) then
			game.ConsoleCommand( "gmod_admin_cleanup\n" )
		end
	end

	BroadcastLua( [[
		for k, v in pairs( ents.FindByClass( "class C_ClientRagdoll" ) ) do
			v:Remove()
		end
	]] )

end

concommand.Add( "map_clear", map_clear )