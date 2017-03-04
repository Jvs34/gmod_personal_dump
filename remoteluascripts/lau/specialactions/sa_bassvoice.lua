if not SA then return end

if SERVER then
	umsg.PoolString("sa_bassvoice_clienttoserver")
end

local newsa=SA:New("Bass Voice test","sa_bassvoice","Allows your player to speak voice lines from the internet!! spooky")

newsa.DropboxLinkPrefix="https://dl.dropboxusercontent.com/u/20140357/pushing%20gaywards/"
newsa.NoSound=-1
newsa.Sounds={
	{name="Yeah I see that, daddy...",url=newsa.DropboxLinkPrefix.."yeahiseethatdaddygaveyougoodadvice.mp3"},
	{name="It gets bigger...",url=newsa.DropboxLinkPrefix.."itgetsbiggerwhenipullonit.mp3"},
	{name="Sometimes I pull on it...",url=newsa.DropboxLinkPrefix.."sometimesipullonitsohardiriptheskin.mp3"},
	{name="Id be right happy to",url=newsa.DropboxLinkPrefix.."idberighthappyto.mp3"},
	{name="hmMMMMm",url=newsa.DropboxLinkPrefix.."hmmmm.mp3"},
	{name="My daddy taught me...",url=newsa.DropboxLinkPrefix.."mydaddytaughtmeafewthingstoo.mp3"},
	{name="Oh shit Im sorry",url=newsa.DropboxLinkPrefix.."ohshitimsorry.mp3"},
	{name="Our dad taught us...",url=newsa.DropboxLinkPrefix.."ourdadtaughtus.mp3"},
	{name="Skin!",url=newsa.DropboxLinkPrefix.."skin.mp3"},
	{name="Sorry for what?",url=newsa.DropboxLinkPrefix.."sorryforwhat.mp3"},
	{name="Will you show me?",url=newsa.DropboxLinkPrefix.."willyoushowme.mp3"},
	{name="This is bullshit",url="https://dl.dropboxusercontent.com/u/20140357/filessharex/bullshit.wav"},
	{name="Terrorists win",url="https://dl.dropboxusercontent.com/u/20140357/filessharex/terwin.wav"},
	{name="EXCUSE ME",url="http://wiki.teamfortress.com/w/images/c/ca/TFC_saveme2.wav?t=20101026024523"},
	{name="Jvs",url="http://77.207.205.135:8080/",streamed=true},
	
	
}
--{name="pushing gaywards",url="https://dl.dropbox.com/u/20140357/filessharex/04%20Pushing%20Gaywards.mp3"},
	

function newsa:Initialize(entity,owner)
	entity.BassSounds={}
	if CLIENT and LocalPlayer()==owner then
		self:CreateVoiceMenu(entity,owner)
	end
end

function newsa:Deinitialize(entity,owner)
	if SERVER then return end
	
	for i,v in pairs(entity.BassSounds) do
		if IsValid(v.Sound) then
			v.Sound:Stop()
		end
	end
	entity.BassSounds=nil
	
	if entity.VoicePanel then
		for i,v in pairs(entity.VoicePanel) do
			if v and v.IsValid and ValidPanel(v) then
				v:Remove()
			end
		end
	end
	
end

function newsa:CreateVoiceMenu(entity,owner)
	entity.VoicePanel={}
	entity.VoicePanel.Frame = vgui.Create( "DFrame" )
	entity.VoicePanel.Frame:SetTitle("sa_bassvoice list")
	entity.VoicePanel.Frame:SetSize(300,300)
	entity.VoicePanel.Frame:SetVisible(true)
	entity.VoicePanel.Frame:SetDeleteOnClose(false)
	--entity.VoicePanel.Frame:ShowCloseButton(false)
	
	
	entity.VoicePanel.IconList=vgui.Create( "DIconLayout", entity.VoicePanel.Frame)
	entity.VoicePanel.IconList:Dock(FILL)
	entity.VoicePanel.IconList:SetSpaceY( 5 )
	entity.VoicePanel.IconList:SetSpaceX( 5 )

	entity.VoicePanel.Buttons={}
	for i,v in pairs(self.Sounds) do
		entity.VoicePanel.Buttons[i] = entity.VoicePanel.IconList:Add("DButton") --vgui.Create( "DButton",entity.VoicePanel.Frame)
		entity.VoicePanel.Buttons[i]:SetSize(120,30)
		entity.VoicePanel.Buttons[i]:SetText(v.name)
		entity.VoicePanel.Buttons[i].Sound=i
		entity.VoicePanel.Buttons[i].Entity=entity
		entity.VoicePanel.Buttons[i].Owner=owner
		entity.VoicePanel.Buttons[i].Newsa=self
		entity.VoicePanel.Buttons[i].DoClick=function(self)
			if self.Newsa and self.Owner and self.Entity then
				self.Newsa:SendSound(self.Entity,self.Owner,self.Sound)
			end
		end
		--entity.VoicePanel.Frame
		
		
	end
	local i=#entity.VoicePanel.Buttons
	entity.VoicePanel.Buttons[i] = entity.VoicePanel.IconList:Add("DButton") --vgui.Create( "DButton",entity.VoicePanel.Frame)
	entity.VoicePanel.Buttons[i]:SetSize(120,30)
	entity.VoicePanel.Buttons[i]:SetText("Stop sounds")
	entity.VoicePanel.Buttons[i].Sound=self.NoSound
	entity.VoicePanel.Buttons[i].Entity=entity
	entity.VoicePanel.Buttons[i].Owner=owner
	entity.VoicePanel.Buttons[i].Newsa=self
	entity.VoicePanel.Buttons[i].DoClick=function(self)
		if self.Newsa and self.Owner and self.Entity then
			self.Newsa:SendSound(self.Entity,self.Owner,self.Sound)
		end
	end
	
	entity.VoicePanel.Frame:Center()
	entity.VoicePanel.Frame:SizeToContents()
end

function newsa:Think(entity,owner,mv)
	if SERVER then return end
	
	local id=entity:GetCurrentBassSound()
	if id==self.NoSound then return end
	if entity.BassSounds[id] then
		
		--check if their gettime is over the getlength, but only if it's blockstreamed
		if not entity.BassSounds[id].Sound:IsBlockStreamed() then
			
			if entity.BassSounds[id].Sound:GetState()==GMOD_CHANNEL_STOPPED then
				self:SendSound(entity,owner,self.NoSound)
			end
		end
		
		
	end

end


function newsa:SendSound(entity,owner,soundindex)
	if entity:GetNextAction() > CurTime() then return end
	
	net.Start("sa_bassvoice_clienttoserver")
		net.WriteInt(soundindex or self.NoSound,8)
	net.SendToServer( )
end

function newsa:ReceiveSoundRequest(entity,owner,soundid)
	if not soundid then
		soundid=self.NoSoud
	end
	
	if entity:GetNextAction() > CurTime() then return end
	
	entity:SetCurrentBassSound(soundid)
	entity:SetNextAction(CurTime()+0.1)
	
end

--done here because otherwise it won't run on all clients
function newsa:AllClientThink(entity,owner,isclientowner)
	if not entity.BassSounds then entity.BassSounds={} end
	
	
	if isclientowner then
	if ValidPanel(entity.VoicePanel.Frame) then
			if owner:KeyDown(IN_ATTACK2) then
				entity.VoicePanel.Frame:SetVisible(true)
				entity.VoicePanel.Frame:Center()
				entity.VoicePanel.Frame:MakePopup()
			else
				entity.VoicePanel.Frame:SetVisible(false)
			end

		end
	
		
	end
	
	local newid=entity:GetCurrentBassSound()
	entity.LastBassSoundId=entity.LastBassSoundId or newid
	
	if entity.LastBassSoundId~=newid then
		--if newid==self.NoSound then
			self:StopAllSounds(entity,owner)
		--[[
		else
			self:StopSound(entity,owner,lastid)
		end
		]]
		
		if newid~=self.NoSound then
			self:PlaySound(entity,owner,entity:GetCurrentBassSound())
		end
		
	end
	
	
	self:LoadUrls(entity,owner)
	self:PositionSounds(entity,owner,isclientowner)
	
	
	entity.LastBassSoundId=entity:GetCurrentBassSound()
end

GAMEMODE.MouthMoveAnimation=function() end


local ffttab={}
function newsa:AnimateMouth(entity,owner)
	if SERVER then return end
	
	local id=entity:GetCurrentBassSound()
	--get a really rough approximate of the fft
	local value=0
	
	if entity.BassSounds[id] and IsValid(entity.BassSounds[id].Sound) and entity.BassSounds[id].Sound:GetState()==GMOD_CHANNEL_PLAYING then
		entity.BassSounds[id].Sound:FFT(ffttab,FFT_256)
		--TODO only filter some channels
		local iterations=0
		for i,v in pairs(ffttab) do
			value=value+v
			iterations=i+1
		end
		value=(value/iterations)*100
	end
	
	
	if id==self.NoSound then return end
	local FlexNum = owner:GetFlexNum() - 1
	if ( FlexNum <= 0 ) then return end
	
	for i=0, FlexNum-1 do
	
		local Name = owner:GetFlexName( i )

		if  Name == "jaw_drop" or Name == "right_part" or Name == "left_part" or Name == "right_mouth_drop" or Name == "left_mouth_drop"  then
			value=math.Clamp(value,0,2)
			owner:SetFlexWeight( i, value )
		end
		
	end
	
end


function newsa:LoadUrls(entity,owner)
	-- i is index and v is the table containing name and url
	for i,v in pairs(self.Sounds) do
		if not entity.BassSounds[i] then	--not here, make it load
			entity.BassSounds[i]={}
			local request="3d"
			if not v.streamed then
				request=request.." noblock"
			end
			sound.PlayURL(v.url,request,function(stream)
					if IsValid(entity) then
						if not IsValid(stream) then 
							entity.BassSounds[i]=nil
						else
							stream:Pause()
							entity.BassSounds[i].Sound=stream
						end
					else
						if IsValid(stream) then	
							stream:Stop()
						end
					end
			end)

		end
	end
	
end

function newsa:PositionSounds(entity,owner,isclientowner)
	local pos=owner:EyePos()
	local dir=owner:EyeAngles():Forward()	--GetAimVector contains their context menu aim as well, not good
	local atchid=owner:LookupAttachment("mouth")
	
	if atchid~= 0 then
		local atch=owner:GetAttachment(atchid)
		if atch then
			pos=atch.Pos
			dir=atch.Ang:Forward()
		end
	end

	
	for i,v in pairs(entity.BassSounds) do
		if IsValid(v.Sound) then
			v.Sound:Set3DCone(45,150,0.3)
			v.Sound:SetPos(pos,dir)
		end
	end
	
end

function newsa:StopAllSounds(entity,owner)
	for i,v in pairs(entity.BassSounds) do
		self:StopSound(entity,owner,i)
	end
end

function newsa:StopSound(entity,owner,id)
	if not entity.BassSounds then return end
	
	if entity.BassSounds[id] and IsValid(entity.BassSounds[id].Sound) and entity.BassSounds[id].Sound:GetState()~=GMOD_CHANNEL_PAUSED and entity.BassSounds[id].Sound:GetState()~=GMOD_CHANNEL_STALLED then
		if not entity.BassSounds[id].Sound:IsBlockStreamed() then
			entity.BassSounds[id].Sound:SetTime(0)
		end
		entity.BassSounds[id].Sound:Pause()
	end
end

function newsa:PlaySound(entity,owner,id)
	if not entity.BassSounds then return end
	
	if entity.BassSounds[id] and IsValid(entity.BassSounds[id].Sound) then
		if not entity.BassSounds[id].Sound:IsBlockStreamed() then
			entity.BassSounds[id].Sound:SetTime(0)
		end
		
		entity.BassSounds[id].Sound:Play()
		entity.BassSounds[id].Sound:SetPlaybackRate(self.Sounds[id].playbackrate or 1)
	end
end



function newsa:Attack(entity,owner,mv)
	--[[
	if entity:GetCurrentBassSound()==self.NoSound then
	
		entity:SetCurrentBassSound(3)
	else
		entity:SetCurrentBassSound(self.NoSound)
	end
	entity:SetNextAction(CurTime()+0.5)
	]]
end


function newsa:SetupMove(entity,owner,movedata,commanddata)
end

function newsa:Move(entity,owner,movedata)
end


function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
end


function newsa:DrawWorldModel(entity,owner)
end


function newsa:PrePlayerDraw(entity,owner)
end

function newsa:PostPlayerDraw(entity,owner)
end



function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)
end


function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
end

function newsa:HUDDraw(entity,owner)
end

function newsa:ResetVars(entity,owner)
	entity:AliasNetworkVar("ActionInt1","CurrentBassSound")	
		
	entity:SetCurrentBassSound(self.NoSound)

end

function newsa:PlayerUse(entity,owner,useentity)
end

function newsa:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
	if not entity.GetCurrentBassSound then return end
	self:AnimateMouth(entity,owner)
end

function newsa:CalcMainActivity(entity,owner,velocity)

end


function newsa:DoAnimationEvent(entity,owner,event,data)
end

function newsa:BuildHandsPosition(entity,owner,handsent)
	
end

function newsa:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	
end

if SERVER then
	net.Receive("sa_bassvoice_clienttoserver", function(len,ply)
		if not IsValid(ply) then return end
		if not IsValid(ply:GetDTEntity(3)) then return end
		local soundid=net.ReadInt(8)
		local ent=ply:GetDTEntity(3):GetActionByClass("sa_bassvoice")
		if IsValid(ent) then
			ent:DoSpecialAction( "ReceiveSoundRequest" , soundid )
		end
	
	end)
end