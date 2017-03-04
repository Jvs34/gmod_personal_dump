local vignettachat = CreateConVar( "cl_vignette", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the vignette" )
surface.CreateFont( "coolvetica", 20, 500, true, false, "GModVignetta" )

local TipColor = Color( 255, 255, 255, 255 )
local disapperafter=1
local roundness=16;
local FPEMOTICONS={":sigh:",":hehe:",":c:",":sympathy:",":laffo:",":cthulhu:",":whip:",":nyoron:",":f5h:",":raise:",":gb2gbs:",":argh:",":saddowns:",":goonsay:",":britain:",":ssj:",":jewish:",":colbert:",":vd:",":moustache:",":drugnerd:",":yoshi:",":pseudo:",":frown:",":11tea:",":banjo:",":smugdog:",":hurr:",":ccb:",":toughguy:",":madmax:",":dominic:",":words:",":pcgaming1:",":flashfact:",":riker:",":godwin:",":shroom:",":hchatter:",":byodood:",":swoon:",":kratos:",":crying:",":whatup:",":nyd:",":f5:",":question:",":gb2fyad:",":angel:",":s:",":gooncamp:",":bravo2:",":ssh:",":jerkbag:",":coffee:",":v:",":monocle:",":drac:",":yohoho:",":protarget:",":frogsiren:",":10bux:",":bang:",":smug:",":huh:",":cawg:",":toot:",":mad:",":doink:",":wooper:",":pcgaming:",":flame:",":rice:",":goatse:",":shopkeeper:",":hawaaaafap:",":byobear:",":sweep:",":kraken:",":crow:",":what:",":nws:",":evol-anim:",":quagmire:",":gb2byob:",":am:",":goonboot:",":bravo:",":spooky:",":j:",":coal:",":ussr:",":monar:",":downswords:",":yarr:",":pranke:",":froggonk:",":3:",":russbus:",":bandwagon:",":smithicide:",":hr:",":catholic:",":todd:",":lsd:",":doh:",":woop:",":patriot:",":flag:",":respek:",":glomp:",":shobon:",":haw:",":byob:",":sweden:",":krad2:",":crossarms:",":weed:",":nms:",":ese:",":qfg:",":gay:",":allears:",":goon:",":boonie:",":spidey:",":itjb:",":clownballoon:",":unsmith:",":mmmsmug:",":downsrim:",":xie:",":pluto:",":frogdowns:",":2bong:",":rudebox:",":smith:",":horse:",":canada:",":tiphat:",":lron:",":devil:",":wookie:",":page3:",":flaccid:",":regd09:",":gizz:",":bahgawd:",":shlick:",":havlat:",":byewhore:",":sweatdrop:",":killdozer:",":coupons:",":wcw:",":ninja:",":engleft:",":q:",":FYH:",":airquote:",":google:",":blush:",":spergin:",":irony:",":clint:",":unsmigghh:",":mmmhmm:",":downsowned:",":xd:",":pirate:",":frogc00l:",":07:",":rubshandstogetheran",":smile:",":holy:",":can:",":tinfoil:",":lovewcc:",":derp:",":woof:",":owned:",":firstpost:",":regd08:",":gibs:",":axe:",":shivdurf:",":happyelf:",":buttertroll:",":supaburn:",":kiddo:",":cop:",":wcc:",":niggly:",":eng101:",":pwn:",":fyadride:",":aaaaa:",":goof:",":black101:",":spain:",":ironicat:",":classic_fillmore:",":uhaul:",":milk:",":downsgun:",":wth:",":pipe:",":frogbon:",":06:",":rolleyes:",":slick:",":hitler:",":camera6:",":their:",":love:",":denmark:",":wom:",":orks:",":fireman:",":redhammer:",":ghost:",":awesomelon:",":sharpton:",":hampants:",":butt:",":sun:",":keke:",":coolfish:",":waycool:",":neckbeard:",":eng99:",":specialschool:",":psypop:",":furcry:",":aaa:",":gonk:",":bigtran:",":sotw:",":iiam:",":chio:",":twisted:",":mexico:",":downsbravo:",":wtf:",":phoneline:",":frog:",":05:",":rolleye:",":sissies:",":hist101:",":ca:",":tf:",":lost:",":Dawkins102:",":wmwink:",":onlyoption:",":filez:",":redface:",":george:",":awesome:",":sg:",":burger:",":suicide:",":kamina:",":cool:",":wal:",":nattyburn:",":emo:",":zoro:",":psylon:",":fuckyou:",":a2m:",":gonchar:",":biggrin:",":sonia:",":iiaca:",":china:",":twentyfour:",":megaman:",":downs:",":wtc:",":phoneb:",":france:",":04:",":roflolmao:",":siren:",":hfive:",":c00lbutt:",":techno:",":lol:",":dance:",":witch:",":ohdear:",":fiesta:",":razz:",":geno:",":australia:",":scotland:",":guitar:",":buddy:",":stoat:",":kakashi:",":confused:",":w2byob:",":munch:",":effort:",":zombie:",":psyduck:",":fuckoff:",":911:",":bick:",":snoop:",":iia:",":chef:",":tubular:",":master:",":dota101:",":wrongful:",":phone:",":foxnews:",":rodimus:",":golgo:",":silent:",":hf:",":c00lbert:",":taco:",":livestock~01-14-04-whore:",":damn:",":wink:",":objection:",":fh:",":rant:",":gbsmith:",":aslol:",":science:",":gtfoycs:",":bubblewoop:",":stat:",":joel:",":commissar:",":w00t:",":mufasa:",":eek:",":zoid:",":psyboom:",":ftbrg:",":350:",":belarus:",":smugspike:",":iceburn:",":cheers:",":trashbear:",":mason:",":doom:",":wotwot:",":pervert:",":fork:",":rock:",":golfclap:",":golfclap:",":signings:",":hellyeah:",":c00l:",":synpa:",":laugh:",":d:",":whoptc:",":obama:",":fappery:",":ramsay:",":gb2hd2k:",":arghfist:",":sax:",":greatgift:",":bsg:",":stalker:",":jihad:",":comeback:",":vick:",":ms:",":drum:",":zerg:",":psyberger:",":fsmug:",":20bux:",":barf:",":smugissar:",":hydrogen:",":chatter:",":toxx:",":mario:",":dong:",":worship:",":pedo:",":flashfap:",":rimshot:",":goleft:",}
local urlpart1,urlpart2="http://www.facepunch.com/fp/emoot/",".gif"
local VIGNETTA_EMOTICON=CreateMaterial("vignettaemoticon1","UnlitGeneric",{})

local function createurl(emoticonname)
  return urlpart1..string.gsub(emoticonname,":","")..urlpart2
end

local function tabfind(tab,str)
  for i,v in pairs(tab) do
    if type(v)=="string" && string.find(str,v) then return true end
  end
  return false;
end

local function getemoticons(str)
  local emot="";
  for i,v in pairs(FPEMOTICONS) do
    local find=string.find(str,v)
    if find then
      str=string.gsub(str,v,"")
      emot=emot..","..v
    end
  end
  return emot;
end

local function getemoticon(str)
  for i,v in pairs(FPEMOTICONS) do
    if string.find(str,v) then
      return v;
    end
  end
end

local function AddVignetta( ply, text)
  ply.Vignetta =ply.Vignetta or {}
  if !ply.Vignetta.Lines then ply.Vignetta.Lines=0; end
  if ply.Vignetta.Lines <3 then
    ply.Vignetta.Lines=ply.Vignetta.Lines+1
  else
    ply.Vignetta.Lines=0;
  end
  --find the emoticon they are using and strip that text from the vignetta
  if tabfind(FPEMOTICONS,text) then
    ply.Vignetta.Emoticon=getemoticon(text);
    text=string.gsub(text,ply.Vignetta.Emoticon,"")

  end
  if string.find(text,"&") then
    text=string.gsub(text,"&","")
  end
  
  ply.Vignetta.text     =(ply.Vignetta.text && ply.Vignetta.Lines < 3)and ply.Vignetta.text.."\n"..text or text
  
  ply.Vignetta.dietime   = CurTime() + 5
  ply.Vignetta.fadeafter  = ply.Vignetta.dietime-disapperafter
  ply.Vignetta.Color=team.GetColor(ply:Team());
  if ply.Vignetta.Emoticon then
    if ply.Emoticon then
      ply.Emoticon:Remove();
      ply.Emoticon=nil;
    end
    ply.Emoticon = vgui.Create("HTML")
    local html=[[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">body {
	-webkit-background-size: 100%;
	background-size: 100%;
	background-image: url('%EMOTE%');
	background-repeat : no-repeat;
	margin: 0px;
	overflow: hidden;
}
</style></head><body></body></html>]]
	
	html=html:gsub("%%EMOTE%%",createurl(ply.Vignetta.Emoticon))
    ply.Emoticon:SetHTML(html)
    ply.Emoticon:SetSize(64,64)
    ply.Emoticon:SetVerticalScrollbarEnabled( false )
    ply.Emoticon:SetPaintedManually( true )
  end
  
end


local function DrawVignetta( ply )
  local tip=ply.Vignetta
  local pos = Vector(0,0,0)
  
  local disappearingalpha=255
  /*
  if tip.fadeafter<CurTime() then
    local fract=math.TimeFraction(tip.dietime-disapperafter,tip.dietime, CurTime() )
    disappearingalpha=Lerp(fract,255,0)
  end
  */
  
  local black = Color( 0, 0, 0, disappearingalpha )
  local tipcol = Color( TipColor.r, TipColor.g, TipColor.b, disappearingalpha )
  
  local x = 0
  local y = 0
  local padding = 10
  local offset = 50
  
  surface.SetFont( "GModVignetta" )
  local w, h = surface.GetTextSize( tip.text )
  local originw,originh=w,h;
  if tip.Emoticon then
    h=h+64
    if w < 64 then
      w=64
    end
  end
  
  x = pos.x - w 
  y = pos.y - h 
  
  x = x - offset
  y = y - offset
  
  
  draw.RoundedBox( roundness, x-padding-2, y-padding-2, w+padding*2+4, h+padding*2+4, black )
  
  
  local verts = {}
  verts[1] = { x=x+w/1.5-2, y=y+h+2 }
  verts[2] = { x=x+w+2, y=y+h/2-1 }
  verts[3] = { x=pos.x-offset/2+2, y=pos.y-offset/2+2 }
  
  draw.NoTexture()
  surface.SetDrawColor( 0, 0, 0, tipcol.a )
  surface.DrawPoly( verts )
  
  
  draw.RoundedBox( roundness, x-padding, y-padding, w+padding*2, h+padding*2, tipcol )
  
  local verts = {}
  verts[1] = { x=x+w/1.5, y=y+h }
  verts[2] = { x=x+w, y=y+h/2 }
  verts[3] = { x=pos.x-offset/2, y=pos.y-offset/2 }
  
  draw.NoTexture()
  surface.SetDrawColor( tipcol.r, tipcol.g, tipcol.b, tipcol.a )
  surface.DrawPoly( verts )
  /*
  if tip.Color then
    black=tip.Color
  end
  */
  draw.DrawText( tip.text, "GModWorldtip", x + w/2, y, black, TEXT_ALIGN_CENTER )
  --draw here
  --
  if tip.Emoticon && ply.Emoticon && ply.Emoticon:GetHTMLMaterial() then
    surface.SetDrawColor( 255,255,255,255 )
    VIGNETTA_EMOTICON:SetMaterialTexture( "$basetexture",ply.Emoticon:GetHTMLMaterial():GetMaterialTexture( "$basetexture" ))
    surface.SetMaterial( VIGNETTA_EMOTICON )
    surface.DrawTexturedRect(x,y+originh,64,64)
  end
end


hook.Add("OnPlayerChat","CreateVignetta",function( ply, strText, bTeamOnly, bPlayerIsDead )
  --[[if ply!=LocalPlayer() || LocalPlayer():Nick()!="Jvs" then
    LocalPlayer():EmitSound("Buttons.snd16" )
  end
  ]]
  if !IsValid(ply) then return end

  AddVignetta(ply,strText)

end)

  hook.Add("PostPlayerDraw", "DrawVignetta", function(ply)
    if !vignettachat:GetBool() then return end
    if !ply:Alive() || !ply.Vignetta  then return end
      if ply.Vignetta.dietime < CurTime() then
        if ply.Emoticon then
          ply.Emoticon:Remove();
          ply.Emoticon=nil;
        end
        ply.Vignetta=nil;
        return;
    end
    cam.Start3D( EyePos(), EyeAngles() )

      local ang = EyeAngles()
      
      ang:RotateAroundAxis( ang:Forward(), 90 )
      ang:RotateAroundAxis( ang:Right(), 90 )
      local posit=ply:GetShootPos()
      local mouth=ply:LookupAttachment("mouth")
      if mouth && ply:GetAttachment(mouth) then
        posit=ply:GetAttachment(mouth).Pos
      end
      cam.Start3D2D(posit, Angle( 0, ang.y, 90 ), 0.3)
        DrawVignetta(ply)
      cam.End3D2D()
    cam.End3D()
  end)
