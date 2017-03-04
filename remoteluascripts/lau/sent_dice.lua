local ENT={}
ENT.Base             = "base_anim"
ENT.PrintName		= "Die"
ENT.Author			= "Jvs"
ENT.Information		= "Do you feel lucky?"
ENT.Category		= "Fun + Games"

ENT.Editable			= false
ENT.Spawnable			= true
ENT.AdminOnly			= true
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end


function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/maxofs2d/cube_tool.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
		self:SetMaterial( "!dicemat" )
		local scale=0.5
		self:SetModelScale(scale,0)
		self:Activate()
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():SetMaterial("concrete")
			
			if scale then
				self:GetPhysicsObject():SetMass( self:GetPhysicsObject():GetMass() * scale )
			end
			
		end
		
		self:SetUseType(SIMPLE_USE)
	end
	
end


if ( CLIENT ) then
	--create the render target
	local circ=surface.GetTextureID( "vgui/circle" )
	local circlesize = 40
	local rtsize = 512
	ENT.OriginalMat = Material("maxofs2d/models/cube_tool.vmt")
	ENT.RT = GetRenderTarget( "DiceRT" , rtsize , rtsize, false )
	
	ENT.RenderedTheThing = false
	
	
	ENT.Sides={
		top={
			x=40,y=0,w=170,h=170,
			draw=function(x,y,w,h)
				surface.DrawTexturedRect(x + w/2 - circlesize/2,y + h/2 -circlesize/2,circlesize,circlesize)
			end
		},
		frnt={
			x=40,y=170,w=170,h=170,
			draw=function(x,y,w,h)
				surface.DrawTexturedRect(x + w/3 - circlesize/2,y + h/3 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.5 - circlesize/2,y + h/1.5 -circlesize/2,circlesize,circlesize)
			end
		},
		bck={
			x=40,y=170*2,w=170,h=170,
			draw=function(x,y,w,h)
				surface.DrawTexturedRect(x + w/5 - circlesize/2,y + h/5 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/2 - circlesize/2,y + h/2 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
			end
		},
		btm={
			x=296,y=0,w=170,h=170,
			draw=function(x,y,w,h)
				y=y-2
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/4 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/4 -circlesize/2,circlesize,circlesize)
			end
		},
		lft={
			x=298,y=170,w=170,h=170,
			draw=function(x,y,w,h)
				x=x-3
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/4 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/2 - circlesize/2,y + h/2 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/4 -circlesize/2,circlesize,circlesize)
			end
		},
		rght={
			x=298,y=170*2,w=170,h=170,
			draw=function(x,y,w,h)
				x=x-3
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/4 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/1.25 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/4 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/1.25 - circlesize/2,y + h/1.9 -circlesize/2,circlesize,circlesize)
				surface.DrawTexturedRect(x + w/4 - circlesize/2,y + h/1.9 -circlesize/2,circlesize,circlesize)
			end
		},
	
	}
	
	hook.Add("PostRender","dicerender",function()
		if ENT.RenderedTheThing then 
			return 
		end
		local oldrt = render.GetRenderTarget()
		local scrw, scrh = ScrW(), ScrH()
		render.SetRenderTarget( ENT.RT )
		render.Clear(255, 255, 255, 255)
		render.SetViewPort(0, 0, rtsize, rtsize)
			cam.Start2D()
				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				for i,v in pairs(ENT.Sides) do
					if v.draw then
						surface.SetDrawColor(0,0,0,255)
						surface.SetTexture( circ )
						v.draw(v.x,v.y,v.w,v.h)
					end
				end
				render.PopFilterMin()
				render.PopFilterMag()			
			cam.End2D()
		render.SetRenderTarget(oldrt)

		render.SetViewPort(0, 0, scrw, scrh)
		
		ENT.RenderedTheThing=true
	end)
	



	ENT.DiceMaterial = CreateMaterial( "dicemat" , "VertexLitGeneric" ,
	{
		['$basetexture' ] = "sprites/orangelight1",
	})
	ENT.DiceMaterial:SetTexture("$basetexture", ENT.RT)
	
	
	function ENT:Draw()
		self:DrawModel()
	end
	
	--[[
	hook.Remove("HUDPaint","test",function()
		
		surface.SetDrawColor(255,255,255,255)
	
		surface.SetMaterial( ENT.OriginalMat )
		surface.DrawTexturedRect( rtsize / 4, 0, rtsize / 4 , rtsize / 4 )
		surface.SetDrawColor(255,255,255,255)
		
		surface.SetMaterial( ENT.DiceMaterial )
		surface.DrawTexturedRect(0, 0,rtsize/4,rtsize/4)
		
		
	end)
	]]
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end

if SERVER then
	function ENT:Use( activator, caller )
		if IsValid(activator) and activator:IsPlayer() then
			activator:PickupObject( self )
		end
	end

	function ENT:PhysicsCollide( data, physobj )
		if ( data.Speed > 70 and data.DeltaTime > 0.1 ) then
			self:EmitSound("Grenade.StepRight")
		end
	end
end


scripted_ents.Register(ENT,"sent_dice",true)
