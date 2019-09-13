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
f:SetScript("OnEvent", function(self, event, errorId, errorMessage)
	if errorMessage == SitErrorMessage then
		DoEmote("stand")
		UIErrorsFrame:Clear()
	elseif errorMessage == "**TAXI**" then
		Dismount()
	elseif errorMessage == "**AUCTION**" then
		Dismount()
	elseif not UnitOnTaxi("player") then
		for _,message in ipairs(MountErrorMessages) do
			 if errorMessage == message then
				Dismount()
				UIErrorsFrame:Clear()
				return
			 end
		end
		for _,message in ipairs(ShapeshiftErrorMessages) do
			 if errorMessage == value then
				 CancelShapeshiftForm()
				 UIErrorsFrame:Clear()
				 return
			 end
		end
	end
end)

