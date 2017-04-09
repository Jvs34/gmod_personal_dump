//----------------------------------------------------------------------
//VoiceMenu,a source engine style menu command,customizable as you like.
//By Jvs,copyright 2009/2010 www.multiplayer-italia.com
//----------------------------------------------------------------------
//REMEMBER!You can't use these commands with this addon!
/*
"con_enable""sv_cheats","_restart","exec","condump","bind","BindToggle",
"alias","ent_fire","ent_setname","sensitivity","name","r_aspect","quit",
"exit","lua_run","lua_run_cl","lua_open","lua_cookieclear","lua_showerrors_cl",
"lua_showerrors_sv","lua_openscript","lua_openscript_cl","lua_redownload",
"sent_reload","sent_reload_cl","swep_reload","swep_reload_cl","gamemode_reload",
"gamemode_reload_cl","con_logfile","clear","rcon_password","test_RandomChance"
*/

//TODO,support for customized voicemenus with file names different from "voicemenu/menu.txt"
require("glon")
surface.CreateFont( "Tahoma", 16, 1000, true, false, "VoicemenuFont")
local voicemenu_FILE="voicemenu/menu.txt" //don't touch this
local EDITOR_MENU=1; //don't touch this
local LAST_MENU=1;	//don't touch this
local voicemenu_COLOR=Color(255, 255, 255, 200) //touch this!
local delaymenu=0.5 //touch this
local drawmenu=0;//don't touch this,the default menu is 0 (none)
local nextmenuopen=CurTime()+delaymenu;//don't touch this.
local voicemenufont="VoicemenuFont";//don't... well,you might touch this if you want to.
local firsttimeloaded=false;//this boolean controls if we loaded the voicemenu from a file for the first time.
local maxx=ScrW()
local maxy=ScrH()
local menx=27; //TODO:Make this x,y tweakable in the voicemenueditor?
local meny=maxy/2;

local editorisopen=false;

local functionstable={}
functionstable[1]={}				
functionstable[1].functname="StupidFunctionName"
functionstable[1].functinfo="This is just a stupid function information,bla bla bla bla."
functionstable[1].functrun=function(bla)MsgN("bla bla bla bla "..bla)end
functionstable[1].functprm=1;

local voicemenu={}	//ABSOLUTELY don't touch this one.			
voicemenu[EDITOR_MENU]={}				
voicemenu[EDITOR_MENU].item={}
	for i =1 ,8 do
	voicemenu[EDITOR_MENU].item[i]={}
	voicemenu[EDITOR_MENU].item[i].text="Empty"..i	
	voicemenu[EDITOR_MENU].item[i].cmd="say"
	voicemenu[EDITOR_MENU].item[i].param="Sorry,but i forgot to edit the voicemenu config,i should write cl_editvoicemenu in console."
	end

	
function RegisterVoicemenuFunction(func,name,info,parameters)	
	local ft={}
	ft.functname=name
	ft.functrun=func
	ft.functinfo=info
	ft.functprm=parameters;
	table.insert(functionstable,ft)
end

local function loadvoicemenu(param)
	if not param || !file.Read(param) then
	voicemenu = glon.decode(file.Read(voicemenu_FILE))
	else
	voicemenu = glon.decode(file.Read(param))
	end
end

local function savevoicemenu()
	file.Write(voicemenu_FILE, glon.encode(voicemenu))
end

local function addvoicemenu()
	local grand=#voicemenu+1
	voicemenu[grand]={}				
	voicemenu[grand].item={}
	for i =1 ,8 do
	voicemenu[grand].item[i]={}
	voicemenu[grand].item[i].text="Empty"..i	
	voicemenu[grand].item[i].cmd=""
	voicemenu[grand].item[i].param=""
	end
end

local function removevoicemenu(number)
	if #voicemenu <=1 then return end //don't remove the last menu
	if ! number then
	table.remove(voicemenu)
	else
	table.remove(voicemenu,number)
	end
end


local function editvoicemenu()
	if(editorisopen)then 
	surface.PlaySound( "buttons/button2.wav" )
	return end
	editorisopen=true;
	gui.EnableScreenClicker(true)
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 50,50 )
	DermaPanel:SetSize( 240, 370 )
	DermaPanel:SetTitle( "VoiceMenu Editor" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( false )
	DermaPanel:SetMouseInputEnabled(true)
	DermaPanel:SetKeyboardInputEnabled(true)
	DermaPanel:MakePopup()

/*
	local ColorCircle= vgui.Create("DColorMixer",DermaPanel)
	ColorCircle:SetPos( 10, 300)
	ColorCircle:SetSize(DermaPanel:GetWide()-5,65)
	ColorCircle:SetConVarR(voicemenu_COLOR.r)
	ColorCircle:SetConVarG(voicemenu_COLOR.g)
	ColorCircle:SetConVarB(voicemenu_COLOR.b)
	ColorCircle:SetConVarA(voicemenu_COLOR.a)
*/	
	local CloseBtn = vgui.Create("DButton", DermaPanel)
	CloseBtn:SetText( "Close" )
	CloseBtn:SetPos( DermaPanel:GetWide()-55, 30)
	CloseBtn:SetWide( 50 )
	CloseBtn:SetTall( 20 )
	CloseBtn.DoClick = function() 
		editorisopen=false;
		DermaPanel:Close() 
		gui.EnableScreenClicker(false)
		surface.PlaySound( "buttons/button24.wav" )
	end
	
	local MenuBtn = vgui.Create("DButton", DermaPanel)
	MenuBtn:SetText( "Menu" )
	MenuBtn:SetPos( DermaPanel:GetWide()-110, 30)
	MenuBtn:SetWide( 50 )
	MenuBtn:SetTall( 20 )
	MenuBtn.DoClick = function() 
						local MenuButtonOptions = DermaMenu()
						MenuButtonOptions:AddOption("Save Voice Menu", function() editorisopen=false; savevoicemenu() DermaPanel:Close() gui.EnableScreenClicker(false) surface.PlaySound( "buttons/button24.wav" )	end ) -- Add options to the menu
						MenuButtonOptions:AddOption("Load Voices Menu", function() editorisopen=false; loadvoicemenu() DermaPanel:Close() gui.EnableScreenClicker(false) surface.PlaySound( "buttons/button24.wav" ) end )
						MenuButtonOptions:AddOption("Add Menu", function() editorisopen=false; addvoicemenu() DermaPanel:Close() gui.EnableScreenClicker(false) surface.PlaySound( "buttons/button24.wav" ) end )
						MenuButtonOptions:AddOption("Remove Menu", function() editorisopen=false; DermaPanel:Close() gui.EnableScreenClicker(false) removevoicemenu(EDITOR_MENU) surface.PlaySound( "buttons/button24.wav" ) end )
						MenuButtonOptions:Open()
					  end
	
	
	local List = vgui.Create("DMultiChoice", DermaPanel );
		List:SetEditable( false )
		List:SetPos( 10, 30)
		for i=1,#voicemenu do List:AddChoice("Menu "..i) end
		List.OnSelect = function(index,value,data) if EDITOR_MENU != value then	LAST_MENU=EDITOR_MENU EDITOR_MENU=value end	end
		if EDITOR_MENU <= #voicemenu then List:ChooseOptionID( EDITOR_MENU ) else List:ChooseOptionID( 1 ) end
		
	local LABELZ={}
	for i=1,8 do
		LABELZ[i] = vgui.Create( "DLabel", DermaPanel ) 
		LABELZ[i]:SetPos( 10,40+(i*30) )
		LABELZ[i]:SetTall( 20 )
		LABELZ[i]:SetWide( 50 )
		LABELZ[i]:SetText("Choice"..i);
	end
		LABELZ[9] = vgui.Create( "DLabel", DermaPanel )
		LABELZ[9]:SetPos( 70,50 )
		LABELZ[9]:SetTall( 20 )
		LABELZ[9]:SetWide( 50 )
		LABELZ[9]:SetText("Text");
		
		LABELZ[10] = vgui.Create( "DLabel", DermaPanel )
		LABELZ[10]:SetPos( 130,50 )
		LABELZ[10]:SetTall( 20 )
		LABELZ[10]:SetWide( 50 )
		LABELZ[10]:SetText("Cmd");
		
		LABELZ[11] = vgui.Create( "DLabel", DermaPanel )
		LABELZ[11]:SetPos( 180,50 )
		LABELZ[11]:SetTall( 20 )
		LABELZ[11]:SetWide( 50 )
		LABELZ[11]:SetText("Param");
	
	local NameEntry={}
	
	for i=1,8 do
		NameEntry[i] = vgui.Create( "DTextEntry", DermaPanel )
		NameEntry[i]:SetPos( 60,40+(i*30) )
		NameEntry[i]:SetTall( 20 )
		NameEntry[i]:SetWide( 50 )
		NameEntry[i]:SetEnterAllowed( true )
		NameEntry[i]:SetValue(voicemenu[EDITOR_MENU].item[i].text);
		NameEntry[i].OnTextChanged  = function(p1)
			voicemenu[EDITOR_MENU].item[i].text=p1:GetValue();
		end
		NameEntry[i].Think = function()
			if LAST_MENU != EDITOR_MENU then NameEntry[i]:SetValue(voicemenu[EDITOR_MENU].item[i].text) end	
		end
	end
	
	local CMDEntry={}
	
	for i=1,8 do
		CMDEntry[i] = vgui.Create( "DTextEntry", DermaPanel )
		CMDEntry[i]:SetPos( 120,40+(i*30) )
		CMDEntry[i]:SetTall( 20 )
		CMDEntry[i]:SetWide( 50 )
		CMDEntry[i]:SetEnterAllowed( true )
		CMDEntry[i]:SetValue(voicemenu[EDITOR_MENU].item[i].cmd);
		CMDEntry[i].OnTextChanged  = function(p1)
			voicemenu[EDITOR_MENU].item[i].cmd=p1:GetValue();
		end
		CMDEntry[i].Think = function()
			if LAST_MENU != EDITOR_MENU then CMDEntry[i]:SetValue(voicemenu[EDITOR_MENU].item[i].cmd) end	
		end
	end
	
	local PRMEntry={}
	
	for i=1,8 do
		PRMEntry[i] = vgui.Create( "DTextEntry", DermaPanel )
		PRMEntry[i]:SetPos( 180,40+(i*30) )
		PRMEntry[i]:SetTall( 20 )
		PRMEntry[i]:SetWide( 50 )
		PRMEntry[i]:SetEnterAllowed( true )
		PRMEntry[i]:SetValue(voicemenu[EDITOR_MENU].item[i].param);
		PRMEntry[i].OnTextChanged  = function(p1)
			voicemenu[EDITOR_MENU].item[i].param=p1:GetValue();
		end
		PRMEntry[i].Think = function()
			if LAST_MENU != EDITOR_MENU then PRMEntry[i]:SetValue(voicemenu[EDITOR_MENU].item[i].param) end	
		end
	end

end
concommand.Add("cl_editvoicemenu", editvoicemenu)


local function SengineCmd(ply,command,arguments)
	local NUM=tonumber(arguments[1])
	if(!NUM || (NUM<=0 || NUM> #voicemenu ))then 
		drawmenu=0;
	end
	if(nextmenuopen<=CurTime() && ply:Alive())then
		if(NUM==nil)then 
		surface.PlaySound( "buttons/button2.wav" )
		return
		end
		
		if(NUM == drawmenu)then
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/blip1.wav" )
		else
		drawmenu=NUM;
		nextmenuopen=CurTime()+delaymenu
		end
	end
end
concommand.Add( "cl_voicemenu", SengineCmd )

local function SEngineMenu()
	if !firsttimeloaded then
		//basically,this is like PlayerInitialSpawn
		//you can put your code here,for example,to choose a different voicemenu per gamemode,server,even level.
		//oh and,like PlayerInitialSpawn,this code is run once.
		if gmod.GetGamemode().Name=="Team Fortress 2" then
			loadvoicemenu("voicemenu/menu_tf2.txt")
			voicemenu_FILE="voicemenu/menu_tf2.txt";//so in the ingame editor you can access to that file.
		else
			loadvoicemenu(voicemenu_FILE) //load the default filename
		end
		firsttimeloaded=true;
	end
	
	local ply = LocalPlayer()
	//Gorden freeman is dead? close the menu,NAO
	if(!ply:Alive() )then
		drawmenu=0;
	end
	//TODO:Put this code inside a "for" cycle,but i'm not sure if that will slow the code.
	if input.IsKeyDown(KEY_1) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[1].cmd ,   voicemenu[drawmenu].item[1].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_2) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[2].cmd ,   voicemenu[drawmenu].item[2].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_3) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[3].cmd ,   voicemenu[drawmenu].item[3].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_4) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[4].cmd ,   voicemenu[drawmenu].item[4].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_5) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[5].cmd ,   voicemenu[drawmenu].item[5].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_6) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[6].cmd ,   voicemenu[drawmenu].item[6].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_7) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[7].cmd ,   voicemenu[drawmenu].item[7].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_8) && drawmenu>0 && drawmenu<=#voicemenu then
		RunConsoleCommand(voicemenu[drawmenu].item[8].cmd ,   voicemenu[drawmenu].item[8].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		surface.PlaySound( "buttons/button24.wav" )
	elseif input.IsKeyDown(KEY_9) && drawmenu>0 && drawmenu<=#voicemenu then
		drawmenu=0;
		surface.PlaySound( "buttons/blip1.wav" )
	end
end

hook.Add( "Think", "SEngineMenu", SEngineMenu )



local function DrawSMenu()
	local ply=LocalPlayer();

	if(drawmenu>0 && drawmenu<=#voicemenu)then
		local maxw=0;
		for i = 1, 8 do
			surface.SetFont(voicemenufont) //this is needed or the getTextSize will screw up.
			local W,H=surface.GetTextSize(i..". "..voicemenu[drawmenu].item[i].text)
			if maxw < W then maxw=W	end //look there is a text larger than our larger text,what the hell?
		end
		
		//souce engine style rounded box.
		draw.RoundedBox(4,menx,meny, maxw+20, meny - 220,Color(0, 0, 0, 76))
		//draw the voicemenu choises!
		for i = 1, 9 do
			if(i==9)then
			draw.DrawText(i..". Cancel",voicemenufont, menx+5,meny+(15*i), voicemenu_COLOR, 0)
			else
			draw.DrawText(i..". "..voicemenu[drawmenu].item[i].text,voicemenufont, menx+5,meny+(15*i), voicemenu_COLOR, 0)
			end
		end
	end
end
hook.Add("HUDPaint", "DrawSMenu", DrawSMenu);

local function SengineDraw( name )
	local ply=LocalPlayer();
	//hey,you are selecting a voicemenu option,meanwhile you shouldn't choose a wepon or seeing the chat.
	if ( (name == "CHudWeaponSelection" or name == "CHudChat") && drawmenu>0 && drawmenu<=#voicemenu ) then return false end
end
hook.Add( "HUDShouldDraw", "SengineDraw", SengineDraw )