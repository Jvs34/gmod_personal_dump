local SWEP={}

SWEP.Base = "weapon_base"
SWEP.Author			= "Jvs"
SWEP.UseHands			= true

SWEP.ViewModel			= "models/player/breen.mdl"
SWEP.WorldModel			= "models/tools/camera/camera.mdl"

SWEP.ViewModelFOV		= 90
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Jvs' tv camera"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.Spawnable            = true
SWEP.AdminOnly        = true

if CLIENT then
	SWEP.RenderGroup = RENDERGROUP_TRANSLUCENT
	function SWEP:ViewModelDrawn()
        self:DrawEffects(true,true)
    end
    
	function SWEP:CreateCamera()
		if IsValid(self.Camera) then return end
		timer.Simple(0,function()
			if not IsValid(self) or IsValid(self.Camera) then return end
			self.Camera=ClientsideModel(self.WorldModel)
			self.Camera:SetNoDraw(true)
			self.Camera:Spawn()
		end)
	end
	
    function SWEP:DrawWorldModelTranslucent()
        self:DrawEffects(false)
    end
	
	function SWEP:DrawWorldModel()
       --self:DrawEffects(false,false)
    end
	
	SWEP.InvisMat="engine/occlusionproxy"
    
	SWEP.GlowMat = CreateMaterial("sprites/orangecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/orangecore1",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
	
	SWEP.GlowColor = Color(255,0,0,255)

	
	function SWEP:DrawHUD()

	end
	
	
	local camposoffset=Vector(5,-1,-6.7)
	local camangoffset=Angle(25,0,180)
	
	local glowoffset=Vector(1.5,3,-2)
	local glowangoff=Angle(0,0,0)
	function SWEP:DrawEffects(view_or_world,translucent)
		self:CreateCamera()
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and self.Owner:GetViewModel() or self.Owner
		if not IsValid(self.Camera) then return end
		local bonematrix=ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld( camposoffset,camangoffset, bonematrix:GetTranslation(), bonematrix:GetAngles() )
		self.Camera:SetRenderOrigin(pos)
		self.Camera:SetRenderAngles(ang)
		self.Camera:DrawModel()
		if self:GetRecording() then
			render.SetMaterial(self.GlowMat)
			pos,ang=LocalToWorld( glowoffset,camangoffset, pos, ang )
		
			render.DrawSprite( pos, 4, 4, self.GlowColor)
		end
		
		
		
	end
	
		
	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( self.InvisMat )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()

	end
	
	function SWEP:GetViewModelPosition(pos,ang)
		pos = pos-60*ang:Up()
		pos = pos-2*ang:Right()
		pos = pos-7*ang:Forward()
		--ang:RotateAroundAxis(ang:Right(), 10)
		--return Vector(),Angle()
		return pos,ang
	end
	
	function SWEP:AdjustMouseSensitivity()

		if ( self.Owner:KeyDown( IN_ATTACK2 )  ) then return 1 end

		return 1 * ( self:GetZoom() / 80 )
	
	end
	
	
	function SWEP:FreezeMovement()

		-- Don't aim if we're holding the right mouse button
		if ( self.Owner:KeyDown( IN_ATTACK2 ) || self.Owner:KeyReleased( IN_ATTACK2 ) ) then 
			return true 
		end

		return false
	
	end
	
	
end
	

function SWEP:Initialize()

	self:SetWeaponHoldType( "rpg" )

end


function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "Zoom" )
	self:NetworkVar( "Bool", 0, "Recording" )
	if ( SERVER ) then
		self:SetZoom( 75 )
		self:SetRecording(false)
	end
end


SWEP.ShootSound				= "NPC_CScanner.TakePhoto"

function SWEP:PrimaryAttack()
	self:EmitSound(self.ShootSound)
	self:SetRecording(not self:GetRecording())
	self:SetNextPrimaryFire(CurTime()+1)
end

function SWEP:Reload()
	self:SetZoom( 75 )
end


function SWEP:SecondaryAttack() end

function SWEP:DoZoomThink( cmd, fDelta )

	-- Right held down
	if ( not cmd:KeyDown( IN_ATTACK2 ) ) then return end
	
	self:SetZoom( math.Clamp( self:GetZoom() + cmd:GetMouseY() * 2 * fDelta, 5, 75 ) )

end

function SWEP:Think() end

function SWEP:Tick()

	local cmd = self.Owner:GetCurrentCommand()
	
	local fDelta = 0.05

	self:DoZoomThink( cmd, fDelta )

end



function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "walk_rpg" ) )
	
	return true
end

weapons.Register(SWEP,"weapon_jvs_tvcamera")