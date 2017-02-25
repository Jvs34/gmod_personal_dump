local Category = "Humans + Resistance"

local NPC = { 	Name = "A scripted npc", 
				Class = "snpc_snpc",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Friendly Rollermine",
				ClassAlt = "npc_friendlyrollermine",
				Class = "npc_rollermine",
				SpawnFlags = SF_ROLLERMINE_FRIENDLY,
				Offset = 16,
				Skin = 1,
				Category = Category	}

list.Set( "NPC", NPC.ClassAlt, NPC )


local NPC = { 	Name = "Citizen Turret",
				ClassAlt = "npc_turret_citizen",
				Class = "npc_turret_floor",
				OnFloor = true,
				SpawnFlags = SF_FLOOR_TURRET_CITIZEN,
				Rotate = Angle( 0, 180, 0 ),
				Offset = 2,
				Category = Category	}

list.Set( "NPC", NPC.ClassAlt, NPC )






Category = "Zombies + Enemy Aliens"


local NPC = { 	Name = "Cavern Dweller",
				ClassAlt = "npc_caverndweller",
				Class = "npc_antlionguard",
				KeyValues = { cavernbreed = 1, incavern = 1 },
				Category = Category	}

list.Set( "NPC", NPC.ClassAlt, NPC )



Category = "Combine"

local NPC = { 	Name = "Combine Mine",
				Class = "combine_mine",
				Offset = 16,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Ceiling Turret",
				Class = "npc_turret_ceiling",
				OnCeiling = true,
				TotalSpawnFlags = 0,
				Rotate = Angle( 0, 180, 0 ),
				Offset = 2,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Ground Turret",
				Class = "npc_turret_ground",
				OnCeiling = true,
				TotalSpawnFlags = 0,
				Rotate = Angle( 0, 180, 0 ),
				Offset = 2,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Combine Dropship",
				Class = "npc_combinedropship",
				InAir = true,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Combine Gunship",
				Class = "npc_combinegunship",
				InAir = true,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Helicopter",
				Class = "npc_helicopter",
				InAir = true,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Strider",
				Class = "npc_strider",
				OnFloor = true,
				SpawnFlags = 65536,
				Offset = 2,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )



local NPC = { 	Name = "Claw Scanner",
				Class = "npc_clawscanner",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )