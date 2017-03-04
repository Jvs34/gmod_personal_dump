if SERVER then
	return
end

local prdents = {}

--the paths we should look for our file in

prdents.Paths = {
	"addons/gmod-predictedentities/lua/entities",
	"addons/gmod-predictedentitiesaddendum/lua/entities"
}

--the path we should use to make the txt to send over
prdents.TempOutputPath = "prdents"

--[[
	This script will not be ran from remote_lua, but from lua_openscript_cl instead
	
	It will: create a txt file from a Lua file inside of gmod-predictedentities and wrap it with the usual
	ENT = {} bullshit and with scripted_ents.Regiter at the bottom of it, after which it will load them
	by using remote_lua_sh ( in this case ) from a command
]]

function prdents.LoadPredEntFile( ply , cmd , args , fullargsstr )
	--not that big of a deal, but EH
	if not IsValid( ply ) then
		return
	end
	
	local filename = args[1]
	if not filename then
		ErrorNoHalt( "No filename given to command!!\n" )
		return
	end
	
	--look for the file in the given folder(s)
	local filehandle = nil
	
	for i ,v in pairs( prdents.Paths ) do
		local fname = v.."/"..filename..".lua"
		print( "SEARCHING IN "..fname )
		
		filehandle = file.Open( fname , "r" , "MOD" )
		
		if filehandle then
			break
		end
	end
	
	if not filehandle then
		ErrorNoHalt( "File " .. filename.. " was not found!!!\n" )
		return
	end
	
	
	--considering in this case that the filename is always the entity, do this
	local prefile = [[ENT = {}

]]
	
	local midfile = filehandle:Read( filehandle:Size() )
	
	filehandle:Close()
	filehandle = nil

	local postfile = ([[


scripted_ents.Register( ENT ,"%s" , true )
scripted_ents.OnLoaded()
ENT = nil
]]):format( filename )
	
	
	local writetxt = file.Open( prdents.TempOutputPath .. "/"..filename..".txt" , "w" , "DATA" )
	
	if not writetxt then
		ErrorNoHalt( "Could not write to "..prdents.TempOutputPath .. "/"..filename..".txt" .. "\n" )
		return
	end
	
	writetxt:Write( prefile )
	writetxt:Write( midfile )
	writetxt:Write( postfile )
	writetxt:Close()
	
	RunConsoleCommand( "remote_lua_sh" , prdents.TempOutputPath .. "/"..filename )
end

function prdents.LoadPredEntFileAutoComplete( cmd , args )
	local res = {}
	
	local filename = args:gsub( "%s?" , "" ) .. "*"
	
	for i ,v in pairs( prdents.Paths ) do
		local filesfound , dirsfound = file.Find( v.."/"..filename , "MOD" )
		--print( v.."/"..filename )
		for _ , filename in pairs( filesfound ) do
			res[#res+1] = cmd.." "..filename:StripExtension()
		end
	end
	
	
	return res
end

concommand.Add( "predent_loadfile" , prdents.LoadPredEntFile , prdents.LoadPredEntFileAutoComplete )