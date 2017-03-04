--AddCSLuaFile()
local ClassName="sent_sphereshield"
local ENT={}

if SERVER then
	--resource.AddFile( "materials/entities/sent_sphereshield.png" )
end

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Sphere Shield"
ENT.Category		= "Fun + Games"
ENT.Author="Jvs"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Editable = true
ENT.TickRate = 0.1

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then return end

	local spawnpos = tr.HitPos + tr.HitNormal * 100

	local ent = ents.Create( ClassName )
	ent:SetPos( spawnpos )
	
	ent:Spawn()
	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float"	, 0 , "Radius" )	--the overall radius of the shield
	self:NetworkVar( "Float"	, 1 , "Energy" )	--the energy of the shield, will explode when reaches 0
	self:NetworkVar( "Float"	, 2 , "DepleteTime" ) --time in seconds that it takes to deplete the shield
	self:NetworkVar( "Float"	, 3 , "NextDeplete" )
	
	self:NetworkVar( "Int"		, 0 , "MaxEnergy" )
	self:NetworkVar( "Int"		, 1 , "MaxRadius" , { KeyName = "Radius", Edit = { type = "Float",min=50,max=1000, category = "Shield", order = 1 } } )
	
	self:NetworkVar( "Bool" 	, 0 , "Active" )
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/Items/combine_rifle_ammo01.mdl" )
		self:SetMaxEnergy( 100 )
		self:SetMaxRadius( 250 )
		self:SetColor( Color( 210 , 255 , 255 , 255 ) )
		self:SetRadius( 0 )
		self:SetEnergy( self:GetMaxEnergy() )
		self:SetDepleteTime( 60 )
		self:SetNextDeplete( CurTime() )
		self:SetLagCompensated( true )
		self:PhysicsInit( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_BBOX )
		self:SetTrigger( true )
		
		self:NetworkVarNotify( "Radius", self.OnRadiusChanged )
		self:NetworkVarNotify( "Active", self.OnActive )
		
		local physobj =  self:GetPhysicsObject() 
		
		if IsValid( physobj ) then
			physobj:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
			physobj:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
			physobj:Wake( )
		end
		
		self.ActiveAfter = -1
		--self.ActiveAfter = CurTime() + 2
		self.ChosenPos = nil
	end
	
	self:EnableCustomCollisions()

end

function ENT:Use( act )
	if not self:GetActive() then
		self:SetActive( true )
	end
end

function ENT:GetMinBounds()
	return Vector(self:GetRadius(),self:GetRadius(),self:GetRadius()) * -1
end

function ENT:GetMaxBounds()
	return Vector(self:GetRadius(),self:GetRadius(),self:GetRadius())
end

function ENT:StartTouch( ent )
end

function ENT:PhysicsUpdate( physobj )
	if not SERVER then return end
	
	if self.ChosenPos and self:GetActive() then
		physobj:EnableCollisions( false )
		physobj:SetPos( self.ChosenPos , true )
		physobj:SetAngles( angle_zero )
	end
	
end

function ENT:PhysicsCollide( event , physobj )
	if not SERVER then return end
	
	if not self:GetActive() and self.ActiveAfter == -1 then
		if event.HitEntity == game.GetWorld() then
			self.ActiveAfter = CurTime()
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
	if not self:GetActive() then return end
	local newenergy = math.Clamp( self:GetEnergy() - dmginfo:GetDamage() / 10, 0 , self:GetMaxEnergy() )
	
	self:SetEnergy( newenergy )
	self:EmitSound( "NPC_CombineBall.Impact" )
end

function ENT:Think()
	if not self:GetActive() then 
		if SERVER then
			if self.ActiveAfter <= CurTime() and self.ActiveAfter ~= -1 then
				self:SetActive( true )
			end
		end
		return 
	end
	
	
	self:SetCollisionBounds( self:GetMinBounds(), self:GetMaxBounds() )
	
	if CLIENT then
		self:SetRenderBounds( self:GetMinBounds(), self:GetMaxBounds() )
		self:SetNextClientThink( CurTime() + 0.1 )
		return
	else
		
		if self:GetDepleteTime()~= -1 and self:GetNextDeplete() < CurTime() and self:GetEnergy() > 0 then
			local charge = self:GetMaxEnergy()  / ( self:GetDepleteTime() / self.TickRate )
			local amount = math.Clamp( self:GetEnergy() - charge , 0 , self:GetMaxEnergy() )
			
			self:SetEnergy( amount )
			self:SetNextDeplete( CurTime() + self.TickRate )
		end
		
		if self:GetEnergy() <= 0 then
			local charge = self:GetMaxRadius()  / ( self:GetDepleteTime() / 5 / self.TickRate )
			local amount = math.Clamp( self:GetRadius() - charge , 0 , self:GetMaxRadius() )
			
			self:SetRadius( amount )
			self:SetNextDeplete( CurTime() + self.TickRate )
		end
		
		if self:GetEnergy() <= 0 and self:GetRadius() <= 0 then
			self:EmitSound( "NPC_CombineBall.Explosion" )
			self:Remove()
			self:NextThink( math.huge )
			return
		end
		
		self:NextThink( CurTime() + 0.1 )
		return
	end
end

function ENT:OnRadiusChanged( varname, oldvalue, newvalue )
	if not self:GetActive() then return end
	self:SetCollisionBounds( self:GetMinBounds(), self:GetMaxBounds() )
	self:SetSolid( SOLID_BBOX )
end

function ENT:OnActive( varname, oldvalue, newvalue )
	if not newvalue then return end
	
	self:SetCollisionBounds( self:GetMinBounds(), self:GetMaxBounds() )
	self:SetRadius( self:GetMaxRadius() )
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_CUSTOM )
	self.ChosenPos = self:GetPos()
end



function ENT:CanTracePass( startpos , direction )
	local distance = (startpos - self:GetPos() ):Length()
	return distance <= self:GetRadius()
end

local function IntersectInfiniteRayWithSphere( vecRayOrigin , vecRayDelta , vecSphereCenter , flRadius )
	local vecSphereToRay = vecRayOrigin - vecSphereCenter

	local a = vecRayDelta:DotProduct( vecRayDelta )
	local pT1 , pT2 = 0 , 0
	-- This would occur in the case of a zero-length ray
	if a == 0 then
		return vecSphereToRay:LengthSqr() <= flRadius * flRadius
	end

	local b = 2 * vecSphereToRay:DotProduct( vecRayDelta )
	local c = vecSphereToRay:DotProduct( vecSphereToRay ) - flRadius * flRadius
	local flDiscrim = b * b - 4 * a * c
   
	if flDiscrim < 0 then
		return false
	end
   
	flDiscrim = math.sqrt( flDiscrim )
	local oo2a = 0.5 / a
	pT1 = ( - b - flDiscrim ) * oo2a
	pT2 = ( - b + flDiscrim ) * oo2a
	return true , pT1 , pT2
end
 
local function IsRayIntersectingSphere( vecRayOrigin, vecRayDelta, vecCenter, flRadius, flTolerance )
	flRadius = flRadius + flTolerance

	local vecRayToSphere =  vecCenter - vecRayOrigin
	local flNumerator = vecRayToSphere:DotProduct( vecRayDelta )
   
	local t
	if flNumerator <= 0 then
		t = 0
	else
		local flDenominator = vecRayDelta:DotProduct( vecRayDelta )
		if flNumerator > flDenominator then
			t = 1
		else
			t = flNumerator / flDenominator
		end
	end
   
	local vecClosestPoint = vecRayOrigin + vecRayDelta * t
	return vecClosestPoint:DistToSqr( vecCenter ) <= flRadius * flRadius
end

--anything bigger than this is allowed to pass
ENT.HullTraceMinSizeAllowed = 10

function ENT:TestCollision( startpos, direction, isbox, extents )
	if not self:GetActive() then return end

	
	if not isbox then
		if not IsRayIntersectingSphere( startpos , direction , self:GetPos() , self:GetRadius() , 1 ) then
			return
		end
	else
		if extents.x >= self.HullTraceMinSizeAllowed and
		extents.y >= self.HullTraceMinSizeAllowed and
		extents.z >= self.HullTraceMinSizeAllowed then
			return
		end
	end
	
		
	if self:CanTracePass( startpos , direction ) then
		return
	end

	local hit ,hitpos1 , hitpos2 = IntersectInfiniteRayWithSphere( startpos , direction , self:GetPos() , self:GetRadius() )
	
	local hitpos = startpos + direction * hitpos1
	local normal = ( self:GetPos() - hitpos ):GetNormal() * -1
	
	return 
	{ 
		HitPos		= hitpos,
		Fraction	= hitpos1,
		Normal = normal,
	}
	
end

function ENT:ImpactTrace( traceResult, damageType, customImpactName )
	if not self:GetActive() then return end
	
	--debugoverlay.Cross( traceResult.HitPos , 16 ,  1 , color_white , true)
	local e = EffectData()
	
	e:SetOrigin( traceResult.HitPos + traceResult.HitNormal )
	e:SetNormal( traceResult.HitNormal )
	e:SetRadius( 3 )
	
	util.Effect( "cball_bounce" , e )
	--util.Effect( "AR2Impact", e )
	return true
end

local proxyent = nil

if CLIENT then
	
	matproxy.Add( {
		name = "ShieldProxy",

		init = function( self, mat, values )
			-- Store the name of the variable we want to set
			self.ResultTo = values.resultvar
		end,

		bind = function( self, mat, ent )
			if not IsValid( proxyent ) then return end
			
			render.UpdateRefractTexture()
			if ( proxyent.GetPlayerColor ) then
				local col = proxyent:GetPlayerColor()
				if ( isvector( col ) ) then
					mat:SetVector( self.ResultTo, col )
				end
			end
		end 
	} )

	--ENT.Mat = Material("models/props_combine/portalball001_sheet")
	ENT.FallbackMat = Material( "models/props_combine/stasisshield_sheet" )
	
	
	ENT.Mat = CreateMaterial("SphereShieldEffectdicks5",
		"Refract",{
			[ "$model" ] = "1",
			[ "$nocull" ] = "1",
			
			[ "$translucent" ] = "1",
			[ "$refractamount" ] = "0.1",
			[ "$refracttint" ] = "[0.7 1 1]",
			
			[ "$dudvmap" ] = "dev/water_dudv",
			[ "$normalmap" ] = "dev/water_normal",
			
			[ "$surfaceprop" ] = "water",
			[ "$bumpframe" ] = "0",
			[ "Proxies"] = {
				[ "ShieldProxy" ] = {
					[ "resultVar" ]	= "$refracttint",
					[ "default"]	=	"0.1 0.1 0.1",
				},
			}
			
		}
	)
	
	ENT.CBallMats = {
		
	}
	
end

function ENT:Draw( flags )
	if not self:GetActive() then
		self:DrawModel()
	end
end

function ENT:GetPlayerColor()
	local col = self:GetColor()
	col = Vector( col.r , col.g , col.b ) / 255
	return col
end

function ENT:DrawTranslucent()
	if self:GetRadius() <= 0 then return end
	
	--HAX: there's no way to set this from the DrawSphere!
	
	proxyent = self
	
	local fuckoffshader = false
	
	if render.GetDXLevel() < 9 or not render.SupportsPixelShaders_1_4() or fuckoffshader then
		
		render.SetMaterial( self.FallbackMat )
	else
		
		render.SetMaterial( self.Mat )
	end
	
	render.UpdateRefractTexture()
	
	render.DrawSphere( self:GetPos() , self:GetRadius() , 32 , 32 , col )
	
	proxyent = nil
end

local function pickupallowed( ply ,ent )
	if IsValid( ent ) and ent:GetClass() == "sent_sphereshield" then return false end
end

hook.Remove( "PhysgunPickup" , "sent_sphereshield" , pickupallowed )
hook.Add( "GravGunPickupAllowed" , "sent_sphereshield" , pickupallowed )

scripted_ents.Register(ENT,ClassName,true)
