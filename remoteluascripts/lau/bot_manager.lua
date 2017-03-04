
local MsgN				= MsgN
local IsValid			= IsValid
local setmetatable	= setmetatable
local util				= util
local ErrorNoHalt		= ErrorNoHalt
local Error				= Error
local player			= player
local hook				= hook
local developer		= GetConVar( "developer" )
local pairs				= pairs
local type				= type
local table				= table

module( "bot_manager" )

local hooks = {
	{
		hookName = "BotOnSound" , behaviour = "OnSound"
	},
	{
		hookName = "BotOnSight" , behaviour = "OnSight"
	},
	{
		hookName = "BotBehaveUpdate" , behaviour = "Update"
	},
	{
		hookName = "BotOnLeaveGround" , behaviour = "OnLeaveGround"
	},	
	{
		hookName = "BotOnLandOnGround" , behaviour = "BotOnLandOnGround"
	},
	{
		hookName = "BotOnTouch" , behaviour = "OnTouch"
	},
	{
		hookName = "BotOnMoveToSuccess" , behaviour = "OnMoveToSuccess"
	},
	{
		hookName = "BotOnMoveToFailure" , behaviour = "OnMoveToFailure"
	},	
	{
		hookName = "BotOnStuck" , behaviour = "OnStuck"
	},		
	{
		hookName = "BotOnUnStuck" , behaviour = "OnUnStuck"
	},
	{
		hookName = "BotOnInjured" , behaviour = "OnInjured"
	},
	{
		hookName = "BotOnKilled" , behaviour = "OnKilled"
	},
	{
		hookName = "BotOnOtherKilled" , behaviour = "OnOtherKilled"
	},
	{
		hookName = "StartCommand" , behaviour = "StartCommand"
	},
}

local function debugSay( ply , text) 
	if developer:GetBool() then 
		ply:Say( text )
	end
end

local BehaviourMeta = {}

local RegisteredBehaviours = {}

--[[

	Create the bot and give it a behaviour

]]
function CreateBot( botname , behaviour )
	
	botname = botname or "Bot"
	
	local player_bot = player.CreateNextBot( botname )
	if not IsValid( player_bot ) then
		Error("Not enough player slots to create " .. botname )
	end
	
	SetBehaviour( player_bot , behaviour , "CreateBot" )
	return player_bot
end

--[[
	Create the actual behaviour object and assign it to the player_bot
]]

function SetBehaviour( player_bot , behaviour , reason  , ... )
	
	if not behaviour or type(behaviour) ~= "string" then return false end
	
	if not RegisteredBehaviours[behaviour] then return false end
	
	if not reason then reason = "No reason" end
	
	
	
	
	
	--if we already have an old behaviour, tell it that it's about to end
	local oldBehaviour
	
	if player_bot.m_currentBehaviour then
		
		oldBehaviour = player_bot.m_currentBehaviour:GetName()
		
		RunBehaviourFunction( player_bot , "OnEnd" , reason , behaviour )
	
	end
	
	local newBehaviour = table.Copy( RegisteredBehaviours[behaviour] )
	
	player_bot.m_currentBehaviour = newBehaviour
	
	
	
	debugSay( player_bot , "I got assigned " .. behaviour .. " for the reason "..reason )
	
	RunBehaviourFunction( player_bot , "OnStart" , reason , oldBehaviour , ... )
	
	--player_bot.m_currentBehaviour:OnStart( player_bot , reason , oldBehaviour )
	return true
end

function GetBehaviour( player_bot )
	return player_bot.m_currentBehaviour
end

function RegisterBehaviour( behaviour_name , behaviour_table )

	RegisteredBehaviours[ behaviour_name ] = behaviour_table
	
	behaviour_table.Name = behaviour_name
	
	setmetatable( RegisteredBehaviours[ behaviour_name ], { __index = BehaviourMeta } )

end

function RunBehaviourFunction( player_bot , function_name , ... )
	
	if player_bot.m_currentBehaviour then
		
		local func = player_bot.m_currentBehaviour[function_name]
		
		if func then
			func( player_bot.m_currentBehaviour , player_bot , ... )
		end
		
	end

end


--[[
	Base behaviour meta
]]

function BehaviourMeta:GetName()
	return self.Name
end

--[[
	Use this function to switch to another behaviour and don't override it!
]]

function BehaviourMeta:Restart( player_bot )
	self:ChangeTo( player_bot , self:GetName() , "Restarting" )
end

function BehaviourMeta:ChangeTo( player_bot , newBehaviour , reason , ... )
	return SetBehaviour( player_bot , newBehaviour , reason , ... )
end

function BehaviourMeta:OnStart( player_bot , reason , oldBehaviour )
end

function BehaviourMeta:OnEnd( player_bot , reason , newBehaviour )
end

function BehaviourMeta:StartCommand( player_bot , cmd )
end

function BehaviourMeta:Update( player_bot , interval )
end

function BehaviourMeta:OnLeaveGround( player_bot , ground )
end

function BehaviourMeta:OnLandOnGround( player_bot , ground )
end

function BehaviourMeta:OnMoveToSuccess( player_bot , path )
end

function BehaviourMeta:OnMoveToFailure( player_bot , path , reason )
end

function BehaviourMeta:OnStuck( player_bot )
end

function BehaviourMeta:OnUnStuck( player_bot )
end

function BehaviourMeta:OnOtherKilled( player_bot , victim , dmginfo )
end

function BehaviourMeta:OnSight( player_bot , entity )
end

function BehaviourMeta:OnLostSight( player_bot , entity )
end

function BehaviourMeta:OnTouch( player_bot , entity )
end

function BehaviourMeta:OnInjured( player_bot , dmginfo )
end

function BehaviourMeta:OnSound( player_bot , emitter , origin , keyvalues )
end


for i,v in pairs( hooks ) do

	hook.Add( v.hookName , "bot_manager" , function( player_bot , ... )
		
		--might happen in case we want to use non bot specific hooks
		if not player_bot:IsBot() then return end
		
		
		RunBehaviourFunction( player_bot , v.behaviour , ... )
		
	end)
	
end