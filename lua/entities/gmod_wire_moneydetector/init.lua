DEFINE_BASECLASS("base_wire_entity")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	BaseClass.Initialize(self)

	self.Inputs = WireLib.CreateInputs(self, { "Range", "AllowCheques" })
	self.Outputs = WireLib.CreateOutputs(self, { "Amount" })

	self.lastAmount = 0
	self.allowCheques = false

	self:UpdateOverlay()
end

function ENT:Setup(allowCheques, range)
	if range then
		self:SetRange(math.max(0, range))
	end

	self.allowCheques = allowCheques

	self:UpdateOverlay()
end

function ENT:TriggerInput(name, value)
	if name == "Range" then
		self:SetRange(math.max(0, value))
	elseif name == "AllowCheques" then
		self.allowCheques = value != 0
	end

	self:UpdateOverlay()
end

function ENT:Think()
	BaseClass.Think(self)

	local amount = self:SearchForMoney()

	if self.lastAmount != amount then
		self.lastAmount = amount
		self:UpdateOverlay()
	end

	WireLib.TriggerOutput(self, "Amount", amount)

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:SearchForMoney()
	local amount = 0

	for k,v in pairs(ents.FindInSphere(self:GetPos(), self:GetRange())) do
		if v:GetClass() == "spawned_money" then
			amount = amount + v:Getamount()
		elseif v:GetClass() == "darkrp_cheque" and self.allowCheques and v:Getrecipient() == self:GetPlayer() then
			amount = amount + v:Getamount()
		end
	end

	return amount
end

function ENT:UpdateOverlay()
	self:SetOverlayText("Range = " .. self:GetRange() .. "\nAllow cheques = " .. tostring(self.allowCheques) .. "\nAmount = " .. self.lastAmount)
end

duplicator.RegisterEntityClass("gmod_wire_moneydetector", WireLib.MakeWireEnt, "Data", "allowCheques")