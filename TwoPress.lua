local SitErrorMessage = SPELL_FAILED_NOT_STANDING

local ShapeshiftErrorMessages = {
	SPELL_FAILED_NOT_SHAPESHIFT,
	SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
	SPELL_NOT_SHAPESHIFTED,
	SPELL_NOT_SHAPESHIFTED_NOSPACE,
	ERR_CANT_INTERACT_SHAPESHIFTED,
	ERR_NOT_WHILE_SHAPESHIFTED,
	ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
	ERR_TAXIPLAYERSHAPESHIFTED,
	ERR_MOUNT_SHAPESHIFTED,
	ERR_EMBLEMERROR_NOTABARDGEOSET,
}


local MountErrorMessages = {
	SPELL_FAILED_NOT_MOUNTED,
	ERR_ATTACK_MOUNTED,
}

local f = CreateFrame("FRAME")
f:RegisterEvent("UI_ERROR_MESSAGE")
f:RegisterEvent("AUCTION_HOUSE_SHOW")
f:RegisterEvent("TAXIMAP_OPENED")
f:SetScript("OnEvent", function(self, event, errorId, errorMessage)
	if event == "UI_ERROR_MESSAGE" then
		if errorMessage == SitErrorMessage then
			DoEmote("stand")
			UIErrorsFrame:Clear()
		elseif not UnitOnTaxi("player") then
			for _,message in ipairs(MountErrorMessages) do
				 if errorMessage == message then
					Dismount()
					UIErrorsFrame:Clear()
					return
				 end
			end
			for _,message in ipairs(ShapeshiftErrorMessages) do
				 if errorMessage == message then
					 CancelShapeshiftForm()
					 UIErrorsFrame:Clear()
					 return
				 end
			end
		end
	elseif event == "TAXIMAP_OPENED" or event == "AUCTION_HOUSE_SHOW" then
		Dismount()
	end
end)

