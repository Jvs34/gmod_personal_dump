

local ClassName="sent_bassradio"
local ENT={}


ENT.Base             = "base_anim"


ENT.PrintName		= "Radio"
ENT.Author			= "Jvs"
ENT.Information		= "Oh shit im sorry"
ENT.Category		= "Fun + Games"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_BOTH


function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Playing")
	self:NetworkVar( "Bool", 1 , "Looping",{ KeyName = "Looping", Edit = { type = "Boolean", category = "Radio", order = 4 } })
	self:NetworkVar( "Bool", 2 , "ConeAudio",{ KeyName = "Directed Sound", Edit = { type = "Boolean", category = "Radio", order = 6 } })
	
	self:NetworkVar( "Float", 0, "TimeStarted")
	self:NetworkVar( "Float", 1, "Volume",{ KeyName = "Volume", Edit = { type = "Float",min=0.1,max=1, category = "Radio", order = 3 } })
	self:NetworkVar( "Float", 2 , "BassPlaybackRate",{ KeyName = "Playback Rate", Edit = { type = "Float", min=0.5 , max = 2 , category = "Radio", order = 5 } })
	
	self:NetworkVar( "String", 0 , "URL",{ KeyName = "URL", Edit = { type = "Generic", category = "Radio", order = 2 } })
	self:NetworkVar( "String", 1 , "Title",{ KeyName = "Title", Edit = { type = "Generic", category = "Radio", order = 1 } })
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/props_lab/citizenradio.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:SetTimeStarted( CurTime() )
		self:SetTitle("")
		self:SetURL("http://dl.dropboxusercontent.com/u/20140357/Pushing%20Gaywards.mp3")
		self:SetVolume( 1 )
		self:SetBassPlaybackRate( 1 )
		self:SetConeAudio( false )
		self:NetworkVarNotify( "URL", self.OnValueChanged )
		self:NetworkVarNotify( "Looping", self.OnValueChanged )
		
		self.RadioButton=ents.Create("widget_radio_button")
		self.RadioButton:SetPos(self:GetPos())
		self.RadioButton:SetParent(self)
		self.RadioButton:SetTransmitWithParent(true)
		self.RadioButton:Spawn()
		self.RadioButton:SetSize(2)
		
		self:DeleteOnRemove(self.RadioButton)
		
		self.RadioSlider=ents.Create("widget_radio_slider")
		self.RadioSlider:SetPos(self:GetPos())
		self.RadioSlider:SetParent(self)
		self.RadioSlider:SetTransmitWithParent(true)
		self.RadioSlider:Spawn()
		self.RadioSlider:SetSize(4)
		
		self:DeleteOnRemove(self.RadioSlider)
		
	else
		self.NextStreamTry = CurTime()
		self.SentRequest = false
		self.StaticSound = CreateSound( self, "Weapon_FlareGun.Burn" )
	end

end

function ENT:OnValueChanged( varname, oldvalue, newvalue )
	if self:GetPlaying() then
		self:SetPlaying(false)
	end
end

ENT.Offsets={
	knob={
		pos=Vector(10,9,7.5),
		ang=angle_zero,
	},
	timer={
		pos=Vector(8.55,-11.2,14.8),
		ang=Angle(0,90,90),
		scale=0.06
	},
	info={
		pos=Vector(8.55,-5.5,14.8),
		ang=Angle(0,90,90),
		scale=0.06
	},
	visualizer={
		pos=Vector(-7.5,13,16),
		ang=Angle(0,-90,90),
		scale=0.06
	},
	slider={
		pos=Vector(7.5,-10,6.5),
		ang=Angle(90,0,0),
	},
}

if CLIENT then

	--[[
	for i=1,ENT.SampleSize do
		ENT.FFT[i]=math.random(0,100)/100
	end
	]]
	ENT.SampleSize=128
	ENT.AverageValues=16
	ENT.FFT={} 
	ENT.AverageBands={}
	
	ENT.StreamLoadingColor=Color(255,0,0,255)
	ENT.StreamLoadedColor=Color(0,255,0,255)
	ENT.StreamOff=Color(255,255,0,255)
	ENT.GlowMat=Material("effects/blueflare1")
	
	function ENT:Draw()
		self:DrawModel()
	end
	
	ENT.RT = GetRenderTarget("RadioBars", 32, 128, false)
	
	

	hook.Add("PostRender","radiobarsrender",function()
		if ENT.RenderedTheThing then return end
		local oldrt = render.GetRenderTarget()
		local scrw, scrh = ScrW(), ScrH()
		render.SetRenderTarget(ENT.RT)
		render.Clear(255, 255, 255, 255)
		render.SetViewPort(0, 0, 32, 128)
			cam.Start2D()
				--[[
				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				]]
				--[[
				for i=0,127 do
					surface.SetDrawColor( math.random(0,255),math.random(0,255),math.random(0,255),255 )
					surface.DrawLine(0,i,32,i)
				end
				]]
				
				local percent=0
				local hue=0
				local saturation=0
				local value=0

				for i=0,ENT.AverageValues-1 do
					percent=(i+1)/ENT.AverageValues
					
					hue=Lerp(percent,0,120)
					saturation=1
					value=0.8
					
					surface.SetDrawColor( HSVToColor(hue,saturation,value) )
					surface.DrawRect( 0,i*8,32,8 )
				
					surface.SetDrawColor( color_black )
					surface.DrawOutlinedRect( 0,i*8,32,8 )
				end
				
				
				--[[
				for i=0,15 do
					surface.SetDrawColor( 0,255,0,255 )
					surface.DrawRect( 0,i*8,32,8 )
				
					surface.SetDrawColor( color_black )
					surface.DrawOutlinedRect( 0,i*8,32,8 )
				end
				]]
				
				--[[
				render.PopFilterMin()
				render.PopFilterMag()
				]]
			cam.End2D()
		render.SetRenderTarget(oldrt)

		render.SetViewPort(0, 0, scrw, scrh)
		
		ENT.RenderedTheThing=true
	end)
	
	ENT.BarsMat=CreateMaterial("BarsMat","UnlitGeneric",{
		['$basetexture' ] = "sprites/orangelight1",
	})
	ENT.BarsMat:SetTexture("$basetexture", ENT.RT)
	
	hook.Remove("HUDPaint","test",function()
		if LocalPlayer():Nick()~="Jvs" then return end
		--drawfplogo(0,0,circlesize,circlesize)
		
		surface.SetDrawColor(255,255,255,255)

		
		surface.SetMaterial(ENT.BarsMat)
		surface.DrawTexturedRect(10,10,32*4, 128*4)
		
		--surface.DrawTexturedRectUV(10 + 32*4,10,32*4, 128*4,0,0.1,1,1)		
	end)
	
	
	
	
	
	local function make_set(t)
		local s = {}
		for i = 1, table.getn(t) do
			s[t[i]] = 1
		end
		return s
	end
	
	local segment_set = make_set {
		"-", "_", ".", "!", "~", "*", "'", "(", 
		")", ":", "@", "&", "=", "+", "$", ",", "?",
	}

	function protect_segment(s)
		return string.gsub(s, "(%W)", function (c) 
			if segment_set[c] then return c
			else return escape(c) end
		end)
	end

	function unescape(s)
		return string.gsub(s, "%%(%x%x)", function(hex)
			return string.char(tonumber(hex, 16))
		end)
	end
	
	function ENT:DrawTranslucent()
				
		--draw effects only if turned on
		
		
			
		--draw the timer
		local str = ""
		local pos , ang = LocalToWorld(self.Offsets.timer.pos,self.Offsets.timer.ang,self:GetPos(),self:GetAngles())
		
		if self:GetPlaying() then
			local t = self:GetCurrentTime()
			
			if self.BassStream then
				t = self.BassStream:GetTime()
			end
			
			str=string.FormattedTime( t, "%02i:%02i" )
			
		end
		
		cam.Start3D2D(pos,ang, self.Offsets.timer.scale or 0.15)
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			surface.SetDrawColor( 0,0,0,255)
			surface.DrawRect(-10,-10,70,45 )
			
			surface.SetFont("ScoreboardDefault")
			surface.SetTextColor(color_white)
			surface.SetTextPos(0,0) 
			surface.DrawText( str )
			

			
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
		
		local str=""
		local otherinfo=nil
		local pos,ang=LocalToWorld(self.Offsets.info.pos,self.Offsets.info.ang,self:GetPos(),self:GetAngles())
		
		if self:GetPlaying() then
			local title=self:GetTitle()
			
			if title=="" then
				local titties=self:GetURL()
				if self.BassStream and self.BassStream.GetFileName then
					titties=self.BassStream:GetFileName()
				end
				title=string.GetFileFromFilename(titties)
			end
			
			title=unescape(title)
			
			surface.SetFont("ScoreboardDefault")
			local fw,fh=surface.GetTextSize(title)
			if fw>100 then
			--if #title > 24 then
				--truncate the title because it may not fit the screen
				title=string.Left( title, 17 )--.."..."
				
			end
			if IsValid(self.BassStream) then
				
				str="Playing "..title
				local l=nil
				if self.BassStream.GetLength then
					l=self.BassStream:GetLength()
				end
				
				otherinfo="Duration "..string.FormattedTime( l or self:GetCurrentTime(), "%02i:%02i" )
				if self.BassStream.GetState then
					if self.BassStream:GetState()==GMOD_CHANNEL_STALLED then
						str="Syncing with server"
						otherinfo="this may take a bit"
					end
				end
			else
				str="Loading "..title
			end
		end
		
		cam.Start3D2D(pos,ang, self.Offsets.info.scale or 0.15)
			
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
			surface.SetDrawColor( 0,0,0,255)
			surface.DrawRect(-10,-10,300,75 )
			
			surface.SetFont("ScoreboardDefault")
			surface.SetTextColor(color_white)
			surface.SetTextPos(0,0) 
			surface.DrawText( str )
			if otherinfo then
				surface.SetTextPos(0,20) 
				surface.DrawText( otherinfo )
			end
			
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
		
		
		local pos,ang=LocalToWorld(self.Offsets.visualizer.pos,self.Offsets.visualizer.ang,self:GetPos(),self:GetAngles())
		local maxw=434
		local maxh=214
		
		local barsize=(maxw/(self.AverageValues)) 
		
		if self:GetPlaying() and self.BassStream and self.BassStream.FFT then
			
			self.BassStream:FFT(self.FFT,FFT_256)

		end
		
		--self.AverageBands={}
	
		
		for i=1,self.AverageValues do
		
			self.AverageBands[i]=0
			for _i=i,i+8 do
				if not self.FFT[_i] then continue end
				self.AverageBands[i]=self.AverageBands[i] + self.FFT[_i]
			end
			self.AverageBands[i]=self.AverageBands[i]/(self.SampleSize/self.AverageValues)
			self.AverageBands[i]=self.AverageBands[i]*5*self:GetVolume()
			
		end
		
		
		cam.Start3D2D(pos,ang, self.Offsets.visualizer.scale or 0.15)
			
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)

			surface.SetDrawColor( 0,0,0,255)
			surface.DrawRect(0,0,maxw,maxh )
			if self:GetPlaying() and self.BassStream and self.BassStream.FFT then
					
			
				for i,v in pairs(self.AverageBands) do
					
					local value = maxh*v
					value=math.Clamp(value,0,maxh)
				
					surface.SetMaterial(self.BarsMat)
					surface.SetDrawColor(255,255,255,255)
					surface.DrawTexturedRectUV((i-1)*barsize,maxh-value,barsize,value,0,1-v,1,1)
		
					
				end
			end
			
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
		
		local col=color_white
		local pos,ang=LocalToWorld(self.Offsets.knob.pos,self.Offsets.knob.ang,self:GetPos(),self:GetAngles())
		if self:GetPlaying() then
			
			if IsValid(self.BassStream) then
				--draw green shit
				col=self.StreamLoadedColor

				if self.BassStream.GetState and self.BassStream:GetState()==GMOD_CHANNEL_STALLED then
					col=self.StreamOff
				end
			else
				col=self.StreamOff
				--draw red shit
			end
		else
			col=self.StreamLoadingColor
		
		end
		render.SetMaterial(self.GlowMat)
		local sine=math.sin(CurTime()*200)*0.5
		render.DrawSprite( pos, 8+sine, 8+sine, col)
	end
end

--[[
 IGModAudioChannel:Stop now permanently deletes the channel
IGModAudioChannel:SetPos now takes an orientation vector as an optional second argument

Added IGModAudioChannel:GetPos()
Added IGModAudioChannel:GetVolume()
Added IGModAudioChannel:SetTime(seconds)
Added IGModAudioChannel:Set3DFadeDistance(min, max)
Added IGModAudioChannel:Get3DFadeDistance()
Added IGModAudioChannel:Set3DCone(innerAngle, outerAngle, outerVolume)
Added IGModAudioChannel:Get3DCone()
Added IGModAudioChannel:GetState(), returns a GMOD_CHANNEL_ enum, see below
Added IGModAudioChannel:IsLooping()
Added IGModAudioChannel:IsOnline()
Added IGModAudioChannel:Is3D()
Added IGModAudioChannel:GetLength(), returns total time in seconds
Added IGModAudioChannel:GetFileName()
Added IGModAudioChannel:GetSamplingRate()
Added IGModAudioChannel:GetBitsPerSample()
Added IGModAudioChannel:GetLevel(), returns two levels for left and right channel (between 0 and 1)
Added IGModAudioChannel:FFT(tbl, type), outputs in tbl, returns number of values output, type is a FFT_ enum, see below

Added enums:
GMOD_CHANNEL_STOPPED
GMOD_CHANNEL_PLAYING
GMOD_CHANNEL_PAUSED
GMOD_CHANNEL_STALLED
FFT_256
FFT_512
FFT_1024
FFT_2048
FFT_4096
FFT_8192
FFT_16384

]]

function ENT:GetCurrentTime()
	return CurTime()-self:GetTimeStarted()
end

function ENT:Think()
	if SERVER then
		--we'll handle the serverside looping and stopping when vinh adds the bindings
		--altough, it'd probably be better to make this code shared
		return
	end
	
	if not self.StaticSound then
		self.StaticSound = CreateSound( self, "Weapon_FlareGun.Burn" )
	end
	
	if self:GetPlaying() then
		if IsValid( self.BassStream ) then
			--only try to sync it if it's not an infinite stream, and we're not over the length of the file
			--if we are, the server will take care of it anyway by
			
			if self.BassStream:GetLength() > 0 then
				if self:GetCurrentTime() <= self.BassStream:GetLength() then
					self.BassStream:SetTime( self:GetCurrentTime() * self:GetBassPlaybackRate() )
				end
				
				if self:GetCurrentTime() >= self.BassStream:GetLength() and self:GetLooping() and self.BassStream:IsLooping() then
					--if this loops over, then normalize the currenttime so that it's like we're starting over
					local normalizedcurrenttime=self:GetCurrentTime()
					while(normalizedcurrenttime > self.BassStream:GetLength()) do
						normalizedcurrenttime = normalizedcurrenttime - self.BassStream:GetLength()
					end
					self.BassStream:SetTime( normalizedcurrenttime )
				end
				
			end
			self.BassStream:SetPlaybackRate( self:GetBassPlaybackRate() )
			
			local audiodir = vector_origin
			
			if self:GetConeAudio() then
				audiodir = self:GetForward()
				self.BassStream:Set3DCone( 90 , 270 , 0.1 )
			else
				self.BassStream:Set3DCone( 0 , 0 , 1 )
			end
			
			self.BassStream:SetPos( self:GetPos() , audiodir )
			self.BassStream:SetVolume( self:GetVolume() )
			
			if self.BassStream.GetState and self.BassStream:GetState()==GMOD_CHANNEL_STALLED then
				if self.StaticSound then
					self.StaticSound:Play()
					self.StaticSound:ChangeVolume(self:GetVolume(),0)
				end
			else
				if self.StaticSound then
					self.StaticSound:Stop()
				end
			end
			
			
		else
			--stream isn't valid yet, play static noise
			if self.StaticSound then
				self.StaticSound:Play()
				self.StaticSound:ChangeVolume( self:GetVolume() , 0 )
			end
			
			if self.NextStreamTry < CurTime() and not self.SentRequest then
				--"3d noplay loop"
				--play a sound to notify the player the request has been sent
				self:EmitSound( "Buttons.snd18" )
				
				local request = "3d noplay noblock"
				
				if self:GetLooping() then
					request = request.." loop"
				end
				
				
				sound.PlayURL(self:GetURL(),request,function(stream , errorid , errorstr )
					--check if the entity was still valid after this, if so
					--call the callback in the entity, otherwise stop everything and
					--send everyone home
					if IsValid(self) then
						self:PlaySoundCallback(stream)
						self.SentRequest=false
					else
						if IsValid(stream) then
							stream:Stop()
							stream=nil
						end
					end
					
					if errorstr then
						print( errorstr )
					end
				end)
				
				self.SentRequest = true
				--start the stream, check every N seconds
				self.NextStreamTry = CurTime() + 10
			end
		end
	else
		self.NextStreamTry = CurTime()
		if IsValid( self.BassStream ) then
			self.BassStream:Stop()
			self.BassStream=nil
			self:EmitSound("Buttons.snd18")
		end
		
		if self.StaticSound then
			self.StaticSound:Stop()
		end
	end
end

function ENT:GetRadioButtonPos()
	return LocalToWorld(self.Offsets.knob.pos,self.Offsets.knob.ang,self:GetPos(),self:GetAngles())
end

function ENT:GetRadioSliderPos()
	return LocalToWorld(self.Offsets.slider.pos,self.Offsets.slider.ang,self:GetPos(),self:GetAngles())
end

function ENT:OnRemove()
	if IsValid(self.BassStream) then
		self.BassStream:Stop()
		self.BassStream=nil
	end
	
	if self.StaticSound then
		self.StaticSound:Stop()
		self.StaticSound=nil
	end
end

function ENT:Use( activator, caller )
	--self:UseRadio()
end

function ENT:UseRadio()
	self:SetPlaying(not self:GetPlaying())
	self:EmitSound("Buttons.snd14")
	if self:GetPlaying() then
		self:SetTimeStarted(CurTime())
	end
end

function ENT:PlaySoundCallback(basschannel)
	if IsValid(basschannel) then
		--assign it as self.BassStream
		if self:GetPlaying() then
			self.BassStream=basschannel
			self.BassStream:Play()
			self.BassStream:SetVolume(self:GetVolume())
			self:EmitSound("weapons/stunstick/spark1.wav")
			if self.BassStream.Set3DFadeDistance then
				self.BassStream:Set3DFadeDistance(500, 1500)
			end
		else
			basschannel:Stop()
			basschannel=nil
		end
	else
		--it failed, try again in a second
		self.NextStreamTry = CurTime() + 1
	end
	
end

scripted_ents.Register(ENT,ClassName,true)



local widget_radio_button = 
{
	Base = "widget_base",
	
	Initialize=function(self)
		self.BaseClass.Initialize(self)
		self:SetNextClick(CurTime()+1)
	end,
	
	SetupDataTables=function(self)
		self.BaseClass.SetupDataTables(self)
		self:NetworkVar("Float",2,"NextClick")
	end,
	
	
	OverlayRender=function(self) end,
	--[[
	Draw=function(self)
		
		local col = Color( 0, 0, 50, 255 )
	
		if ( self:IsHovered() ) then
			col = Color( 20, 50, 100, 255 )
		elseif ( self:SomethingHovered() ) then
			-- less alpha
		end
		
		if ( self:IsPressed() ) then
		
			col = Color( 180, 180, 50, 255 )
			
			if ( LocalPlayer():GetHoveredWidget() == LocalPlayer():GetPressedWidget() ) then
				col = Color( 255, 255, 100, 255 )
			end
			
		end
		
		if self:GetNextClick()>CurTime() then
			
			col = Color(255,180,180,255)
			
		end
		
		
		local vSize = Vector( self:GetSize(), self:GetSize(), self:GetSize() )

		render.SetColorMaterialIgnoreZ()
		render.DrawBox( self:GetPos(),self:GetAngles(), vSize*-1,vSize, ColorAlpha( col, 0.8 ), false )
		
		render.SetColorMaterial()
		render.DrawBox( self:GetPos(),self:GetAngles(), vSize*-1,vSize, col, false )				
	end,
	]]
	
	CalcAbsolutePosition = function( self, v, a )
		local v=vector_origin
		local a=angle_zero
		if IsValid(self:GetParent()) then
			if self:GetParent().GetRadioButtonPos then
				v,a=self:GetParent():GetRadioButtonPos()
			end
		end
		return v, a
	
	end,

	OnClick = function( self, ply )
		if CLIENT then return end
		
		if self:GetNextClick()>CurTime() then return end
	
		
		if IsValid(self:GetParent()) and self:GetParent().UseRadio then
			self:GetParent():UseRadio()
		end
		self:SetNextClick(CurTime()+0.3)
	end
}

scripted_ents.Register( widget_radio_button, "widget_radio_button" )

local widget_radio_slider = 
{
	Base = "widget_base",
	
	Initialize=function(self)
		self.BaseClass.Initialize(self)
		self:SetModel("models/maxofs2d/button_slider.mdl")
	end,
	
	SetupDataTables=function(self)
		self.BaseClass.SetupDataTables(self)

	end,
	
	OverlayRender=function(self) end,
	
	Draw=function(self)
		self:SetModelScale(0.5,0)
		if IsValid(self:GetParent()) and self:GetParent().GetVolume then
			self:SetPoseParameter("switch",self:GetParent():GetVolume())
		end
		self:DrawModel()
	end,
	
	CalcAbsolutePosition = function( self, v, a )
		local v=vector_origin
		local a=angle_zero
		if IsValid(self:GetParent()) then
			if self:GetParent().GetRadioSliderPos then
				v,a=self:GetParent():GetRadioSliderPos()
			end
		end
		return v, a
	
	end,

	DragThink=function( ply, mv, dist )
		if CLIENT then return end
		
	end,
	OnClick = function( self, ply )
		if CLIENT then return end
		
	end,
	
	TestCollision=function(self) 
	
	end,
}

scripted_ents.Register( widget_radio_slider, "widget_radio_slider" )