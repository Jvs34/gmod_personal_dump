--[[ 
Jvs' ping tool
This is some kind of mixture between the ping tool in portal 2 and the coaching tool in tf2.
Altough the last one sucks because it makes you read text in a fast paced combat game and it takes the whole screen when you are far away from it.
	

Inner workings:

CLIENT user input
	User brings up the voicemenu (eh,whatever),uses the command pingtool <type>
	The pingtool is just a clientside command that will check if everything is valid (type,position and entity) and then it'll send the validated stuff to the server.
	
SERVER receives the command
	Checks if the informations given are really correct (never trust the client)
	If it's only marking a position,then do a trace on the world and calculate the normal from the impact trace on the world
	Also don't allow to mark teammates with the ping tool,only enemies and props (depends on the marker type)
	Do not send the usermessage to enemies or to the marker target
	If everything is right then send an usermessage back with the type of the mark,position or entity
	Don't let the user use the ping tool again in 2/4 seconds

CLIENT receives the usermessage
	Create the clientside effect of the ping tool mark,play a sound (on the entity who fired it?)
	Draw the marker on the hud along with an arrow,of course scale it depending on the distance
	If the marker expires then gracefully draw it with a smaller alpha until it dies out

]]

local function IsMounted2(gaym)
	local t=engine.GetGames()
	for i,v in pairs(t) do
		if v and v.title==gaym and v.mounted then return true end
	end
	return false
end

local MarkersTypes={
	ATTACK={onEntities=true,onTeamMates=false,onWorld=true,Icon=IsMounted2("Team Fortress 2") and "HUD/hud_icon_attack" or "VGUI/achievements/hl2_kill_allc1709snipers",markerSound=Sound("coach/coach_attack_here.wav")},
	GOHERE={onEntities=false,onTeamMates=false,onWorld=true,Icon=IsMounted2("Team Fortress 2") and "HUD/arrow_big_down" or "VGUI/achievements/hl2_escape_apartmentraid",drawRoundedBox=6,markerSound=Sound("coach/coach_go_here.wav"),concept="TLK_PLAYER_GO"},
	LOOKHERE={onEntities=true,onTeamMates=true,onWorld=true,onWalls=true,Icon=IsMounted2("Team Fortress 2") and "HUD/ico_camera" or "VGUI/hud/autoaim",drawRoundedBox=6,markerSound=Sound("coach/coach_look_here.wav")},
	
	DEFEND={onEntities=true,onTeamMates=true,onWorld=true,Icon="HUD/hud_icon_defend",markerSound=Sound("coach/coach_defend_here.wav")},
	CAPTURE={IsTf2=true,onEntities=false,onTeamMates=false,onWorld=true,Icon="HUD/hud_icon_capture",markerSound=Sound("coach/coach_attack_here.wav")},
	--these don't need sounds,they'll call the vocalisation of the player
	BUILDSENTRY={IsTf2=true,onEntities=false,onTeamMates=false,onWorld=true,Icon="HUD/hud_obj_status_sentry_1",drawRoundedBox=6,markerSound=Sound(""),concept="TLK_PLAYER_SENTRYHERE"},
	BUILDDISPENSER={IsTf2=true,onEntities=false,onTeamMates=false,onWorld=true,Icon="HUD/hud_obj_status_dispenser",drawRoundedBox=6,markerSound=Sound(""),concept="TLK_PLAYER_DISPENSERHERE"},
	BUILDTELEPORTER={IsTf2=true,onEntities=false,onTeamMates=false,onWorld=true,Icon="HUD/hud_obj_status_tele_entrance",drawRoundedBox=6,markerSound=Sound(""),concept="TLK_PLAYER_TELEPORTERHERE"},
	TIMER={onEntities=false,onTeamMates=false,onWorld=true,onWalls=true,Icon="HUD/ico_time_none",drawRoundedBox=6,markerSound=Sound("ui/hint.wav"),dingSound=Sound("ui/hitsound.wav")},
	
	TEST={IsTf2=true,ignoreEntities=true,onEntities=false,onTeamMates=false,onWorld=true,onWalls=false,Icon="vgui/achievements/tf_scout_cap_flag_without_attacking",customEffect="TESTCheckPoint",markerSound="vo/announcer_am_capincite02.wav"},

}
local mEnums={}
local count=1;
for i,v in pairs(MarkersTypes) do
	mEnums[count]=i;
	count=count+1;
end

local function tableRemoveEntry(tab,entry)
	for i,v in pairs(tab) do
		if v==entry then tab[i]=nil; break; end
	end
end


local size=16;
local function PlayerTrace(ply,normal,ignoreentities,tracehull)
    local trace = {}
    
    trace.start = ply:EyePos()
    if tracehull then
		trace.mins = Vector(size/-2,size/-2,size/-2)
		trace.maxs = Vector(size/2,size/2,size/2)
	end
	trace.endpos = trace.start + (normal * 4096 * 4)
    trace.filter = ignoreentities and ents.GetAll() or {ply,ply:GetVehicle()}
	return tracehull and util.TraceHull( trace ) or util.TraceLine( trace );
end


if CLIENT then
	local defaultPingtoolSize = CreateClientConVar("pingtool_size",1)
	local groundmat=IsMounted2("Team Fortress 2") and Material("vgui/flagtime_full.vmt") or Material("VGUI/hud/xbox_reticle.vmt") 
	local RT1 = render.GetBloomTex0()
	local RT2 = render.GetBloomTex1()
	local VPW = RT1:GetMappingWidth()
	local VPH = RT1:GetMappingHeight()
	local MaterialBlurX = Material( "pp/blurx" )
    local MaterialBlurY = Material( "pp/blury" )
    local MaterialWhite = CreateMaterial( "WhiteMaterial", "VertexLitGeneric", {
        ["$basetexture"] = "color/white",
        ["$vertexalpha"] = "1",
        ["$model"] = "1",
    } )
    local MaterialComposite = CreateMaterial( "CompositeMaterial", "UnlitGeneric", {
        ["$basetexture"] = "_rt_FullFrameFB",
        ["$additive"] = "1",
    } )
	local laser =CreateMaterial("sprites/pinglaser",
			"UnlitGeneric",{
				['$basetexture' ] = "sprites/laser",
				[ '$nopicmip' ] = "1",
                [ '$additive' ] = "1",
				[ '$vertexcolor' ] = "1",
				[ '$vertexalpha' ] = "1",
            }
    )
	local sprite =CreateMaterial("sprites/pingglow4",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/animglow01-",
				[ '$nopicmip' ] = "1",
				[ '$additive' ] = "1",
				[ '$vertexcolor' ] = "1",
				[ '$vertexalpha' ] = "1",
			}
    )
	
	local mTexIds={}
	for i,v in pairs(MarkersTypes) do
		if v.Icon then
			mTexIds[i]=surface.GetTextureID(v.Icon);
		end
	end

	local pingMenu={}
	pingMenu.defaultMarker="LOOKHERE";
	pingMenu.pingMenuOpened=false;
	pingMenu.selectedMarker=pingMenu.defaultMarker
	pingMenu.openedTime=0;
	pingMenu.slice=360/(#mEnums-1);
	pingMenu.halfslice=pingMenu.slice/2;
	local Marker={mEnt=nil,mPos=nil,mNormal,mType="ATTACK",mDieTime=nil,mDuplicated=false,mSize=1}
	local Markers={}
	
	function Marker:New(mEnt,mPos,mNormal,mType,mDuration,mSize)
		local newmarker={}
		setmetatable(newmarker, self)
		self.__index = self
		newmarker:Initialize(mEnt,mPos,mNormal,mType,mDuration,mSize)
		table.insert(Markers,newmarker)
		return newmarker
	end
	
	function Marker:__tostring()
		return "[Marker/"..self.mType.." "..self.mSize.." Died="..tostring((self.mDieTime or 0) < UnPredictedCurTime()).."]"
	end
	
	function Marker:Initialize(mEnt,mPos,mNormal,mType,mDuration,mSize)
		
		self.mEnt=Entity(mEnt)
		
		self.mDuplicated=false;
		
		if IsValid(self.mEnt) then
			for i,v in pairs(Markers) do
				if v.mEnt==self.mEnt and v!=self then self.mDuplicated=true; break end
			end
		end
		
		if self.mDuplicated then self:Remove() return end
		
		if MarkersTypes[mType].markerSound~="" then
			--surface.PlaySound(MarkersTypes[mType].markerSound)
			local str=IsMounted2("Team Fortress 2") and MarkersTypes[mType].markerSound or "HL1/fvox/bell.wav"
			--str="ui/hint.wav"
			surface.PlaySound(str)
			--[[
			if IsValid(self.mEnt) then
				self.mEnt:EmitSound(str,255,100)
			elseif self.mPos then
				WorldSound(str,self.mPos,165,100)
			end
			]]
		end
	
		--surface.PlaySound("ui/hint.wav")
		

		self.mPos=mPos
		self.mType=mType
		self.mNormal=mNormal
		self.mSize=mSize or 1;
		self.mDieTime=UnPredictedCurTime()+mDuration
		
		--spawn the effect only if we have a mPos and a mNormal is pointing on the ground up to 90 degrees
		--this ensures marker effects won't show up on walls,unless the type of the marker says so
		local attach;
		for i,v in pairs(mEnums) do
			if self.mType == v then attach=i break end
		end
		if !IsValid(self.mEnt) and self.mPos and self.mNormal then
			local ang=self.mNormal:Angle()
			if (ang.p>300 || ang.p<270) and !MarkersTypes[self.mType].onWalls then return end
			local eff=EffectData();
			eff:SetOrigin(self.mPos)
			eff:SetNormal(self.mNormal)
			eff:SetScale(mDuration)
			eff:SetMagnitude(self.mSize)
			eff:SetAttachment(attach)
			
			util.Effect(MarkersTypes[mType].customEffect or "PingTool",eff )
		end
		
		if IsValid(self.mEnt) then 
			local eff=EffectData();
			eff:SetEntity(self.mEnt)
			eff:SetAttachment(attach)
			eff:SetMagnitude(self.mSize)
			eff:SetScale(mDuration)
			util.Effect(MarkersTypes[mType].customEffectEntity or "PingTool_ent", eff )
		
		end
		self.Initialized=true;
	end
	
	function Marker:Think()
		if !self.Initialized then return end
		if self.mDieTime < UnPredictedCurTime() then self:Remove() end
	end
	
	function Marker:Remove()
		tableRemoveEntry(Markers,self)
		for i,v in pairs(self) do
			if type(v)=="function" then continue end
			self[i]=nil;
		end
		self=nil;
	end
	-----------------------PingTool
	local SEFFECT={}
	SEFFECT.Ground=groundmat
	SEFFECT.Beam=Material( "effects/lamp_beam" )
	function SEFFECT:Init(data)
		local Vec=Vector(1000,1000,1000)
		self:SetRenderBounds( Vec*-1,Vec)
		self.mScale=data:GetMagnitude() or 1
		self.mSize=48*self.mScale
		self.mAddSize=IsMounted2("Team Fortress 2") and 0 or 24*self.mScale
		self.mType=mEnums[data:GetAttachment()]
		self.mTexId=surface.GetTextureID(MarkersTypes[self.mType].Icon);
		self.mPos=data:GetOrigin()
		self.mNormal=data:GetNormal()
		self.mDuration=data:GetScale() or 5
		self.mDieTime=UnPredictedCurTime()+self.mDuration
		self.mDieTimeFade=UnPredictedCurTime()+self.mDuration - 1
		self.mSpawnedTime=UnPredictedCurTime()+0.2
		self.mSpawned=UnPredictedCurTime();
		self.Color=team.GetColor(LocalPlayer():Team())
		self.mOneTimeCircle={Speed = 0.5,Color=Color(self.Color.r*0.5,self.Color.g*0.5,self.Color.b*0.5),Size = self.mSize,Alpha = 255}
	end

	function SEFFECT:Think()
		if self.mOneTimeCircle.Alpha > 1 then
			self.mOneTimeCircle.Alpha = self.mOneTimeCircle.Alpha - FrameTime() * 255 * 5 * self.mOneTimeCircle.Speed
			self.mOneTimeCircle.Size = self.mOneTimeCircle.Size + FrameTime() * 256 * self.mOneTimeCircle.Speed
		end
		return self.mDieTime>UnPredictedCurTime()
	end
	
	function SEFFECT:Render()
		if (self.mOneTimeCircle.Alpha > 1 ) then
			render.SetMaterial( self.Ground )
			render.DrawQuadEasy( self.mPos+self.mNormal*0.1,self.mNormal,self.mOneTimeCircle.Size+self.mAddSize, self.mOneTimeCircle.Size+self.mAddSize,Color(self.mOneTimeCircle.Color.r,self.mOneTimeCircle.Color.g,self.mOneTimeCircle.Color.b , self.mOneTimeCircle.Alpha ) )
		end
	
		local alpha=255
		local speed=360
		if self.mDieTimeFade<UnPredictedCurTime() then
			local frac=math.TimeFraction(self.mDieTime-1,self.mDieTime, UnPredictedCurTime() )
			alpha=Lerp(frac,255,0)
		end
		if self.mSpawnedTime>UnPredictedCurTime() and self.mDieTimeFade>UnPredictedCurTime() then
			local frac=math.TimeFraction(self.mSpawned,self.mSpawnedTime, UnPredictedCurTime() )
			alpha=Lerp(frac,0,255)
		end
		
		render.SetMaterial( self.Beam )
		render.StartBeam( 3 )
			render.AddBeam( self.mPos + (self.mNormal * -1) * 1, self.mSize/2, 0.0, Color( self.Color.r, self.Color.g, self.Color.b, alpha/2) )
			render.AddBeam( self.mPos - (self.mNormal * -1) * self.mSize, self.mSize/2, 0.5, Color( self.Color.r, self.Color.g, self.Color.b, alpha) )
			render.AddBeam( self.mPos - (self.mNormal * -1) * self.mSize*2, self.mSize/2, 1, Color( self.Color.r, self.Color.g, self.Color.b, 0) )
		render.EndBeam()
		
		render.SetMaterial( sprite )
		render.DrawSprite(self.mPos+self.mNormal*0.5,8*self.mScale,8*self.mScale,Color( self.Color.r, self.Color.g, self.Color.b, alpha) )
		render.DrawQuadEasy(self.mPos+self.mNormal*0.5,self.mNormal,8*self.mScale,8*self.mScale,Color( self.Color.r, self.Color.g, self.Color.b, alpha),0)		
		
		render.SetMaterial( self.Ground )
		render.DrawQuadEasy( self.mPos+self.mNormal*0.5,self.mNormal,self.mSize+self.mAddSize,self.mSize+self.mAddSize,Color( self.Color.r, self.Color.g, self.Color.b, alpha ),0) 
		render.DrawQuadEasy( self.mPos+self.mNormal*0.5,self.mNormal,self.mSize+self.mAddSize,self.mSize+self.mAddSize,Color( 255, 255, 255, alpha ),UnPredictedCurTime()*speed)
		local eyeang=EyeAngles();
		eyeang.p=0;
		eyeang:RotateAroundAxis(eyeang:Up(),90)
		eyeang:RotateAroundAxis(eyeang:Forward(),EyeAngles().p-90)
		eyeang:RotateAroundAxis(eyeang:Up(),180)
		cam.IgnoreZ(true)
		render.SetBlend(alpha)
		cam.Start3D2D( self.mPos - (self.mNormal * (-1 +math.cos(UnPredictedCurTime()*2.5)/(8))   ) * self.mSize*2,eyeang, 0.5*self.mScale )
			if MarkersTypes[self.mType].drawRoundedBox then
				draw.RoundedBox( MarkersTypes[self.mType].drawRoundedBox,-24,-24,48,48,Color(50,50,50,alpha))
			end
			surface.SetTexture( self.mTexId );
			surface.SetDrawColor(255,255,255,alpha)
			surface.DrawTexturedRect(-24,-24,48,48);
		cam.End3D2D()
		cam.IgnoreZ(false)
		render.SetBlend(1)
	end
	effects.Register(SEFFECT,"PingTool")
	-----------------------PingTool_ent
	SEFFECT={}
	SEFFECT.Beam=Material( "effects/lamp_beam" )
	function SEFFECT:Init(data)
		local Vec=Vector(1000,1000,1000)
		self:SetRenderBounds( Vec*-1,Vec)
		self.mEnt=data:GetEntity()
		local size=self.mEnt:OBBMaxs().x+self.mEnt:OBBMaxs().y+self.mEnt:OBBMaxs().z
		self.mScale=data:GetMagnitude();
		self.mSize=size
		self.mSize=math.Clamp(self.mSize,24,48)* self.mScale
		self.mType=mEnums[data:GetAttachment()]
		self.mTexId=surface.GetTextureID(MarkersTypes[self.mType].Icon);
		self.mDuration=data:GetScale() or 5
		self.mDieTime=UnPredictedCurTime()+self.mDuration
		self.mDieTimeFade=UnPredictedCurTime()+self.mDuration - 1
		self.mSpawnedTime=UnPredictedCurTime()+0.2
		self.mSpawned=UnPredictedCurTime();
		self.Color=team.GetColor(LocalPlayer():Team())
		self:SetParent(self.mEnt)
		self:SetPos(self.mEnt:GetPos())
	end
	
	
	function SEFFECT:Think()
		if IsValid(self.mEnt) then
			self:SetPos(self.mEnt:GetPos())
			if !self.Parented then
				self:SetParent(self.mEnt)
				self.Parented=true;
			end
			if self.mEnt:IsNPC() and self.mEnt:GetMoveType()==0 then
				return false;
			end
		end
		
		return self.mDieTime>UnPredictedCurTime() or !IsValid(self.mEnt) or self.mEnt:IsEffectActive(EF_NODRAW) or (self.mEnt:IsPlayer() and self.mEnt:Alive()==false)
	end
	
	function RenderToGlowTexture( entity,alpha,color )
        if not IsValid( entity ) then return end
        
        local w, h = ScrW(), ScrH()

        local oldRT = render.GetRenderTarget()
        render.SetRenderTarget( RT1 )
            render.SetViewPort( 0, 0, VPW, VPH )
            cam.IgnoreZ( true )
                render.SuppressEngineLighting( true )
                render.SetBlend( alpha/255 )
				render.SetColorModulation( color.r / 255, color.g / 255, color.b / 255 )
                    render.MaterialOverride( MaterialWhite )
                    if entity.Draw then
						entity:Draw();
					else
						entity:DrawModel()
                    end
					render.MaterialOverride()
                render.SetColorModulation( 1, 1, 1 )
                render.SetBlend( 1 )
                render.SuppressEngineLighting( false )
            cam.IgnoreZ( false )
            render.SetViewPort( 0, 0, w, h )
        render.SetRenderTarget( oldRT )
        
    end

    hook.Add("RenderScene","JintoGlow",function( Origin, Angles )
        local oldRT = render.GetRenderTarget()
        render.SetRenderTarget( RT1 )
        render.Clear( 0, 0, 0, 255, true )
        render.SetRenderTarget( oldRT )
    end)
     

    hook.Add("RenderScreenspaceEffects","JintoGlow",function( )
        MaterialBlurX:SetMaterialTexture( "$basetexture", RT1 )
        MaterialBlurY:SetMaterialTexture( "$basetexture", RT2 )
        MaterialBlurX:SetMaterialFloat( "$size", 6 )
        MaterialBlurY:SetMaterialFloat( "$size", 6 )
        
        local oldRT = render.GetRenderTarget()
        
        render.SetRenderTarget( RT2 )
        render.SetMaterial( MaterialBlurX )
        render.DrawScreenQuad()

        render.SetRenderTarget( RT1 )
        render.SetMaterial( MaterialBlurY )
        render.DrawScreenQuad()
        render.SetRenderTarget( oldRT )
        
        render.SetStencilEnable( true )
        render.SetStencilReferenceValue( 0 )
        render.SetStencilTestMask( 1 )
        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
        render.SetStencilPassOperation( STENCILOPERATION_ZERO )
        
        MaterialComposite:SetMaterialTexture( "$basetexture", RT1 )
        render.SetMaterial( MaterialComposite )
        render.SetBlend( 0.1 )
        render.DrawScreenQuad()
        render.SetBlend( 1 )
        
        render.SetStencilEnable( false )
        
    end)
	
	
    function RenderToStencil( entity )
        if not IsValid( entity ) then return end
        
        render.SetStencilEnable( true )
        render.SetStencilFailOperation( STENCILOPERATION_KEEP )
        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
        render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
        render.SetStencilWriteMask( 1 )
        render.SetStencilReferenceValue( 1 )
        
        cam.IgnoreZ( true )
			render.SetBlend( 0 )
				render.MaterialOverride( MaterialWhite )
				entity:DrawModel()
            render.MaterialOverride()
            render.SetBlend( 1 )
        cam.IgnoreZ( false )
        render.SetStencilEnable( false )
    end
	
	
	function SEFFECT:Render()
		if !IsValid(self.mEnt) then return end
		local alpha=255
		local speed=360
		local pos=Vector()
		pos=(self.mEnt.EyePos) and self.mEnt:EyePos() or self.mEnt:LocalToWorld(self.mEnt:OBBCenter())
		if self.mDieTimeFade<UnPredictedCurTime() then
			local frac=math.TimeFraction(self.mDieTime-1,self.mDieTime, UnPredictedCurTime() )
			alpha=Lerp(frac,255,0)
		end
		if self.mSpawnedTime>UnPredictedCurTime() and self.mDieTimeFade>UnPredictedCurTime() then
			local frac=math.TimeFraction(self.mSpawned,self.mSpawnedTime, UnPredictedCurTime() )
			alpha=Lerp(frac,0,255)
		end
				
		RenderToStencil( self.mEnt)
		RenderToGlowTexture( self.mEnt,alpha,self.Color)
		render.SetMaterial( self.Beam )
		render.StartBeam( 3 )
			render.AddBeam(pos + Vector(0,0,-1) * 1, self.mSize/2, 0.0, Color( self.Color.r, self.Color.g, self.Color.b, 0) )
			render.AddBeam(pos - Vector(0,0,-1) * self.mSize, self.mSize/2, 0.5, Color( self.Color.r, self.Color.g, self.Color.b, alpha/2) )
			render.AddBeam(pos - Vector(0,0,-1) * self.mSize*1.5, self.mSize/2, 1, Color( self.Color.r, self.Color.g, self.Color.b, 0) )
		render.EndBeam()
		local eyeang=EyeAngles();
		eyeang.p=0;
		eyeang:RotateAroundAxis(eyeang:Up(),90)
		eyeang:RotateAroundAxis(eyeang:Forward(),EyeAngles().p-90)
		eyeang:RotateAroundAxis(eyeang:Up(),180)
		
		cam.IgnoreZ(true)
		render.SetBlend(alpha)
		cam.Start3D2D( pos - Vector(0,0,1)*(-1 +math.cos(UnPredictedCurTime()*2.5)/(8)) * self.mSize*1.5,eyeang, 0.5*self.mScale )
			if MarkersTypes[self.mType].drawRoundedBox then
				draw.RoundedBox( MarkersTypes[self.mType].drawRoundedBox,-24,-24,48,48,Color(50,50,50,alpha))
			end
			surface.SetTexture( self.mTexId );
			surface.SetDrawColor(255,255,255,alpha)
			surface.DrawTexturedRect(-24,-24,48,48);
		cam.End3D2D()
		render.SetBlend(1)
		cam.IgnoreZ(false)
		
	end
	
	effects.Register(SEFFECT,"PingTool_ent")
	-----------------------TESTCheckPoint
	SEFFECT={}
	SEFFECT.BeamModel="models/effects/cappoint_hologram.mdl"
	SEFFECT.CPModel="models/props_gameplay/cap_point_base.mdl"
	function SEFFECT:Init(data)
		local Vec=Vector(300,300,300)
		self:SetRenderBounds(Vec*-1,Vec)
		local size=data:GetMagnitude()
		self.mSize=Vector(1,1,1)*size
		self.mDuration=data:GetScale() or 5
		self.mDieTime=UnPredictedCurTime()+self.mDuration
		self.mDieTimeFade=UnPredictedCurTime()+self.mDuration - 1
		self.mPos=data:GetOrigin()
		self.mNormal=data:GetNormal():Angle()
		self.mSpawnedTime=UnPredictedCurTime()+0.2
		self.mSpawned=UnPredictedCurTime();
		self.Color=team.GetColor(LocalPlayer():Team())
		self.CP=ClientsideModel(self.CPModel)
		self.CP:SetNoDraw(true)
		self.CP:SetModelScale(self.mSize)
		self.CP:Spawn()
		
		self.Beam=ClientsideModel(self.BeamModel)
		self.Beam:SetModelScale(self.mSize)
		self.Beam:SetNoDraw(true)
		self.Beam:SetSequence(0)
		self.Beam:SetCycle(0)
		self.Beam:Spawn()
	end
	
	
	function SEFFECT:Think()
	
		return self.mDieTime>UnPredictedCurTime()
	end
	
	function SEFFECT:Render()
		if !IsValid(self.CP) or !IsValid(self.Beam) then return end
		local alpha=255
		local speed=360
		
		if self.mDieTimeFade<UnPredictedCurTime() then
			local frac=math.TimeFraction(self.mDieTime-1,self.mDieTime, UnPredictedCurTime() )
			alpha=Lerp(frac,255,1)/255
		end
		
		if self.mSpawnedTime>UnPredictedCurTime() and self.mDieTimeFade>UnPredictedCurTime() then
			local frac=math.TimeFraction(self.mSpawned,self.mSpawnedTime, UnPredictedCurTime() )
			alpha=Lerp(frac,0,255)
		end
		
		render.SetBlend(alpha)
		self.CP:SetRenderOrigin(self.mPos)
		self.CP:SetRenderAngles(self.mRotateAng)
		self.CP:DrawModel();
		self.Beam:FrameAdvance(FrameTime())
		self.Beam:SetRenderOrigin(self.mPos)
		self.Beam:SetRenderAngles(self.mRotateAng)
		self.Beam:DrawModel();
		render.SetBlend(1)
	end
	
	effects.Register(SEFFECT,"TESTCheckPoint")
	
	hook.Add("Think","Markers_Think",function()
		for i,v in pairs(Markers) do
			if v then	v:Think();	end
		end
	end)
	
	concommand.Remove("pingtool")
	concommand.Add("pingtool", function(ply,command,args)
		if !IsValid(ply) || !ply:Alive() then return end
		--check if the type of the pingtool is valid
		
		local mType=args[1]
		local mEnt;
		local mPos;
		local mSize=args[2] or (defaultPingtoolSize:GetFloat() or 1)
		mSize=tostring(math.Round(mSize,1))
		if !MarkersTypes[mType] then return end
		
		--do a trace,check whatever we've hit
		local tr=PlayerTrace(ply,ply:GetCursorAimVector(),MarkersTypes[mType].ignoreEntities)
		if tr.HitSky || !tr.Hit then return end		
		--if our entity is valid and the markertype allows entities then go on
		
		if IsValid(tr.Entity) and MarkersTypes[mType].onEntities then
			if (!tr.Entity:IsPlayer()) or (tr.Entity:IsPlayer() and tr.Entity:Team()==LocalPlayer():Team() and MarkersTypes[mType].onTeamMates) or (tr.Entity:IsPlayer() and tr.Entity:Team()~=LocalPlayer():Team())then
				mEnt=tr.Entity
			end
		end
		
		if !IsValid(mEnt) and MarkersTypes[mType].onWorld then
			mPos=tr.HitPos;
		end
		
		if !mEnt and !mPos then return end
		
		if mEnt then
			RunConsoleCommand("__pingtool",mSize,mType,mEnt:EntIndex())
		else
			RunConsoleCommand("__pingtool",mSize,mType,-1,math.Round(mPos.x),math.Round(mPos.y),math.Round(mPos.z)) --rounding is necessary to trunk the concommand length a bit
		end
	end)
	
	
	hook.Add("Think","PingMenu_Think",function()
		if (!IsValid(LocalPlayer()) || !LocalPlayer():Alive() ) and pingMenu.pingMenuOpened then
			pingMenu.pingMenuOpened=false;
			pingMenu.selectedMarker=pingMenu.defaultMarker
		end
	end)
	
	hook.Add("PlayerBindPress","PingMenu_Bind",function(ply,bind,pressed ) 
		if string.find(string.lower(bind),"attack") and LocalPlayer():Alive() and pingMenu.pingMenuOpened then
			pingMenu.pingMenuOpened=false;
			pingMenu.selectedMarker=pingMenu.defaultMarker
			return true;
		end
	end)
	
	local idlethreshold=5;
	local idletime=UnPredictedCurTime()+1;
	local idling=false;
	
	local xcenter=ScrW()/2
	local ycenter=ScrH()/2
	local mousex=xcenter
	local mousey=ycenter
	
	concommand.Add("+pingmenu", function(ply,command,args)
		if !IsValid(ply) || !ply:Alive() then return end
		pingMenu.pingMenuOpened=true;
		pingMenu.openedTime=UnPredictedCurTime()+1;
		idletime=UnPredictedCurTime()+1;
		idling=false;
		mousex=xcenter
		mousey=ycenter
	end)
	
	concommand.Add("-pingmenu", function(ply,command,args)
		if !IsValid(ply) || !ply:Alive() || !pingMenu.pingMenuOpened then pingMenu.pingMenuOpened=false; return end
		pingMenu.pingMenuOpened=false;
		if !pingMenu.selectedMarker then
			pingMenu.selectedMarker=pingMenu.defaultMarker
		end
		RunConsoleCommand("pingtool",pingMenu.selectedMarker)
		pingMenu.selectedMarker=pingMenu.defaultMarker
	end)
	

	
	hook.Add("PostDrawOpaqueRenderables","PingMenu_DrawTarget",function()
		if pingMenu.pingMenuOpened then
			local offset=Vector(0,-5,-13);
			local startpos=LocalPlayer():EyePos();
			local spos=LocalToWorld(offset,Angle(0,0,0),startpos,LocalPlayer():EyeAngles());
			local trace=PlayerTrace(LocalPlayer(),LocalPlayer():GetAimVector(),false)
			local size=1+(math.random(1,10)/70)
			if !trace.Hit then return end
			local endpos=trace.HitPos
			local ang;
			local col=team.GetColor(LocalPlayer():Team());
			col.a=200+math.random(0,55)
			local ent=(!LocalPlayer():ShouldDrawLocalPlayer()) and LocalPlayer():GetViewModel() or LocalPlayer():GetActiveWeapon()
			if LocalPlayer():ShouldDrawLocalPlayer() then
				if LocalPlayer():LookupBone("ValveBiped.Bip01_R_Hand") then
					spos,ang=LocalPlayer():GetBonePosition(LocalPlayer():LookupBone("ValveBiped.Bip01_R_Hand"))
				end
			end
			
			if IsValid(ent) then
				local attach=ent:GetAttachment(ent:LookupAttachment("muzzle"))
				if !attach then attach=ent:GetAttachment(ent:LookupAttachment("core")) end
				if attach then
				spos=attach.Pos
				end
			end
			
			
			
			render.SetMaterial( laser )
			render.DrawBeam(spos,endpos,4,1,1,col)
			
			if trace.Hit and IsValid(trace.Entity) then
				RenderToStencil(trace.Entity)
				RenderToGlowTexture(trace.Entity,255,team.GetColor(LocalPlayer():Team()))
			end
			render.SetMaterial( sprite )
			render.DrawSprite(endpos,8*size,8*size,team.GetColor(LocalPlayer():Team()) )
			render.DrawQuadEasy(endpos,trace.HitNormal,8*size,8*size,team.GetColor(LocalPlayer():Team()),0)
			
			render.DrawSprite(spos,6*size,6*size,team.GetColor(LocalPlayer():Team()) )
		end
	end)
	local nextselectTime=0.1
	local nextselect=UnPredictedCurTime();


	local xey2;
	local yey2;

	hook.Add("InputMouseApply", "PingMenu_SelectMarker", function(cmd, x, y, angle)
		if pingMenu.pingMenuOpened and pingMenu.openedTime<UnPredictedCurTime() then
			mousex=mousex+(math.Clamp(x,-10,10))
			mousey=mousey+(math.Clamp(y,-10,10))
			
			mousex=math.Clamp(mousex,xcenter-90,xcenter+90)
			mousey=math.Clamp(mousey,ycenter-90,ycenter+90)
			
			if nextselect<UnPredictedCurTime() then
				
				local curangle=0;
				for i,v in pairs(MarkersTypes) do
					if i==pingMenu.defaultMarker then
						xey2=xcenter;
						yey2=ycenter;
					else
						xey2=xcenter+(math.cos(math.rad(curangle)))*80;
						yey2=ycenter-(math.sin(math.rad(curangle)))*80;
					end
					
					if i~=pingMenu.defaultMarker then
						curangle=curangle+pingMenu.slice;
					end
					if i~=pingMenu.selectedMarker and math.Dist(mousex,mousey,xey2,yey2)<25 then
						pingMenu.selectedMarker=i;
						nextselect=UnPredictedCurTime()+nextselectTime;
					end
				end
				curangle=0;
			
				
			end
			
			return true
		end
	end)

	local xey,yey=0,0;

	local sizeselected=64;
	local sizenormal=40;
	local cursize=sizenormal;
	local defangle=0
	local curangle=defangle;
	hook.Add("HUDPaint","PingMenu_Draw",function()
		if pingMenu.pingMenuOpened and pingMenu.openedTime<UnPredictedCurTime() then
			for i,v in pairs(MarkersTypes) do
				if i==pingMenu.defaultMarker then
					--draw to the center
					xey=xcenter;
					yey=ycenter;
				else
					xey=xcenter+(math.cos(math.rad(curangle)))*80;
					yey=ycenter-(math.sin(math.rad(curangle)))*80;
				end
				cursize=(pingMenu.selectedMarker==i) and sizeselected or sizenormal
				if v.drawRoundedBox then
					draw.RoundedBox( v.drawRoundedBox,xey-(cursize/2),yey-(cursize/2),cursize,cursize,Color(50,50,50,255))
				end
				surface.SetTexture( mTexIds[i] );
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(xey-(cursize/2),yey-(cursize/2),cursize,cursize);
				if i~=pingMenu.defaultMarker then
					curangle=curangle+pingMenu.slice;
				end
				
			end

			curangle=defangle;
		end
	end)
	--[[
		float
		string
		bool
		bool==true 
			long
		bool
		bool==true 
			long 
			long 
			long
		bool
		bool==true
			vectornormal
	]]
	usermessage.Hook("PingTool", function( um )
		--if !IsMounted2("Team Fortress 2") then return end
		local mEnt,mType,mPos,mNormal,mSize
		mSize=um:ReadFloat();
		mType=um:ReadString();
		if MarkersTypes[mType].IsTf2 and !IsMounted2("Team Fortress 2") then return end
		if um:ReadBool()==true then
			mEnt=(um:ReadLong())
		end
		if um:ReadBool()==true then
			mPos=Vector(um:ReadLong(),um:ReadLong(),um:ReadLong())
		end
		if um:ReadBool()==true then
			mNormal=um:ReadVectorNormal()
		end
		Marker:New(mEnt,mPos,mNormal,mType,5,mSize)
	end)
	
else


	local function HandleMarker(ply,mType,mEnt,mPos,mSize)
		if ply.MarkingTime >= CurTime() then return end
		--everything should be ok by now,hopefully
		local mNormal
		if !mSize || type(mSize)!="number" then
			mSize=1;
		end
		mSize=math.Clamp(math.Round(mSize,1),0.1,5)
		if mPos then
			local tr_mNormal=(mPos-ply:EyePos()):Normalize()
			local tres=PlayerTrace(ply,tr_mNormal,MarkersTypes[mType].ignoreEntities)
			mNormal=tres.HitNormal
		end
		local ang=(mNormal) and mNormal:Angle() or nil
		
		if ang and (ang.p>300 || ang.p<270) and !MarkersTypes[mType].onWalls then return end
			
		if MarkersTypes[mType] and MarkersTypes[mType].concept and ply.IsHL2 and ply:IsHL2()==false then
			concommand.Run( ply,"__svspeak",{MarkersTypes[mType].concept}) --hacky but it should work just fine,plus compatibility just increased by 10%
		end
		--get the normal from the current ply's eyepos to the mPos if there's one
		ply.MarkingTime=CurTime() +5
		local rf=RecipientFilter()
		rf:AddPlayer( ply )
		for i,v in pairs(team.GetPlayers( ply:Team() ))do
			if mEnt == v or v:IsBot() then continue end
			rf:AddPlayer(v)
		end
		--[[
			float
			string
			bool
			bool==true 
				long
			bool
			bool==true 
				long 
				long 
				long
			bool
			bool==true
				vectornormal
		]]
		umsg.Start("PingTool",rf)
			umsg.Float(mSize)
			umsg.String(mType)
			umsg.Bool(IsValid(mEnt))
			if IsValid(mEnt) then umsg.Long(mEnt:EntIndex()) end
			umsg.Bool(mPos~=nil)
			if mPos then 
				umsg.Long(math.Round(mPos.x)) 
				umsg.Long(math.Round(mPos.y))
				umsg.Long(math.Round(mPos.z))
			end
			umsg.Bool(mNormal~=nil)
			if mNormal then 
				umsg.VectorNormal(mNormal) 
			end
		umsg.End()
		
	end
	
	concommand.Remove("__pingtool")
	concommand.Add("__pingtool", function(ply,command,args)
		if !IsValid(ply) || !ply:Alive() then return end
		ply.MarkingTime=ply.MarkingTime or CurTime()
		local mSize=tonumber(args[1]) or 1
		local mType=args[2]
		local mEnt=Entity(tonumber(args[3]) or -1) or nil;
		local mPos=(tonumber(args[4]) and tonumber(args[5]) and tonumber(args[6])) and Vector(args[4],args[5],args[6]) or nil;
		if ply.MarkingTime >= CurTime() then return end
		if !MarkersTypes[mType] then return end
		if !IsValid(mEnt) and !mPos then return end 
		if mPos and IsValid(mEnt) then return end
		if mPos and !MarkersTypes[mType].onWorld then return end
		if IsValid(mEnt) and mEnt:IsPlayer() and (mEnt:Team()==ply:Team() and !MarkersTypes[mType].onTeamMates ) then return end
		if mEnt==ply then return end
		HandleMarker(ply,mType,mEnt,mPos,mSize)
	end)

end