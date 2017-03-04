/*----------------------------------------------------------------------
	2.4 Changelog
	- Removed arm for melee holdtype, it just did not look good in many cases, mainly because they don't animate while attacking
	- Made legs move forward as you look up, looks as if you are bending over to look down or something. It's definitly an improvement.
		* Added option to revert to use the old mode. ( cl_legs_leanmode 0 will revert to the old way )
	- Moved the legs forward a small amount
	- Corrected vehicle pose parameter value ( This just adjusts where the arms are at on the steering wheel )
	- Fixed ducking in air making the legs z position move up. This is determined by the size of the players ducked hull and there is no way to get it
	- Added two global functions for third party modification
		* ShouldDrawLegs() -- Will return if the legs should be rendered for that frame
		* GetLocalPlayersLegs() -- Will return the leg entity if visible, if not visible it returns local player
	- Fixed legs drawing while spectating another entity ( Example: Catdaemon's shuttle )
	- Fixed certain models showing as errors
*/----------------------------------------------------------------------

/*----------------------------------------------------------------------
	DO NOT CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!
*/----------------------------------------------------------------------

if SERVER then
	AddCSLuaFile( "cl_legs.lua" )
	return
end



local Legs = {}
Legs.LegEnt = nil


function ShouldDrawLegs()
	return 	Legs.EnabledVar:GetBool() and
			IsValid( Legs.LegEnt ) and
			( LocalPlayer():Alive() or ( LocalPlayer().IsGhosted and LocalPlayer():IsGhosted() ) ) and
			Legs:CheckDrawVehicle() and
			GetViewEntity() == LocalPlayer() and
			!LocalPlayer():ShouldDrawLocalPlayer() and
			!LocalPlayer():GetObserverTarget()
end

--[[You can't really get another players legs, so we return the player back.
This would just simplify render hooks if you wanted to change the appearance
of a players model and make the legs mimic that change.
Seeing how you are probably going to be using this for a players model, we return
the legs if they are visible. If they aren't visible, then your playermodel might be
so we return back the localplayer. Confusing, but makes things really simple.

Example of usage below.

local MatWireFrame = Material( "models/wireframe" )
hook.Add( "RenderScreenspaceEffects", "RenderWireFrame", function() -- Will render all players with a wireframe overlay.
	for k,v in ipairs( player.GetAll() ) do
		SetMaterialOverride( MatWireFrame )
			GetPlayerLegs( ply ):DrawModel() -- If the player is the local player, it returns their legs if visible so we can make our legs have the same effect applied to it all with one simple line
		SetMaterialOverride( nil )
	end
end )]]
function GetPlayerLegs( ply )
	return ply and ply != LocalPlayer() and ply or ( ShouldDrawLegs() and Legs.LegEnt or LocalPlayer() )
end

Legs.EnabledVar = CreateConVar( "cl_legs", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the legs" )
Legs.VehicleDrawVar = CreateConVar( "cl_legs_vehicle", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the legs in a vehicle" )
Legs.LeanMode = CreateConVar( "cl_legs_leanmode", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the adjusting of the legs forward/backwards position determined by eye pitch" )

Legs.FixedModelNames = { -- Broken model path = key, fixed model path = value
	["models/humans/group01/female_06.mdl"] = "models/player/group01/female_06.mdl",
	["models/humans/group01/female_01.mdl"] = "models/player/group01/female_01.mdl",
	["models/alyx.mdl"] = "models/player/alyx.mdl",
	["models/humans/group01/female_07.mdl"] = "models/player/group01/female_07.mdl",
	["models/charple01.mdl"] = "models/player/charple01.mdl",
	["models/humans/group01/female_04.mdl"] = "models/player/group01/female_04.mdl",
	["models/humans/group03/female_06.mdl"] = "models/player/group03/female_06.mdl",
	["models/gasmask.mdl"] = "models/player/gasmask.mdl",
	["models/humans/group01/female_02.mdl"] = "models/player/group01/female_02.mdl",
	["models/gman_high.mdl"] = "models/player/gman_high.mdl",
	["models/humans/group03/male_07.mdl"] = "models/player/group03/male_07.mdl",
	["models/humans/group03/female_03.mdl"] = "models/player/group03/female_03.mdl",
	["models/police.mdl"] = "models/player/police.mdl",
	["models/breen.mdl"] = "models/player/breen.mdl",
	["models/humans/group01/male_01.mdl"] = "models/player/group01/male_01.mdl",
	["models/zombie_soldier.mdl"] = "models/player/zombie_soldier.mdl",
	["models/humans/group01/male_03.mdl"] = "models/player/group01/male_03.mdl",
	["models/humans/group03/female_04.mdl"] = "models/player/group03/female_04.mdl",
	["models/humans/group01/male_02.mdl"] = "models/player/group01/male_02.mdl",
	["models/kleiner.mdl"] = "models/player/kleiner.mdl",
	["models/humans/group03/female_01.mdl"] = "models/player/group03/female_01.mdl",
	["models/humans/group01/male_09.mdl"] = "models/player/group01/male_09.mdl",
	["models/humans/group03/male_04.mdl"] = "models/player/group03/male_04.mdl",
	["models/player/urban.mbl"] = "models/player/urban.mdl", -- It fucking returns the file type wrong as "mbl" D:
	["models/humans/group03/male_01.mdl"] = "models/player/group03/male_01.mdl",
	["models/mossman.mdl"] = "models/player/mossman.mdl",
	["models/humans/group01/male_06.mdl"] = "models/player/group01/male_06.mdl",
	["models/humans/group03/female_02.mdl"] = "models/player/group03/female_02.mdl",
	["models/humans/group01/male_07.mdl"] = "models/player/group01/male_07.mdl",
	["models/humans/group01/female_03.mdl"] = "models/player/group01/female_03.mdl",
	["models/humans/group01/male_08.mdl"] = "models/player/group01/male_08.mdl",
	["models/humans/group01/male_04.mdl"] = "models/player/group01/male_04.mdl",
	["models/humans/group03/female_07.mdl"] = "models/player/group03/female_07.mdl",
	["models/humans/group03/male_02.mdl"] = "models/player/group03/male_02.mdl",
	["models/humans/group03/male_06.mdl"] = "models/player/group03/male_06.mdl",
	["models/barney.mdl"] = "models/player/barney.mdl",
	["models/humans/group03/male_03.mdl"] = "models/player/group03/male_03.mdl",
	["models/humans/group03/male_05.mdl"] = "models/player/group03/male_05.mdl",
	["models/odessa.mdl"] = "models/player/odessa.mdl",
	["models/humans/group03/male_09.mdl"] = "models/player/group03/male_09.mdl",
	["models/humans/group01/male_05.mdl"] = "models/player/group01/male_05.mdl",
	["models/humans/group03/male_08.mdl"] = "models/player/group03/male_08.mdl",
	--Thanks Jvs
	["models/monk.mdl"] = "models/player/monk.mdl",
	["models/eli.mdl"] = "models/player/eli.mdl",
}

--[[hook.Add( "Initialize", "Legs:LoadModels", function() -- Used this for generating the list above
	print( "Legs.FixedModelNames = {" )
	for k,v in pairs( list.Get( "PlayerOptionsModel" ) ) do
		v = v:lower()
		print( "\t[\"" .. v:gsub( "/player/", "/" ):gsub( "/group0%d/", "/humans%1" ) .. "\"] = \"" .. v .. "\"," )
	end
	print( "}" )
end )]]

function Legs:FixModelName( mdl ) -- For some reason, the client returns the original HL2 version model of the player, not the player model.. Weird right? Only applies to the default player models.
	mdl = mdl:lower()
	return self.FixedModelNames[ mdl ] or mdl --Derp
	--[[for k,v in pairs( self.FixedModelNames ) do -- Better fix
		if k == mdl then
			return v
		end
	end
	return mdl]]
end

function Legs:SetUp() -- Creates our legs

	self.LegEnt = ClientsideModel( Legs:FixModelName( LocalPlayer():GetModel() ), RENDER_GROUP_OPAQUE_ENTITY )
	self.LegEnt:SetNoDraw( true ) -- We render the model differently
	self.LegEnt:SetSkin( LocalPlayer():GetSkin() )
	self.LegEnt:SetMaterial( LocalPlayer():GetMaterial() )
	self.LegEnt.LastTick = 0
end

-- Temporary values
Legs.PlaybackRate = 1
Legs.Sequence = nil
Legs.Velocity = 0
Legs.OldWeapon = nil
Legs.HoldType = nil

-- Can change to whatever you want, I think these two look best
Legs.BoneHoldTypes = { ["none"] = {
							"ValveBiped.Bip01_Head1",
							"ValveBiped.Bip01_Neck1",
							"ValveBiped.Bip01_Spine4",
							"ValveBiped.Bip01_Spine2",
						},
						["default"] = { -- The default bones to be hidden if there is no hold type bones
							"ValveBiped.Bip01_Head1",
							"ValveBiped.Bip01_Neck1",
							"ValveBiped.Bip01_Spine4",
							"ValveBiped.Bip01_Spine2",
							"ValveBiped.Bip01_L_Hand",
							"ValveBiped.Bip01_L_Forearm",
							"ValveBiped.Bip01_L_Upperarm",
							"ValveBiped.Bip01_L_Clavicle",
							"ValveBiped.Bip01_R_Hand",
							"ValveBiped.Bip01_R_Forearm",
							"ValveBiped.Bip01_R_Upperarm",
							"ValveBiped.Bip01_R_Clavicle"
						},
						["vehicle"] = { -- Bones that are deflated while in a vehicle
							"ValveBiped.Bip01_Head1",
							"ValveBiped.Bip01_Neck1",
							"ValveBiped.Bip01_Spine4",
							"ValveBiped.Bip01_Spine2",
						}
					}
				
Legs.BonesToRemove = {}
Legs.BoneMatrix = nil
Legs.Tf2ClassBones={}
Legs.Tf2ClassBones["shared"]={"spine4","neck","arm","head","hand","pinky","thumb","collar"}
Legs.Tf2ClassBones["scout"]={}
Legs.Tf2ClassBones["pyro"]={}
Legs.Tf2ClassBones["demoman"]={}
Legs.Tf2ClassBones["heavy"]={}
Legs.Tf2ClassBones["engineer"]={}
Legs.Tf2ClassBones["medic"]={}
Legs.Tf2ClassBones["sniper"]={}
Legs.Tf2ClassBones["soldier"]={}
Legs.Tf2ClassBones["spy"]={}
Legs.Tf2ClassBones["civilian"]={}
local function tabfind(tab,str)
	if !tab then return end
	for i,v in pairs(tab) do
		if type(v)=="string" && string.find(str,v) then return true end
	end
	return false;
end

function Legs:WeaponChanged( weap ) --Different bones will be visible for different hold types
	if IsValid( self.LegEnt ) then
		if IsValid( weap ) then
			self.HoldType = weap:GetHoldType()
		else
			self.HoldType = "none"
		end
		function self.LegEnt:BuildBonePositions( numbones, numphysbones )
			//tf2 gamemode stuff
			if LocalPlayer().IsHL2 && !LocalPlayer():IsHL2() then
				local tab=Legs.Tf2ClassBones[string.lower(LocalPlayer():GetPlayerClass())];
				for i=0,LocalPlayer():GetBoneCount()-1 do
				local bonename=string.lower(LocalPlayer():GetBoneName(i))
					if tabfind(Legs.Tf2ClassBones["shared"],bonename) || tabfind(tab,bonename) then
						Legs.BoneMatrix = self:GetBoneMatrix( self:LookupBone(bonename) )
						Legs.BoneMatrix:Scale( vector_origin ) -- Deflates the bone
						self:SetBoneMatrix(self:LookupBone(bonename), Legs.BoneMatrix )
					end
				end
				return;
			end
			//default stuff
			Legs.BonesToRemove = {
				"ValveBiped.Bip01_Head1"
			}
			if !LocalPlayer():InVehicle() then
				Legs.BonesToRemove = Legs.BoneHoldTypes[ Legs.HoldType ] or Legs.BoneHoldTypes[ "default" ]
			else
				Legs.BonesToRemove = Legs.BoneHoldTypes[ "vehicle" ]
			end
			for k, v in ipairs( Legs.BonesToRemove ) do -- Loop through desired bones
				Legs.BoneMatrix = self:GetBoneMatrix( self:LookupBone( v ) )
				if Legs.BoneMatrix then
					Legs.BoneMatrix:Scale( vector_origin ) -- Deflates the bone
					self:SetBoneMatrix( self:LookupBone( v ), Legs.BoneMatrix )
				end
			end
			
			

			
		end
	end
end

Legs.BreathScale = 0.5
Legs.NextBreath = 0

function Legs:Think( maxseqgroundspeed )
	if IsValid( self.LegEnt ) then
		if LocalPlayer():GetActiveWeapon() != self.OldWeapon then -- Player switched weapons, change the bones for new weapon
			self.OldWeapon = LocalPlayer():GetActiveWeapon()
			self:WeaponChanged( self.OldWeapon )
		end
		
		if self.LegEnt:GetModel() != self:FixModelName( LocalPlayer():GetModel() ) then --Player changed model without spawning?
			self.LegEnt:SetModel( self:FixModelName( LocalPlayer():GetModel() ) )
			--print( LocalPlayer():GetModel(), self:FixModelName( LocalPlayer():GetModel() ) )
		end
		
		self.LegEnt:SetMaterial( LocalPlayer():GetMaterial() )
		self.LegEnt:SetSkin( LocalPlayer():GetSkin() )

		self.Velocity = LocalPlayer():GetVelocity():Length2D()
		
		self.PlaybackRate = 1

		if self.Velocity > 0.5 then -- Taken from the SDK, gets the proper play back rate
			if maxseqgroundspeed < 0.001 then
				self.PlaybackRate = 0.01
			else
				self.PlaybackRate = self.Velocity / maxseqgroundspeed
				self.PlaybackRate = math.Clamp( self.PlaybackRate, 0.01, 10 )
			end
		end
		
		self.LegEnt:SetPlaybackRate( self.PlaybackRate ) -- Change the rate of playback. This is for when you walk faster/slower
		
		self.Sequence = LocalPlayer():GetSequence()
		
		if ( self.LegEnt.Anim != self.Sequence ) then -- If the player changes sequences, change the legs too
			self.LegEnt.Anim = self.Sequence
			self.LegEnt:ResetSequence( self.Sequence )
		end
		
		self.LegEnt:FrameAdvance( CurTime() - self.LegEnt.LastTick ) -- Advance the amount of frames we need
		self.LegEnt.LastTick = CurTime()
		
		Legs.BreathScale = sharpeye and sharpeye.GetStamina and math.Clamp( math.floor( sharpeye.GetStamina() * 5 * 10 ) / 10, 0.5, 5 ) or 0.5 -- More compatability for sharpeye. This changes the models breathing paramaters to go off of sharpeyes stamina system
		
		if Legs.NextBreath <= CurTime() then -- Only update every cycle, should stop MOST of the jittering
			Legs.NextBreath = CurTime() + 1.95 / Legs.BreathScale
			self.LegEnt:SetPoseParameter( "breathing", Legs.BreathScale )
		end
		
		self.LegEnt:SetPoseParameter( "move_yaw", ( LocalPlayer():GetPoseParameter( "move_yaw" ) * 360 ) - 180 ) -- Translate the walk direction
		self.LegEnt:SetPoseParameter( "body_yaw", ( LocalPlayer():GetPoseParameter( "body_yaw" ) * 180 ) - 90 ) -- Translate the body yaw
		self.LegEnt:SetPoseParameter( "spine_yaw",( LocalPlayer():GetPoseParameter( "spine_yaw" ) * 180 ) - 90 ) -- Translate the spine yaw
		
		if ( LocalPlayer():InVehicle() ) then
			self.LegEnt:SetColor( color_transparent )
			self.LegEnt:SetPoseParameter( "vehicle_steer", ( LocalPlayer():GetVehicle():GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 ) -- Translate the vehicle steering
		end
		//tf2 gamemode
		if LocalPlayer().IsHL2 && !LocalPlayer():IsHL2() then
				local velocity=LocalPlayer():GetVelocity()
				local c = LocalPlayer():GetPlayerClassTable()
				local maxspeed = 100
				
				if c and c.Speed then maxspeed = c.Speed end
				
				if (LocalPlayer():OnGround() and LocalPlayer():Crouching()) then
					maxspeed = maxspeed / 10
				elseif LocalPlayer():WaterLevel() > 1 then
					maxspeed = maxspeed * 0.8
				end
				
				if c and c.ModifyMaxAnimSpeed then
					maxspeed = c.ModifyMaxAnimSpeed(LocalPlayer(), maxspeed)
				end
				
				maxspeed = maxspeed * 3
				
				local vel = 1 * velocity
				vel:Rotate(Angle(0,-LocalPlayer():EyeAngles().y,0))
				vel:Rotate(Angle(-vel:Angle().p,0,0))
				
				self.LegEnt:SetPoseParameter("move_x", vel.x / maxspeed)
				self.LegEnt:SetPoseParameter("move_y", -vel.y / maxspeed)
				
		end
			
	end
end

hook.Add( "UpdateAnimation", "Legs:UpdateAnimation", function( ply, velocity, maxseqgroundspeed )
	if ply == LocalPlayer() then
		if IsValid( Legs.LegEnt ) then
			Legs:Think( maxseqgroundspeed ) -- Called every frame. Pass the ground speed for later use
		else
			Legs:SetUp() -- No legs, create them. Should only be called once
		end
	end
end )

-- More temp. shit
Legs.RenderAngle = nil
Legs.BiaisAngle = nil
Legs.RadAngle = nil
Legs.RenderPos = nil
Legs.RenderColor = {}
Legs.ClipVector = vector_up * -1
Legs.ForwardOffset = -24

Legs.Tf2ClassForwardOffset={civilian=-25,soldier=-26,scout=-20,pyro=-23,engineer=-23,heavy=-25,spy=-20,medic=-16,sniper=-17,demoman=-27}

function Legs:CheckDrawVehicle() -- Will return true if the player is in a vehicle and NOT in third person, or the player is not in a vehicle
	return LocalPlayer():InVehicle() and ( !gmod_vehicle_viewmode:GetBool() and self.VehicleDrawVar:GetBool() ) or !LocalPlayer():InVehicle()
end

hook.Add( "RenderScreenspaceEffects", "Legs:Render", function() -- Need to find a better place to render. Legs half-way in water = looks like they are clipped
	cam.Start3D( EyePos(), EyeAngles() )
		if ShouldDrawLegs() then -- Render check
		
			Legs.RenderPos = LocalPlayer():GetPos()
			if LocalPlayer():InVehicle() then -- The player is in a vehicle, so we use the vehicles angles, not the LocalPlayer
				Legs.RenderAngle = LocalPlayer():GetVehicle():GetAngles()
				Legs.RenderAngle:RotateAroundAxis( Legs.RenderAngle:Up(), 90 ) -- Fix it
			else -- This calculates the offset behind the player, adjust the -22 if you want to move it
				Legs.BiaisAngles = sharpeye_focus and sharpeye_focus.GetBiaisViewAngles and sharpeye_focus:GetBiaisViewAngles() or LocalPlayer():EyeAngles() -- Compatability for SharpEye
				Legs.RenderAngle = Angle( 0, Legs.BiaisAngles.y, 0 )
				Legs.RadAngle = math.rad( Legs.BiaisAngles.y )
				
				if Legs.LeanMode:GetBool() then -- Leaning is moving the legs forward as wee look up, gives the effect of bending over
					Legs.ForwardOffset = -12 + ( 1 - ( math.Clamp( Legs.BiaisAngles.p - 45, 0, 45 ) / 45 ) * 7 ) -- Push the legs forward as we look up
				else
					Legs.ForwardOffset = -22
				end
				//tf2 gamemode
				if LocalPlayer().IsHL2 && !LocalPlayer():IsHL2() then
					local offset=Legs.Tf2ClassForwardOffset[string.lower(LocalPlayer():GetPlayerClass())];
					Legs.ForwardOffset=offset or Legs.ForwardOffset;
				end
				//default stuff
				Legs.RenderPos.x = Legs.RenderPos.x + math.cos( Legs.RadAngle ) * Legs.ForwardOffset
				Legs.RenderPos.y = Legs.RenderPos.y + math.sin( Legs.RadAngle ) * Legs.ForwardOffset
				
				if LocalPlayer():GetGroundEntity() == NULL then -- Crappy duck fix
					Legs.RenderPos.z = Legs.RenderPos.z + 8
					if LocalPlayer():KeyDown( IN_DUCK ) then
						Legs.RenderPos.z = Legs.RenderPos.z - 28
					end
				end
			end
			
			Legs.RenderColor.r, Legs.RenderColor.g, Legs.RenderColor.b, Legs.RenderColor.a = LocalPlayer():GetColor() -- Set color will not work in this case, so we render it manually
			
			render.EnableClipping( true )
				render.PushCustomClipPlane( Legs.ClipVector, Legs.ClipVector:Dot( EyePos() ) ) -- Clip the model so if we look up we should never see any part of the legs model
					render.SetColorModulation( Legs.RenderColor.r / 255, Legs.RenderColor.g / 255, Legs.RenderColor.b / 255 ) -- Render the color correctly
						render.SetBlend( Legs.RenderColor.a / 255 )
							hook.Call( "PreLegsDraw", GAMEMODE, Legs.LegEnt )
							--cam.IgnoreZ( true ) --Attempted to give them draw priority over the world. Works, but they are drawn above view model ToDo: Fix
								Legs.LegEnt:SetRenderOrigin( Legs.RenderPos )
								Legs.LegEnt:SetRenderAngles( Legs.RenderAngle )
								Legs.LegEnt:SetupBones()
								Legs.LegEnt:DrawModel()
								Legs.LegEnt:SetRenderOrigin()
								Legs.LegEnt:SetRenderAngles()
							--cam.IgnoreZ( false )
							hook.Call( "PostLegsDraw", GAMEMODE, Legs.LegEnt )
						render.SetBlend( 1 )
					render.SetColorModulation( 1, 1, 1 )
				render.PopCustomClipPlane()
			render.EnableClipping( false )
		end
	cam.End3D()
end )