SetDefaultTab ('Tools')

local sharedSpells = {
	["Sayan Power"] = {"Oozaru Power"},
	["Tetsu no kawa"] = {"Kinzoku no Kawa"},
	["Power Impact"] = {"Power Impact Reverse"},
	["Power Impact Reverse"] = {"Power Impact"},
	["Ultimate Power"] = {"Destruction Power"},
	["Oozaru Transf"] = {"Oozaru Transformation"}
};

local msgStart = "You are exhausted in ";
local config = tyrBot.storage.especiaisConfig.spells;

local doSetEntry = function(name, value)
	local entry = tyrBot.getSpellData(name);
	if (not entry) then return; end
	if (entry.cooldownTime ~= value) then
		entry.cooldownTime = value;
	end
end

local setCooldown = function(spellName, cooldown)
	local sharedCooldowns = sharedSpells[spellName];
	local time = os.time() + cooldown;
	if (sharedCooldowns ~= nil) then
		for _, spell in ipairs(sharedCooldowns) do
			doSetEntry(spell, time);
		end
	end
	doSetEntry(spellName, time);
end


onTextMessage(function(mode, text)
	local _, startIndex = text:find(msgStart);
	if (not startIndex) then return; end
	local split = text:sub(startIndex):split("for:");
	local spellName = split[1]:trim();
	local cooldown = tonumber(text:match("%d+"));
	if (not cooldown) then return; end

	setCooldown(spellName, cooldown);
end)

macro(100, function()
	local data = {};
	local time = os.time();
	for type, values in pairs(config) do
		for _, entry in ipairs(values) do
			local cooldownTime = entry.cooldownTime;
			if ((cooldownTime or 0) >= time) then
				local formattedName = entry.spellName:ucwords();
				if (sharedSpells[formattedName]) then
					data[formattedName] = cooldownTime;
				end
			end
		end
	end
	
	for name, cooldown in pairs(data) do
		local sharedCooldowns = sharedSpells[name];
		for _, spell in ipairs(sharedCooldowns) do
			doSetEntry(spell, cooldown);
		end
	end
	
	data = nil;
end);



local name = name();
if (type(storage.cooldownTable) ~= "table") then
	storage.cooldownTable = {};
end
if (storage.cooldownTable[name] == nil) then
	storage.cooldownTable[name] = {};
end
cooldownTable = storage.cooldownTable[name];


setCooldownTime = function(var_name, value)
	cooldownTable[var_name] = (os.time() + tonumber(value));
end

isOnCooldown = function(var_name)
	local value = (cooldownTable[var_name] or 0);
	return os.time() < value;
end;

local bolAction = "hi";
local blessAction = "hi";

hasProtections = function()
	if (storage.bless == player:getId()) then
		local ringItem = getFinger();
		if (ringItem and ringItem:getId() == 6300) then
			return true;
		end
	end
end

local talk = function(msg)
	if (msg == "hi") then
		g_game.talkChannel(2, 0, msg); -- whisper
		delay(1000);
		return;
	end
	NPC.say(msg);
end

blessMacro = macro(1, function(self)
	if (storage.bless == player:getId()) then
		return self.setOff();
	end
	if (checkBless == nil) then
		NPC.say("!bless");
		return delay(300);
	end
	
	local playerPos = player:getPosition();
	for _, spec in ipairs(getSpectators(playerPos.z)) do
		if (spec:isNpc() and spec:getName() == "Blessed Tapion") then
			local specPos = spec:getPosition();
			if (specPos ~= nil) then
				local distance = getDistanceBetween(specPos, playerPos);
				if (distance <= 1) then
					sayBless = true;
				elseif (distance >= 7) then
					player:autoWalk(specPos);
					delay(500);
				end
				g_game.use(spec:getTile():getTopUseThing());
				break;
			end
		end
	end
	if (sayBless == true) then
		talk(blessAction);
	end
end)

bolMacro = macro(1, function(self)
	if (blessMacro.isOn()) then
		return;
	end
	if (getFinger()) then
		modules.game_console.removeTab("NPCs");
		NPC.closeTrade();
		return self.setOff();
	end

	local playerPos = player:getPosition();
	for _, spec in ipairs(getSpectators(playerPos.z)) do
		if (spec:isNpc() and spec:getName() == "Yama Helper") then
			local specPos = spec:getPosition();
			if (specPos ~= nil) then
				local distance = getDistanceBetween(specPos, playerPos);
				if (distance <= 1) then
					sayBol = true;
				elseif (distance >= 7) then
					player:autoWalk(specPos);
					delay(500);
				end
				g_game.use(spec:getTile():getTopUseThing());
				break;
			end
		end
	end
	
	if (not sayBol) then
		return;
	end
	if (bolAction ~= true) then
		talk(bolAction);
		return;
	end
	NPC.buy(6299, 1)
	delay(500);
end)

onTalk(function(name, level, mode, text, channelId, pos)
	if (blessMacro.isOff() and bolMacro.isOff()) then
		return;
	end
	if (mode ~= 51) then
		return;
	end
    if (name ~= "Blessed Tapion" and name ~= "Yama Helper") then
		if (bolAction == "hi" or blessAction == "hi") then
			for i = 1, 5 do
				schedule(i * 200, function()
					talk("bye");
				end)
			end
		end
		return
	end
	if (text:find("Estou aqui para oferecer")) then
		blessAction = "yes"
	elseif text:find("{protegido} !") then
		blessMacro.setOff();
		storage.bless = player:getId();
		modules.game_console.removeTab("NPCs");
		talkPrivate(player:getName(), "Bless comprado!");
	elseif text:find("Estou ajudando o Yama aqui no mund") then
		bolAction = "trade"
	elseif text:find("Don't you like it?") then
		bolAction = true
	end
end)

onTextMessage(function(mode, text)
	if (text == "Not protected!") then
		checkBless = true;
	elseif (text == "Protected!") then
		blessMacro.setOff();
		storage.bless = player:getId();
	end
end)

onTextMessage(function(mode, text)
	if (text:find("pode se transformar!")) then
		outfitTransform = player:getOutfit().type;
	elseif (text:find("precisa estar no level")) then
		levelTransform = tonumber(text:match("%d+"));
	end
end)

transformMacro = macro(1, function()
	if (levelTransform and level() < levelTransform) then
		return;
	end
	if (player:getOutfit().type == outfitTransform) then
		return;
	end

	say("!transformar");
end);
