

hook.Add("ShouldCollide","PhysicsBones",function(ent1,ent2)
	if not IsValid(ent1) or not IsValid(ent2) then return end
	
	if ent1:GetOwner() == ent2:GetOwner() then return false end
	
	if ent2:IsVehicle() then return false end

end)

if SERVER then
	concommand.Add("givemebones", function(ply,command,args)
		if not IsValid(ply) then return end

		for i=0,ply:GetHitBoxCount(0)-1 do
			local bone = ply:GetHitBoxBone(i ,0)
			local bm = ply:GetBoneMatrix( bone )
			if bm then
				
				local minb,maxb = ply:GetHitBoxBounds( i, 0 )
				
				local boneshadow = ents.Create("sent_ply_boneshadow")
				--should we set these as lag compensated? they are ignored by traces anyway
				--there wouldn't be much point in it unless we just want to move with the player

				boneshadow:SetPos(bm:GetTranslation())
				boneshadow:SetAngles(bm:GetAngles())
				boneshadow:SetParentedBone(bone)
				boneshadow:SetMinBounds(minb * ply:GetModelScale())
				boneshadow:SetMaxBounds(maxb * ply:GetModelScale())
				boneshadow:SetOwner( ply )
				boneshadow:Spawn()
				
			end
		end
		
	end)
end

local ENT={}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.Author="Jvs"

function ENT:Initialize()
	--this can only work shared if we use setupbones everytime we want to access the player's bones!
	--but since it's being called individually from EACH bone entity, this is a no-no, so maybe we should compute all the physics
	--on a controller instead, and call setupbones clientside once before accessing that bonedata
	
	--or maybe we can just run this shit shared on Move with FrameTime() as the delta like I do in cl_playerphys
	
	if SERVER then
		self:SetCollisionBounds( self:GetMinSize() , self:GetMaxSize() )
		self:PhysicsInitBox( self:GetMinSize() , self:GetMaxSize() )
		self:MakePhysicsObjectAShadow( false, false )
		
		self:StartMotionController()
		self:SetCustomCollisionCheck( true )
		self:EnableCustomCollisions( true )
		self:GetPhysicsObject():SetMass(70)
		self:GetPhysicsObject():SetMaterial( "gmod_silent" )
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"ParentedBone")
	self:NetworkVar("Vector",0,"MinBounds")
	self:NetworkVar("Vector",1,"MaxBounds")
end

function ENT:GetMinSize()
	return self:GetMinBounds()
end

function ENT:GetMaxSize()
	return self:GetMaxBounds()
end

function ENT:PhysicsSimulate( phys, delta )

	if not IsValid(self:GetOwner()) or self:GetOwner():GetObserverMode()~=0 or not self:GetOwner():Alive() then return SIM_NONE end
	
	
	local bm = self:GetOwner():GetBoneMatrix( self:GetParentedBone() )
	
	if not bm then return end
	
	phys:EnableCollisions( self:GetOwner():GetMoveType() ~=MOVETYPE_NOCLIP )
	
	phys:UpdateShadow(bm:GetTranslation(),bm:GetAngles(),delta)
	
	
	local mypos = phys:GetPos()
	--this avoids the physobj staying behind stilll colliding with shit while the player either noclipped or modified his bones and shit somehow
	if math.abs((mypos - bm:GetTranslation()):Length()) > 50 then
		phys:SetPos(bm:GetTranslation(),true)
	end
	return SIM_NONE
end

function ENT:TestCollision( startpos, delta, isbox, extents )
	return
end

local wireframe = Material("models/wireframe")

function ENT:Draw()
	local cmin,cmax = self:GetCollisionBounds()
	
	render.SetMaterial(wireframe)
	render.DrawBox( self:GetPos(), self:GetAngles(), cmin, cmax, color_white, true )
	
end

function ENT:Think()
	if CLIENT then
		self:SetRenderBounds( self:GetMinSize() , self:GetMaxSize() )
	end
	
	self:PhysWake()	--never go to sleep! sleep is for weaklings, and faggots, like vinh
end

scripted_ents.Register(ENT,"sent_ply_boneshadow",true)