
local WHITEMAT = Material( "models/debug/debugwhite" )
local BACKGROUNDCOLOR = Color( 255 , 255 , 255 , 255 )--color_white--Color( 0 , 255 , 0 , 255 )
local LIGHTCOLOR = Color( 70 , 70 , 70 , 255 )
local DEFAULTFOV = 45
local FOLDER = "JVSAVATAR"
local XPOS = 0
local YPOS = 0
local CAMPOS = Vector( 16.5 , -7.8 , 74 )
local CAMANG = Angle( -6.5 , 155 , 0 )
local RENDERSIZES = {
	32,
	64,
	128,
	184,	--steam wtf???
	256,
	512
}
local GENERALSIZE = RENDERSIZES[4]
local RENDERQUEUE = {}

if not file.Exists( FOLDER , "DATA" ) then
	file.CreateDir( FOLDER )
end

for i ,v in pairs( RENDERSIZES ) do
	if not file.Exists( FOLDER.."/"..v.."x"..v , "DATA" ) then
		file.CreateDir( FOLDER.."/"..v.."x"..v )
	end
end

local CURRENTMODE = "normal"
local TEXTURETOREPLACE = "models/player/spy/mask_scout"
local TEXTURETOREPLACEWITH = "data/"..FOLDER.."/mask_luaking.png"
local REPLACEPNG = Material( TEXTURETOREPLACEWITH , "vertexlitgeneric smooth" )
local REPLACEMATERIAL = CreateMaterial( "avatarspymaskmat" ,
	"VertexLitGeneric",
	{
		["$basetexture"] = "",
		["$phong"] = "1",
		["$phongboost"] = ".2",
		["$phongexponent"] = "10",
		["$lightwarptexture" ] = "models/player/pyro/pyro_lightwarp",
		["$phongfresnelranges"] = "[.7 15 20]",
		["$halflambert"] = "1",
		["$rimlight"] = "1",
		["$rimlightexponent"] = "4",
		["$rimlightboost"] = "2",
		["$cloakPassEnabled"] = "1",
		["$cloakColorTint"] = "[0.4 0.5 1]",
		Proxies = {
			["spy_invis"] = {
			},
			["AnimatedTexture"] = {
				["animatedtexturevar"] = "$detail",
				["animatedtextureframenumvar"] = "$detailframe",
				["animatedtextureframerate"] = 30
			}
		}
	}
)
REPLACEMATERIAL:SetTexture( "$basetexture" , REPLACEPNG:GetTexture( "$basetexture" ) )

local TEXTUREREPLACENUMBER = -1

local function CopyFlexesTo( ent1 , ent2 )
	if not IsValid( ent1 ) or not IsValid( ent2 ) then
		ent1:SetFlexScale( 1 )
		ent2:SetFlexScale( 1 )
		
		local flexes = {}
		
		for i = 0 , ent1:GetFlexNum() - 1 do
			flexes[ent1:GetFlexName( i )] = ent1:GetFlexWeight( i )
		end
		
		--it might have the same flexes but they might not be ordered in the same way
		
		for i = 0 , ent2:GetFlexNum() - 1 do
			local ourname = ent2:GetFlexName( i )
			if flexes[ourname] then
				ent2:SetFlexWeight( i , flexes[ourname] )
			end
		end
	end
end

if IsValid( SPYMODEL ) then
	SPYMODEL:Remove()
end

if MODESMODELS then
	for i , v in pairs( MODESMODELS ) do
		if IsValid( v ) then
			v:Remove()
		end
	end
end

MODESMODELS = {}

local REDORBLUE = false

SPYMODEL = ClientsideModel( "models/player/spy.mdl" )
SPYMODEL:SetNoDraw( true )
SPYMODEL:SetCycle( 0 )
SPYMODEL:SetLOD( 0 )

for i ,v in pairs( SPYMODEL:GetMaterials() ) do
	if v == TEXTURETOREPLACE then
		TEXTUREREPLACENUMBER = i - 1
		break
	end
end

local MODES = {
	normal = {
		init = function( spyent )
		
		end,
		setup = function( spyent , redorblue )
			spyent:SetBodygroup( 1 , 1 )
		end,
		render = function( spyent )
			
		end,
		when = "always",
	},
	vr = {
		init = function( spyent )
			local vrheadset = ClientsideModel( "models/player/items/all_class/all_class_oculus_spy_on.mdl" )
			vrheadset:SetNoDraw( true )
			vrheadset:AddEffects( EF_BONEMERGE )
			vrheadset:SetParent( spyent )
			
			MODESMODELS["vr"] = vrheadset
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["vr"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["vr"]:DrawModel()
		end,
		when = "vr",
	},
	xmas = {
		init = function( spyent )
			local xmashat = ClientsideModel( "models/player/items/all_class/xms_santa_hat_spy.mdl" )
			xmashat:SetNoDraw( true )
			xmashat:AddEffects( EF_BONEMERGE )
			xmashat:SetParent( spyent )
			
			MODESMODELS["xmas"] = xmashat
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["xmas"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 1 )
		end,
		render = function( spyent )
			MODESMODELS["xmas"]:DrawModel()
		end,
		when = "december",
	},
	xmastree = {
		init = function( spyent )
			local xmastree = ClientsideModel( "models/player/items/all_class/oh_xmas_tree_spy.mdl" )
			xmastree:SetNoDraw( true )
			xmastree:AddEffects( EF_BONEMERGE )
			xmastree:SetParent( spyent )
			
			MODESMODELS["xmastree"] = xmastree
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["xmastree"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 1 )
		end,
		render = function( spyent )
			MODESMODELS["xmastree"]:DrawModel()
		end
	},
	summerseal = {
		init = function( spyent )
			local summerseal = ClientsideModel( "models/player/items/all_class/seal_mask_spy.mdl" )
			summerseal:SetNoDraw( true )
			summerseal:AddEffects( EF_BONEMERGE )
			summerseal:SetParent( spyent )
			
			MODESMODELS["summerseal"] = summerseal
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["summerseal"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["summerseal"]:DrawModel()
		end,
		when = "summer",
	},
	batman = {
		init = function( spyent )
			local batman = ClientsideModel( "models/workshop/player/items/all_class/bak_arkham_cowl/bak_arkham_cowl_spy.mdl" )
			batman:SetNoDraw( true )
			batman:AddEffects( EF_BONEMERGE )
			batman:SetParent( spyent )
			
			MODESMODELS["batman"] = batman
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["batman"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["batman"]:DrawModel()
		end,
		when = "batman",
	},
	metalgear = {
		init = function( spyent )
			local hair = ClientsideModel( "models/workshop/player/items/all_class/sbox2014_camo_headband/sbox2014_camo_headband_spy.mdl" )
			hair:SetNoDraw( true )
			hair:AddEffects( EF_BONEMERGE )
			hair:SetParent( spyent )
			
			MODESMODELS["metalgearhair"] = hair
			
			local eyepatch = ClientsideModel( "models/workshop/player/items/all_class/short2014_all_eyepatch/short2014_all_eyepatch_spy.mdl" )
			eyepatch:SetNoDraw( true )
			eyepatch:AddEffects( EF_BONEMERGE )
			eyepatch:SetParent( spyent )
			
			MODESMODELS["metalgeareyepatch"] = eyepatch
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["metalgearhair"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["metalgearhair"]:DrawModel()
			MODESMODELS["metalgeareyepatch"]:DrawModel()
		end,
		when = "metalgear",
	},
	french = {
		init = function( spyent )
			local hat = ClientsideModel( "models/workshop/player/items/all_class/short2014_vintage_director/short2014_vintage_director_spy.mdl" )
			hat:SetNoDraw( true )
			hat:AddEffects( EF_BONEMERGE )
			hat:SetParent( spyent )
			
			MODESMODELS["frenchhat"] = hat
			
			local scarf = ClientsideModel( "models/workshop/player/items/spy/dec2014_stealthy_scarf/dec2014_stealthy_scarf.mdl" )
			scarf:SetNoDraw( true )
			scarf:AddEffects( EF_BONEMERGE )
			scarf:SetParent( spyent )
			
			MODESMODELS["frenchscarf"] = scarf
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["frenchhat"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["frenchscarf"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["frenchhat"]:DrawModel()
			MODESMODELS["frenchscarf"]:DrawModel()
		end
	},
	thief = {
		init = function( spyent )
			local hat = ClientsideModel( "models/workshop/player/items/spy/fall2013_superthief/fall2013_superthief.mdl" )
			hat:SetNoDraw( true )
			hat:AddEffects( EF_BONEMERGE )
			hat:SetParent( spyent )
			
			MODESMODELS["thiefhat"] = hat
			
			local scarf = ClientsideModel( "models/workshop/player/items/spy/fall2013_escapist/fall2013_escapist.mdl" )
			scarf:SetNoDraw( true )
			scarf:AddEffects( EF_BONEMERGE )
			scarf:SetParent( spyent )
			
			MODESMODELS["thiefscarf"] = scarf
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["thiefhat"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["thiefscarf"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["thiefhat"]:DrawModel()
			MODESMODELS["thiefscarf"]:DrawModel()
		end
	},
	invisibleman = {
		init = function( spyent )
			local hat = ClientsideModel( "models/player/items/spy/hwn_spy_hat.mdl" )
			hat:SetNoDraw( true )
			hat:AddEffects( EF_BONEMERGE )
			hat:SetParent( spyent )
			
			MODESMODELS["invisiblemanhat"] = hat
			
			local goggles = ClientsideModel( "models/player/items/spy/hwn_spy_misc1.mdl" )
			goggles:SetNoDraw( true )
			goggles:AddEffects( EF_BONEMERGE )
			goggles:SetParent( spyent )
			
			MODESMODELS["invisiblemangoggles"] = goggles
			
			local scarf = ClientsideModel( "models/player/items/spy/hwn_spy_misc2.mdl" )
			scarf:SetNoDraw( true )
			scarf:AddEffects( EF_BONEMERGE )
			scarf:SetParent( spyent )
			
			MODESMODELS["invisiblemanscarf"] = scarf
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["invisiblemanhat"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["invisiblemangoggles"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["invisiblemanscarf"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["invisiblemanhat"]:DrawModel()
			MODESMODELS["invisiblemangoggles"]:DrawModel()
			MODESMODELS["invisiblemanscarf"]:DrawModel()
		end
	},
	alien = {
		init = function( spyent )
			local hat = ClientsideModel( "models/player/items/all_class/all_class_reddit_alt_spy.mdl" )
			hat:SetNoDraw( true )
			hat:AddEffects( EF_BONEMERGE )
			hat:SetParent( spyent )
			
			MODESMODELS["alienhat"] = hat
			
			local mask = ClientsideModel( "models/workshop/player/items/spy/invasion_the_graylien/invasion_the_graylien.mdl" )
			mask:SetNoDraw( true )
			mask:AddEffects( EF_BONEMERGE )
			mask:SetParent( spyent )
			
			MODESMODELS["alienmask"] = mask
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["alienhat"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["alienmask"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["alienhat"]:DrawModel()
			MODESMODELS["alienmask"]:DrawModel()
		end,
		when = "xcom",
	},
	investigator = {
		init = function( spyent )
			local hat = ClientsideModel( "models/player/items/spy/spy_private_eye.mdl" )
			hat:SetNoDraw( true )
			hat:AddEffects( EF_BONEMERGE )
			hat:SetParent( spyent )
			
			MODESMODELS["investigatorhat"] = hat
			
			local goggles = ClientsideModel( "models/player/items/all_class/sd_glasses_spy.mdl" )
			goggles:SetNoDraw( true )
			goggles:AddEffects( EF_BONEMERGE )
			goggles:SetParent( spyent )
			goggles:SetBodygroup( 1 , 1 )
			MODESMODELS["investigatorgoggles"] = goggles
			
			local scarf = ClientsideModel( "models/workshop/player/items/spy/dec15_chicago_overcoat/dec15_chicago_overcoat.mdl" )
			scarf:SetNoDraw( true )
			scarf:AddEffects( EF_BONEMERGE )
			scarf:SetParent( spyent )
			
			MODESMODELS["investigatorscarf"] = scarf
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["investigatorhat"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["investigatorgoggles"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["investigatorscarf"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["investigatorhat"]:DrawModel()
			MODESMODELS["investigatorgoggles"]:DrawModel()
			MODESMODELS["investigatorscarf"]:DrawModel()
		end
	},
	judge = {
		init = function( spyent )
			local hat = ClientsideModel( "models/player/items/spy/noblehair.mdl" )
			hat:SetNoDraw( true )
			hat:AddEffects( EF_BONEMERGE )
			hat:SetParent( spyent )
			
			MODESMODELS["judgehat"] = hat
			
			local goggles = ClientsideModel( "models/player/items/spy/fwk_spy_specs.mdl" )
			goggles:SetNoDraw( true )
			goggles:AddEffects( EF_BONEMERGE )
			goggles:SetParent( spyent )
			goggles:SetBodygroup( 1 , 1 )
			MODESMODELS["judgegoggles"] = goggles
			
			local scarf = ClientsideModel( "models/workshop/player/items/spy/sept2014_lady_killer/sept2014_lady_killer.mdl" )
			scarf:SetNoDraw( true )
			scarf:AddEffects( EF_BONEMERGE )
			scarf:SetParent( spyent )
			
			MODESMODELS["judgescarf"] = scarf
			
		end,
		setup = function( spyent , redorblue )
			MODESMODELS["judgehat"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["judgegoggles"]:SetSkin( redorblue and 0 or 1 )
			MODESMODELS["judgescarf"]:SetSkin( redorblue and 0 or 1 )
			spyent:SetBodygroup( 1 , 0 )
		end,
		render = function( spyent )
			MODESMODELS["judgehat"]:DrawModel()
			MODESMODELS["judgegoggles"]:DrawModel()
			MODESMODELS["judgescarf"]:DrawModel()
		end
	},
}

local function SetupSpy( mode , redorblue )
	SPYMODEL:SetSequence( "stand_sapper" )
	
	local skin = 4 + ( redorblue and 0 or 1 )
	SPYMODEL:SetSkin( skin )
	
	MODES[mode].setup( SPYMODEL , redorblue )
	
	SPYMODEL:SetAngles( Angle( 0 , 0 , 0 ) )
	SPYMODEL:SetupBones()
end

local modesfile = file.Open( FOLDER.."/avatars.txt" , "wb" , "DATA" )

for i , v in pairs( MODES ) do
	v.init( SPYMODEL )
	modesfile:Write( i .. "\n" )
end

modesfile:Flush()
modesfile:Close()

for i , v in pairs( MODESMODELS ) do
	v:SetLOD( 0 )
end


SetupSpy( "normal" , REDORBLUE ) --needed otherwise the rendering might fuck up as the animation is still blending in!!!
--but there's probably a way to finish the blending instantly

local function FollowSpyModelHead()
	local resultpos , resultang , fov
	--TODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODO
	resultpos = CAMPOS
	resultang = CAMANG
	fov = DEFAULTFOV
	
	return resultpos , resultang , fov
end

local function RenderSpy( size , mode , redorblue , inworld )
	
	SetupSpy( mode , redorblue )
	
	if not inworld then
		surface.SetDrawColor( BACKGROUNDCOLOR )
		surface.DrawRect( XPOS , YPOS , size , size )
	end
	
	
	local campos , camang , fov = FollowSpyModelHead() --TODO: this just returns the normal values for now
	
	if not inworld then
		cam.Start3D( campos , camang , fov , XPOS , YPOS , size , size , nil , nil )
	end
	
	render.SuppressEngineLighting( true )
	
	render.SetLightingOrigin( campos )
	render.ResetModelLighting( 1 , 1 , 1 )
	render.SetColorModulation( 1 , 1 , 1 )
	
	
	for i = 0, 6 do
		render.SetModelLighting( i , LIGHTCOLOR.r / 255 , LIGHTCOLOR.g / 255 , LIGHTCOLOR.b / 255 )
	end
	
	if IsValid( SPYMODEL ) then
		SPYMODEL:SetEyeTarget( campos )
		
		render.MaterialOverrideByIndex( TEXTUREREPLACENUMBER , REPLACEMATERIAL )
		SPYMODEL:DrawModel()
		render.MaterialOverrideByIndex( TEXTUREREPLACENUMBER , nil )
		
		for i ,v in pairs( MODESMODELS ) do
			if IsValid( v ) then
				CopyFlexesTo( SPYMODEL , v )
			end
		end
		
		MODES[mode].render( SPYMODEL )
	end
	
	if inworld then
		--a cam3d2d is probably better than this
		render.SetMaterial( WHITEMAT )
		local dir = camang:Forward()
		local pos = dir * 100
		
		
		render.DrawQuadEasy( pos , dir * - 1 , 256 , 256 , color_white , 0 )
	end
	
	render.SuppressEngineLighting( false )
	
	if not inworld then
		cam.End3D()
		
		render.ClearDepth()
	end
end

local function ExecuteQueue()
	
	for i , v in pairs( RENDERQUEUE ) do
		local size = v.size
		RenderSpy( size , v.mode , v.redorblue )
		
		local filedata = render.Capture(
		{
			format = "jpeg",
			quality = 100,
			x = XPOS,
			y = YPOS,
			w = size,
			h = size
		})
		
		local destfolder = FOLDER.."/"..v.size.."x"..v.size
		
		destfolder = destfolder .. "/" .. v.mode .. "_" .. ( v.redorblue and "red" or "blu" ) .. ".jpg"
		
		local imagefile = file.Open( destfolder , "wb" , "DATA" )
		
		if filedata and imagefile then
			imagefile:Write( filedata )
			imagefile:Flush()
			imagefile:Close()
		end
		
		
	end
	
	RENDERQUEUE = {}
end

local function StartRenderCommand( ply , cmd , args , argstr )
	
	for i , v in pairs( RENDERSIZES ) do
		for j , k in pairs( MODES ) do
			RENDERQUEUE[ #RENDERQUEUE + 1 ] = {
				size = v,
				redorblue = false,
				mode = j,
			}
			
			RENDERQUEUE[ #RENDERQUEUE + 1 ] = {
				size = v,
				redorblue = true,
				mode = j,
			}
		end
		
	end
end 

hook.Add( "HUDPaint" , "RenderSpy" , function()
	if #RENDERQUEUE > 0 then
		ExecuteQueue()
	else
		RenderSpy( GENERALSIZE , CURRENTMODE , REDORBLUE )
	end
end)

hook.Add( "PostDrawOpaqueRenderables" , "RenderSpy" , function( drawingdepth, drawingskybox )
	if not drawingdepth and not drawingskybox then
		RenderSpy( nil , CURRENTMODE , REDORBLUE , true )
	end
end)

concommand.Add( "avatar_startrender" , StartRenderCommand , nil , "starts rendering a Jvs avatar" , FCVAR_SERVER_CANNOT_QUERY + FCVAR_CLIENTCMD_CAN_EXECUTE )