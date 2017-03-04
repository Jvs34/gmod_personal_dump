if SERVER then return end

for i,ply in pairs(player.GetAll()) do
	if IsValid(ply._FakePhysics) then
		ply._FakePhysics:Remove()
	end
end


local cl_debug_playerphys = CreateClientConVar( "cl_debug_playerphys", 0, true, true )


local function InitPhysics(ply,ent)
	ent:SetRenderBounds( ply:OBBMins(), ply:OBBMaxs() )
	ent:SetCollisionBounds( ply:OBBMins() , ply:OBBMaxs() )
	ent:PhysicsInitBox( ply:OBBMins() , ply:OBBMaxs() )
	ent:MakePhysicsObjectAShadow( false, false )
	
	local physobj = ent:GetPhysicsObject()
	
	physobj:SetMass(85)
	physobj:SetMaterial( "player" )
	physobj:SetDragCoefficient( 0 )
	physobj:SetInertia( Vector( 1, 1, 1 ) )
	physobj:SetDamping( 0.1, 0.1 )

end
local wireframe = Material("models/wireframe")

local function HandlePlayerPhysics(ply)
	if not IsValid(ply._FakePhysics) then
		ply._FakePhysics = ClientsideModel("models/Gibs/HGIBS.mdl")
		
		ply._FakePhysics.RenderOverride = function(self) 
			if cl_debug_playerphys:GetBool() then
				local cmin,cmax = self:GetCollisionBounds()
			
				render.SetMaterial(wireframe)
				render.DrawBox( self:GetPos(), self:GetAngles(), cmin, cmax, color_white, true )
			end
		end
		
		ply._FakePhysics:SetOwner(ply)
		--override the garbage collector? no need to, it already has that defined																										
		
	end
	
	--this way if LastPlayerCrouch is nil it will initialize the physobj the first time, ingenious, I know
	if ply._FakePhysics.LastPlayerCrouch ~= ply:Crouching() then
		ply._FakePhysics.LastPlayerCrouch = ply:Crouching()
		
		InitPhysics(ply,ply._FakePhysics)
	end
	
	--this check is not needed but HEY you never know with this kind of hacky shit
	if IsValid(ply._FakePhysics:GetPhysicsObject()) then
		ply._FakePhysics:GetPhysicsObject():UpdateShadow(ply:GetPos(),angle_zero,FrameTime())
		local mypos = ply._FakePhysics:GetPhysicsObject():GetPos()
		
		--obviously, our fake physics controller can't go everywhere like we do, so teleport it if it goes too far away
		
		if math.abs((mypos - ply:GetPos()):Length()) > 50 then
			ply._FakePhysics:GetPhysicsObject():SetPos(ply:GetPos(),true)
		end
	
	end
	
	
end


if game.SinglePlayer() then
	hook.Add("Think","HandlePlayerPhysics",function()
		HandlePlayerPhysics(LocalPlayer())
	end)
else
	hook.Add("PrePlayerDraw","HandlePlayerPhysics",function(ply)
		if ply ~= LocalPlayer() then
			HandlePlayerPhysics( ply )
		end
	end)
	
	hook.Add("Move","HandlePlayerPhysics",function(ply,mv)
		HandlePlayerPhysics( ply )
	end)

end
