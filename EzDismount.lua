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

function EzDismount_chkerror(errorId, errorMessage)
   -- Stand up if you are trying to do something while sitting
   if (errorMessage == EzDSitErr )  then
      if (EzDismount_Config[EzDPlayer]["Stand"] == "ON") then
         DoEmote("stand")
			UIErrorsFrame:Clear()
      end
      return;
   end
   
    -- Flightpath Dismount enabled
   if (errorMessage == "**TAXI**" ) then
      if (EzDismount_Config[EzDPlayer]["Dismount"] == "ON") then
         EzD_dismount();
      end
      return;
   end

   -- Auctioneer Dismount enabled
   if (errorMessage == "**AUCTION**" ) then
      if (EzDismount_Config[EzDPlayer]["Auction"] == "ON") then
         EzD_dismount();
      end
      return;
   end

   -- Mount Error
   if ( not UnitOnTaxi("player") ) then
      for _, value in pairs(EzDMountErr.Error) do
          if (errorMessage == value ) then
             if (EzDismount_Config[EzDPlayer]["Dismount"] == "ON") then
                EzD_dismount();
             end
             return;
          end
      end
   end

   -- Shapeshift Error
   if ( not UnitOnTaxi("player") ) then
      for _, value in pairs(EzDShiftErr.Error) do
          if (errorMessage == value) then
             EzD_unshift()
				 UIErrorsFrame:Clear()
          end
      end
   end

end

-------------------------
-- Cancel Shapeshift Buff
-------------------------
function EzD_unshift()

	CancelShapeshiftForm()
	if true then return end

   local shifttable = nil;

   -- Set Texture Table based on Class
   if (EzDClass == "Druid") then
      if ( EzDismount_Config[EzDPlayer]["Druid"] == "ON" ) then
         shifttable = EzDMountText.Druid;
      end
   elseif (EzDClass == "Shaman") then
      if ( EzDismount_Config[EzDPlayer]["Wolf"] == "ON" ) then
         shifttable = EzDMountText.Shaman;
      end
   elseif (EzDClass == "Priest") then
      if ( EzDismount_Config[EzDPlayer]["Shadowform"] == "ON" ) then
         shifttable = EzDMountText.Priest;
      end
   end

   -- Only Continue if we have a table to work with
   if shifttable ~= nil then
      -- Loop thru the 16 max player buffs
      for i=0,16,1 do

         -- Skip over excluded textures
         if not EzD_shiftexclude(i) then

            -- Look for shapeshift buff texture
            if EzD_checktext(i, shifttable) then
               CancelPlayerBuff(i);
            end

         end

      end
   end

end

