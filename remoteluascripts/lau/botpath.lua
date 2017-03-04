
local path = Path( "Follow" )
path:Invalidate()
path:Compute( NULL, Vector(0,0,0), 1 )

path:Invalidate()
path:Compute( NULL, Vector(0,300,0), 1 )
path:Draw()
print(path)