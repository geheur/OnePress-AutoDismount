-- EzDismount : A quick and dirty dismounting mod, useful for PVP or herb/ore collecting
-- By Gaddur of the Eonar Server

local EzDClass
local EzDPlayer

EzDismount_ver = "v3.4";
EzDismount_fullver = ("EzDismount " .. EzDismount_ver);

---------------------------------
-- Stuff to do when Mod is loaded
---------------------------------
function EzDismount_onload()

	EzDClass = UnitClass("player");
	EzDPlayer = (UnitName("player").." of "..GetRealmName())
	EZDismount_DetPlayer:SetText(EzDPlayer.." Server");

	--Create user table if it doesnt exist
	if (EzDismount_Config == nil) then
		EzDismount_Config = {};
	end

	if (EzDismount_Config[EzDPlayer] == nil) then
		EzDismount_reset();
	end
	
	-- Convert Anyone with "TAXI" to "ON" since setting was removed in v3.0
	if (EzDismount_Config[EzDPlayer]["Dismount"] == "TAXI") then
	   EzDismount_Config[EzDPlayer]["Dismount"] = "ON";
        end

  	EzD_chat("## " .. EzDismount_fullver .. " Loaded ##  Use /ezd or /ezd help", 0.0, 1.0, 0.0);

  	SlashCmdList["EZDISMOUNT"] = EzDismount_options;
   	SLASH_EZDISMOUNT1 = "/ezd";
   	SLASH_EZDISMOUNT2 = "/ezdismount";

	-- Set Default Colors
	EZDismount_ShamanTitle:SetTextColor(255,255,255,255);
	EZDismount_DruidTitle:SetTextColor(255,255,255,255);
	EZDismount_PriestTitle:SetTextColor(255,255,255,255);
	EzDismount_Text_Status_VOFF:SetTextColor(255,0,0,255);
	EzDismount_Text_Status_VON:SetTextColor(0,255,0,255);
	EzDismount_Text_Shaman_VOFF:SetTextColor(255,0,0,255);
	EzDismount_Text_Shaman_VON:SetTextColor(0,255,0,255);
	EzDismount_Text_Druid_VOFF:SetTextColor(255,0,0,255);
	EzDismount_Text_Druid_VON:SetTextColor(0,255,0,255);
	EzDismount_Text_Shadowform_VOFF:SetTextColor(255,0,0,255);
	EzDismount_Text_Shadowform_VON:SetTextColor(0,255,0,255);
	EzDismount_Text_Stand_VOFF:SetTextColor(255,0,0,255);
	EzDismount_Text_Stand_VON:SetTextColor(0,255,0,255);
	EzDismount_Text_Auction_VOFF:SetTextColor(255,0,0,255);
	EzDismount_Text_Auction_VON:SetTextColor(0,255,0,255);
	EZDismount_DetPlayer:SetTextColor(255,255,255,255);
	EzDismount_Text_MoonCB:SetTextColor(255,0,0,255);
	EzDismount_Text_TreeCB:SetTextColor(255,0,0,255);
	EzDismount_Text_US:SetTextColor(255,0,0,255);

        EzD_loadshiftexc();

 end

----------------------------------
-- Parse out option from / Command
----------------------------------
function EzDismount_options(msg)

        -- Show Config Menu
	if (msg == "") then
         	EzDismount_Toggle();
        end

        -- Dump Textures to chatwindow
	if (string.lower(msg) == "debug") then
		EzDismount_debug();
  	end
  	
  	-- Dump Target Textures to chatwindow
	if (string.lower(msg) == "debugtarget") then
		EzDismount_debugtarget();
  	end

	 -- Reload UI
	if (string.lower(msg) == "reload") then
		ReloadUI();
  	end

  	-- Reset Settings
	if (string.lower(msg) == "reset") then
		EzDismount_reset();
  	end

        -- Help
	if (string.lower(msg) == "help") or (msg == "?") then
		EzDismount_help();
  	end
  	
  	-- Print Table
	if (string.lower(msg) == "table") then
		EzDismount_table();
  	end

end

------------------
-- Reset Variables
------------------
function EzDismount_reset()

        EzDismount_Config[EzDPlayer] = {
			["Dismount"]   = "ON";
			["Druid"]      = "ON";
                        ["Shadowform"] = "ON";
			["Wolf"]       = "ON";
   			["Stand"]      = "ON";
                        ["Auction"]    = "ON";
                        ["DruidExcMoon"] = 0;
                        ["DruidExcTree"] = 0;
                        ["LinkShift"] = 0;
	}

        EzD_chat("** EzDismount Config reset for " .. EzDPlayer .. " **");
end

----------------
-- Toggle Values
----------------
function EzDismount_ChgValue(msg)


  -- Auto-dismount toggle
  if (string.lower(msg) == "on/off") then
  
     if (EzDismount_Config[EzDPlayer]["Dismount"] == "ON") then
        EzDismount_Config[EzDPlayer]["Dismount"] = "OFF";
     else
	EzDismount_Config[EzDPlayer]["Dismount"] = "ON";
     end

  -- Auctioneer toggle
  elseif (string.lower(msg) == "auction") then

     if (EzDismount_Config[EzDPlayer]["Auction"] == "ON") then
	EzDismount_Config[EzDPlayer]["Auction"] = "OFF";
     else
	EzDismount_Config[EzDPlayer]["Auction"] = "ON";
     end

  -- Stand toggle
  elseif (string.lower(msg) == "stand") then

     if (EzDismount_Config[EzDPlayer]["Stand"] == "ON") then
        EzDismount_Config[EzDPlayer]["Stand"] = "OFF";
     else
	EzDismount_Config[EzDPlayer]["Stand"] = "ON";
     end

  -- Druid toggle
  elseif (string.lower(msg) == "druid") then

     if (EzDismount_Config[EzDPlayer]["Druid"] == "ON") then
        EzDismount_Config[EzDPlayer]["Druid"] = "OFF";
     else
	EzDismount_Config[EzDPlayer]["Druid"] = "ON";
     end

  -- Shaman toggle
  elseif (string.lower(msg) == "wolf") then
  
     if (EzDismount_Config[EzDPlayer]["Wolf"] == "ON") then
        EzDismount_Config[EzDPlayer]["Wolf"] = "OFF";
     else
	EzDismount_Config[EzDPlayer]["Wolf"] = "ON";
     end
  
  -- Shadowform toggle
  elseif (string.lower(msg) == "shadowform") then

  if (EzDismount_Config[EzDPlayer]["Shadowform"] == "ON") then
     EzDismount_Config[EzDPlayer]["Shadowform"] = "OFF";
  else
     EzDismount_Config[EzDPlayer]["Shadowform"] = "ON";
  end

  end

  EzDismount_Refresh();

end

-----------------------------------------
-- Toggles the showing/hiding of the Menu
-----------------------------------------
function EzDismount_Toggle()

	if ( EzDismount_Menu:IsVisible() ) then
		EzDismount_Menu:Hide();
	else
		EzDismount_Menu:Show();
	end

end

--------------------
-- Refresh Screen
--------------------

function EzDismount_Refresh()

	EzDismount_Text_Status_VOFF:SetText("");
	EzDismount_Text_Status_VON:SetText("");
	EzDismount_Text_Shaman_VOFF:SetText("");
	EzDismount_Text_Shaman_VON:SetText("");
	EzDismount_Text_Druid_VOFF:SetText("");
	EzDismount_Text_Druid_VON:SetText("");
	EzDismount_Text_Shadowform_VOFF:SetText("");
	EzDismount_Text_Shadowform_VON:SetText("");
	EzDismount_Text_Stand_VOFF:SetText("");
	EzDismount_Text_Stand_VON:SetText("");
	EzDismount_Text_Auction_VOFF:SetText("");
	EzDismount_Text_Auction_VON:SetText("");

	-- Mounts
	EzDismount_Text_Status:SetText("Automatic dismounting is :");
	if ( EzDismount_Config[EzDPlayer]["Dismount"] == "OFF" ) then
		EzDismount_Text_Status_VOFF:SetText("[OFF]");
	end

	if (EzDismount_Config[EzDPlayer]["Dismount"] == "ON" ) then
		EzDismount_Text_Status_VON:SetText("[ON]");
	end

        -- Auctioneer Dismount
        EzDismount_Text_Auction:SetText("Automatic auctioneer dismount is :");
        if ( EzDismount_Config[EzDPlayer]["Auction"] == "OFF" ) then
		EzDismount_Text_Auction_VOFF:SetText("[OFF]");
        else
                EzDismount_Text_Auction_VON:SetText("[ON]");
	end

	-- Auto-Stand
	EzDismount_Text_Stand:SetText("Automatic stand from sit is :");
	if ( EzDismount_Config[EzDPlayer]["Stand"] == "OFF" ) then
		EzDismount_Text_Stand_VOFF:SetText("[OFF]");
        else
                EzDismount_Text_Stand_VON:SetText("[ON]");
	end

	-- Shaman
	EzDismount_Text_Shaman:SetText("Auto-cancel of Ghostwolf is :");
	if ( EzDismount_Config[EzDPlayer]["Wolf"] == "OFF" ) then
		EzDismount_Text_Shaman_VOFF:SetText("[OFF]");
	else
		EzDismount_Text_Shaman_VON:SetText("[ON]");
	end

	-- Druid
	EzDismount_Text_Druid:SetText("Auto-cancel of shapeshifts is :");
	if ( EzDismount_Config[EzDPlayer]["Druid"] == "OFF" ) then
		EzDismount_Text_Druid_VOFF:SetText("[OFF]");
	else
		EzDismount_Text_Druid_VON:SetText("[ON]");
	end

	-- Shadowform
	EzDismount_Text_Shadowform:SetText("Auto-cancel of Shadowform :");
	if ( EzDismount_Config[EzDPlayer]["Shadowform"] == "OFF" ) then
		EzDismount_Text_Shadowform_VOFF:SetText("[OFF]");
	else
		EzDismount_Text_Shadowform_VON:SetText("[ON]");
	end
	
	-- Druid Exclude Check Boxes
	EzDismount_CB1:SetChecked(EzDismount_Config[EzDPlayer]["DruidExcMoon"])
        EzDismount_CB2:SetChecked(EzDismount_Config[EzDPlayer]["DruidExcTree"])
        
        if ( EzDismount_Config[EzDPlayer]["Druid"] == "OFF" ) then
           EzDismount_CB1:Disable();
           EzDismount_CB2:Disable();
        else
           EzDismount_CB1:Enable();
           EzDismount_CB2:Enable();
        end
        
        -- Link Unshift to Dismount
	EzDismount_US:SetChecked(EzDismount_Config[EzDPlayer]["LinkShift"])

        if ( EzDismount_Config[EzDPlayer]["Dismount"] == "OFF" ) then
           EzDismount_US:Disable();
        else
           EzDismount_US:Enable();
        end

end

------------------------
-- Check UI Events Event
------------------------
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

--------------------------------------------------------------
-- Look for Mount Buff Icon and cancel it (Alternate Function)
--------------------------------------------------------------
function EzD_getdown()

  EzD_dismount();

end

-----------------------------
-- Dismount/Cancel Mount Buff
-----------------------------
function EzD_dismount()
  
   Dismount();
  
   -- Should we drop a shapeshift? only if Linked Checkbox is selected
   if EzDismount_Config[EzDPlayer]["LinkShift"] == 1 then
      EzD_unshift();
   end

end

---------------------------------------
-- Dismount/Cancel Mount Buff (Old Way)
---------------------------------------
function EzD_dismountOld()
   
   -- Loop thru the 16 max player buffs
   for i=0,16,1 do

       -- Skip over excluded buff names
       if not EzD_exclude(i) then

          -- Look for mount buff texture, then buff name
          if EzD_checktext(i, EzDMountText.Mount) then
             CancelPlayerBuff(i);
             break;
          elseif EzD_checkname(i, EzDMountBuff.Mount) then
             CancelPlayerBuff(i);
             break;
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

-----------------------------------------------------
-- Check Buff Texture of Buff ID against passed Table
-----------------------------------------------------
function EzD_checktext(i, pTable)

  local bufftext;
  local result = false;

  bufftext = GetPlayerBuffTexture(i);

  if ( bufftext ~= nil ) then
     for _, value in pairs(pTable) do
         if string.find(string.lower(bufftext), string.lower(value)) then
            result = true;
            break;
         end
      end
  end

  return result

end

--------------------------------------------------
-- Check Buff Name of Buff ID against passed Table
--------------------------------------------------
function EzD_checkname(i, pTable)

  local buffname;
  local result = false;

  buffname = GetPlayerBuffName(i);

  if ( buffname ~= nil ) then
     for _, value in pairs(pTable) do
         if string.find(string.lower(buffname), string.lower(value)) then
            result = true;
            break;
         end
      end
  end

  return result

end


--------------------------------------
-- Exclude as mount based on buff name
--------------------------------------
function EzD_exclude(i)

  local buffname;
  local result = false;

  buffname = GetPlayerBuffName(i);

  if ( buffname ~= nil ) then
     for _, value in pairs(EzDMountBuff.Exclude) do
         if ( string.lower(value) == string.lower(buffname) ) then
            result = true;
            break;
         end
      end
  end

  return result

end

-------------------------------------------
-- Exclude Shapeshift based on buff texture
-------------------------------------------
function EzD_shiftexclude(i)

  local bufftext;
  local result = false;

  bufftext = GetPlayerBuffTexture(i);

  if ( bufftext ~= nil ) then
     for _, value in pairs(EzDShiftExc) do
         if string.find(string.lower(bufftext), string.lower(value)) then
            result = true;
            break;
         end
      end
  end

  return result

end


--------------------------------------------------------------------------
-- Dump current Buffs to chat window, also show Mounted Status
-------------------------------------------------------------------------
function EzDismount_debug()

   local bufftext;
   local buffname;
   local debugmsg;

   EzD_chat("** " ..EzDismount_fullver.. " Debug Info **");

   if IsMounted() then
      EzD_chat("Mounted : Yes");
   else
      EzD_chat("Mounted : No");
   end

   EzD_chat("- Current Buff List -");

   for i=0,16,1 do

      buffname = GetPlayerBuffName(i);
      bufftext = GetPlayerBuffTexture(i);

      if (bufftext ~= nil) then
         debugmsg = ("(" .. i .. ") [" ..buffname.. "]  "..bufftext);
         EzD_chat(debugmsg);
      end

   end

end

--------------------------
-- Show slash command help
--------------------------
function EzDismount_help()

  EzD_chat("## " .. EzDismount_fullver .. " ##", 0.0, 1.0, 0.0);

  for _, value in pairs(EzDHelp.List) do
      EzD_chat(value, 0.0, 1.0, 0.0);
  end

end

--------------------------------------
-- Put Text in the Default Chat Window
--------------------------------------
function EzD_chat(msg)

  DEFAULT_CHAT_FRAME:AddMessage(msg, 0.0, 1.0, 0.0);

end

-------------------------------------------
-- Dump current target Buffs to chat window
-------------------------------------------
function EzDismount_debugtarget()

   local bufftext;
   local buffname;
   local debugmsg;

   EzD_chat("** " ..EzDismount_fullver.. " Target Debug Info **");
   EzD_chat("- Current Buff List -");

   for i=0,16,1 do

      buffname = UnitBuff("target", i);
      _,_,bufftext = UnitBuff("target", i);

      if (bufftext ~= nil) then
         debugmsg = ("(" .. i .. ") [" ..buffname.. "]  "..bufftext);
         EzD_chat(debugmsg);
      end

   end

end


---------------------------------
-- Print Shapeshift Exclude Table
---------------------------------
function EzDismount_table()

     for _, value in pairs(EzDShiftExc) do
             EzD_chat(value);
     end

     EzD_chat("** End of EzDShiftExc Table **");

end


--------------------------------
-- Load Shapeshift Exclude Table
--------------------------------
function EzD_loadshiftexc()

     EzDShiftExc = {};

     -- Druid
     if EzDismount_Config[EzDPlayer]["DruidExcMoon"] == 1 then
        table.insert(EzDShiftExc, EzDExcludeMoon);
     end

     if EzDismount_Config[EzDPlayer]["DruidExcTree"] == 1 then
        table.insert(EzDShiftExc, EzDExcludeTree);
     end


end

----------------------------------
-- Toggle Exclude Moonkin Checkbox
----------------------------------
function EzD_checkmoon()

   local r = 0;

   if EzDismount_CB1:GetChecked() == 1 then
      r = 1;
   end

   EzDismount_Config[EzDPlayer]["DruidExcMoon"]= r;

   EzD_loadshiftexc();

end

-------------------------------
-- Toggle Exclude Tree Checkbox
-------------------------------
function EzD_checktree()

   local r = 0;

   if EzDismount_CB2:GetChecked() == 1 then
      r = 1;
   end
   
   EzDismount_Config[EzDPlayer]["DruidExcTree"]= r;

   EzD_loadshiftexc();

end

----------------------------------
-- Toggle Link Unshift to Dismount
----------------------------------
function EzD_checkshift()

   local r = 0;

   if EzDismount_US:GetChecked() == 1 then
      r = 1;
   end
   
   EzDismount_Config[EzDPlayer]["LinkShift"]= r;

end

----------------------------------
-- One click autounshift.
----------------------------------

--[[
TODO
Mouse clicks (important for stuff in bags).
Support for bar addons.
Dismount support.
Spell queueing - will it queue spells while you're in shapeshift form, or do I need to check if the cooldown of a spell is < 400ms rather than that it is zero?

/script getkey("1")

/script getkey("C")

/dump getkey("HOME")

-- hooksecurefunc is a post hook so this probably won't work.
/script hooksecurefunc("CastSpellByName", function(...) print("bla", ...) end)
/script hooksecurefunc("CastSpell", function(...) print("bla", ...) end)
/script hooksecurefunc(CastSpellByName, function(...) print("bla", ...) end)
/script hooksecurefunc("SecureActionButton_OnClick", function(...) print("bla", ...) CancelShapeshiftForm() end)

/dump ActionButton_GetPagedID("MULTIACTIONBAR4BUTTON7")
/dump ActionButton_GetPagedID("MultiBarLeftButton7")

/script for i,v in pairs(_G) do if strfind(i, "GetAction") then print(i,v) end end
/script for i,v in pairs(_G) do if strfind(i, "cast") then print(i,v) end end

/dump ("cats"):match("cats")
/dump ("ACTIONBUTTON12"):match("ACTIONBUTTON(%d+)")
/dump ("MULTIACTIONBAR2BUTTON12"):match("MULTIACTIONBAR(%d+)BUTTON(%d+)")

/dump SecureCmdOptionParse("/cast Lightning Bolt")
/dump SecureCmdOptionParse("/cast [harm]Purge(Rank 1);Cure Poison")

1-12,13-24: ActionButtonN
MultiBarBottomLeftButton1-12: 61-72 (1)
MultiBarBottomRightButton1-12: 49-60 (2)
MultiBarLeftButton1-12: 37-48 (4)
MultiBarRightButton1-12: 25-36 (3)
--]]

--[[
/dump IsUsableSpell("Hearthstone")
/dump IsUsableItem("Hearthstone")
--]]

local debug = true

local function getButtonForBinding(bindingName)
	local buttonNum = bindingName:match("ACTIONBUTTON(%d+)")
	if buttonNum then return _G["ActionButton"..buttonNum] end

	local barNum, buttonNum = bindingName:match("MULTIACTIONBAR(%d+)BUTTON(%d+)")
	if barNum and buttonNum and tonumber(barNum) >= 1 and tonumber(barNum) <= 4 then
		local buttonName = (
			barNum == "1" and "MultiBarBottomLeftButton" or
			barNum == "2" and "MultiBarBottomRightButton" or
			barNum == "3" and "MultiBarRightButton" or
			"MultiBarLeftButton"
		)..buttonNum
		return _G[buttonName]
	end
	-- return nil

	-- error("unrecognized binding \""..bindingName.."\"")
end

local function getActionButtonSpell(button)
	local action = button.action
	if not action then return end

	-- print("button is", button)
	-- print("action", action)
	local type, id, subtype = GetActionInfo(action)
	-- print(type, id, subtype)
	return type, id
end

local function getkey(button)
	-- print(GetBindingAction(button), GetBindingByKey(button))
	local bindingName = GetBindingByKey(button)

	if bindingName == nil then
		-- print("binding is nil")
		return
	end

	if bindingName:find("^SPELL") then
		return "spell", bindingName:match("SPELL%s(.*)")
	elseif bindingName:find("^MACRO") then
		return "macro", bindingName:match("MACRO%s(.*)")
	elseif bindingName:find("^ITEM") then
		return "item", bindingName:match("ITEM%s(.*)")
	else
		local button
		if bindingName:find("^CLICK") then
			local buttonName, keyToClickWith = bindingName:match("CLICK%s(.*):(.*)")
			-- print(buttonName, keyToClickWith)
			button = _G[buttonName]
		else
			button = getButtonForBinding(bindingName)
		end

		if not button then return end
		return getActionButtonSpell(button)
	end
end

local function addModifiersToBaseKeyName(baseKeyName)
	local t = {}
	-- Order matters! "SHIFT-ALT-T" is not a valid keybind!
	t[#t+1] = IsAltKeyDown() and "ALT" or nil
	t[#t+1] = IsControlKeyDown() and "CTRL" or nil
	t[#t+1] = IsShiftKeyDown() and "SHIFT" or nil
	t[#t+1] = baseKeyName
	return table.concat(t, "-")
end

local playerIsMoving = false

local function Stand()
	if not playerIsMoving then DoEmote("stand") end -- Standing while moving will trigger an error message.
end

local function decideToCancelForm(type, spell)
	if type == "spell" then
		local usable, nomana = IsUsableSpell(spell)
		local startTime, cd = GetSpellCooldown(spell)
		local spellName,_,_,castTime,_,_,_ = GetSpellInfo(spell)
		local inRange = IsSpellInRange(spellName, UnitExists("target") and "target" or "player") -- TODO check whether user has autoselfcast? Or, maybe just use "target" as it will return nil for self cast spells which is fine.
		-- Unfortunately, we will still unshapeshift for the "Invalid target" error. This is not a downgrade over 2-press EzDismount however.
		if not usable and not nomana and cd == 0 and (not inRange or inRange == 1) and (castTime == 0 or not playerIsMoving) then
			CancelShapeshiftForm()
			Stand()
		end
	elseif type == "item" then
		local usable, mysteryreturnvalue = IsUsableItem(spell)
		local startTime, cd = GetSpellCooldown(spell)
		if not usable and cd == 0 then
			CancelShapeshiftForm()
			Stand()
		end

		if debug and mysteryreturnvalue then Message(spell.." has second return value true!") end
	elseif type == "macro" then
		if true or not debug then return end

		print("type is macro")
		local _,_,body,_ = GetMacroInfo(spell)
		print("SecureCmdOptionParse", SecureCmdOptionParse(body))

		decideToCancelForm(typeResult, spellResult)
	else error("unknown type") end
end

local function isShapeshiftedOrMounted() -- TODO remove.
	return GetShapeshiftForm(true) ~= 0 or IsMounted()
end

--[[
/script local f=CreateFrame("Frame")f:RegisterEvent("UI_ERROR_MESSAGE")f:SetScript("OnEvent",function(self,event,...)DoEmote("stand")end)f:EnableKeyboard(true)f:SetPropagateKeyboardInput(true)f:SetScript("OnKeyDown",function(self,key)DoEmote("stand")end)
/script local f=CreateFrame("Frame")f:RegisterEvent("UI_ERROR_MESSAGE")f:SetScript("OnEvent",function(self,event,...)DoEmote("stand")end)f:EnableKeyboard(true)f:SetPropagateKeyboardInput(true)f:SetScript("OnKeyDown",function(self,key)DoEmote("stand")end)
--]]


local actionButtonNames = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton"}
function getActionButtons()
	local n = 1
	return function()
		if n > 60 then return end
		
		local button = _G[actionButtonNames[math.floor((n - 1) / 12) + 1]..((n - 1) % 12 + 1)]

		n = n + 1
		return button
	end
end

local hookedActionButtonsOwner = CreateFrame("BUTTON", nil, nil, "SecureHandlerClickTemplate,SecureActionButtonTemplate")
hookedActionButtonsOwner:RegisterForClicks("AnyDown")
function hookedActionButtonsOwner:stand()
	if debug then print("standing from actionbutton mouse click") end
	DoEmote("stand")
end -- TODO can I have this function in F instead?
local function hookActionButton(button)
	hookedActionButtonsOwner:WrapScript(button, "OnClick", (debug and "print('prehook',button,down,[[owner]],owner,[[control]],control) " or "").."owner:CallMethod('stand')")
end

local function hookActionButtons()
	for button in getActionButtons() do
		hookActionButton(button)
	end
end

-- Actually setting stuff up that isn't defining functions.

hookActionButtons()

local f = CreateFrame("Frame")
f:EnableKeyboard(true)
f:SetPropagateKeyboardInput(true)
f:RegisterEvent("PLAYER_STARTED_MOVING")
f:RegisterEvent("PLAYER_STOPPED_MOVING")
f:RegisterEvent("UI_ERROR_MESSAGE")
f:SetScript("OnEvent", function(self, event, ...)
	if debug then if event == "UI_ERROR_MESSAGE" and strfind(select(1, ...), "shapeshift") then print("Should have cancelled form!", ...) end end
	if event == "PLAYER_STARTED_MOVING" then
		playerIsMoving = true
	elseif event == "PLAYER_STOPPED_MOVING" then
		playerIsMoving = false
	end
end)
-- TODO consider hooking the keyup? May matter especially for spellbook where dragging probably would dismount you.
f:SetScript("OnKeyDown", function(self, key)
	key = addModifiersToBaseKeyName(key)

	local type, spell = getkey(key)
	if not type then return end
	-- if debug then print(key, "\""..type.."\"", spell) end

	decideToCancelForm(type, spell)
end)

--[[
ContainerFrame[1-5]Item[1-n]
--]]

-- if debug and false then
if debug and false then
	local lastFrame
	WorldFrame:HookScript("OnUpdate", function(self, button)
		local frame = GetMouseFocus()
		if frame == lastFrame then return end
		lastFrame = frame
		if not frame then print("frame is nil") return end

		local type, spell = getActionButtonSpell(frame)
		if type and spell then
			print("action button", type, spell)
			return
		end

		local bagIndex, itemIndex = frame:GetName():match("ContainerFrame(%d)Item(%d+)")
		if bagIndex and itemIndex then
			local _, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bagIndex - 1 --[[backback is 0 in this case even though it's 1 in the frame's name]], itemIndex)
			print("bag item", itemID)
			return
		end

		print("new frame, type unknown")
	end)
end

--[[
-- /dump UnitName("mouseover")
-- /dump GameTooltip:GetUnit()

#showtooltip Charge
#show Charge
/cast Battle Stance
/cast Charge

#showtooltip Hamstring
#show Hamstring
/cast [stance:2] Battle Stance
/cast Hamstring

WorldFrame:HookScript("OnMouseDown", function(self, button)
	print("onmousedown")
	local frame = GetMouseFocus()
	if frame == lastFrame then return end
	lastFrame = frame
	if not frame then print("frame is nil") return end

	local type, spell = getActionButtonSpell(frame)
	if type and spell then
		print("action button", type, spell)
		decideToCancelForm(type, spell)
		return
	end

	local bagIndex, itemIndex = frame:GetName():match("ContainerFrame(%d)Item(%d+)")
	if bagIndex and itemIndex then
		local _, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bagIndex - 1, itemIndex) -- backback is 0 in this case even though it's 1 in the frame's name
		print("bag item", itemID)
		decideToCancelForm("item", itemID)
		return
	end

	print("new frame, type unknown")
end)
--]]


--[[
/script function ActionButton4:stand() print("standing") DoEmote("stand") end -- TODO can I have this function in F instead?
/script f:UnwrapScript(ActionButton4, "OnClick") -- TODO why doesn't the after script run?
--]]

--[[
/script ActionButton4:HookScript("OnClick", function() print("standing") DoEmote("stand") end) -- BAD

/script levelmin=30 levelmax=50
/script levelmin=50 levelmax=60
/script levelmin=1 levelmax=60

/script PickupContainerItem(0, 2) PickupInventoryItem("MainHandSlot") PickupContainerItem(0, 3) PickupInventoryItem("OffHandSlot")--]]

