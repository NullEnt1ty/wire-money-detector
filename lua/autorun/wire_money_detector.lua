local CONVAR_MAX_RANGE = "wire_money_detector_admin_maxrange"

if SERVER then

	util.AddNetworkString("wmd_admin_maxrange")

	CreateConVar(CONVAR_MAX_RANGE, "500",
		{FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED},
		"Limits the maximum range a client may set.")

	local function maxRangeChanged(convar, oldVar, newVar)
		-- Restrict all currently spawned money detectors to the max range.
		for k,v in pairs(ents.FindByClass("gmod_wire_moneydetector")) do
			v:SetRange(math.min(v:GetRange(), newVar))
			v:UpdateOverlay()
		end
	end
	cvars.AddChangeCallback(CONVAR_MAX_RANGE, maxRangeChanged)

	local function setMaxRange(len, ply)
		if not ply:IsSuperAdmin() then return end
		
		RunConsoleCommand(CONVAR_MAX_RANGE, net.ReadUInt(32))
	end
	net.Receive("wmd_admin_maxrange", setMaxRange)

else

	language.Add("spawnmenu.utilities.money_detector", "Money Detector")
	language.Add("utilities.money_detector.max_range", "Maximum Range")

	local function createSlider(dform, label, min, max)
		--[[
			Ugly hacky code incoming!

			DNumSlider.OnValueChanged is called every time the value was changed.
			Even when you're still editing it (e.g. by holding the slider).
			This leads to an enormous amount of calls of OnValueChanged, which
			is impractical if you're doing network stuff.

			To avoid this, I have to detour some internal functions, which is really
			hacky code.
		]]

		local numSlider = dform:NumSlider(label, nil, min, max)

		-- Slider
		local sliderOnMouseReleased = numSlider.Slider.OnMouseReleased

		numSlider.Slider.OnMouseReleased = function(self, mcode)
			sliderOnMouseReleased(self, mcode)
			numSlider:OnValueChangedAlt(numSlider:GetValue())
		end

		-- Slider Knob
		local knobOnMouseReleased = numSlider.Slider.Knob.OnMouseReleased

		numSlider.Slider.Knob.OnMouseReleased = function(self, mcode)
			knobOnMouseReleased(self, mcode)
			numSlider:OnValueChangedAlt(numSlider:GetValue())
		end

		-- Text entry
		-- OnLoseFocus is called twice for some reason. Well, fuck it.
		local textEntryOnLoseFocus = numSlider.TextArea.OnLoseFocus

		numSlider.TextArea.OnLoseFocus = function(self)
			textEntryOnLoseFocus(self)
			numSlider:OnValueChangedAlt(numSlider:GetValue())
		end

		-- Scratch
		local scratchOnMouseReleased = numSlider.Scratch.OnMouseReleased

		numSlider.Scratch.OnMouseReleased = function(self, mcode)
			scratchOnMouseReleased(self, mcode)
			numSlider:OnValueChangedAlt(numSlider:GetValue())
		end

		return numSlider
	end

	local function createAdminPanel(panel)
		if not LocalPlayer():IsSuperAdmin() then
			local label = panel:Help("Superadmin only")
			label:SetColor(Color(255, 40, 40))
			
			return
		end

		local maxRangeSlider = createSlider(panel, "#utilities.money_detector.max_range", 0, 99999)
		maxRangeSlider:SetValue(GetConVarNumber(CONVAR_MAX_RANGE))
		maxRangeSlider.OnValueChangedAlt = function(self, val)
			net.Start("wmd_admin_maxrange")
				net.WriteUInt(val, 32)
			net.SendToServer()
		end
	end

	local function populateUtilityMenu()
		spawnmenu.AddToolMenuOption("Utilities", "Admin", "Admin_Money_Detector", "#spawnmenu.utilities.money_detector", "", "", createAdminPanel)
	end
	hook.Add("PopulateToolMenu", "wmd_PopulateToolMenu", populateUtilityMenu)

end