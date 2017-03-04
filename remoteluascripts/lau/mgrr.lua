
if SERVER then
	return
end

if MGRR then
	MGRR:Remove()
	MGRR = nil
end

MGRR = {}
MGRR.BaseLink = "https://dl.dropboxusercontent.com/u/20140357/mgrr/%s.mp3"
MGRR.MainAppend = "instrumental"
MGRR.SecondaryAppend = "vocals"
MGRR.AppendSymbol = "_"
MGRR.Songs = {
	"asoulcantbecut",
	"astrangeriremain",
	"collectiveconsciousness",
	"darkskies",
	"immyownmasternow",
	"ithastobethisway",
	"redsun",
	"returntoashes",
	"rulesofnature",
	"thehotwindblowing",
	"theonlythingiknowforreal",
	"thestainsoftime"
}


MGRR.MainChannel = nil
MGRR.SecondaryChannel = nil
MGRR.PlayMainChannel = true
MGRR.Initialized = false


function MGRR:Init()
	self:LoadSong( table.Random( self.Songs ) )
	self.Initialized = true
end

function MGRR:CanInit()
	return not self.Initialized
end


function MGRR:Think()
	
	self.PlayMainChannel = input.IsButtonDown( MOUSE_5 )
	
	if input.IsButtonDown( MOUSE_5 ) then
		
	end
	
	if IsValid( self.MainChannel ) and IsValid( self.SecondaryChannel ) then
		--start playback
		if self.MainChannel:GetState() ~= GMOD_CHANNEL_PLAYING then
			self.MainChannel:Play()
		end
		
		if self.SecondaryChannel:GetState() ~= GMOD_CHANNEL_PLAYING then
			self.SecondaryChannel:Play()
		end
		
		
		--sync the secondary track to the first one
		if self.SecondaryChannel:GetLength() <= self.MainChannel:GetLength() then
			self.SecondaryChannel:SetTime( self.MainChannel:GetTime() )
		end
		
		if self.PlayMainChannel then
			self.MainChannel:SetVolume( 1 )
			self.SecondaryChannel:SetVolume( 0 )
		else
			self.MainChannel:SetVolume( 0 )
			self.SecondaryChannel:SetVolume( 1 )
		end
		
	end
end

function MGRR:LoadSong( name )
	self:LoadChannel( name , true )
	self:LoadChannel( name , false )
end

function MGRR:LoadChannel( name , isprimary )
	local filename = string.format( "%s%s%s" , name , self.AppendSymbol , isprimary and self.MainAppend or self.SecondaryAppend )
	local path = string.format( self.BaseLink , filename )
	print( path )
	sound.PlayURL( path , "noblock noplay" , function( channel , errorid , errorname )
		if IsValid( channel ) then
			channel:EnableLooping( true )
			if isprimary then
				self.MainChannel = channel
			else
				self.SecondaryChannel = channel
			end
		else
			print( "Error loading "..path .. " : "..errorname )
		end
	end)
	
	
end

function MGRR:Remove()
	if IsValid( self.MainChannel ) then
		self.MainChannel:Stop()
	end
	
	if IsValid( self.SecondaryChannel ) then
		self.SecondaryChannel:Stop()
	end
end

hook.Add( "Think" , "MGRRThink" , function()
	if MGRR then
		
		if MGRR:CanInit() then
			MGRR:Init()
		end
		
		MGRR:Think()
	end
end)