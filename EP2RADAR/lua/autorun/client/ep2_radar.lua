//if !DAMNIT_THIS_DAMN_THING_DOES_NOT_WORKS then return end

//this radar needs some of the swep-bases functions,don't forget it when you run it

local RADAR_DOT_NORMAL		=0
local RADAR_IGNORE_Z			=true	//always draw this item as if it was at the same Z as the player
local RADAR_MAX_GHOST_ALPHA	=25


local RADAR_PANEL_MATERIAL			="vgui/screens/radar"
local RADAR_CONTACT_LAMBDA_MATERIAL	="vgui/icons/icon_lambda"	// Lambda cache
local RADAR_CONTACT_BUSTER_MATERIAL	="vgui/icons/icon_buster"	// Striderbuster
local RADAR_CONTACT_STRIDER_MATERIAL	="vgui/icons/icon_strider"	// Strider
local RADAR_CONTACT_DOG_MATERIAL		="vgui/icons/icon_dog"		// Dog
local RADAR_CONTACT_BASE_MATERIAL		="vgui/icons/icon_base"		// Ally base
local	m_radarContacts={}
				//Vector	m_vecOrigin;
				//int		m_iType;
				//float	m_flTimeToRemove;
				
				
local	m_iNumRadarContacts;//Jvs:this is an unused variable,it was causing too much problems,seriousely.

local	m_pVehicle;
local	m_iImageID;
local	m_textureID_IconLambda;
local	m_textureID_IconBuster;
local	m_textureID_IconStrider;
local	m_textureID_IconDog;
local	m_textureID_IconBase;
local	m_bUseFastUpdate;
local	m_ghostAlpha;			// How intense the alpha channel is for CRT ghosts
local	m_flTimeStopGhosting;	
local	m_flTimeStartGhosting;

local RADAR_UPDATE_FREQUENCY		=1.5
local RADAR_UPDATE_FREQUENCY_FAST	=0.5

local RADAR_CONTACT_NONE = -1
local RADAR_CONTACT_GENERIC = 0
local RADAR_CONTACT_MAGNUSSEN_RDU =1
local RADAR_CONTACT_DOG=2
local RADAR_CONTACT_ALLY_INSTALLATION=3
local RADAR_CONTACT_ENEMY=4			// 'regular' sized enemy (Hunter)
local RADAR_CONTACT_LARGE_ENEMY=5
local RADAR_CONTACT_SMALL_ENEMY=6

local RADAR_SIZE=0.50;
local RADAR_BLIP_FADE_TIME =1.0
local radar_range=CreateClientConVar("addon_radar_range", "3000" );
local RADAR_USE_ICONS=CreateClientConVar("addon_radar_useicons","1" );



local function RadarGetWide() return 256*RADAR_SIZE;end
local function RadarGetTall() return 256*RADAR_SIZE;end

local function GetHudPosX() return 30;end
local function GetHudPosY() return 30;end
function RadarPrintList() PrintTable(m_radarContacts) end

local function GetUseIcons() return RADAR_USE_ICONS:GetBool() end

local function ClearAllRadarContacts() 
m_radarContacts={}
end
//---------------------------------------------------------
//---------------------------------------------------------
local function Init()
	m_pVehicle = NULL;
	m_iImageID=nil;
	m_textureID_IconLambda = -1;
	m_textureID_IconBuster = -1;
	m_textureID_IconStrider = -1;
	m_textureID_IconDog = -1;
	m_textureID_IconBase = -1;
	
	ClearAllRadarContacts();
	
	m_ghostAlpha = 0;
	m_flTimeStartGhosting = CurTime() + 1.0;
	m_flTimeStopGhosting=0
end




//---------------------------------------------------------
// Purpose: Search the contact list for a specific contact
//---------------------------------------------------------
local function FindRadarContact( vecOrigin )
	for i,v in pairs(m_radarContacts) do
		if v && v.m_vecOrigin == vecOrigin then
			return v;
		end
	end

	return nil;
end



//---------------------------------------------------------
// Purpose: Register a radar contact in the list of contacts
//---------------------------------------------------------
function AddRadarContact( vecOrigin,iType,flTimeToLive )
	local v = vecOrigin;
	local iExistingContact = FindRadarContact( vecOrigin );

	if( iExistingContact )then
		// Just update this contact.
		iExistingContact.m_flTimeToRemove = CurTime() + flTimeToLive;
		return;
	end
	local newcontact={}
	newcontact.m_vecOrigin = vecOrigin;
	newcontact.m_iType = iType;
	newcontact.m_flTimeToRemove = CurTime() + flTimeToLive;
	table.insert(m_radarContacts,newcontact)
end



//---------------------------------------------------------
// Purpose: Go through all radar targets and see if any
//			have expired. If yes, remove them from the
//			list.
//---------------------------------------------------------
function MaintainRadarContacts()
	local bKeepWorking = true;
	while( bKeepWorking ) do
		bKeepWorking = false;
		for i,v in pairs(m_radarContacts) do
			local pContact = v;
			if !pContact then continue;end 
			if( CurTime() >= pContact.m_flTimeToRemove )then
				// Time for this guy to go. Easiest thing is just to copy the last element 
				// into this element's spot and then decrement the count of entities.
				bKeepWorking = true;
				table.remove(m_radarContacts,i)
				break;
			end
		end
	end
end



//---------------------------------------------------------
// Purpose: Draw the radar panel.
//			We're probably doing too much other work in here
//---------------------------------------------------------
local function Paint()
	if !IsValid(LocalPlayer()) || LocalPlayer():Alive()==false then return end
	if (!m_iImageID)then
		// Set up the image ID's if they've somehow gone bad.
		m_textureID_IconLambda = surface.GetTextureID(RADAR_CONTACT_LAMBDA_MATERIAL);

		m_textureID_IconBuster = surface.GetTextureID(RADAR_CONTACT_BUSTER_MATERIAL);

		m_textureID_IconStrider = surface.GetTextureID(RADAR_CONTACT_STRIDER_MATERIAL);

		m_textureID_IconDog = surface.GetTextureID(RADAR_CONTACT_DOG_MATERIAL);

		m_textureID_IconBase = surface.GetTextureID(RADAR_CONTACT_BASE_MATERIAL);

		m_iImageID = surface.GetTextureID(RADAR_PANEL_MATERIAL);
	end
	// Draw the radar background.
	local wide=RadarGetWide();
	local tall=RadarGetTall();
	local alpha = 255;
	draw.RoundedBox(4,GetHudPosX()-5,GetHudPosX()-5,RadarGetWide()+10,RadarGetTall()+10,Color(0, 0, 0, 76))
	surface.SetDrawColor(255, 255, 255, alpha);
	surface.SetTexture(m_iImageID);
	
	surface.DrawTexturedRect(GetHudPosX(),GetHudPosX(), wide, tall);
	
	
	// Manage the CRT 'ghosting' effect
	if( CurTime() > m_flTimeStartGhosting )then
		if( m_ghostAlpha < RADAR_MAX_GHOST_ALPHA )then
			m_ghostAlpha=m_ghostAlpha+1;
		else
			m_flTimeStartGhosting = FLT_MAX;
			m_flTimeStopGhosting = CurTime() + math.random(1.0,2.0);// How long to ghost for
		end
	elseif( CurTime() > m_flTimeStopGhosting )then
		// We're supposed to stop ghosting now.
		if( m_ghostAlpha > 0 )then
			// Still fading the effects.
			m_ghostAlpha=m_ghostAlpha-1;
		else
			// DONE fading the effects. Now stop ghosting for a short while
			m_flTimeStartGhosting = CurTime() + math.random(2.0,3.0);// how long between ghosts
			m_flTimeStopGhosting = FLT_MAX;
		end
	end

	// Now go through the list of radar targets and represent them on the radar screen
	// by drawing their icons on top of the background.
	local pLocalPlayer = LocalPlayer();
	
	for i,v in pairs(m_radarContacts) do
		local alpha = 90;
		local pContact = v;
		if !pContact then continue;end
		
		local deltaT = pContact.m_flTimeToRemove - CurTime();
		if ( deltaT < RADAR_BLIP_FADE_TIME )then
			local factor = deltaT / RADAR_BLIP_FADE_TIME;

			alpha = alpha * factor ;

			if( alpha < 10 )then
				alpha = 10;
			end
		end
		local flicker = math.random( 0, 30 );
		if( GetUseIcons() )then
			DrawIconOnRadar( pContact.m_vecOrigin, pLocalPlayer, pContact.m_iType, RADAR_IGNORE_Z, 255, 255, 255, alpha + flicker );
		else
			DrawPositionOnRadar( pContact.m_vecOrigin, pLocalPlayer, pContact.m_iType, RADAR_IGNORE_Z, 255, 255, 255, alpha + flicker );
		end
	end

	MaintainRadarContacts();
end


//---------------------------------------------------------
// Scale maps the distance of the target from the radar 
// source. 
//
//		1.0 = target at or beyond radar range.
//		0.5 = target at (radar_range * 0.5) units distance
//		0.25 = target at (radar_range * 0.25) units distance
//		-etc-
//---------------------------------------------------------

function WorldToRadar(location,origin,angles,x,y,z_delta,scale )
	local bInRange = true;
	
	local x_diff = location.x - origin.x;
	local y_diff = location.y - origin.y;

	// Supply epsilon values to avoid divide-by-zero
	if(x_diff == 0)then
		x_diff = 0.00001;
	end
	
	if(y_diff == 0)then
		y_diff = 0.00001;
	end
	
	local iRadarRadius = RadarGetWide();									//width of the panel
	local fRange = radar_range:GetFloat();

	// This magic /2.15 makes the radar scale seem smaller than the VGUI panel so the icons clamp
	// to the outer ring in the radar graphic, not the very edge of the panel itself.
	local fScale = (iRadarRadius/2.15) / fRange;					

	local flOffset = math.atan(math.rad(y_diff/x_diff));
	y_diff = -1*(math.sqrt((x_diff)*(x_diff) + (y_diff)*(y_diff)));
	
	
	flOffset = angles.y + flOffset;
	flOffset=flOffset-90
	// Transform relative to radar source
	local xnew_diff = x_diff * math.cos(math.rad(flOffset)) - y_diff * math.sin(math.rad(flOffset));
	local ynew_diff = x_diff * math.sin(math.rad(flOffset)) + y_diff * math.cos(math.rad(flOffset));
	xnew_diff=-1*xnew_diff
	
	if ( (-1 *y_diff) > fRange )then
		local flScale;

		flScale = ( -1 * y_diff) / fRange;

		xnew_diff =xnew_diff/(flScale);
		ynew_diff =ynew_diff/(flScale);

		bInRange = false;

		scale = 1.0;
	else
	
		// scale
		local flDist = math.sqrt( ((xnew_diff)*(xnew_diff) + (ynew_diff)*(ynew_diff)) );
		scale = flDist / fRange;
	end


	// Scale the dot's position to match radar scale
	xnew_diff =xnew_diff* fScale;
	ynew_diff =ynew_diff*fScale;
	

	
	// Translate to screen coordinates
	x = (iRadarRadius/2) + xnew_diff;
	y = (iRadarRadius/2) + ynew_diff;
	z_delta = 0.0;

	return bInRange,x,y,z_delta,scale;
end



function DrawPositionOnRadar(vecPos,pLocalPlayer,r_type,flags,r,g,b,a )
	local x, y, z_delta;
	local iBaseDotSize = 3;

	local viewAngle = pLocalPlayer:EyeAngles();
	viewAngle.p=0
	if( m_pVehicle != NULL )then
		viewAngle = m_pVehicle:GetAngles();
		viewAngle.y =viewAngle.y+ 90.0;
	end

	local flScale;
	local lolret;
	lolret,x,y,z_delta,flScale=WorldToRadar( vecPos, pLocalPlayer:GetShootPos(), viewAngle, x, y, z_delta, flScale );

	z_delta = 0;

	if r_type==RADAR_CONTACT_GENERIC then
		r =	255;	g = 170;	b = 0;
		iBaseDotSize =iBaseDotSize* 2;
	elseif r_type==RADAR_CONTACT_MAGNUSSEN_RDU then
		r =	0;		g = 200;	b = 255;
		iBaseDotSize =iBaseDotSize* 2;
	elseif r_type==RADAR_CONTACT_ENEMY then
		r = 255;	g = 0;	b = 0;
		iBaseDotSize =iBaseDotSize* 2;
	elseif r_type==RADAR_CONTACT_LARGE_ENEMY then
		r = 255;	g = 0;	b = 0;
		iBaseDotSize =iBaseDotSize* 4;
	elseif r_type==RADAR_CONTACT_SMALL_ENEMY then
		r = 255;	g = 0;	b = 0;
		iBaseDotSize =iBaseDotSize* 1.5;
	end

	DrawRadarDot( x, y, z_delta, iBaseDotSize, flags, r, g, b, a );
end

//---------------------------------------------------------
// Purpose: Compute the proper position on the radar screen
//			for this object's position relative to the player.
//			Then draw the icon in the proper location on the
//			radar screen.
//---------------------------------------------------------
local RADAR_ICON_MIN_SCALE	=0.75
local RADAR_ICON_MAX_SCALE	=1.0
function DrawIconOnRadar(vecPos,pLocalPlayer,r_type,flags,r,g,b,a)

	local x, y, z_delta;
	local wide, tall;

	// for 'ghosting' CRT effects:
	local xmod;
	local ymod;
	local xoffset;
	local yoffset;

	// Assume we're going to use the player's location and orientation
	local viewAngle = pLocalPlayer:EyeAngles();
	viewAngle.p=0;
	local viewOrigin = pLocalPlayer:GetShootPos();

	// However, happily use those of the vehicle if available!
	if( m_pVehicle != NULL )then
		viewAngle = m_pVehicle:GetAngles();
		viewAngle.y =viewAngle.y+ 90;
		viewOrigin = m_pVehicle:GetPos();
	end
	local flScale;
	local retlol
	retlol,x,y,z_delta,flScale=WorldToRadar( vecPos, viewOrigin, viewAngle, x, y, z_delta, flScale );
	
	flScale = RemapValClamped( flScale, 1.0, 0.0, RADAR_ICON_MIN_SCALE, RADAR_ICON_MAX_SCALE );

	// Get the correct icon for this r_type of contact
	local iTextureID_Icon = -1;

	if r_type==RADAR_CONTACT_GENERIC then
		iTextureID_Icon = m_textureID_IconLambda;
	elseif r_type==RADAR_CONTACT_MAGNUSSEN_RDU then
		iTextureID_Icon = m_textureID_IconBuster;
	elseif r_type==RADAR_CONTACT_ENEMY || r_type==RADAR_CONTACT_LARGE_ENEMY || r_type==RADAR_CONTACT_SMALL_ENEMY then
		iTextureID_Icon = m_textureID_IconStrider;
	elseif r_type==RADAR_CONTACT_DOG then
		iTextureID_Icon = m_textureID_IconDog;
	elseif r_type==RADAR_CONTACT_ALLY_INSTALLATION then
		iTextureID_Icon = m_textureID_IconBase;
	end

	surface.SetDrawColor( r, g, b, a );
	surface.SetTexture( iTextureID_Icon );
	wide,tall=surface.GetTextureSize( iTextureID_Icon);
	local scr_scale=RadarGetWide()/256
	wide = ( (wide * scr_scale) );
	tall = ( (tall * scr_scale) );
	
	wide = ( (wide * flScale) );
	tall = ( (tall * flScale) );
	
	if( r_type == RADAR_CONTACT_LARGE_ENEMY )then
		wide =wide*2;
		tall =tall*2;
	end
	
	if( r_type == RADAR_CONTACT_SMALL_ENEMY )then
		wide =wide*0.75;
		tall =tall*0.75;
	end

	// Center the icon around its position.
	x = x-(wide >> 1);
	y = y-(tall >> 1);

	surface.DrawTexturedRect(x+GetHudPosX(), y+GetHudPosX(), wide,tall);
	// Draw the crt 'ghost' if the icon is not pegged to the outer rim
	
	if( flScale > RADAR_ICON_MIN_SCALE && m_ghostAlpha > 0 )then
		surface.SetDrawColor( r, g, b, m_ghostAlpha );
		xmod = math.random( 1, 4 );
		ymod = math.random( 1, 4 );
		xoffset = math.random( -1, 1 );
		yoffset = math.random( -1, 1 );
		x = x-(xmod - xoffset);
		y = y-(ymod - yoffset);
		wide = wide+(xmod + xoffset);
		tall = tall+(ymod + yoffset);
		surface.DrawTexturedRect(x+GetHudPosX(), y+GetHudPosX(),wide,tall);
	end
	
end

local function FillRect(x,y,w,h)
	surface.DrawRect( x+GetHudPosX(), y+GetHudPosX(),w,h );
end

function DrawRadarDot(x,y, z_diff,iBaseDotSize,flags,r,g,b,a )

	surface.SetDrawColor( r, g, b, a );

	if ( z_diff < -128 )then // below the player
		z_diff =z_diff * -1;

		if ( z_diff > 3096 )then
			z_diff = 3096;
		end

		local iBar = ( z_diff / 400 ) + 2;

		// Draw an upside-down T shape to symbolize the dot is below the player.

		iBaseDotSize =iBaseDotSize/ 2;

		//horiz
		FillRect( x-(2*iBaseDotSize), y, 5*iBaseDotSize, iBaseDotSize );

		//vert
		FillRect( x, y - iBar*iBaseDotSize, iBaseDotSize, iBar*iBaseDotSize );
	elseif ( z_diff > 128 )then // above the player
		if ( z_diff > 3096 )then
			z_diff = 3096;
		end

		local iBar = ( z_diff / 400 ) + 2;

		iBaseDotSize =iBaseDotSize/ 2;
		
		// Draw a T shape to symbolize the dot is above the player.

		//horiz
		FillRect( x-(2*iBaseDotSize), y, 5*iBaseDotSize, iBaseDotSize );

		//vert
		FillRect( x, y, iBaseDotSize, iBar*iBaseDotSize );
	else 
		FillRect( x, y, iBaseDotSize, iBaseDotSize );
	end
end



//Jvs:these 4 tables are here for npcs/entities to appear on the radar,because the jalopy's radar only cares about info_
local lil_enemys={"npc_rollermine","npc_manhack","npc_cscanner","combine_mine","grenade_helicopter"}
local enemys={"npc_combine_s","npc_hunter","npc_strider","npc_helicopter","npc_metropolice","npc_combinegunship","npc_combinedropship","npc_zombine","npc_rollermine","npc_manhack","npc_cscanner","combine_mine","grenade_helicopter"}
local big_enemys={"npc_strider","npc_helicopter","npc_combinegunship","npc_combinedropship"}
local frienz={"npc_alyx","npc_barney"}



local m_flNextRadarUpdateTime=CurTime();
local miNumRadarContacts=0;
local function RadarSearch()	
	local m_vecRadarContactPos={}
	local m_iRadarContactType={}

	if( !forceUpdate && CurTime() < m_flNextRadarUpdateTime )then
		return;
	end
	// Count the targets on radar. If any more targets come on the radar, we beep.
	local m_iNumOldRadarContacts = miNumRadarContacts;

	m_flNextRadarUpdateTime = CurTime() + RADAR_UPDATE_FREQUENCY;
	miNumRadarContacts = 0;

	local pEnt;

	local vecJalopyOrigin = LocalPlayer():GetShootPos();

	for i,v in pairs(ents.GetAll()) do
		pEnt=v;
		local r_type = RADAR_CONTACT_NONE;

		if (IsValid(pEnt) && table.HasValue(enemys,pEnt:GetClass()) )then
			if ( table.HasValue(big_enemys,pEnt:GetClass()) )then
				r_type = RADAR_CONTACT_LARGE_ENEMY;
			elseif ( table.HasValue(lil_enemys,pEnt:GetClass()) )then
				r_type = RADAR_CONTACT_SMALL_ENEMY;
			else
				r_type = RADAR_CONTACT_ENEMY;
			end
		end

		if( r_type != RADAR_CONTACT_NONE )then
			local vecPos = pEnt:GetPos();
			m_vecRadarContactPos[miNumRadarContacts]=vecPos;
			m_iRadarContactType[miNumRadarContacts]=r_type;
			miNumRadarContacts=miNumRadarContacts+1;
		end

	end

	if( miNumRadarContacts > m_iNumOldRadarContacts )then
		// Play a bleepy sound
		surface.PlaySound("vehicles/junker/radar_ping_friendly1.wav");
	end
	
	
	local flContactTimeToLive=RADAR_UPDATE_FREQUENCY;
	
	
	for i=0,miNumRadarContacts do
		if m_vecRadarContactPos[i] && m_iRadarContactType[i] then
			AddRadarContact(m_vecRadarContactPos[i],m_iRadarContactType[i], flContactTimeToLive );
		end
	end
	
end

Init();

//AddRadarContact(Vector(0,50,0),RADAR_CONTACT_MAGNUSSEN_RDU,60)

hook.Add("HUDPaint", "EP2_RADAR_PAINT", Paint);
hook.Add( "Think", "EP2_RADAR_THINK", RadarSearch )