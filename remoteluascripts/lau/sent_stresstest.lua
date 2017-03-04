

local ClassName="sent_stresstest"
local ENT={}
ENT.Base             = "base_anim"
ENT.PrintName		= "A TEST"
ENT.Author			= "Jvs"
ENT.Information		= ""
ENT.Category		= "Fun + Games"

ENT.Spawnable			= true
ENT.AdminOnly			= true
ENT.RenderGroup 		= RENDERGROUP_BOTH

ENT.VarCount = 10

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

		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
		self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
	end
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_PVS
	end
	
	function ENT:Think()
		
		for i = 0 , self.VarCount do
			self:SetNW2Float( "penis_float"..i , math.cos( CurTime() * i ) * i )
			local ang = Angle( self:GetNW2Float( "penis_float"..i ) , self:GetNW2Float( "penis_float"..i ) , self:GetNW2Float( "penis_float"..i ) )
			self:SetNW2Angle( "penis_angle"..i , ang )
			local vec = Vector( 0 , 0 , 100	)
			vec:Rotate( ang )
			self:SetNW2Vector( "penis_vector"..i , vec )
			self:SetNW2Bool( "penis_bool"..i , self:GetNW2Bool( "penis_bool"..i ) == nil and false or not self:GetNW2Bool( "penis_bool"..i ) )
		end
		
		self:NextThink( CurTime() + engine.TickInterval() )
		return true
	end
else
	ENT.WireFrame = Material( "models/wireframe" )
	function ENT:Draw()

		self:DrawModel()
		for i = 0 , self.VarCount do
			local endpos = self:GetNW2Vector( "penis_vector"..i ) + self:GetPos()
			render.DrawLine( self:GetPos(), endpos , color_white, true )
			if self:GetNW2Bool( "penis_bool"..i) then
				render.SetMaterial( self.WireFrame )
				render.DrawSphere( endpos , 5 , 4 , 4 , color_white )
			end
		end
	end
end
scripted_ents.Register(ENT,ClassName,true)