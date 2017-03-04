local ClassName="sent_twitchstream"
local ENT={}

ENT.Base             = "base_anim"


ENT.PrintName		= "Twitch stream?"
ENT.Author			= "Jvs"
ENT.Information		= "????"
ENT.Category		= "Jvs"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= true

function ENT:SpawnFunction( ply, tr, ClassName )
	return false
	
	--[[
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	]]
end



ENT.RefreshTime=5

function ENT:SetupDataTables()
	self:NetworkVar("String",0,"StreamName", { KeyName = "streamname", Edit = { type = "Generic", category = "Stream", order = 1 } } )
end

function ENT:Initialize()

	if ( SERVER ) then
		
		self:SetUseType(SIMPLE_USE)
		self:SetStreamName("jamezpb")
		self:SetModel("models/props_phx/rt_screen.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	else
		
		self.NextRefresh=CurTime()+self.RefreshTime
		self:CreatePanel()
	
	end
	
end

function ENT:CreatePanel()
	self.HTMLPanel = vgui.Create("HTML")

	self.HTMLPanel:SetPos(0, 0)

	self.HTMLPanel:SetSize(470,290)
	self.HTMLPanel:OpenURL("http://www.twitch.tv/"..self:GetStreamName().."/popout")
	
	self.CurrentStream=self:GetStreamName()
	self.HTMLPanel:SetPaintedManually(true)
end


ENT.Sides={
	{
		scale=0.12,
		pos=Vector(6,-28,37),
		ang=Angle(0,90,90),
	},
}

function ENT:Draw()

	self:DrawModel()
	
	if self.HTMLPanel then
		for i,v in pairs(self.Sides) do
			local pos,ang=LocalToWorld(v.pos or vector_origin,v.ang or angle_zero,self:GetPos(),self:GetAngles())
			cam.Start3D2D(pos,ang, v.scale or 0.15)
				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				self.HTMLPanel:SetPaintedManually(false)
				self.HTMLPanel:PaintManual()
				self.HTMLPanel:SetPaintedManually(true)
				render.PopFilterMin()
				render.PopFilterMag()
			cam.End3D2D()
		end
	end
end



function ENT:OnTakeDamage(dmginfo)
end

function ENT:Think()
	if SERVER then return end
	
	if not ValidPanel(self.HTMLPanel) then
		self:CreatePanel()
	end
	
	if self.NextRefresh <= CurTime() then	
		self.NextRefresh = CurTime() + self.RefreshTime
		if self:GetStreamName() ~= self.CurrentStream then
			self.HTMLPanel:OpenURL("http://www.twitch.tv/"..self:GetStreamName().."/popout")
			--self.HTMLPanel:RunJavascript( "location.reload(true);" )
			self.CurrentStream = self:GetStreamName()
		end
	end
	
	--self.Cmd=LocalPlayer():GetCurrentCommand()
	
end

function ENT:OnRemove()
	if CLIENT then
		--remove that shit yo
		if self.HTMLPanel then
			self.HTMLPanel:Remove()
			self.HTMLPanel=nil
		end
	end
end


scripted_ents.Register(ENT,ClassName,true)