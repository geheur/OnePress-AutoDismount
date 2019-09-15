local addonName, addonTable = ...
_G[addonName] = addonTable

--[[
/script EzDismount.debug = true
--]]

local function debug()
	return true or addonTable.debug
end
local function dp(...)
	if debug() then print(...) end
end

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
	return nil
end

local function getActionButtonSpell(button)
	local action = button.action
	if not action then return end

	local type, id, subtype = GetActionInfo(action)
	return type, id
end

local function getkey(button)
	local bindingName = GetBindingByKey(button)

	if bindingName == nil then
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

local function getSpellsCastByMacro(macroBody)
	local spells = {}
	for line in macroBody:gmatch("[^\r\n]+") do
		local n1,n2 = line:find("^/cast")
		if not n1 then n1,n2 = line:find("^/use") end
		if n1 then
			local spellToCast, target = SecureCmdOptionParse(line:sub(n2 + 1))
			tinsert(spells, spellToCast)
			dp("line", ":", line, ":", line:sub(n2 + 1), ":", spellToCast)
		end
	end
	return spells
end

local function decideToCancelForm(type, spell)
	if type == "spell" then
		local usable, nomana = IsUsableSpell(spell)
		local startTime, cd = GetSpellCooldown(spell)
		local spellName,_,_,castTime,_,_,_ = GetSpellInfo(spell)
		local inRange = IsSpellInRange(spellName, UnitExists("target") and "target" or "player") -- TODO check whether user has autoselfcast? Or, maybe just use "target" as it will return nil for self cast spells which is fine.
		-- Unfortunately, we will still unshapeshift for the "Invalid target" error. This is not a downgrade over 2-press EzDismount however.
		dp(tostring(not usable and not nomana and cd == 0 and (not inRange or inRange == 1) and (castTime == 0 or not playerIsMoving))..":",
				not usable, not nomana, cd == 0, (not inRange or inRange == 1), (castTime == 0 or not playerIsMoving))
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

		if debug() and mysteryreturnvalue then Message(spell.." has second return value true!") end
	elseif type == "macro" then
		local _,_,body,_ = GetMacroInfo(spell)
		local spells = getSpellsCastByMacro(body)
		for _,spellToCast in ipairs(spells) do
			local s1, s2 = IsUsableSpell(spellToCast)
			local i1, i2 = IsUsableSpell(spellToCast)
			local spellType
			if s1 or s2 then
				spellType = "spell"
			elseif i1 or i2 then
				spellType = "item"
			end
			-- spellType == nil might mean that the spell/item cannot be used, or that there's a typo.
			if spellType then decideToCancelForm(spellType, spellToCast) end
		end
	else error("unknown type") end
end

-- 1 mod n = 1
-- n mod n = n
local function oneIndexedModulo(dividend, divisor)
	return ((dividend - 1) % divisor) + 1
end

-- 1 / n = 1
-- n / n = 1
local function oneIndexedIntegerDivision(dividend, divisor)
	return math.floor((dividend - 1) / divisor) + 1
end

local actionButtonNames = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton"}
function getActionButtonsVanillaUi()
	local n = 1
	return function()
		if n > 60 then return end
		
		local button = _G[actionButtonNames[oneIndexedIntegerDivision(n, 12)]..oneIndexedModulo(n, 12)]

		n = n + 1
		return button
	end
end

--[[
function getActionButtonsBartender()
	print("TODO bartender support")
	-- TODO
end
--]]

local hookedButtonsOwner = CreateFrame("BUTTON", nil, nil, "SecureHandlerClickTemplate,SecureActionButtonTemplate")
hookedButtonsOwner:RegisterForClicks("AnyDown")
function hookedButtonsOwner:actionButtonPressed(button)
	local type, spell = getActionButtonSpell(button)
	dp("pressed", type, spell)
	decideToCancelForm(type, spell)
end
local funcIndex = 1
local function createFunc(owner, button, func)
	local name = "func"..funcIndex
	funcIndex = funcIndex + 1
	owner[name] = function(self)
		func(self, button)
	end
	return name
end
local function hookActionButton(button)
	local funcName = createFunc(hookedButtonsOwner, button, hookedButtonsOwner.actionButtonPressed)
	hookedButtonsOwner:WrapScript(button, "OnClick", (debug() and "print('prehook',button,down,[[owner]],owner,[[control]],control) " or "").."owner:CallMethod('"..funcName.."', self)")
end

local function hookActionButtons()
	-- if Bartender4 then
		-- for button in getActionButtonsBartender() do
			-- hookActionButton(button)
		-- end
	-- else
		for button in getActionButtonsVanillaUi() do
			hookActionButton(button)
		end
	-- end
end

-- Actually setting stuff up that isn't defining functions.

hookActionButtons()

local f = CreateFrame("Frame")
f:EnableKeyboard(true)
f:SetPropagateKeyboardInput(true)
f:RegisterEvent("PLAYER_STARTED_MOVING")
f:RegisterEvent("PLAYER_STOPPED_MOVING")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_STARTED_MOVING" then
		playerIsMoving = true
	elseif event == "PLAYER_STOPPED_MOVING" then
		playerIsMoving = false
	end
end)
-- TODO consider hooking the keyup?
f:SetScript("OnKeyDown", function(self, key)
	key = addModifiersToBaseKeyName(key)

	local type, spell = getkey(key)
	if not type then return end
	dp(key, "\""..type.."\"", spell)

	decideToCancelForm(type, spell)
end)
