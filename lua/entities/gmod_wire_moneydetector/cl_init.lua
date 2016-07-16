DEFINE_BASECLASS("base_wire_entity")
include("shared.lua")

local function minVector(a, b)
	local c = Vector()

	c.x = math.min(a.x, b.x)
	c.y = math.min(a.y, b.y)
	c.z = math.min(a.z, b.z)

	return c
end

local function maxVector(a, b)
	local c = Vector()

	c.x = math.max(a.x, b.x)
	c.y = math.max(a.y, b.y)
	c.z = math.max(a.z, b.z)

	return c
end

function ENT:Think()
	-- Override this hook to stop the base entity from overriding the render bounds.

	self:SetRenderBounds(self:CalcRenderBounds())
end

function ENT:Draw()
	BaseClass.Draw(self)

	self:DrawSphere()
end

function ENT:DrawSphere()
	local weapon = LocalPlayer():GetActiveWeapon()
	local tool = IsValid(weapon) and weapon:GetClass() == "gmod_tool" and weapon:GetToolObject()

	if tool and tool.Mode == "wire_money_detector" or GetConVarNumber("wire_money_detector_show_sphere_holstered") >= 1 then
		render.DrawWireframeSphere(self:GetPos(), self:GetRange(), 24, 24, Color(255, 0, 0), true)
	end
end

function ENT:CalcRenderBounds()
	local range = self:GetRange()
	local vecRange = Vector(range, range, range)
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()

	return minVector(-vecRange, mins), maxVector(vecRange, maxs)
end