local addonName, addonTable = ...

--[[
/script EzDismount.debug = true
--]]

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

	local type, id, subtype = GetActionInfo(action)
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
		if addonTable.debug then print(tostring(not usable and not nomana and cd == 0 and (not inRange or inRange == 1) and (castTime == 0 or not playerIsMoving))..":",
				not usable, not nomana, cd == 0, (not inRange or inRange == 1), (castTime == 0 or not playerIsMoving)) end
		if not nomana and cd == 0 and (not inRange or inRange == 1) and (castTime == 0 or not playerIsMoving) then
			if not usable then
				CancelShapeshiftForm()
			end
			Stand()
		end
	elseif type == "item" then
		local usable, mysteryreturnvalue = IsUsableItem(spell)
		local startTime, cd = GetSpellCooldown(spell)
		if not usable and cd == 0 then
			CancelShapeshiftForm()
			Stand()
		end

		if addonTable.debug and mysteryreturnvalue then Message(spell.." has second return value true!") end
	elseif type == "macro" then
		if true or not addonTable.debug then return end

		print("type is macro")
		local _,_,body,_ = GetMacroInfo(spell)
		print("SecureCmdOptionParse", SecureCmdOptionParse(body))

		decideToCancelForm(typeResult, spellResult)
	else error("unknown type") end
end

local function isShapeshiftedOrMounted() -- TODO remove.
	return GetShapeshiftForm(true) ~= 0 or IsMounted()
end

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
	if addonTable.debug then print("standing from actionbutton mouse click") end
	DoEmote("stand")
end -- TODO can I have this function in F instead?
local function hookActionButton(button)
	hookedActionButtonsOwner:WrapScript(button, "OnClick", (addonTable.debug and "print('prehook',button,down,[[owner]],owner,[[control]],control) " or "").."owner:CallMethod('stand')")
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
	if addonTable.debug then if event == "UI_ERROR_MESSAGE" and strfind(select(1, ...), "shapeshift") then print("Should have cancelled form!", ...) end end

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
	if addonTable.debug then print(key, "\""..type.."\"", spell) end

	decideToCancelForm(type, spell)
end)

if addonTable.debug and false then
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
-- TODO
Add this for items in bags.
Support for bar addons.
Dismount support.
Investigate spell queueing - will it queue spells while you're in shapeshift form, or do I need to check if the cooldown of a spell is < 400ms rather than that it is zero?

Default UI action button names.
ActionButton1-12: 1-12,13-24
MultiBarBottomLeftButton1-12: 61-72 (1)
MultiBarBottomRightButton1-12: 49-60 (2)
MultiBarLeftButton1-12: 37-48 (4)
MultiBarRightButton1-12: 25-36 (3)

-- Crap:

/script function ActionButton4:stand() print("standing") DoEmote("stand") end -- TODO can I have this function in F instead?
/script f:UnwrapScript(ActionButton4, "OnClick") -- TODO why doesn't the after script run?

/script ActionButton4:HookScript("OnClick", function() print("standing") DoEmote("stand") end) -- BAD

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
--]]

--[[
Crashing script. Lol.
/script local f=CreateFrame("Frame")f:RegisterEvent("UI_ERROR_MESSAGE")f:SetScript("OnEvent",function(self,event,...)DoEmote("stand")end)f:EnableKeyboard(true)f:SetPropagateKeyboardInput(true)f:SetScript("OnKeyDown",function(self,key)DoEmote("stand")end)
/script local f=CreateFrame("Frame")f:RegisterEvent("UI_ERROR_MESSAGE")f:SetScript("OnEvent",function(self,event,...)DoEmote("stand")end)f:EnableKeyboard(true)f:SetPropagateKeyboardInput(true)f:SetScript("OnKeyDown",function(self,key)DoEmote("stand")end)
--]]

--[[
/dump IsUsableSpell("Hearthstone")
/dump IsUsableItem("Hearthstone")
--]]

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

