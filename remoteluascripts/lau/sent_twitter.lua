local ClassName="sent_twitter"
local ENT={}

ENT.Base             = "base_anim"


ENT.PrintName		= "Peniscorp twitter"
ENT.Author			= "Jvs"
ENT.Information		= "????"
ENT.Category		= "Jvs"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= true

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 100
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end



ENT.RefreshTime=30

function ENT:Initialize()

	if ( SERVER ) then
		
		self:SetUseType(SIMPLE_USE)

		self:SetModel("models/hunter/plates/plate1x2.mdl")
	
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		--self:SetMaterial("models/shiny")
		
	else
		
		self.NextRefresh=CurTime()+self.RefreshTime
		self.HTMLPanel = vgui.Create("HTML")

		self.HTMLPanel:SetPos(0, 0)

		self.HTMLPanel:SetSize(390,800)
		self.HTMLPanel:OpenURL("http://gbandshb.altervista.org/test.html")
		self.HTMLPanel:SetPaintedManually(true)
	
	end
	
end



ENT.Sides={
	{
		scale=0.12,
		pos=Vector(-24,48,1.8),
		ang=Angle(0,0,0),
	},
	{
		scale=0.12,
		pos=Vector(24,48,-1.8),
		ang=Angle(180,0,0),
	},
	
}

function ENT:Draw()

	self:DrawModel()
	
	if self.HTMLPanel then
		for i,v in pairs(self.Sides) do
			local pos,ang=LocalToWorld(v.pos or vector_origin,v.ang or angle_zero,self:GetPos(),self:GetAngles())
			--[[
			cam.Start3D2D(pos,ang, v.scale or 0.15)
				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				surface.SetDrawColor( 0,0,0,255)
				surface.DrawRect( 0,0,ScrW(),ScrH() )
				
				
				local pnls=vgui.GetWorldPanel( ):GetChildren()
				local x,y
				local w,h
				
				for i,v in pairs(pnls) do
					
					if v and v:GetClassName()=="LuaEditablePanel" then
						--v:SetPaintedManually(true)
						local wasvisible=true--v:IsVisible()
						
						if not wasvisible then
							v:Show()
						end
						
						v:PaintManual()
						
						if not wasvisible then
							v:Hide()
						end
						--v:SetPaintedManually(false)

						x,y=v:GetPos()
						w,h=v:GetSize()
						surface.SetDrawColor( 0,0,0,255)
						surface.DrawRect( x,y,w,h )
						
					end
				end
				
				
				

				
				render.PopFilterMin()
				render.PopFilterMag()
			cam.End3D2D()
			]]
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
	if self.NextRefresh <= CurTime() then
		
		if not self.HTMLPanel then
			self.HTMLPanel = vgui.Create("HTML")

			self.HTMLPanel:SetPos(0, 0)

			self.HTMLPanel:SetSize(390,800)
			self.HTMLPanel:OpenURL("http://gbandshb.altervista.org/test.html")
			self.HTMLPanel:SetPaintedManually(true)
			self.NextRefresh=CurTime() + self.RefreshTime
		else
			
			if not self.HTMLPanel:IsLoading() then
				self.HTMLPanel:RunJavascript( "location.reload(true);" )
				self.NextRefresh=CurTime() + self.RefreshTime
			else
				self.NextRefresh=CurTime() + self.RefreshTime/5
			end
		
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