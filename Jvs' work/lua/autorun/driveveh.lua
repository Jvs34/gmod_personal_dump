
//
// Don't try to edit this file if you're trying to add new vehicles
// Just make a new file and copy the format below.
//

local Category = "Half-Life 2"

//
//
local function HandleJeep( vehicle, player )
	return player:SelectWeightedSequence( ACT_DRIVE_JEEP)
end

local function HandleBoat( vehicle, player )
	return player:SelectWeightedSequence( ACT_DRIVE_AIRBOAT)
end

local function HandleSeat( vehicle, player )
	return player:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER)
end
local V = {
				// Required information
				Name = "Jalopy Seat",
				Class = "prop_vehicle_prisoner_pod",
				Category = Category,

				// Optional information
				Author = "VALVe",
				Information = "A Seat from VALVe's Jalopy",
				Model = "models/nova/jalopy_seat.mdl",
				KeyValues = {
								vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
								limitview		=	"0"
							},
				Members = {
								HandleAnimation = HandleSeat,
							}
}
list.Set( "Vehicles", "Seat_Jalopy", V )

local V = {
				// Required information
				Name = "APC",
				Class = "prop_vehicle_jeep_old",
				Category = Category,

				// Optional information
				Author = "VALVe",
				Information = "A Combine APC",
				Model = "models/combine_apc.mdl",
				KeyValues = {
								vehiclescript	=	"scripts/vehicles/apc.txt"
							}
			}

list.Set( "Vehicles", "APC", V )

local V = {
				// Required information
				Name = "Jeep Seat Driveable",
				Class = "prop_vehicle_prisoner_pod",
				Category = Category,

				// Optional information
				Author = "VALVe",
				Information = "A Seat from VALVe's Jeep",
				Model = "models/nova/jeep_seat.mdl",
				KeyValues = {
								vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
								limitview		=	"0"
							},
				Members = {
								HandleAnimation = HandleJeep,
							}
}
list.Set( "Vehicles", "Seat_Jeep_drive", V )

local V = {
				// Required information
				Name = "Airboat Seat Driveable",
				Class = "prop_vehicle_prisoner_pod",
				Category = Category,

				// Optional information
				Author = "VALVe",
				Information = "A Seat from VALVe's Airboat",
				Model = "models/nova/airboat_seat.mdl",
				KeyValues = {
								vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
								limitview		=	"0"
							},
				Members = {
								HandleAnimation = HandleBoat,
							}
}
list.Set( "Vehicles", "Seat_Airboat_drive", V )

local V = {
				// Required information
				Name = "Jalopy with Jeep Sounds",
				Class = "prop_vehicle_jeep",
				Category = Category,

				// Optional information
				Author = "VALVe",
				Information = "The muscle car from Episode 2",
				Model = "models/vehicle.mdl",
				KeyValues = {
								vehiclescript	=	"scripts/vehicles/jalopyjeepsound.txt"
							}
			}

list.Set( "Vehicles", "JalopySnd", V )