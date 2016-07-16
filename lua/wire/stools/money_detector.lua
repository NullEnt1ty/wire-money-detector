WireToolSetup.setCategory("Detection")
WireToolSetup.open("money_detector", "Money Detector", "gmod_wire_moneydetector", nil, "Money Detectors")
WireToolSetup.BaseLang()
WireToolSetup.SetupMax(20)

TOOL.ClientConVar = {
	model = "models/jaanus/wiretool/wiretool_siren.mdl",
	range = 50,
	allow_cheques = 0,
	show_sphere_holstered = 0,
}

TOOL.Information = {
	{ name = "left" },
}

if CLIENT then
	language.Add("tool.wire_money_detector.name", "Money Detector Tool (Wire)")
	language.Add("tool.wire_money_detector.desc", "Spawns a money detector for use with the wire system.")
	language.Add("tool.wire_money_detector.left", "Create/Update "..TOOL.Name)
	language.Add("WireMoneyDetectorTool_range", "Range")
	language.Add("WireMoneyDetectorTool_allow_cheques", "Allow cheques")
	language.Add("WireMoneyDetectorTool_show_sphere_holstered", "Show sphere when tool is holstered")

	function TOOL.BuildCPanel(panel)
		WireToolHelpers.MakePresetControl(panel, "wire_money_detector")
		ModelPlug_AddToCPanel(panel, "Misc_Tools", "wire_money_detector", true)

		panel:NumSlider("#WireMoneyDetectorTool_range", "wire_money_detector_range", 0, 500)
		panel:CheckBox("#WireMoneyDetectorTool_allow_cheques", "wire_money_detector_allow_cheques")
		panel:CheckBox("#WireMoneyDetectorTool_show_sphere_holstered", "wire_money_detector_show_sphere_holstered")
	end
end

if SERVER then
	function TOOL:GetConVars()
		return self:GetClientNumber("allow_cheques") != 0, self:GetClientNumber("range")
	end
end