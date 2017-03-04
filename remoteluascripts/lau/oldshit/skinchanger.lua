--if notgame.SinglePlayer() then return end


local hevmaterial=Material("models/Weapons/V_hand/v_hand_sheet")
local oldhevbasetexture=nil
local firstuse=false
local HTMLPANEL
local skins={
["gman"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/gman.png",
["police"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/metrocop.png",
["barney"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/metrocop.png",
["super_soldier"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/supercombine.png",
["group03/male"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/rebels.png",
["combine_soldier_prisonguard"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/combineprisonguard.png",
["combine_soldier"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/combinesoldier.png",
["monk"]="http://i227.photobucket.com/albums/dd126/Jvsthebest/monk.png",
}
local skin=""
local skintochange="" --this is the url
local changedskin=false
local htmmat=nil
local htmpath=nil
local isloading=true
local function skinschangerthink()
	if not firstuse then
		oldhevbasetexture=hevmaterial:GetMaterialTexture( "$basetexture" )
		
		HTMLPANEL=vgui.Create("HTML")
		HTMLPANEL:SetSize(512,512)
		HTMLPANEL:SetVerticalScrollbarEnabled( false )
		HTMLPANEL:SetPaintedManually( true )
		function HTMLPANEL:FinishedURL(url)
			isloading=false
		end
		firstuse=true
		return
	end
	if not HTMLPANEL then return end
	skintochange=""
	
	for i,v in pairs(skins) do
		if string.find(LocalPlayer():GetModel(),i) then
			skintochange=v
			break
		end
	end
	
	if skintochange ~= skin then
		print(skintochange)
		HTMLPANEL:OpenURL(skintochange)
		skin=skintochange
		changedskin=false
		isloading=true
	end
	
	
	if not htmmat && HTMLPANEL then
		htmmat=HTMLPANEL:GetHTMLMaterial()
		if htmmat then
			htmpath=htmmat:GetMaterialTexture( "$basetexture" )
		end
	end
	
	if isloading && changedskin==false then
		hevmaterial:SetMaterialTexture( "$basetexture",oldhevbasetexture)
	end
	
	if HTMLPANEL && isloading==false && htmmat && changedskin==false && htmpath then
		if skintochange=="" then
			hevmaterial:SetMaterialTexture( "$basetexture",oldhevbasetexture)
		else
			hevmaterial:SetMaterialTexture( "$basetexture",htmpath)
		end
		changedskin=true
	end
end
hook.Add("Think","SkinsChangerThink",skinschangerthink)