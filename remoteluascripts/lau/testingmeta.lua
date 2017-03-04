local accessorsexample = {
	"Origin",
	"Velocity",
	"Angles",
	"OldAngles",
	"AbsMoveAngles",
	"MoveAngles",
	"MaxSpeed",
	"MaxClientSpeed",
	"Buttons",
	"OldButtons",
	"ImpulseCommand",
	"ForwardSpeed",
	"SideSpeed",
	"UpSpeed",
	"ConstraintRadius",
}

local meta = {
	__index = function() end,
	__newindex = function() end,
}

for i , v in pairs( accessorsexample ) do
	meta["Get"..v] = function() end
	meta["Set"..v] = function() end
end

for i , v in pairs( meta ) do
	local functionname = i
	
	if functionname:find( "^Get" ) then
		local functionnamestripped = functionname:gsub( "^Get" , "" )
		print( functionnamestripped )
	end
	
	
	
end