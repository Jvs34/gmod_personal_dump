local SWEP={}

SWEP.Base = "weapon_base"
SWEP.Author			= "Jvs"
SWEP.UseHands			= true

SWEP.ViewModel			= "models/player/breen.mdl"
SWEP.WorldModel			= "models/maxofs2d/camera.mdl"

SWEP.ViewModelFOV		= 90
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Jvs camera"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.Spawnable            = true
SWEP.AdminOnly        = true
	
if CLIENT then
    local da_centerglow = CreateMaterial("sprites/orangecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/orangecore1",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
	function SWEP:ViewModelDrawn()
        self:DrawEffects(true)
    end
    
	function SWEP:CreateCamera()
		if IsValid(self.Camera) then return end
		timer.Simple(0,function()
			if not IsValid(self) or IsValid(self.Camera) then return end
			self.Camera=ClientsideModel(self.WorldModel)
			self.Camera:SetNoDraw(true)
			self.Camera:AddEffects(EF_BONEMERGE)
			self.Camera:SetParent(self.Owner:GetViewModel())
			self.Camera:Spawn()
		end)
	end
	
    function SWEP:DrawWorldModel()
        self:DrawEffects(false)
    end
	
	
	local mat2=Material("models/debug/debugwhite")
	SWEP.InvisMat="engine/occlusionproxy"
	local cameramat = CreateMaterial(
        "CameraMat",
        "UnlitGeneric",
        {
            [ '$basetexture' ] = camerart,
        }
    )
	
	SWEP.GlowMat=Material("effects/blueflare1")

	SWEP.view = {}
	SWEP.view.x = 0
	SWEP.view.y = 0
	SWEP.view.scale=1
	SWEP.view.w = ScrW()/4
	SWEP.view.h = ScrH()/4
	SWEP.view.nearz=0.1
	SWEP.view.farz=50
	SWEP.view.fov=90
	SWEP.view.drawhud = false
	SWEP.view.drawviewmodel = false
	local camerart = GetRenderTarget( "JvsCameraRt", ScrW()/4, ScrH()/4, false )
	
	
	function SWEP:DrawHUD()

	end
	
	hook.Add( "RenderScene", "JvsCameraRTDraw", function( Origin, Angles )
		
		if not IsValid(LocalPlayer()) or not IsValid(LocalPlayer():GetActiveWeapon()) then return end
		local wep=LocalPlayer():GetActiveWeapon()
		if not wep.view then return end
	
		wep.view.origin = LocalPlayer():EyePos()
		wep.view.angles = LocalPlayer():EyeAngles()
		wep.view.fov=wep:GetZoom()
		cameramat:SetTexture( "$basetexture", camerart )
		local oldrt = render.GetRenderTarget()
		render.SetRenderTarget( camerart )
			render.Clear( 0, 0, 0, 255, true )
			render.ClearDepth()
			render.ClearStencil()
			render.RenderView( wep.view )
		render.SetRenderTarget( oldrt )
		
	end )
	
	local camposoffset=Vector(-1.5,-3,3.75)
	local camangoffset=Angle(0,0.5,0)
	function SWEP:DrawEffects(view_or_world)
		self:CreateCamera()
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and self.Camera or self
		if not IsValid(self.Camera) then return end
		self.Camera:SetParent(self.Owner:GetViewModel())
		local atch=ent:GetAttachment(1)
		if not atch then return end
		local pos,ang=LocalToWorld( camposoffset,camangoffset, atch.Pos, atch.Ang )
		if view_or_world then
			self.Camera:DrawModel()
			
			cam.Start3D2D(pos,ang,0.2)
			--cam.IgnoreZ(false)	
				surface.SetMaterial(cameramat)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(0,0,15,11)
			--cam.IgnoreZ(true)
			cam.End3D2D( )
			
		else
			self:DrawModel()
		end
		
			render.SetMaterial(self.GlowMat)
			render.DrawSprite( atch.Pos, 8, 8, color_white)
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
		pos = pos+0.3*ang:Right()
		pos = pos-3*ang:Forward()
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
	
	local EFFECT={}
	function EFFECT:Init( data )
		
		local vOffset = data:GetOrigin()
		local ent = data:GetEntity()
		
		local dlight = DynamicLight( ent:EntIndex() )

		if ( dlight ) then

			local c = self:GetColor()

			dlight.Pos = vOffset
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 10
			dlight.Size = 512
			dlight.DieTime = CurTime() + 0.02
			dlight.Decay = 512 * 1

		end
		
	end


	--[[---------------------------------------------------------
	   THINK
	-----------------------------------------------------------]]
	function EFFECT:Think( )
		return false
	end

	--[[---------------------------------------------------------
	   Draw the effect
	-----------------------------------------------------------]]
	function EFFECT:Render()
	end
	effects.Register(EFFECT,"JvsCameraFlash")
end
	

function SWEP:Initialize()

	self:SetWeaponHoldType( "camera" )

end


function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "Zoom" )
	if ( SERVER ) then
		self:SetZoom( 75 )
	end
end


SWEP.ShootSound				= "NPC_CScanner.TakePhoto"

function SWEP:PrimaryAttack()
	self:EmitSound( self.ShootSound )


	local vPos = self.Owner:GetShootPos()
	local vForward = self.Owner:GetAimVector()

	local trace = {}
		trace.start = vPos
		trace.endpos = vPos + vForward * 256
		trace.filter = self.Owner

	tr = util.TraceLine( trace )

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	util.Effect( "JvsCameraFlash", effectdata, true )
	self:SetNextPrimaryFire(CurTime()+0.1)
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
	vm:ResetSequence( vm:LookupSequence( "walk_camera" ) )
	
	return true
end

weapons.Register(SWEP,"weapon_jvs_camera")