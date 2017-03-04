AddCSLuaFile()
	
if SERVER then
	
	hook.Add( "DoPlayerDeath" , "GibPlayer" , function(ply , attacker , dmginfo)
		if dmginfo:IsDamageType( DMG_ALWAYSGIB ) then
			local effect = EffectData()
			effect:SetEntity( ply )
			util.Effect( "gmod_player_gib" , effect )
			return true
		end
	end)
	
else
	local EFFECT = {}
	
	function EFFECT:Init( data )
		self.Owner = data:GetEntity()
		self.EyeTarget = self.Owner:GetEyeTrace().HitPos
		self.Owner:SetupBones()
		
		self:SetModel( self.Owner:GetModel() )
		
		self:SetPos( self.Owner:GetPos() )
		self:SetRenderBounds( self.Owner:GetRenderBounds() )
		
		self.LifeTime = CurTime() + 10
		
		self.BoneCache = {}
		
		for i = 0 , self.Owner:GetBoneCount() -1 do
			local bm = self.Owner:GetBoneMatrix( i )
			if bm then
				self.BoneCache[i] = bm
			end
		end
		self:AddCallback( "BuildBonePositions" , self.BuildBonePositions )
	end
	
	function EFFECT:BuildBonePositions()
		for i , v in pairs( self.BoneCache ) do
			local mybm = self:GetBoneMatrix( i )
			if mybm then
				self:SetBoneMatrix( i , v )
			end
		end
	
	end
	
	function EFFECT:Think()
		if self.LifeTime < CurTime() then
			return false
		end
		return true
	end
	
	function EFFECT:Render()
		self:SetEyeTarget( self.EyeTarget )
		self:DrawModel()
	end
	
	effects.Register( EFFECT , "gmod_player_gib" )

end