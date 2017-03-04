local ENT = {}
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Wheel test"
ENT.Author            = "Jvs"
ENT.Information        = ""
ENT.Category        = "Other"
ENT.Spawnable            = true
ENT.AdminOnly        = true

function ENT:SpawnFunction( ply, tr )
    if ( not tr.Hit ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 40
    
    local ent = ents.Create( "sent_wheelshit" )
    ent:SetPos( SpawnPos )
    ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/xeon133/offroad/off-road-80.mdl" )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:PhysWake()
		self:StartMotionController( true )
	end
end

function ENT:SetupDataTables()

end

function ENT:Think()

end

function ENT:OnRemove()

end

if SERVER then
	
	function ENT:OnTakeDamage(dmgfo)

	end


	function ENT:PhysicsSimulate( phys, deltaTime )
		phys:Wake()
		
		local angledirection = Vector( 1000 , 0 , 0 ) * phys:GetMass()
		local direction = Vector( 0 , 0 , 0 )

		return angledirection , direction , SIM_LOCAL_FORCE 
	end



	function ENT:PhysicsCollide( data, physobj )

	end
else
	
	function ENT:Draw()

		self:DrawModel()
	end

end

scripted_ents.Register(ENT,"sent_wheelshit",true)