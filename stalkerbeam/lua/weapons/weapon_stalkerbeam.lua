AddCSLuaFile()

if SERVER then
	resource.AddFile("materials/entities/weapon_stalkerbeam.png")
	resource.AddFile("materials/hud/killicons/weapon_stalkerbeam.vmt")
end

DEFINE_BASECLASS( "weapon_base" )
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Stalker Beam"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 54
	SWEP.SwayScale			= 0					-- The scale of the viewmodel sway
	SWEP.BobScale			= 0					-- The scale of the viewmodel bob
	
	SWEP.Contact		= "jvs_34@yahoo.it"
	SWEP.Purpose		= "Damage anything! Stalker...style?"
	SWEP.Instructions	= "Primary: Stalker Beam. Secondary:Upgrade"
	SWEP.RenderGroup 		= RENDERGROUP_TRANSLUCENT
	local laser = CreateMaterial("sprites/laserbeamnew",
            "UnlitGeneric",{
				['$basetexture' ] = "sprites/laser",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
	local colbeam={Color(255, 0, 0,255),Color(255, 50, 0,255),Color(255, 150, 0,255)}
	local sprite={
		CreateMaterial("sprites/redglow1stalker",
				"UnlitGeneric",
				{
					['$basetexture' ] = "sprites/redglow1",
					[ '$additive' ] = "1",
					[ '$vertexcolor' ] = "1",
					[ '$vertexalpha' ] = "1",
				}
		),
		CreateMaterial("sprites/orangeglow1stalker",
				"UnlitGeneric",{
					['$basetexture' ] = "sprites/orangeglow1",
					[ '$additive' ] = "1",
					[ '$vertexcolor' ] = "1",
					[ '$vertexalpha' ] = "1",
				}
		),
		CreateMaterial("sprites/yellowglow1stalker",
				"UnlitGeneric",{
					['$basetexture' ] = "sprites/yellowglow1",
					[ '$additive' ] = "1",
					[ '$vertexcolor' ] = "1",
					[ '$vertexalpha' ] = "1",
				}
		)
	}
	
	
	function SWEP:ViewModelDrawn( vm )
		if not self:GetAttacking() then return end
		self:DrawBeamAndSprites( true )
	end

	function SWEP:DrawWorldModelTranslucent()
		if not self:GetAttacking() then return end
		
		self:DrawBeamAndSprites( false )
	end
	
	function SWEP:DrawBeamAndSprites( isfirstperson )
		local traceres = self:DoBeamTrace()
		
		local StartPos = vector_origin
		
		if isfirstperson then
			StartPos , _ = LocalToWorld( Vector( 0 , 0 , 4 ) , angle_zero , self.Owner:EyePos() , self.Owner:EyeAngles() )
		else
			local atch = self.Owner:LookupAttachment("eyes")
			if atch then
				StartPos = LocalToWorld( Vector( 0 , 0 , 4 ) , angle_zero , self.Owner:GetAttachment( atch ).Pos , self.Owner:GetAttachment( atch ).Ang )
			else
				--fallback in case we don't find the attachment on this model
				StartPos = LocalToWorld( Vector( 0 , 0 , 4 ) , angle_zero , self.Owner:EyePos() , self.Owner:EyeAngles() )
			end
		end

		render.SetMaterial( laser )
		render.DrawBeam( StartPos,traceres.HitPos, 2, 0, 0, colbeam[self:GetPower()] )

		render.SetMaterial( sprite[self:GetPower()] )
		render.DrawSprite( StartPos ,76.8, 76.8, colbeam[self:GetPower()] )
		render.DrawSprite( StartPos ,16,16, colbeam[self:GetPower()] )
		render.DrawSprite( traceres.HitPos ,10,10, colbeam[self:GetPower()] )
		self:CreateLight( StartPos ,100,0)
		self:CreateLight( traceres.HitPos ,50,1)
	end
	
	function SWEP:CreateLight(pos,size,numb)
		local dlight = DynamicLight( self:EntIndex() + numb )
		if ( dlight ) then
			local tab = colbeam[self:GetPower()]
			dlight.r = tab.r
			dlight.g = tab.g
			dlight.b = tab.b
		
			dlight.Pos =  pos
			dlight.Brightness = 4
			dlight.Size =size
			dlight.Decay = size
			dlight.DieTime = CurTime() + 0.1
		end
	end
	
	function SWEP:DrawWorldModel()

	end
	
	killicon.Add( "weapon_stalkerbeam" , "hud/killicons/weapon_stalkerbeam", color_white )
end

SWEP.Category				= "Jvs" 
SWEP.Slot					= 3
SWEP.SlotPos				= 5
SWEP.Weight					= 5
SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel 				= "models/effects/teleporttrail_alyx.mdl"
SWEP.WorldModel 			= "models/effects/teleporttrail_alyx.mdl"

SWEP.Range					= 3600 * 12--because it's in feet,we convert it.
SWEP.BeamDamage = { 1 , 3 , 10 }
SWEP.DamageDelay			= 0.1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo 		= false
SWEP.Primary.Automatic 	= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo 		= false
SWEP.Secondary.Automatic 	= false

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	
	if SERVER then
		self:SetAttackTime( CurTime() )
		self:SetPower( 1 )
		self:SetAttacking( false )
		self:SetNextScream( CurTime() )
	end	
end 

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool" , 0 , "Attacking" )
	self:NetworkVar( "Int" , 0 , "Power" )
	self:NetworkVar( "Float" , 0 , "AttackTime" )
	self:NetworkVar( "Float" , 1 , "NextDecal" )
	self:NetworkVar( "Float" , 2 , "NextScream" )
	
	self:NetworkVar( "Entity" , 0 , "BeamEnd" )
end

function SWEP:Shoot()
	self.Owner:LagCompensation( true )
	local traceres = self:DoBeamTrace()
	self.Owner:LagCompensation( false )
	
	if SERVER and IsValid( traceres.Entity ) then
		local DMG = DamageInfo()
		DMG:SetDamageType(DMG_SHOCK)		
		DMG:SetDamage(self.BeamDamage[self:GetPower()] or 1 )
		DMG:SetAttacker(self.Owner)
		DMG:SetInflictor(self)
		DMG:SetDamagePosition(traceres.HitPos)
		DMG:SetDamageForce(self.Owner:GetAimVector()*3500*self:GetPower())
		traceres.Entity:TakeDamageInfo(DMG)
	end
end
function SWEP:Holster( wep )
	if SERVER then
		self:DestroyEndPos()
	end
	return true
end

function SWEP:OnRemove()
	if not SERVER then return end 
	self:DestroyEndPos()
end


function SWEP:Deploy()
	self.m_WeaponDeploySpeed=1
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:Beam(bool)
	self:SetAttacking( bool )
	if SERVER then
		if IsValid( self:GetBeamEnd() ) then
			self:GetBeamEnd():SetActive( bool )
		end
	end
end

function SWEP:CreateEndPos()
	if not IsValid( self:GetBeamEnd() ) and SERVER then
		self:SetBeamEnd( ents.Create("sb_controller") )
		self:GetBeamEnd():SetOwner(self.Owner)
		self:GetBeamEnd():SetPos(Vector(0,0,0))
		self:GetBeamEnd():Spawn()
	end
end

function SWEP:DestroyEndPos()
	if IsValid( self:GetBeamEnd() )then
		self:GetBeamEnd():SetActive( false )
		self:GetBeamEnd():Remove()
		self:SetBeamEnd( NULL )
	end
end

function SWEP:UpdateSoundPos()
	self:CreateEndPos()
	if SERVER and IsValid( self:GetBeamEnd() ) then
		
		local traceres = self:DoBeamTrace()
		self:GetBeamEnd():SetPos( traceres.HitPos )
		
		local hit = false
		if traceres.Hit then
			local hitent = traceres.Entity
			
			if IsValid( hitent ) then
				local bloodcolor = hitent:GetBloodColor()
				if bloodcolor and bloodcolor ~= DONT_BLEED and bloodcolor ~= BLOOD_COLOR_MECH then
					hit = true
				end
			end
		end
		
		if hit then
			self:GetBeamEnd():SetSoundMode( 2 )
			self:GetBeamEnd():SetPitch( 100 + math.random(1,2) )
		else
			self:GetBeamEnd():SetSoundMode( 1 )
			self:GetBeamEnd():SetPitch( 100 + ( 10 * ( self:GetPower() - 1 ) ) + math.random(1,2) )
		end
	end
end

function SWEP:Upgrade()
	if self:GetPower()<3 then
		self:SetPower( self:GetPower() + 1 )
	end
end

function SWEP:BeamDecal()
	local traceres = self:DoBeamTrace()
	if traceres.HitWorld and not traceres.HitSky then
		local Pos1 = traceres.HitPos + traceres.HitNormal
		local Pos2 = traceres.HitPos - traceres.HitNormal
		util.Decal("FadingScorch" ,Pos1,Pos2)
	end
end

function SWEP:Think()
	if self.Owner:KeyDown( IN_ATTACK ) and not self.Owner:KeyDown(IN_ZOOM) and self:HasPrimaryAmmo() then
		self:Beam(true)
		self:UpdateSoundPos()
		
		if self:GetNextDecal() < CurTime() then
			self:BeamDecal()
			self:SetNextDecal( CurTime() + 0.1 )
		end
		
		if self:GetAttackTime() < CurTime() then
			self:Shoot()
			self:EatAmmo()
			self:SetAttackTime( CurTime() + self.DamageDelay )
		end
	else
		self:Beam( false )
	end
	
	self:NextThink( CurTime() + 0.1 )
	return true
end

function SWEP:DoBeamTrace()
	local tr = {}
	tr.start = self.Owner:EyePos()
	tr.endpos = tr.start + self.Owner:EyeAngles():Forward() * self.Range
	tr.mask = MASK_SHOT
	tr.filter = {
		self.Owner,
		self,
		self:GetBeamEnd()
	}
	return util.TraceLine( tr )
end

function SWEP:HasPrimaryAmmo()
	return true	--we will always return true on this side,the other weapon will return true if it has enough ammo
end

function SWEP:EatAmmo()
	--self:TakePrimaryAmmo(1)
end

function SWEP:CanUpgrade()
	return true	--we will always return true on this side,the other weapon will return true if it has enough ammo
end

function SWEP:UpgradeAmmo()

end

function SWEP:OnDrop()
	self:DestroyEndPos()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
	if self:GetNextScream() < CurTime() and self:GetPower() < 3 and self:CanUpgrade() then
		self:Upgrade()
		self:UpgradeAmmo()
		self:EmitSound("d3_citadel.stalker_shriek1")
		self:SetNextScream( CurTime() + 3 ) --SoundDuration("d3_citadel.stalker_shriek1")
	end
end

function SWEP:Reload()end