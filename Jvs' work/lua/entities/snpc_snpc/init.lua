 AddCSLuaFile( "cl_init.lua" ) 
 AddCSLuaFile( "shared.lua" ) 
   
 include('shared.lua') 
 ENT.m_iClass					= CLASS_CITIZEN_REBEL // NPC Class
 AccessorFunc( ENT, "m_iClass", 			"NPCClass" )
local schdChase = ai_schedule.New( "AIFighter Chase" ) //creates the schedule used for this npc
	
	schdChase:AddTask( "FindEnemy", 		{ Class = "player", Radius = 200000 } )
	schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
   	schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
    	schdChase:EngTask( "TASK_WAIT", 0.2 ) 

 function ENT:Initialize() 
   
	
 	self:SetModel( "models/Humans/Group01/male_07.mdl" ) 
 	 
 	self:SetHullType( HULL_HUMAN ); 
 	self:SetHullSizeNormal(); 
 	self:SetSolid( SOLID_BBOX )  
 	self:SetMoveType( MOVETYPE_STEP ) 
 	 
 	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_ANIMATEDFACE | CAP_TURN_HEAD | CAP_USE_SHOT_REGULATOR | CAP_AIM_GUN | CAP_DUCK | CAP_INNATE_MELEE_ATTACK1)
 	 
 	self:SetMaxYawSpeed( 5000 ) 
 
 	self:SetHealth(100) 
	self:SetMaxHealth(100)
	self:Give("weapon_crowbar")
 end 

function ENT:SelectSchedule() 

	self:StartSchedule( schdChase )
  
end 

function ENT:Think()

end

function ENT:OnTakeDamage(dmginfo)
end
	


function ENT:OnRemove()

end