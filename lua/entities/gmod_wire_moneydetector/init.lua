DEFINE_BASECLASS("base_wire_entity")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	BaseClass.Initialize(self)

	self.Inputs = WireLib.CreateInputs(self, { "Range", "AllowCheque", "AllowMoneyPot" })
	self.Outputs = WireLib.CreateOutputs(self, { "Amount" })

	self.lastAmount = 0
	self.allowCheque = false
	self.allowMoneyPot = false

	self:UpdateOverlay()
end

function ENT:Setup(allowCheque, allowMoneyPot, range)
	if range then
		local maxRange = math.min(range, GetConVarNumber("wire_money_detector_admin_maxrange"))
		self:SetRange(math.max(0, maxRange))
	end

	self.allowCheque = allowCheque
	self.allowMoneyPot = allowMoneyPot

	self:UpdateOverlay()
end

function ENT:TriggerInput(name, value)
	if name == "Range" then
		self:SetRange(math.max(0, value))
	elseif name == "AllowCheque" then
		self.allowCheque = value != 0
	elseif name == "AllowMoneyPot" then
		self.allowMoneyPot = value != 0
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
		elseif v:GetClass() == "darkrp_cheque" and self.allowCheque and v:Getrecipient() == self:GetPlayer() then
			amount = amount + v:Getamount()
		elseif v:GetClass() == "darkrp_moneypot" and self.allowMoneyPot then
			amount = amount + v:GetMoney()
		end
	end

	return amount
end

function ENT:UpdateOverlay()
	self:SetOverlayText("Range = " .. self:GetRange() ..
		"\nAllow cheque = " .. tostring(self.allowCheque) ..
		"\nAllow money pot = " .. tostring(self.allowMoneyPot) ..
		"\nAmount = " .. self.lastAmount)
end

duplicator.RegisterEntityClass("gmod_wire_moneydetector", WireLib.MakeWireEnt, "Data", "allowCheque", "allowMoneyPot")