local ClassName="sent_dick"
local ENT={}

ENT.Base             = "base_anim"


ENT.PrintName		= "????"
ENT.Author			= "Jvs"
ENT.Information		= "????"
ENT.Category		= "Jvs"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= false

function ENT:SpawnFunction( ply, tr, ClassName )
	--[[
	if not ply:IsAdmin() and not TRUSTED[ply:SteamID()] then 
		return 
	end
	]]
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 100
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetOwner(ply)
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

if CLIENT then
	if not RENDERER then
		RENDERER = ClientsideModel("models/props_junk/watermelon01.mdl")
		RENDERER:SetNoDraw(true)
	end

	local function SetModelScale(ent, scl)
		local mat = Matrix()
		mat:Scale(scl)
		ent:EnableMatrix("RenderMultiply", mat)
	end
	
	local shiny = Material("models/shiny")
	
	function phallusent( ent , length , owner )
		local m, pos, ang, scl

		length = (length or 0)+1

		scl = 2
		m = Matrix()
		pos = ent:GetPos()
		ang = ent:GetAngles()
		
		pos , ang = LocalToWorld( Vector( 0 , 0 , -25 ) , angle_zero , pos , ang )
		
		m:Translate(pos)
		m:Rotate(ang)
		m:Rotate(Angle(0,90,0))
		m:Translate(Vector(-3,8,-12))

		local r, g, b = 1, 0.8, 0.5
		local ctable = ent:GetColor()
		
		if ctable.r ~= 255 and ctable.g ~= 255 and ctable.b ~= 255 then
			r = ctable.r / 255
			g = ctable.g / 255
			b = ctable.b / 255
		end
		
		--[[
		if niggas[pl:GetModel()] then
		r, g, b = 0.4, 0.2, 0
		end
		]]

		----

		m:Translate(scl*Vector(0,-4,6))
		pos, ang = m:GetTranslation(), m:GetAngles()

		RENDERER:SetModel("models/dav0r/hoverball.mdl")
		RENDERER:SetRenderOrigin(pos)
		RENDERER:SetRenderAngles(ang)
		SetModelScale(RENDERER, scl*Vector(0.3,0.3,0.3))

		render.MaterialOverride(shiny)
		render.SetColorModulation(r, g, b)
		RENDERER:SetupBones()
		RENDERER:DrawModel()
		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride()

		----

		m:Translate(scl*Vector(3,0,0))
		pos, ang = m:GetTranslation(), m:GetAngles()

		RENDERER:SetModel("models/dav0r/hoverball.mdl")
		RENDERER:SetRenderOrigin(pos)
		RENDERER:SetRenderAngles(ang)
		SetModelScale(RENDERER, scl*Vector(0.3,0.3,0.3))


		render.MaterialOverride(shiny)
		render.SetColorModulation(r, g, b)
		RENDERER:SetupBones()
		RENDERER:DrawModel()
		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride()

		----

		m:Translate(scl*Vector(-1.5,0,1+2 * length))
		pos, ang = m:GetTranslation(), m:GetAngles()
		ang:RotateAroundAxis(ang:Forward(), 180)

		RENDERER:SetModel("models/props_c17/canister01a.mdl")
		RENDERER:SetRenderOrigin(pos)
		RENDERER:SetRenderAngles(ang)
		SetModelScale(RENDERER, scl*Vector(0.3,0.3,0.1 * length))


		render.MaterialOverride(shiny)
		render.SetColorModulation(r, g, b)
		if length < 0 then
		render.CullMode(MATERIAL_CULLMODE_CW)
		end
		RENDERER:SetupBones()
		RENDERER:DrawModel()
		if length < 0 then
		render.CullMode(MATERIAL_CULLMODE_CCW)
		end
		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride()

		----

		m:Translate(scl*Vector(0,0,3 * length))
		pos, ang = m:GetTranslation(), m:GetAngles()

		RENDERER:SetModel("models/dav0r/hoverball.mdl")
		RENDERER:SetRenderOrigin(pos)
		RENDERER:SetRenderAngles(ang)
		SetModelScale(RENDERER, scl*Vector(0.3,0.3,0.3))


		render.MaterialOverride(shiny)
		render.SetColorModulation(1, 0.4, 0.8)
		RENDERER:SetupBones()
		RENDERER:DrawModel()
		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride()

		RENDERER:DisableMatrix("RenderMultiply")
	end



end

function ENT:SetupDataTables()

end

function ENT:Initialize()

	if ( SERVER ) then
		
		self:SetUseType(SIMPLE_USE)

		self:SetModel("models/props_c17/canister01a.mdl")
		--models/props_junk/Shovel01a.mdl
		--self:SetModel("models/props_junk/Shovel01a.mdl")
		self:EnableCustomCollisions()
	
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self:MakePhysicsObjectAShadow( )
		
		if IsValid(self:GetOwner()) then
			self:GetOwner().__Dick=self
		end
		
		self:StartMotionController()
		hook.Add( "PlayerSpawn" , self , self.OnPlayerSpawn )
	else
		self:EnableCustomCollisions()
	end
	
end

if CLIENT then
	function ENT:Draw()
		phallusent( self , 4 , self:GetOwner() )
		--self:DrawModel()
	end
end

function ENT:OnPlayerSpawn( ply )
	if ply == self:GetOwner() and ply.__Dick == self then
		self:SetPos( ply:EyePos() )
	end
end

function ENT:EndTouch(ent)
	if not IsValid(self:GetOwner()) then return	end
	self:SetPhysicsAttacker(self:GetOwner())
	if ent:IsPlayer() or ent:IsNPC() then return end
	
	ent:SetPhysicsAttacker(self:GetOwner())
end

function ENT:PhysicsSimulate( phys, delta )
	local ply = self:GetOwner()
	
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	local coll = ply:GetMoveType() ~= MOVETYPE_NOCLIP
	
	if not ply:Alive() then
		coll = false
	end
	
	self:SetNoDraw( not coll )
	phys:EnableCollisions( coll )
	
	
	
	
	local pos = ply:EyePos()
	local ang = ply:EyeAngles()
	
	--[[
	local scl = 1
	local m = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Pelvis"))
	if not m then return end
	
	m:Translate(scl*Vector(0,-4,20))
	pos, ang = m:GetTranslation(), m:GetAngles()
	]]
	
	local extradick = 20
	local c = Vector( 50 , 0 , -25 )
	local v = Angle( 90 , 90 , 90 )
	
	if ply:KeyDown(IN_ATTACK) then
		c.x = c.x + extradick
	end
	
	if ply:KeyDown( IN_RELOAD ) then
		v.p = v.p + CurTime() * 120
	end
	
	pos , ang=LocalToWorld( c , v , pos , ang )
	
	
	
	--phys:SetPos(pos)
	--phys:SetAngles(ang)
	phys:Wake()

	phys:UpdateShadow(pos,ang,delta)
end

function ENT:UpdateSize()

end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:Think()
	if CLIENT then
		return
	end
	
	if IsValid( self:GetOwner() ) and self:GetOwner():IsPlayer() and self:GetOwner().__Dick == self then
		self:GetOwner():StripWeapons()
	end
	
	self:NextThink( CurTime() + 2 )
	return true
end

function ENT:OnRemove()

end


scripted_ents.Register(ENT,ClassName,true)