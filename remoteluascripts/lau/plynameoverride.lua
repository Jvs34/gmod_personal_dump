
local META		= FindMetaTable( "Player" )

if not META then return end

if not META.OldGetName then
	META.OldGetName=META.GetName
end

if not META.OldName then
	META.OldName=META.Name
end

if not META.OldNick then
	META.OldNick=META.Nick
end


function META:Nick()
	if self:GetDTString(2)=="" or not self:GetDTString(2) then
		return self:OldNick()
	end
	return GetDTString(2) or self:OldNick()
end

META.Name=META.Nick
META.GetName=META.Nick


if SERVER then

	function META:SetCustomName(str)
		self:SetDTString(2,str or "")
	end
end