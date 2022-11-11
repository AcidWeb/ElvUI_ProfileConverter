local _G = _G
local _, ns = ...

local LibDeflate = LibStub("LibDeflate")
local LibCompress = LibStub("LibCompress")
local LibBase64 = LibStub("LibBase64-1.0-ElvUI")
local AceGUI = LibStub("AceGUI-3.0")

ns = LibStub("AceAddon-3.0"):NewAddon("ElvUI Profile Converter", "AceConsole-3.0")

function ns:Convert(dataString)
   if strfind(dataString, '!E1!') then
      return "Error: Input already uses a new format.", false
   end
   if not LibBase64:IsBase64(dataString) then
      return "Error: Input doesn't look like a correct profile.", false
   end
   
   local decodedData = LibBase64:Decode(dataString)
   local decompressedData, decompressedMessage = LibCompress:Decompress(decodedData)
   
   if not decompressedData then
      return format("Error decompressing data: %s.", decompressedMessage), false
   end
   
   local compressedData = LibDeflate:CompressDeflate(decompressedData, {level = 5})
   local profileExport = LibDeflate:EncodeForPrint(compressedData)
   
   return "!E1!"..profileExport, true
end

function ns:HandleConversion()
   local payload, sucess = ns:Convert(ns.gui.editbox:GetText())
   if sucess then
      ns.gui.editbox:SetText(payload)
      ns.gui.editbox:HighlightText()
      ns.gui.frame:SetStatusText("Conversion complete. The profile above can be pasted into ElvUI.")
   else
      ns.gui.editbox:SetText("")
      ns.gui.frame:SetStatusText(payload)
   end
end

function ns:SlashCommand()
	ns.gui.frame:Show()
end

function ns:OnInitialize()
   ns.gui = {}
   ns.gui.frame = AceGUI:Create("Frame")
   ns.gui.frame:SetTitle("|cff1784d1ElvUI|r Profile Converter")
   ns.gui.frame:SetLayout("Fill")
   ns.gui.editbox = AceGUI:Create("MultiLineEditBox")
   ns.gui.editbox:SetLabel("Paste the old profile into the editbox below:")
   ns.gui.editbox:SetFullWidth(true)
   ns.gui.editbox:SetFullHeight(true)
   ns.gui.editbox:SetCallback("OnEnterPressed", ns.HandleConversion)
   ns.gui.frame:AddChild(ns.gui.editbox)
   ns.gui.frame:Hide()

   _G.ElvUIConverterFrame = ns.gui.frame
   tinsert(_G.UISpecialFrames, "ElvUIConverterFrame")

   self:RegisterChatCommand("econvert", "SlashCommand")
end