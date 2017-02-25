//----------------------------------------------------------------------
//VoiceMenu,a source engine style menu command,customizable as you like.
//By Jvs,copyright 2009/2010 www.multiplayer-italia.com
//----------------------------------------------------------------------
surface.CreateFont( "Tahoma", 16, 1000, true, false, "CoolText")
//REMEMBER!You can't use these commands with this addon!

/*
"con_enable""sv_cheats","_restart","exec","condump","bind","BindToggle",
"alias","ent_fire","ent_setname","sensitivity","name","r_aspect","quit",
"exit","lua_run","lua_run_cl","lua_open","lua_cookieclear","lua_showerrors_cl",
"lua_showerrors_sv","lua_openscript","lua_openscript_cl","lua_redownload",
"sent_reload","sent_reload_cl","swep_reload","swep_reload_cl","gamemode_reload",
"gamemode_reload_cl","con_logfile","clear","rcon_password","test_RandomChance"
*/

//And of course you can't use any function with "ent_" inside,ex: "client_ent_nwfloat"
local voicemenufont="CoolText";
//this is just an example of tf2 voicemenu,modify it as you like,but DON'T,and i say,DON'T reupload
//any part of this addon withouth my permission
//to create a new menu paste from |
local hevmenu={}				//|
//Menu 1						//V
	hevmenu[1]={}				//here to the end of hevmenu[1].item[8],and of course change the new hevmenu[1] to hevmenu[2]
	hevmenu[1].item={}
	hevmenu[1].item[1]={}
	hevmenu[1].item[1].text="Medic!"
	hevmenu[1].item[1].cmd="say"
	hevmenu[1].item[1].param="Medic!"
	hevmenu[1].item[2]={}
	hevmenu[1].item[2].text="Thanks"
	hevmenu[1].item[2].cmd="say"
	hevmenu[1].item[2].param="Thanks!"
	hevmenu[1].item[3]={}
	hevmenu[1].item[3].text="Go,go,go!"
	hevmenu[1].item[3].cmd="say"
	hevmenu[1].item[3].param="Go go go!"
	hevmenu[1].item[4]={}
	hevmenu[1].item[4].text="Move gear forward!"
	hevmenu[1].item[4].cmd="say"
	hevmenu[1].item[4].param="Move gear forward"
	hevmenu[1].item[5]={}
	hevmenu[1].item[5].text="Go left!"
	hevmenu[1].item[5].cmd="say"
	hevmenu[1].item[5].param="Go to the left!"
	hevmenu[1].item[6]={}
	hevmenu[1].item[6].text="Go Right!"
	hevmenu[1].item[6].cmd="say"
	hevmenu[1].item[6].param="Go to the right!"
	hevmenu[1].item[7]={}
	hevmenu[1].item[7].text="Yes"
	hevmenu[1].item[7].cmd="say"
	hevmenu[1].item[7].param="Yes"
	hevmenu[1].item[8]={}
	hevmenu[1].item[8].text="No"
	hevmenu[1].item[8].cmd="say"
	hevmenu[1].item[8].param="No"
//menu2
	hevmenu[2]={}				
	hevmenu[2].item={}
	hevmenu[2].item[1]={}
	hevmenu[2].item[1].text="Incoming!"
	hevmenu[2].item[1].cmd="say"
	hevmenu[2].item[1].param="Incoming!"
	hevmenu[2].item[2]={}
	hevmenu[2].item[2].text="Spy!"
	hevmenu[2].item[2].cmd="say"
	hevmenu[2].item[2].param="Spy!"
	hevmenu[2].item[3]={}
	hevmenu[2].item[3].text="Sentry ahead!"
	hevmenu[2].item[3].cmd="say"
	hevmenu[2].item[3].param="Sentry ahead!"
	hevmenu[2].item[4]={}
	hevmenu[2].item[4].text="Need a teleporter here!"
	hevmenu[2].item[4].cmd="say"
	hevmenu[2].item[4].param="Need a teleporter here!"
	hevmenu[2].item[5]={}
	hevmenu[2].item[5].text="Need a dispenser here!"
	hevmenu[2].item[5].cmd="say"
	hevmenu[2].item[5].param="Need a dispenser here!"
	hevmenu[2].item[6]={}
	hevmenu[2].item[6].text="Need a sentry here!"
	hevmenu[2].item[6].cmd="say"
	hevmenu[2].item[6].param="Need a sentry here!"
	hevmenu[2].item[7]={}
	hevmenu[2].item[7].text="Activate the charge!"
	hevmenu[2].item[7].cmd="say"
	hevmenu[2].item[7].param="Activate the charge!"
	hevmenu[2].item[8]={}
	hevmenu[2].item[8].text="I am fully charged"
	hevmenu[2].item[8].cmd="say"
	hevmenu[2].item[8].param="I am fully charged!"
//menu3
	hevmenu[3]={}				
	hevmenu[3].item={}
	hevmenu[3].item[1]={}
	hevmenu[3].item[1].text="Help!"
	hevmenu[3].item[1].cmd="say"
	hevmenu[3].item[1].param="Help!"
	hevmenu[3].item[2]={}
	hevmenu[3].item[2].text="Battle cry"
	hevmenu[3].item[2].cmd="say"
	hevmenu[3].item[2].param="Let's waste stuff!"
	hevmenu[3].item[3]={}
	hevmenu[3].item[3].text="Cheers."
	hevmenu[3].item[3].cmd="say"
	hevmenu[3].item[3].param="Hehehe."
	hevmenu[3].item[4]={}
	hevmenu[3].item[4].text="Jeers."
	hevmenu[3].item[4].cmd="say"
	hevmenu[3].item[4].param="Damn..."
	hevmenu[3].item[5]={}
	hevmenu[3].item[5].text="Positive"
	hevmenu[3].item[5].cmd="say"
	hevmenu[3].item[5].param="Awesome."
	hevmenu[3].item[6]={}
	hevmenu[3].item[6].text="Negative"
	hevmenu[3].item[6].cmd="say"
	hevmenu[3].item[6].param="You all suck"
	hevmenu[3].item[7]={}
	hevmenu[3].item[7].text="Nice shot"
	hevmenu[3].item[7].cmd="say"
	hevmenu[3].item[7].param="Nice shot"
	hevmenu[3].item[8]={}
	hevmenu[3].item[8].text="Good Job"
	hevmenu[3].item[8].cmd="say"
	hevmenu[3].item[8].param="Good Job"
//menu3
	hevmenu[4]={}				
	hevmenu[4].item={}
	hevmenu[4].item[1]={}
	hevmenu[4].item[1].text="Question"
	hevmenu[4].item[1].cmd="speak_citizen"
	hevmenu[4].item[1].param="question"
	hevmenu[4].item[2]={}
	hevmenu[4].item[2].text="Follow me."
	hevmenu[4].item[2].cmd="speak_citizen"
	hevmenu[4].item[2].param="followme"
	hevmenu[4].item[3]={}
	hevmenu[4].item[3].text="You are a traitor!"
	hevmenu[4].item[3].cmd="speak_citizen"
	hevmenu[4].item[3].param="traitor"
	hevmenu[4].item[4]={}
	hevmenu[4].item[4].text="Took Position."
	hevmenu[4].item[4].cmd="speak_citizen"
	hevmenu[4].item[4].param="tookposition"
	hevmenu[4].item[5]={}
	hevmenu[4].item[5].text="Waiting..."
	hevmenu[4].item[5].cmd="speak_citizen"
	hevmenu[4].item[5].param="waiting"
	hevmenu[4].item[6]={}
	hevmenu[4].item[6].text="Cheer"
	hevmenu[4].item[6].cmd="speak_citizen"
	hevmenu[4].item[6].param="cheer"
	hevmenu[4].item[7]={}
	hevmenu[4].item[7].text=""
	hevmenu[4].item[7].cmd=""
	hevmenu[4].item[7].param=""
	hevmenu[4].item[8]={}
	hevmenu[4].item[8].text=""
	hevmenu[4].item[8].cmd=""
	hevmenu[4].item[8].param=""
local delaymenu=0.5 
local drawmenu=0;//don't touch this,the default menu is 0 (none)
local nextmenuopen=CurTime()+delaymenu;//don't spam the voicemenu.

local function SengineCmd(ply,command,arguments)
	local NUM=tonumber(arguments[1])
	if(!arguments[1] || (NUM<=0 || NUM> #hevmenu ))then 
		drawmenu=0;
	end
	if(nextmenuopen<=CurTime() && ply:Alive())then
		if(NUM == drawmenu)then
		drawmenu=0;
		ply:EmitSound("buttons/blip1.wav",100,100)
		else
		drawmenu=NUM;
		nextmenuopen=CurTime()+delaymenu
		end
	end
end
concommand.Add( "hev_voicemenu", SengineCmd )

local function SEngineMenu()

	local ply = LocalPlayer()
	//Gorden freeman is dead? close the menu,NAO
	if(!ply:Alive() )then
		drawmenu=0;
	end
	//TODO:Making this stupid code only one if,so i can use moar menus
	if input.IsKeyDown(KEY_1) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[1].cmd ,   hevmenu[drawmenu].item[1].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_2) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[2].cmd ,   hevmenu[drawmenu].item[2].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_3) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[3].cmd ,   hevmenu[drawmenu].item[3].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_4) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[4].cmd ,   hevmenu[drawmenu].item[4].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_5) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[5].cmd ,   hevmenu[drawmenu].item[5].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_6) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[6].cmd ,   hevmenu[drawmenu].item[6].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_7) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[7].cmd ,   hevmenu[drawmenu].item[7].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_8) && drawmenu>0 && drawmenu<=#hevmenu then
		RunConsoleCommand(hevmenu[drawmenu].item[8].cmd ,   hevmenu[drawmenu].item[8].param);
		drawmenu=0;
		nextmenuopen=CurTime()+delaymenu
		ply:EmitSound("buttons/button24.wav")
	elseif input.IsKeyDown(KEY_9) && drawmenu>0 && drawmenu<=#hevmenu then
		drawmenu=0;
		ply:EmitSound("buttons/blip1.wav")
	end
end

hook.Add( "Think", "SEngineMenu", SEngineMenu )

local menx,meny=27,ScrH() / 2;

local function DrawSMenu()
	local ply=LocalPlayer();
	if(drawmenu>0 && drawmenu<=#hevmenu)then
		//souce engine style rounded box.
		draw.RoundedBox(4,menx,meny, ScrW() / 2 - 300 , ScrH() / 2 - 220,Color(0, 0, 0, 76))
		//draw the voicemenu choises!
		for i = 1, 9 do
			if(i==9)then
			draw.DrawText(i..". Cancel",voicemenufont, menx+5,meny+(15*i), Color(255, 220, 0, 200), 0)
			else
			draw.DrawText(i..". "..hevmenu[drawmenu].item[i].text,voicemenufont, menx+5,meny+(15*i), Color(255, 220, 0, 200), 0)
			end
		end
	end
end
hook.Add("HUDPaint", "DrawSMenu", DrawSMenu);

local function SengineDraw( name )
	local ply=LocalPlayer();
	//ehi,you are selecting a voicemenu option,meanwhile you shouldn't choose a wepon or seeing the chat.
	if ( (name == "CHudWeaponSelection" or name == "CHudChat") && drawmenu>0 && drawmenu<=#hevmenu ) then return false end
end
hook.Add( "HUDShouldDraw", "SengineDraw", SengineDraw )