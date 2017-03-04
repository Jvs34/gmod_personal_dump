
if SERVER then
	return
end

if MISHMASH then
	MISHMASH:Remove()
	MISHMASH = nil
end

MISHMASH = {}

local XCOM = true

if MGR then

	MISHMASH.BaseLink = "https://dl.dropboxusercontent.com/u/20140357/mgrr/%s.mp3"
	MISHMASH.MainAppend = "instrumental"
	MISHMASH.SecondaryAppend = "vocals"
	MISHMASH.AppendSymbol = "_"
	MISHMASH.Songs = {
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

end

if XCOM then

	MISHMASH.BaseLink = "https://dl.dropboxusercontent.com/u/20140357/xcom2/Combat_%s.mp3"
	MISHMASH.MainAppend = "XCOM"
	MISHMASH.SecondaryAppend = "Alien"
	MISHMASH.AppendSymbol = "_"
	MISHMASH.Songs = {
		"01",
		"02",
		"03",
		"04",
		"05",
		"06",
		"07",
		"08",
		"09",
		"10",
		
	}
end


MISHMASH.MainChannel = nil
MISHMASH.SecondaryChannel = nil
MISHMASH.PlayMainChannel = true
MISHMASH.Initialized = false


function MISHMASH:Init()
	self:LoadSong( table.Random( self.Songs ) )
	self.Initialized = true
end

function MISHMASH:CanInit()
	return not self.Initialized
end


function MISHMASH:Think()
	
	self.PlayMainChannel = not input.IsButtonDown( MOUSE_5 )
	
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
		--if self.SecondaryChannel:GetLength() <= self.MainChannel:GetLength() then
			self.SecondaryChannel:SetTime( self.MainChannel:GetTime() )
		--end
		
		if self.PlayMainChannel then
			self.MainChannel:SetVolume( 1 )
			self.SecondaryChannel:SetVolume( 0 )
		else
			self.MainChannel:SetVolume( 0 )
			self.SecondaryChannel:SetVolume( 1 )
		end
		
	end
end

function MISHMASH:LoadSong( name )
	self:LoadChannel( name , true )
	self:LoadChannel( name , false )
end

function MISHMASH:LoadChannel( name , isprimary )
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

function MISHMASH:Remove()
	if IsValid( self.MainChannel ) then
		self.MainChannel:Stop()
	end
	
	if IsValid( self.SecondaryChannel ) then
		self.SecondaryChannel:Stop()
	end
end

hook.Add( "Think" , "MISHMASHThink" , function()
	if MISHMASH then
		
		if MISHMASH:CanInit() then
			MISHMASH:Init()
		end
		
		MISHMASH:Think()
	end
end)