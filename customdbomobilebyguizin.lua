
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
end
  
  
  local isStacking = false;
  local stackMonster = nil;
  local current_vocation;
  
  local g_mouse = modules.corelib.g_mouse;
  local g_keyboard = modules.corelib.g_keyboard;
  
  local stackSpells = {
	  {
		  name = "Shunkanido",
		  distance = 8
	  },
	  {
		  name = "Teleport",
		  distance = 4
	  }
  };
  
  local availableKeys = {
	  ['Up'] = { 0, -6 },
	  ['Down'] = { 0, 6 },
	  ['Left'] = { -7, 0 },
	  ['Right'] = { 7, 0 }
  };
  
  local directions = {
	  ["Up"] = "n",
	  ["Down"] = "s",
	  ["Left"] = "w",
	  ["Right"] = "e"
  };
  
  local stackData = {
	  ["n"] = function(playerPos, creaturePos) return playerPos.y > creaturePos.y; end,
	  ["s"] = function(playerPos, creaturePos) return playerPos.y < creaturePos.y; end,
	  ["w"] = function(playerPos, creaturePos) return playerPos.x > creaturePos.x; end,
	  ["e"] = function(playerPos, creaturePos) return playerPos.x < creaturePos.x; end
  };
  
  local sortData = {
	  ["n"] = function(a, b) return a.position.y < b.position.y; end,
	  ["s"] = function(a, b) return a.position.y > b.position.y; end,
	  ["w"] = function(a, b) return a.position.x < b.position.x; end,
	  ["e"] = function(a, b) return a.position.x > b.position.x; end
  };
  
  local doFilter = function(data, dir)
	  local i = 1;
	  local canStack = stackData[dir];
	  local playerPos = player:getPosition();
	  while true do
		  local currentValue = data[i];
		  if (currentValue == nil) then
			  break;
		  end
  
		  if (not canStack(playerPos, currentValue.position)) then
			  table.remove(data, i);
			  i = 0;
		  end
		  i = i + 1;
	  end
  end
  
  local function setStacking(value)
	  isStacking = value;
	  if (keepTarget ~= nil) then
		  keepTarget.isStacking = value;
	  end
  
	  if (value == true and tyrBot) then
		  tyrBot.comboDelay = now + 500;
	  end
  
	  if (value == false and stackMonster ~= nil and stackMonster == g_game.getAttackingCreature()) then
		  stackMonster = nil;
		  g_game.cancelAttack();
	  end
  end
  
  function Stack()
	  local playerPos = player:getPosition();
	  local creatures = {};
	  local spectators = getSpectators(playerPos.z);
  
	  -- Adicionando monstros à lista de criaturas
	  for _, creature in ipairs(spectators) do
		  if (creature:isMonster()) then
			  local creaturePos = creature:getPosition();
			  if (creaturePos ~= nil and getDistanceBetween(playerPos, creaturePos) >= 1) then
				  local data = {
					  creature = creature,
					  position = creaturePos
				  };
				  table.insert(creatures, data);
			  end
		  end
	  end
  
	  -- Ordena as criaturas pela distância em relação ao jogador
	  table.sort(creatures, function(a, b) return getDistanceBetween(playerPos, a.position) < getDistanceBetween(playerPos, b.position); end);
  
	  -- Se não houver monstros, sai da função
	  local closestMonster = creatures[1];
	  if (closestMonster == nil) then
		  return false;
	  end
  
	  -- Ataca o monstro mais próximo
	  setStacking(true);
	  stackMonster = closestMonster.creature;
  
	  if (g_game.getAttackingCreature() ~= closestMonster.creature) then
		  g_game.attack(closestMonster.creature);
	  end
  
	  -- Verifica a distância para decidir qual magia usar
	  local distance = getDistanceBetween(playerPos, closestMonster.position);
	  
	  -- Usa Shunkanido no último monstro com distância de 8 e Teleport no monstro mais próximo com distância de 4
	  if (distance > 7) then
		  say("Shunkanido");
	  else
		  say("Teleport");
	  end
  
	  return true;
  end
  
  macro(1, function()
	  if (g_keyboard.isKeyPressed("F2")) then
		  if (Stack()) then return; end
	  end
	  setStacking(false);
  end)
  
  


local lastRegeneration;
macro(1, function()
    if (player:getLevel() < 10) then return; end
    if (hppercent() < 100 or lastRegeneration == nil) then
        local headers = {"Majin", "Namekian", "Big", ""};
        for _, header in ipairs(headers) do
            local spell = header .. " Regeneration";
            say(spell);
            if (lastRegeneration == spell:trim():lower()) then
                return;
            end
        end
    end
end)

onTalk(function(name, level, mode, text)
    if (name ~= player:getName()) then return; end
    if (mode ~= 44) then return; end
    
    local talked_msg = text:trim():lower();
    if (talked_msg:find("regeneration")) then
        lastRegeneration = talked_msg;
    end
    
end)



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
end)


UI.Separator()


modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/Custom-mobile-NTO/refs/heads/main/GateKeaper.lua', function(script)
assert(loadstring(script))()
end);

modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/Custom-mobile-NTO/refs/heads/main/Linhadotempo.lua', function(script)
assert(loadstring(script))()
end);
UI.Separator()
    
    
    local stopPvp;
    local lastAlarm;
    
    onTextMessage(function(mode, text)
    
    if text:lower():find('was not justified') then
        stopPvp = nil;
    end
    end)
    
    onTextMessage(function(mode, text)
    if (not text:match("atualmente tem %d+ frags no dia")) then return; end
    
    local numbersOnMessage = {};
    for _, token in ipairs(text:split(" ")) do
        local asNumber = tonumber(token);
        if (asNumber ~= nil) then
            table.insert(numbersOnMessage, asNumber);
        end
    end
    
    stopPvp = false;
    local maximumFrags = {6, 14, 30};
    for index, currentFrag in ipairs(numbersOnMessage) do
        local maximumFrag = maximumFrags[index];
        if (currentFrag >= maximumFrag) then
            stopPvp = true;
            break;
        end
    end
    
    say(tr("!pvp %s", stopPvp and "off" or "on"));
    end)
    
    macro(1000, function()
    
    if (stopPvp == nil) then
        say("!frags");
        return;
    end
    
    if (stopPvp == true) then
        if ((lastAlarm or 0) < os.time()) then
            playSound("/sounds/alarm.ogg");
            lastAlarm = os.time() + 15;
        end
        say("!pvp off");
    end
    
    end)
    
    
    setDefaultTab ('Cave')
    
    macro(1, "Auto Say",  function()
    
    say(storage.Spells)
    
    end)
    
    addTextEdit("Spells", storage.Spells or "POWER DOWN", function(widget, text) 
    storage.Spells = text
    end)
    
    
    addSeparator ()
    
    
    local function Combo()
      if not g_game.isAttacking() then return false end
      say(storage.magiaantired)
     end
     
     local timeArea
     local MonstersCount
     macro(1, 'Anti-Red', function()
      MonstersCount = 0
      for _, x in ipairs(getSpectators(true)) do
       local checkPosz = math.abs(x:getPosition().z - player:getPosition().z)
       if checkPosz <= 3 then
        if (x:isPlayer() and x ~= player and x:getEmblem() ~= 1 and x:getShield() < 3) or player:getSkull() >= 3 then
         timeArea = now + 30
        elseif checkPosz == 0 and x:isMonster() and getDistanceBetween(x:getPosition(), player:getPosition()) <= 2 then
         MonstersCount = MonstersCount + 1
        end
       end
      end
      if MonstersCount > 1 and (not timeArea or timeArea < now) then
       say(storage.antiredarea)
      else
       Combo()
      end
     end)
     
     addTextEdit("ManatrainText", storage.magiaantired or "magia target", function(widget, text) 
     storage.magiaantired = text
     end)
     
     addTextEdit("ManatrainText", storage.antiredarea or "magia area", function(widget, text) 
     storage.antiredarea = text
     end)
    
     addSeparator ()

    
      addSeparator ()
    
    
      local lastPlayerDetected = 0;
    macro(100, "Player Detected", function()
        for _, creature in pairs(getSpectators(pos)) do
            if (creature:isPlayer() and creature:getId() ~= player:getId() and creature:getEmblem() ~= 1) then
                playSound("/sounds/Player_Detected.ogg");
                g_window.setTitle(player:getName() .. ' - PLAYER DETECTED!');
                lastPlayerDetected = now + 10000;
                delay(1500);
                break;
            end
        end
    
    end);
    
    macro(100, function()
        if (lastPlayerDetected < now) then
            g_window.setTitle(player:getName());
        end
    end);
    
    
    doAttack = function(target)
        if not target or not g_game.getLocalPlayer() then
            return 
        end
        if not g_game.canPerformGameAction() or target:getId() == g_game.getLocalPlayer():getId() then
            return 
        end
        if g_game.getFollowingCreature() and g_game.getFollowingCreature():getId() == target:getId() then
            g_game.cancelFollow()
        end
        if g_game.getAttackingCreature() and g_game.getAttackingCreature():getId() == target:getId() then
            g_game.cancelAttack()
            local message = OutputMessage.create()
            message:addU8(0xBE)
            message:addU32(target:getId())
            g_game.getProtocolGame():send(message)
    
        else
        g_game.attack(target)
            local message = OutputMessage.create()
            message:addU8(0xF4)
            message:addU32(target:getId())
            g_game.getProtocolGame():send(message)
        end
        end
    
    
        AtkTarget = {
        targetId = nil,
        lastTargetTime = 0,
        MESSAGE_NOT_SHOOTING_SKILLS = {
            'you can only use it on creatures.',
            'pode usar isso em criaturas.',
        }, 
        lastCast = 0,
        lastRecast = 0,
        };
    
        macro(1, function()
        local target = g_game.getAttackingCreature();
        if (target) then
            if (not AtkTarget.targetId or target:getId() ~= AtkTarget.targetId) then
                AtkTarget.targetId = target:getId();
            end
        end
        end);
        
        setDefaultTab ('Others')

        macro(200, 'Attack-Target', function()
        if (isInPz()) then return; end
        local currentTarget = g_game.getAttackingCreature();
        if (not AtkTarget.targetId) then return; end
        if (g_game.isAttacking()) then return; end
        if (AtkTarget.lastCast >= now) then return; end
        for _, creature in pairs(getSpectators()) do
            if (creature:isPlayer()) then
                if (creature:getId() == AtkTarget.targetId) then
                    doAttack(creature);
                    AtkTarget.lastCast = now + 20;
                end
            end
        end
        end);
    
        onKeyDown(function(key)
        if (key == 'Escape') then
            local target = g_game.getAttackingCreature();
            if (not target or target:getId() == AtkTarget.targetId) then
                g_game.cancelAttackAndFollow();
                AtkTarget.targetId = nil;
            end
        end
        end);
    
        onTextMessage(function (mode, text)
        text = text:lower();
        if (AtkTarget.lastRecast >= now) then return; end
        for _, message in ipairs(AtkTarget.MESSAGE_NOT_SHOOTING_SKILLS) do
            if (text:find(message) and g_game.isAttacking() and AtkTarget.targetId) then
                g_game.cancelAttack();
                AtkTarget.lastRecast = now + 20;
            end
        end
        end);
    
    
    
    
    
        
    

    
    
    macro(100, function()
    
        for a, spec in ipairs(getSpectators()) do
            
        if spec:getName():lower() then
        
        if spec:getShield() == 1 then
        
        g_game.partyJoin(spec:getId())
        
        return
        
        end
        
        end
        
        end
        
        end)
    
        macro(50,  function()
    
            if not modules.corelib.g_keyboard.areKeysPressed('F1') then
            
            if (hppercent() <= 68) then
            usewith(3587, player)
            delay(100)
            end
            
            end
            
            end)
    
            macro(50,  function()
    
                if not modules.corelib.g_keyboard.areKeysPressed('F1') then
                
                if hasManaShield() and player:getMana() <= 20 then
                usewith(3587, player)
                delay(100)
                end
                
                end
                
                end)
    
    
        
    
    local healthId = 3062
    local healthPercent = 30
    macro(200, "Pedra Reviver", function()
    if (hppercent() <= healthPercent) then
    usewith(healthId, player)
    end
    end)
    
    
    
    
    
    
    setDefaultTab ('Others')
    
         Panels.AttackLeaderTarget(batTab)
         addSeparator("sep", batTab)
         
    
                  
    
       
    
 EnemyIcon = addIcon("Enemy", {item=7657, text="Enemy"}, macro(1, function()
    local attcked = g_game.getAttackingCreature()
    local analiseHP1 = 100
    local analiseCID1 = nil

    for _, pla in ipairs(getSpectators(posz())) do
        if not attcked or attcked:isMonster() or (attcked:isPlayer() and pla:getHealthPercent() <= attcked:getHealthPercent() * 0.6) then
            if pla:isPlayer() and pla:getEmblem() ~= 1 and pla:getShield() <= 2 then
                if pla:getHealthPercent() <= analiseHP1 then
                    analiseHP1 = pla:getHealthPercent()
                    analiseCID1 = getCreatureById(pla:getId())
                end
            end
        end
    end

    if analiseCID1 ~= nil then
        g_game.attack(analiseCID1)
    end
end))

-- Adicionando movimentação do ícone na tela
EnemyIcon:breakAnchors()
EnemyIcon:move(150, 260) -- Altere os valores X (300) e Y (260) conforme a posição desejada

  
          

          local primeiro_foco = {'Rubinho Barrichello'}
  
          local segundo_foco = {'DanielAuregliett'}
          
          local terceiro_foco = {'IgorKarkaroff', 'JaoTIpoPIRANHA'}
          
          local quarto_foco = {'HAFIKI', 'GLEISSAOTANKDEGUERRA', '  HASHIRAMAcarniceiro'}
          
          macro(100, "Enemy All", function()
          
          attcked = g_game.getAttackingCreature()
          
          local analiseHP2 = 100
          
          local analiseCID2 = nil
          
          for _, pla in ipairs(getSpectators(posz())) do
          if not attcked or attcked:isMonster() or attcked:isPlayer() and pla:getHealthPercent() <= attcked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla:getEmblem() ~= 1 and pla:getShield() <= 2 then
          if table.find(primeiro_foco, pla:getName()) then
          g_game.attack(pla)
          return
          end
          end
          end
          end
          
          for _, pla in ipairs(getSpectators(posz())) do
          if not attcked or attcked:isMonster() or attcked:isPlayer() and pla:getHealthPercent() <= attcked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla:getEmblem() ~= 1 and pla:getShield() <= 2 then
          if table.find(segundo_foco, pla:getName()) then
          g_game.attack(pla)
          return
          end
          end
          end
          end
          
          for _, pla in ipairs(getSpectators(posz())) do
          if not attcked or attcked:isMonster() or attcked:isPlayer() and pla:getHealthPercent() <= attcked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla:getEmblem() ~= 1 and pla:getShield() <= 2 then
          if table.find(terceiro_foco, pla:getName()) then
          g_game.attack(pla)
          return
          end
          end
          end
          end
          
          for _, pla in ipairs(getSpectators(posz())) do
          if not attcked or attcked:isMonster() or attcked:isPlayer() and pla:getHealthPercent() <= attcked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla:getEmblem() ~= 1 and pla:getShield() <= 2 then
          if table.find(quarto_foco, pla:getName()) then
          g_game.attack(pla)
          return
          end
          end
          end
          end
          
          for _, pla in ipairs(getSpectators(posz())) do
          if not attcked or attcked:isMonster() or attcked:isPlayer() and pla:getHealthPercent() <= attcked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla:getEmblem() ~= 1 and pla:getShield() <= 2 then
          
          if pla:getHealthPercent() <= analiseHP2 then
          analiseHP2 = pla:getHealthPercent()
          analiseCID2 = getCreatureById(pla:getId())
          end
          
          end
          end
          end
          
          if analiseCID2 ~= nil then
          g_game.attack(analiseCID2)
          return
          end
          
          end)
          
          
          
          
          macro(200, "Yellow Skull%", function() -- ATACAR YELLOW COM MENOS HP
          
          for _, pla in ipairs(getSpectators(posz())) do
          
          attacked = g_game.getAttackingCreature()
          
          if not attacked or attacked:isMonster() or attacked:isPlayer() and pla:getHealthPercent() < attacked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla ~= player and pla:getHealthPercent() < 90 and pla:getEmblem() ~= 1 and pla:getSkull() == 1 and pla:getShield() <= 2 then 
          g_game.attack(pla)
          end
          end
          
          end
          
          delay(100)
          
          end)
          
          
          macro(100, function()
          
          if player:getShield() == 3 or player:getShield() == 5 or player:getShield() == 7 or player:getShield() == 9 then return end
          
          for _, pla in ipairs(getSpectators(posz())) do
          
          if pla:isPlayer() and pla:getEmblem() == 1 and pla:isPartyLeader() then 
          g_game.partyJoin(pla:getId())
          end
          
          end
          
          end)
          
          
          macro(200, "White Skull PK%", function() -- ATACAR O PK COM MENOS HP
          
          for _, pla in ipairs(getSpectators(posz())) do
          
          attacked = g_game.getAttackingCreature()
          
          if not attacked or attacked:isMonster() or attacked:isPlayer() and pla:getHealthPercent() < attacked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla ~= player and pla:getHealthPercent() <85 and pla:getEmblem() ~= 1 and pla:getSkull() == 3 and pla:getShield() <= 2 then 
          g_game.attack(pla)
          end
          end
          
          end
          
          delay(100)
          
          end)
          
          macro(200, "White Skull All", function() -- ATACAR QUALQUER PK
          
          for _, pla in ipairs(getSpectators(posz())) do
          
          attacked = g_game.getAttackingCreature()
          
          if not attacked or attacked:isMonster() or attacked:isPlayer() and pla:getHealthPercent() < attacked:getHealthPercent()*0.6 then
          if pla:isPlayer() and pla ~= player and pla:getEmblem() ~= 1 and pla:getSkull() == 3 and pla:getShield() <= 2 then 
          g_game.attack(pla)
          end
          end
          
          end
          
          delay(100)
          
          end)



       FollowAttack = {
    flags = { ignoreNonPathable = true, precision = 0, ignoreCreatures = true },
};

FollowAttack.getDirection = function(playerPos, direction)
    if (direction == 0) then playerPos.y = playerPos.y - 1;
    elseif (direction == 1) then playerPos.x = playerPos.x + 1;
    elseif (direction == 2) then playerPos.y = playerPos.y + 1;
    elseif (direction == 3) then playerPos.x = playerPos.x - 1;
    end
    return playerPos;
end

-- Ícone "Follow Attack"
FollowAttack.Icon = addIcon("Follow Attack", {item=7657, text="Follow Attack"}, macro(1, function()
    if (not g_game.isAttacking() or g_game.isAttacking() and not g_game.getAttackingCreature():isPlayer()) then return; end

    local playerPos = pos();
    local target = g_game.getAttackingCreature();
    local targetPosition = target:getPosition();

    -- Verifica a distância para o alvo
    if (getDistanceBetween(playerPos, targetPosition) == 0) then g_game.setChaseMode(0) end
    if (getDistanceBetween(playerPos, targetPosition) <= 1) then return; end

    local path = findPath(playerPos, targetPosition, 20, FollowAttack.flags);
    if (not path) then return; end

    local tileToUse = playerPos;
    for i, value in ipairs(path) do 
        if (i > 6) then break; end
        tileToUse = FollowAttack.getDirection(tileToUse, value);
    end
    tileToUse = g_map.getTile(tileToUse);
    use(tileToUse:getTopUseThing());
end))

-- Liberar âncoras e mover o ícone
FollowAttack.Icon:breakAnchors()
FollowAttack.Icon:move(150, 160)  -- Altere os valores X/Y conforme onde você quer posicioná-lo

local nextTransformationLevel;
local blockTransform;
local waitingMsg;




macro(200, function()
	if (not hasProtections()) then return; end
	if (blockTransform) then return; end
	
	
	local level = player:getLevel();
	if (not nextTransformationLevel or nextTransformationLevel <= level) then
		NPC.say("!transformarfinal");
	end
	
end)



onTextMessage(function(mode, text)
	if (text:find("se transformar")) then
		blockTransform = true;
	elseif (text:find("Voc� precisa estar no level")) then
		local level = text:match("%d+");
		level = tonumber(level);
		if (level) then
			waitingMsg = nil;
			nextTransformationLevel = level;
		end
	elseif (text == "Voc� se transformou!") then
		waitingMsg = nil;
		blockTransform = nil;
	end
end)



UI.Separator()
UI.Separator()

Maker = {}

local openedChannels = {
    guild = false,
    party = false
}

Maker.macro = macro(1000, "Combo Maker", function()  -- checa a cada 1 segundo

    -- Abre Guild Channel
    if not openedChannels.guild then
        local guildTab = modules.game_console.getTab("Guild Channel")
        if not guildTab then
            g_game.joinChannel(0)  -- ID do guild channel
            openedChannels.guild = true
        elseif not guildTab:isVisible() then
            guildTab:show()
            openedChannels.guild = true
        else
            openedChannels.guild = true
        end
    end

    -- Abre Party Channel
    if not openedChannels.party then
        local partyTab = modules.game_console.getTab("Party Channel")
        if not partyTab then
            g_game.joinChannel(1)  -- ID do party channel
            openedChannels.party = true
        elseif not partyTab:isVisible() then
            partyTab:show()
            openedChannels.party = true
        else
            openedChannels.party = true
        end
    end
end)

-- Lógica de ataque do Combo Maker
onTalk(function(name, level, mode, text, channelId, pos)
    if not Maker.macro.isOn() then return end

    -- Captura ID após o ponto (.123456)
    local targetId = tonumber(text:match("%.?(%d+)"))
    if not targetId then return end

    local target = getCreatureById(targetId)
    if not target then return end

    -- Verifica se está no mesmo andar e não é o alvo já atacado
    if target:getPosition().z ~= posz() then return end
    if g_game.getAttackingCreature() and g_game.getAttackingCreature():getId() == targetId then return end

    g_game.attack(target)
end)

UI.Separator()
UI.Separator()



-- BugMap Mobile (corrigido, sem ícone)
if not modules._G.g_app.isMobile() then return end

local bugMapMobile = {}
bugMapMobile.pointer = nil
bugMapMobile.initialPos = nil
bugMapMobile.setupAttempts = 0

local availableKeys = {
    ['Up']    = { 0, -6 },
    ['Down']  = { 0,  6 },
    ['Left']  = { -7, 0 },
    ['Right'] = { 7,  0 }
}

local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then return nil end
    return res
end

local function setupPointer()
    local root = g_ui.getRootWidget()
    if not root then return false end

    local pointer = root:recursiveGetChildById('pointer')
    if not pointer then
        for _, child in ipairs(root:getChildren()) do
            local id = child:getId()
            if id and id:lower():find('pointer') then
                pointer = child
                break
            elseif child.pointer then
                pointer = child.pointer
                break
            end
        end
    end
    if not pointer then return false end

    bugMapMobile.pointer = pointer
    local pos = safeCall(function() return pointer:getPosition() end)
    local w   = safeCall(function() return pointer:getWidth() end)
    local h   = safeCall(function() return pointer:getHeight() end)

    if pos and w and h and h ~= 0 then
        bugMapMobile.initialPos = { x = pos.x / w, y = pos.y / h }
    else
        local mt = safeCall(function() return pointer:getMarginTop() end) or 0
        local ml = safeCall(function() return pointer:getMarginLeft() end) or 0
        bugMapMobile.initialPos = { x = mt, y = ml }
    end
    return true
end

function bugMapMobile.logic()
    local player = g_game.getLocalPlayer()
    if not player then return end
    if not bugMapMobile.pointer then return end

    local curPos = safeCall(function() return bugMapMobile.pointer:getPosition() end)
    local w = safeCall(function() return bugMapMobile.pointer:getWidth() end)
    local h = safeCall(function() return bugMapMobile.pointer:getHeight() end)
    if not curPos or not w or not h or h == 0 then return end

    local keypadPos = { x = curPos.x / w, y = curPos.y / h }
    local diffPos = { x = bugMapMobile.initialPos.x - keypadPos.x, y = bugMapMobile.initialPos.y - keypadPos.y }

    local dx, dy
    if math.abs(diffPos.y) < 0.46 then
        if diffPos.x > 0 then
            dx, dy = availableKeys['Left'][1], availableKeys['Left'][2]
        elseif diffPos.x < 0 then
            dx, dy = availableKeys['Right'][1], availableKeys['Right'][2]
        else return end
    elseif math.abs(diffPos.x) < 0.46 then
        if diffPos.y > 0 then
            dx, dy = availableKeys['Up'][1], availableKeys['Up'][2]
        elseif diffPos.y < 0 then
            dx, dy = availableKeys['Down'][1], availableKeys['Down'][2]
        else return end
    else
        return
    end

    local pPos = player:getPosition()
    local target = { x = pPos.x + (dx or 0), y = pPos.y + (dy or 0), z = pPos.z }
    local tile = g_map.getTile(target)
    if not tile then return end

    local top = tile:getTopUseThing() or tile:getTopThing()
    if not top then return end

    if top:isMultiUse() then
        useWith(top, player)
    else
        g_game.use(top)
    end
end

-- Macro ativo sempre
macro(50, function()
    if not bugMapMobile.pointer then
        bugMapMobile.setupAttempts = (bugMapMobile.setupAttempts or 0) + 1
        if not setupPointer() then
            if bugMapMobile.setupAttempts > 6 then
                return -- para de tentar depois de algumas falhas
            end
            return
        end
        bugMapMobile.setupAttempts = 0
    end
    bugMapMobile.logic()
end)



-- Escadas/TP Mobile (F1)
ClosestStair = {}
ClosestStair.tile = nil
ClosestStair.aditionalTiles = {1948,1067,595,5293,5542,1648,1666,1678,1949,13296,1646,5111,7771,8657,1680,6264,1664,6262,5291,6905,8265,8263,7727,7725,6896,6207,8367}
ClosestStair.ignoredTiles = {7804}
ClosestStair.walkTime = now

-- 🔹 Macro que detecta o tile mais próximo válido
ClosestStair.macro = macro(200, function()
    local tiles = g_map.getTiles(posz())
    local playerPos = pos()
    local closestTile = nil

    for _, tile in ipairs(tiles) do
        local tilePosition = tile:getPosition()
        local tileDistance = getDistanceBetween(playerPos, tilePosition)
        local minimapColor = g_map.getMinimapColor(tilePosition)
        local StairColor = minimapColor == 210
        local items = tile:getItems()

        if StairColor and not tile:isPathable() then
            local hasIgnored = false
            for _, item in ipairs(items) do
                if table.find(ClosestStair.ignoredTiles, item:getId()) then
                    hasIgnored = true
                    break
                end
            end
            if not hasIgnored and (closestTile == nil or tileDistance < getDistanceBetween(playerPos, closestTile:getPosition())) then
                closestTile = tile
            end
        else
            for _, item in ipairs(items) do
                if table.find(ClosestStair.aditionalTiles, item:getId()) then
                    if closestTile == nil or tileDistance < getDistanceBetween(playerPos, closestTile:getPosition()) then
                        closestTile = tile
                        break
                    end
                end
            end
        end
    end

    if ClosestStair.tile then
        ClosestStair.tile:setText("")
    end
    ClosestStair.tile = closestTile
    if ClosestStair.tile then
        ClosestStair.tile:setText("Press F1")
    end
end)

-- 🔹 Checagem da tecla F1
macro(100, function()
    local g_keyboard = modules.corelib.g_keyboard
    if not g_keyboard.isKeyPressed('F1') then return end
    local tile = ClosestStair.tile
    if not tile then
        return modules.game_textmessage.displayGameMessage("Nenhuma escada/TP encontrada")
    end

    local tilePos = tile:getPosition()
    local distance = getDistanceBetween(pos(), tilePos)

    if tile:canShoot() then
        use(tile:getTopUseThing())
    else
        autoWalk(tilePos, 100, {ignoreNonPathable=true, precision=1, ignoreCreatures=false, ignoreStairs=true})
    end

    if (ClosestStair.walkTime < now and distance == 1) then
        CaveBot.walkTo(tilePos, 1, {precision=1})
        ClosestStair.walkTime = now + 1
    end
end)
