--[[
	Clientside models hud
	A hud made by me (Jvs) that uses stock hl2 props on the screen as health monitors,time showing and shit like that.
	It will probably be horribly unoptimized and it will even look bad on other resolutions,but who cares as long as I like it.
	Hell,you are not even supposed to be able to read this text,unless I give this script to you.

]]

local CSHUD={}
--holds every modules this hud will use,like CSHUDHealthArmor,CSHUDTimeRadio and so on
CSHUD.Modules={}
CSHUD.Initialized=false;
CSHUD.Debug=false;

local CSModule={}

	
function CSModule:New(name)
	local newmodule={}
	setmetatable(newmodule, self)
	self.__index = self
	self.Name=name;
	print("Created new CSModule called "..self.Name)
	return newmodule
end

function CSModule:BaseInitialize()
	self:SetPos(0,0)
	self:SetSize(50,50)
	self.Name=self.Name or "No module name set"
	self.ContentFrom="hl2"
	self:Initialize();
end

function CSModule:Initialize() end
function CSModule:SetPos(x,y) self.m_xpos=x; self.m_ypos=y; end
function CSModule:GetPos() return self.m_xpos,self.m_ypos end
function CSModule:SetSize(width,height) self.m_width=width; self.m_height=height; end
function CSModule:GetSize() return self.m_width,self.m_height end
function CSModule:Think()end
function CSModule:HUDPaint(col)end

function CSModule:Remove()
	for i,v in pairs(self) do
		if type(v)=="function" then continue end
		if type(v)=="CSent" then v:Remove() end
		self[i]=nil;
	end
end


function CSHUD:Initialize()
	if self.Initialized then return end
	--we are not on sandbox,leave self.Initalized to false to stop hooks from working
	local tb=GM or GAMEMODE
	if !tb || !tb.Name || string.lower(tb.Name)!="sandbox" then self:RemoveHooks() return end
	
	for i,v in pairs(self.Modules) do
		if !v then continue end
		v:BaseInitialize()
		if self.Debug then
			MsgN(v.Name.." initialized")
		end
	end
	self.Initialized=true;
end

function CSHUD:RemoveHooks()
	--hook.Remove("InitPostEntity","CSHUD:Initialize")--may cause error if it's being called inside an initpostentity hook itself
	hook.Remove("Think","CSHUD:Think")
	hook.Remove("HUDPaint","CSHUD:HUDPaint")
	hook.Remove("HUDShouldDraw","CSHUD:HUDShouldDraw")
	for i,v in pairs(self.Modules)do
		if !v then continue end
		v:Remove();
	end
	self.Modules={}
end

concommand.Add("cl_csmremove", function(ply,command,args)
		if !IsValid(ply) || !CSHUD.Initialized then return end
		CSHUD:RemoveHooks()
end)

function CSHUD:AddModule(tab)
	if !tab then ErrorNoHalt("Trying to register an empty table\n") return end
	if tab.ContentFrom and !table.HasValue(GetMountedContent(),tab.ContentFrom) then ErrorNoHalt("\nTrying to register "..modulename.." without having ",tab.ContentFrom) return end
	table.insert(self.Modules,tab)
end

function CSHUD:Think()
	if !self.Initialized then return end
	for i,v in pairs(self.Modules) do
		if !v then continue end;
		v:Think()
	end
end

function CSHUD:HUDShouldDraw( name )
	if !self.Initialized then return end
	for i,v in pairs(self.Modules) do
		if !v then continue end;
		if v.CHUDTOHIDE==name || v.CHUDTOHIDE2==name then return false end
	end
end



function CSHUD:ShouldDraw()
	return (LocalPlayer():Alive() and LocalPlayer():Health()>0)
end

function CSHUD:HUDPaint()
	if !self.Initialized then return end
	if !self:ShouldDraw() then return end
	local col=render.GetLightColor( LocalPlayer():EyePos() )
	
	for i,v in pairs(self.Modules) do
		if !v then continue end;
		if self.Debug then
			local w,h=v:GetSize()
			local x,y=v:GetPos()
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(x,y,w,h)
		end
		
		v:HUDPaint(col)
	end

end



local function StartDrawing3d(vCamPos,vLookAngle,fov,x,y,size,lightingposition,col,lightslighting)
	cam.Start3D( vCamPos,vLookAngle, fov,x,y,size,size)
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( lightingposition)
	render.ResetModelLighting( col.r, col.g, col.b )
	
	render.SetModelLighting( BOX_TOP, col.r, col.g, col.b )
	if lightslighting then
	--blend the new color with the current lighting
	render.SetModelLighting( BOX_FRONT, col.r+lightslighting.r,col.g+lightslighting.g,col.b+lightslighting.b)
	else
	render.SetModelLighting( BOX_FRONT, col.r, col.g, col.b )
	end
end

local function StopDrawing3d()
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
end



hook.Add("InitPostEntity","CSHUD:Initialize",function() CSHUD:Initialize() end)
hook.Add("Think","CSHUD:Think",function() CSHUD:Think() end)
hook.Add("HUDPaint","CSHUD:HUDPaint",function() CSHUD:HUDPaint() end)
hook.Add("HUDShouldDraw", "CSHUD:HUDShouldDraw", function(name) local val=CSHUD:HUDShouldDraw(name); if val==false then return val end end )

--Here starts the modules,i will probably make them in their own file,whatever

local CS_DOOMHUD=CSModule:New("Doom HUD sorta")

local BoneList = {
	"ValveBiped.Bip01_Pelvis",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.forward",
	
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Anim_Attachment_RH",
	
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Anim_Attachment_LH",
	
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_R_Foot",
	
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
	
	"ValveBiped.Bip01_R_Wrist",
	"ValveBiped.Bip01_R_Ulna",
	"ValveBiped.Bip01_L_Wrist",
	"ValveBiped.Bip01_L_Ulna",
}

local function HeadGibBuildBones(ent)
local b, m
	
	b = ent:LookupBone("ValveBiped.Bip01_Head1")
	m = ent:GetBoneMatrix(b)
	m:SetTranslation(Vector(0,0,0))
	m:Scale(Vector(4,4,4))
	ent:SetBoneMatrix(b,m)
	
	b = ent:LookupBone("ValveBiped.Bip01_Spine4")
	m = ent:GetBoneMatrix(b)
	m:Scale(Vector(0.25,0.25,0.25))
	ent:SetBoneMatrix(b,m)
	
	local pos = Vector(0,0,0) + Vector(0,0,1) * 65
	
	for _,bone in ipairs(BoneList) do
		b = ent:LookupBone(bone)
		if b and b>=0 then
			m = ent:GetBoneMatrix(b)
			if m then
				m:Scale(Vector(0,0,0))
				m:SetTranslation(pos)
				ent:SetBoneMatrix(b, m)
			end
		end
	end
end

--[[
local function BuildGayBonePositions(self,bone,physbone)
	for i=0,self:GetBoneCount()-1 do
	local bm = self:GetBoneMatrix( i )
		if !bm then continue end
		bm:SetTranslation(Vector(0,0,0))
		
		if string.find(string.lower(self:GetBoneName(i)),"head") or string.find(string.lower(self:GetBoneName(i)),"neck") or string.find(string.lower(self:GetBoneName(i)),"spine4") then 
			if !string.find(string.lower(self:GetBoneName(i)),"spine4") then
				bm:Scale(Vector(1.01,1.01,1.01))
				bm:SetAngle(Angle(0,0,0))
			end
			self:SetBoneMatrix(i,bm )
		continue 
		end
		bm:Scale(Vector(0.01,0.01,0.01))
		self:SetBoneMatrix(i, bm )
	end
end
]]
function CS_DOOMHUD:Initialize()
	self.Size=150
	self:SetSize(self.Size,self.Size)
	self:SetPos(0,ScrH()-self.Size)
	self.LightPos=Vector(0,0,10)
	self.PlayerModel=ClientsideModel("models/Combine_Helicopter/helicopter_bomb01.mdl",RENDERGROUP_OPAQUE)
	self.PlayerModel:SetNoDraw(false)
	print(self.PlayerModel,type(self.PlayerModel))
	self.PlayerModel.BuildBonePositions=HeadGibBuildBones
end

function CSModule:Think()
	if self.PlayerModel:GetModel()~=LocalPlayer():GetModel() then
		self.PlayerModel:SetModel(LocalPlayer():GetModel())
		print(self.PlayerModel:GetModel())
	end
end

function CSModule:HUDPaint(col)
	if !IsValid(self.PlayerModel) then return end
	StartDrawing3d(Vector( 18.5,1, 0 ),Angle(0,180,0),75,self.m_xpos,self.m_ypos,self.Size,self.LightPos,col,col)
		self.PlayerModel:SetRenderOrigin(Vector(0,0,-65))
		self.PlayerModel:DrawModel()
	StopDrawing3d()
end






local CSHUDHealthArmor=CSModule:New("Health Monitor")

function CSHUDHealthArmor:Initialize()
	self.FizzMat=Material("Effects/tvscreen_noise001a.vmt")
	self.FizzID=surface.GetTextureID( "Effects/tvscreen_noise001a")

	self.CurrentScale=4;
	self.Size=150
	self:SetSize(self.Size,self.Size)
	self:SetPos(0,ScrH()-self.Size)
	
	self.MaxW,self.MaxH=45*self.CurrentScale,45*self.CurrentScale
	self.MaxHealth=100;
	self.MonitorRenderAngOrigin=Angle(-7,12,5)
	self.Monitor=ClientsideModel("models/props_lab/monitor01b.mdl",RENDERGROUP_OPAQUE)
	self.Monitor:SetNoDraw(true)
	self.Scale=0.2/self.CurrentScale;
	self.BigFont="CSHUDHealthArmor_Font_Big_9"
	self.SmallFont="CSHUDHealthArmor_Font_Smaller9"
	surface.CreateFont( "HalfLife2",30*self.CurrentScale, 400, true, true, self.BigFont ,true,true)
	surface.CreateFont( "HalfLife2",25*self.CurrentScale, 400, true, true, self.SmallFont)
	self.CHUDTOHIDE="CHudHealth"
	self.CHUDTOHIDE2="CHudBattery"
	self.HealthColor=Color(0,0,0)
	self.GlowMat=Material("effects/blueflare1")
	self.LastHealth=nil;
	self.LastArmor=nil;
	self.RandomBreakage=CurTime()-0.1;
	self.RandomBreakageDrawTime=CurTime()-0.1;
	self.HealthBlurTime=CurTime();
	self.ArmorBlurTime=CurTime();
	self.HealthDangerMin=11;
	self.HealthDangerMax=16;
end

function CSHUDHealthArmor:GetFont()
	return (LocalPlayer():Armor()>0) and self.SmallFont or self.BigFont
end

function CSHUDHealthArmor:Think()
	--think will always be called,even though HUDPaint will not
	if !self.LastHealth then
		self.LastHealth=LocalPlayer():Health()
	end
	if !self.LastArmor then
		self.LastArmor=LocalPlayer():Armor()
	end
	
	if LocalPlayer():Health() != self.LastHealth and LocalPlayer():Alive() then
		self.HealthBlur=true;
		local difference=math.abs(LocalPlayer():Health()-self.LastHealth)
		self.BlurTime=1			--0.1*difference
		self.HealthBlurTime=CurTime()+self.BlurTime;
	end
	if self.HealthBlurTime<CurTime() and self.HealthBlur then
		self.HealthBlur=false;
		self.HealthBlurTime=CurTime()
	end
	
	if LocalPlayer():Armor() != self.LastArmor and LocalPlayer():Alive() then
		self.ArmorBlur=true;
		local difference=math.abs(LocalPlayer():Armor()-self.LastArmor)
		self.BlurTime=1			--0.1*difference
		self.ArmorBlurTime=CurTime()+self.BlurTime;
	end
	if self.ArmorBlurTime<CurTime() and self.ArmorBlur then
		self.ArmorBlur=false;
		self.ArmorBlurTime=CurTime()
	end
	
	if LocalPlayer():Alive() and LocalPlayer():Health()<= self.MaxHealth then
		self.HealthColor.r=Lerp(LocalPlayer():Health()/self.MaxHealth,170,0)
		self.HealthColor.g=Lerp(LocalPlayer():Health()/self.MaxHealth,0,170)
		self.HealthColor.b=0 --Lerp(LocalPlayer():Health()/self.MaxHealth,)
	else
		self.HealthColor=Color(0,170,0)
	end
	
	if LocalPlayer():Alive() and LocalPlayer():Health()<self.HealthDangerMax and self.RandomBreakage<CurTime() then
		local delay=math.random(1, Lerp(LocalPlayer():Health()/self.HealthDangerMax,2,8))
		--ErrorNoHalt("WARNING LOW HEALTH\n")
		LocalPlayer():EmitSound("ambient/energy/spark"..math.random(1,6)..".wav",25,100)
		self.RandomBreakage=CurTime()+delay
		self.RandomBreakageDrawTime=CurTime()+0.3
	end
	
	self.LastHealth=LocalPlayer():Health()
	self.LastArmor=LocalPlayer():Armor()

end


function CSHUDHealthArmor:HUDPaint(col)
	local lightslighting=Color(self.HealthColor.r/255,self.HealthColor.g/255,self.HealthColor.b/255)
	local textposx,textposy=self.MaxW/2,(self.MaxH/2);
	
	if LocalPlayer():Armor()>0 then
		textposy=(self.MaxH/2)-(10*self.CurrentScale);
	end
	
	lightslighting=Color(lightslighting.r/2,lightslighting.g/2,lightslighting.b/2)--soften it a bit
	self.MonitorRenderAng=self.MonitorRenderAngOrigin*1	--right right,right,it's a metatable,it would keep a reference to the original if i don't do this
	
	StartDrawing3d(Vector( 18.5,1, 0 ),Angle(0,180,0),75,self.m_xpos,self.m_ypos,self.Size,self.Monitor:GetPos(),col,lightslighting)
	--draw clientside model here
	self.Monitor:SetRenderAngles(self.MonitorRenderAng)
	self.Monitor:DrawModel();
	
		
	local pos, ang = self.Monitor:GetPos(), self.MonitorRenderAng
	local up, right,forward = self.MonitorRenderAng:Up(),self.MonitorRenderAng:Right(),self.MonitorRenderAng:Forward()

	
	pos = pos + right*5.5 + forward*6.5 + up*4.85;
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)
	cam.Start3D2D(pos,ang,self.Scale)
		--draw the background
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0,0,self.MaxW,self.MaxH)
		
				if LocalPlayer():Armor()>0 then
					draw.SimpleText(LocalPlayer():Armor(), self:GetFont(),textposx,textposy+(20*self.CurrentScale), Color(0,0,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
			draw.SimpleText(LocalPlayer():Health(), self:GetFont(),textposx,textposy, self.HealthColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			
			if self.HealthBlur and self.HealthBlurTime>CurTime() then
				local alphalerp;
				local frac=math.TimeFraction(self.HealthBlurTime-self.BlurTime,self.HealthBlurTime, CurTime() )
				alphalerp=Lerp(frac,255,0)
				local hlcolor=Color(self.HealthColor.r,self.HealthColor.g,self.HealthColor.b,alphalerp);
				draw.SimpleTextOutlined(LocalPlayer():Health(), self:GetFont(),textposx,textposy, hlcolor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1*self.CurrentScale,hlcolor)
			end
			
			if self.ArmorBlur and self.ArmorBlurTime>CurTime() then
				local alphalerp;
				local frac=math.TimeFraction(self.ArmorBlurTime-self.BlurTime,self.ArmorBlurTime, CurTime() )
				alphalerp=Lerp(frac,255,0)
				local hlcolor=Color(0,0,255,alphalerp);
				if LocalPlayer():Armor()>0 then
					draw.SimpleTextOutlined(LocalPlayer():Armor(), self:GetFont(),textposx,textposy+(20*self.CurrentScale), hlcolor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1*self.CurrentScale,hlcolor)
				end
			end
			
			if !self.HealthBlur and LocalPlayer():Health()<self.HealthDangerMin then
				local alphalerp;
				alphalerp=(0 - ((math.cos(CurTime()))))*120 --Lerp(frac,120,0)
				local hlcolor=Color(self.HealthColor.r,self.HealthColor.g,self.HealthColor.b);
				hlcolor.a=TimedCos(0.5,0,255,0) --alphalerp;
				
				draw.SimpleTextOutlined(LocalPlayer():Health(),self:GetFont(),textposx,textposy, hlcolor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1*self.CurrentScale,hlcolor)
			end
		if self.RandomBreakageDrawTime>=CurTime() then
			surface.SetTexture(self.FizzID)
			surface.DrawTexturedRect(0,0,self.MaxW,self.MaxH)
		end
		
	cam.End3D2D()
	render.SetMaterial(self.GlowMat)
	render.DrawSprite( pos+forward*1.01 + right*-9.6 + up*-1.5, 4, 4, self.HealthColor)
	render.DrawSprite( pos+forward*1.01 + right*-9.6 + up*-2.5, 4, 4, self.HealthColor)
	render.DrawSprite( pos+forward*1.01 + right*-9.6 + up*-3.5, 4, 4, self.HealthColor)
	StopDrawing3d()
end


CSHUD:AddModule(CSHUDHealthArmor)
--CSHUD:AddModule(CS_DOOMHUD)
if LocalPlayer and IsValid(LocalPlayer())then
	CSHUD:Initialize()
end