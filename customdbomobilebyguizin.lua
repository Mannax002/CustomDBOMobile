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
		  tyrBot.Delay = now + 500;
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



UI.Separator()

modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/CustomDBOMobile/refs/heads/main/TimeSpell.lua', function(script)
    assert(loadstring(script))()
end);

modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/CustomDBOMobile/refs/heads/main/Combo.lua', function(script)
    assert(loadstring(script))()
end);

modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/CustomDBOMobile/refs/heads/main/TravelDBO.lua', function(script)
    assert(loadstring(script))()
end);

modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/CustomDBOMobile/refs/heads/main/script.lua', function(script)
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




UI.Separator()
local getDistance = function(p1, p2)

    local distx = math.abs(p1.x - p2.x);
    local disty = math.abs(p1.y - p2.y);

    return math.sqrt(distx * distx + disty * disty);
end

getWalkingPosition = function(pos)
	
	local tiles = g_map.getTiles(pos.z);
	local playerPos = player:getPosition();
	local walkPos;
	
	for _, tile in ipairs(tiles) do
		local tilePos = tile:getPosition();
		if (tilePos ~= nil and tile:isWalkable() and tile:isPathable()) then
			if (not walkPos) then
				if (findPath(playerPos, tilePos, 20)) then
					walkPos = tilePos;
				end
			else
				local distance = getDistance(tilePos, pos);
				local currentDistance = getDistance(walkPos, pos);
				if (distance < currentDistance and findPath(playerPos, tilePos, 20)) then
					walkPos = tilePos;
				end
			end
		end
	end
	
	return walkPos;
end


local nextPosition = {
	{x = 0, y = -1},
	{x = 1, y = 0},
	{x = 0, y = 1},
	{x = -1, y = 0},
	{x = 1, y = -1},
	{x = 1, y = 1},
	{x = -1, y = 1},
	{x = -1, y = -1}
};

local getPosition = function(pos, dir)
    local nextPos = nextPosition[dir + 1]

    pos.x = pos.x + nextPos.x
    pos.y = pos.y + nextPos.y

    return pos
end

useWalk = function(pos)
    local playerPos = player:getPosition();
    local path = findPath(playerPos, pos, 20);
    if (not path) then return; end
	
	local last_value;
	local stopped;
    for index, direction in ipairs(path) do
		if (index > 5) then
			stopped = true;
			break;
		end
        playerPos = getPosition(playerPos, direction);
		last_value = direction;
    end
	
	if (not stopped and last_value) then
		playerPos = getPosition(playerPos, last_value);
	end
	
    local tile = g_map.getTile(playerPos);
    local topThing = tile and tile:getTopUseThing();
    if (topThing) then
		use(topThing);
    end
end

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
local specialBuffs = {
  "Justice Aura",
  "Body manipulation",
  "Ultimate fusion energy",
  "kinzoku no kawa",
  "hakaishin aura"
}

local defaultBuff = "Ultimate Power Up"
local cooldown = 60000 -- 60 segundos
local lastBuffTime = 0
local currentSpellIndex = 1

macro(1000, "Auto Buff", function()
  if (now - lastBuffTime) < cooldown then
    return
  end

  -- Se ainda há magias especiais para tentar
  if currentSpellIndex <= #specialBuffs then
    say(specialBuffs[currentSpellIndex])
    currentSpellIndex = currentSpellIndex + 1
  else
    -- Nenhuma magia especial funcionou, usa Ultimate Power Up
    say(defaultBuff)
    -- Reset para a próxima tentativa após cooldown
    currentSpellIndex = 1
    lastBuffTime = now
  end
end)
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


-- Inicializa storage
if type(storage.cooldownTable) ~= "table" then
    storage.cooldownTable = {}
end

local name = name()
if storage.cooldownTable[name] == nil then
    storage.cooldownTable[name] = {}
end
local cooldownTable = storage.cooldownTable[name]

setCooldownTime = function(var_name, value)
    cooldownTable[var_name] = os.time() + tonumber(value)
end

isOnCooldown = function(var_name)
    local value = cooldownTable[var_name] or 0
    return os.time() < value
end

-- Variáveis globais
local isStacking = false
local stackMonster = nil
local current_vocation = nil
local exhaustedTime = 0

-- Spells de stack
local stackSpells = {
    {
        name = "Shunkanido",
        cooldown = 10,
        level = 400,
        mlevel = 150
    },
    {
        name = "Teleport",
        exhaust = 2000,
        distance = 4
    }
}

-- Funções auxiliares
local function setStacking(value)
    isStacking = value
    if not value and stackMonster then
        stackMonster = nil
    end
end

local function getStackingSpell()
    local level = player:getLevel()
    local mlevel = player:getMagicLevel()
    for _, data in ipairs(stackSpells) do
        if not isOnCooldown(data.name) then
            if (not data.mlevel or data.mlevel <= mlevel) and (not data.level or data.level <= level) then
                return data
            end
        end
    end
end

local function StackToMonster(target)
    if not target then return false end
    local playerPos = pos()
    local targetPos = target:getPosition()

    -- Define direção do player baseada na posição do monstro
    local playerDir = player:getDirection() -- 0=n,1=e,2=s,3=w
    if targetPos.y < playerPos.y then
        if playerDir ~= 0 then turn(0) end
    elseif targetPos.y > playerPos.y then
        if playerDir ~= 2 then turn(2) end
    elseif targetPos.x > playerPos.x then
        if playerDir ~= 1 then turn(1) end
    elseif targetPos.x < playerPos.x then
        if playerDir ~= 3 then turn(3) end
    end

    local stackingSpell = getStackingSpell()
    if not stackingSpell then return false end

    local distance = getDistanceBetween(playerPos, targetPos)
    setStacking(true)
    stackMonster = target

    if g_game.getAttackingCreature() ~= target then
        g_game.attack(target)
    end

    if distance > 4 then
        say(stackingSpell.name)
        setCooldownTime(stackingSpell.name, stackingSpell.cooldown or 0)
    else
        say("Teleport")
    end
    return true
end

-- Macro Mobile F2
macro(50, function()
    if not modules.corelib.g_keyboard.isKeyPressed("F2") then return end

    local playerPos = pos()
    local spectators = getSpectators(playerPos.z)
    local closest = nil
    local minDist = 100

    for _, c in ipairs(spectators) do
        if c:isMonster() or c:getEmblem() == 1 then
            local cPos = c:getPosition()
            local d = getDistanceBetween(playerPos, cPos)
            if d < minDist then
                minDist = d
                closest = c
            end
        end
    end

    StackToMonster(closest)
end)

-- Atualiza vocação do player
onTextMessage(function(mode, text)
    if text:starts("You see yourself.") then
        text = text:split(" ")
        local vocation = {}
        local start_found = false
        for index = 1, table.size(text) do
            local word = text[index]
            if start_found then
                if word == "and" then break end
                table.insert(vocation, word)
                if word:find("%.") then
                    vocation[#vocation] = word:sub(1, -2)
                    break
                end
            elseif word == "are" then
                start_found = true
            end
        end
        vocation = table.concat(vocation, " ")
        current_vocation = vocation
    end
end)

-- Adiciona spells extras por vocação
macro(1, function(self)
    if not current_vocation then return end
    if current_vocation == "Paikuhan" then
        table.insert(stackSpells, 1, {
            name="Blazing Zephyr",
            cooldown=2,
            mlevel=140,
            level=400
        })
    elseif current_vocation == "Hitto" then
        table.insert(stackSpells, 1, {
            name="Time Skip Vital Point Attack",
            cooldown=7,
            mlevel=100,
            level=200
        })
    end
    self:setOff()
end)







----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
scriptFuncs = {};
comboSpellsWidget = {};
fugaSpellsWidgets = {};

scriptFuncs.readProfile = function(filePath, callback)
    if g_resources.fileExists(filePath) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(filePath))
        end)
        if not status then
            return warn("Error: ".. result)
        end

        callback(result);
    end
end

scriptFuncs.saveProfile = function(configFile, content)
    local status, result = pcall(function()
        return json.encode(content, 2)
    end);

    if not status then
        return warn("Error:" .. result);
    end
    g_resources.writeFileContents(configFile, result);
end

storageProfiles = {
    comboSpells = {},
    fugaSpells = {},
    keySpells = {}
}

MAIN_DIRECTORY = "/bot/" .. modules.game_bot.contentsPanel.config:getCurrentOption().text .. "/storage/"
STORAGE_DIRECTORY = "" .. MAIN_DIRECTORY .. g_game.getWorldName() .. '.json';

if not g_resources.directoryExists(MAIN_DIRECTORY) then
    g_resources.makeDir(MAIN_DIRECTORY);
end

function resetCooldowns()
    if storageProfiles then
        if storageProfiles.comboSpells then
            for _, spell in ipairs(storageProfiles.comboSpells) do
                spell.cooldownSpells = nil
            end
        end
    end
end

scriptFuncs.readProfile(STORAGE_DIRECTORY, function(result)
    storageProfiles = result;
    if (type(storageProfiles.comboSpells) ~= 'table') then
        storageProfiles.comboSpells = {};
    end
    if (type(storageProfiles.fugaSpells) ~= 'table') then
        storageProfiles.fugaSpells = {};
    end
    if (type(storageProfiles.keySpells) ~= 'table') then
        storageProfiles.keySpells = {};
    end
    resetCooldowns();
end);

scriptFuncs.reindexTable = function(t)
    if not t or type(t) ~= "table" then
        return
    end

    local i = 0
    for _, e in pairs(t) do
        i = i + 1
        e.index = i
    end
end

firstLetterUpper = function(str)
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

storage['iconScripts'] = storage['iconScripts'] or {
    comboMacro = false,
    fugaMacro = false,
    keyMacro = false
}

local isOn = storage['iconScripts'];

function removeTable(tbl, index)
    table.remove(tbl, index)
end

function canCastFuga()
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if ((value.enableLifes and value.lifes > 0 and value.activeCooldown and value.activeCooldown >= os.time()) or
            (not value.enableLifes and value.activeCooldown and value.activeCooldown >= os.time())) then
            return true;
        end
    end
    return false;
end

function getPlayersAttack(multifloor)
    multifloor = multifloor or false;
    local count = 0;
    for _, spec in ipairs(getSpectators(multifloor)) do
        if spec:isPlayer() then
            count = count + 1;
        end
    end
    return count;
end

function calculatePercentage(var)
    local multiplier = getPlayersAttack(false);
    return multiplier and var + (multiplier * 7) or var
end

function stopToCast()
    if not fugaIcon.title:isOn() then
        return false;
    end
    for index, value in ipairs(storageProfiles.fugaSpells) do
        if value.enabled and value.activeCooldown and value.activeCooldown >= os.time() then
            return false;
        end
        if hppercent() <= calculatePercentage(value.selfHealth) + 3 then
            if (not value.totalCooldown or value.totalCooldown <= os.time()) then
                return true;
            end
        end
    end
    return false;
end

function isAnySelectedKeyPressed()
    for index, value in ipairs(storageProfiles.keySpells) do
        if value.enabled and (modules.corelib.g_keyboard.isKeyPressed(value.keyPress)) then
            return true;
        end
    end
    return false;
end

function formatTime(seconds)
    if seconds < 60 then
        return seconds .. 's'
    else
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        return string.format("%dm %02ds", minutes, remainingSeconds)
    end
end

formatRemainingTime = function(time)
    local remainingTime = (time - now) / 1000;
    local timeText = '';
    timeText = string.format("%.0f", (time - now) / 1000) .. "s";
    return timeText;
end

formatOsTime = function(time)
    local remainingTime = (time - os.time());
    local timeText = '';
    timeText = string.format("%.0f", (time - os.time())) .. "s";
    return timeText;
end

attachSpellWidgetCallbacks = function(widget, spellId, table)
    widget.onDragEnter = function(self, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        self:breakAnchors()
        self.movingReference = {
            x = mousePos.x - self:getX(),
            y = mousePos.y - self:getY()
        }
        return true
    end

    widget.onDragMove = function(self, mousePos, moved)
        local parentRect = self:getParent():getRect()
        local newX = math.min(math.max(parentRect.x, mousePos.x - self.movingReference.x),
            parentRect.x + parentRect.width - self:getWidth())
        local newY = math.min(math.max(parentRect.y - self:getParent():getMarginTop(),
            mousePos.y - self.movingReference.y), parentRect.y + parentRect.height - self:getHeight())
        self:move(newX, newY)
        if table[spellId] then
            table[spellId].widgetPos = {
                x = newX,
                y = newY
            }
            scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
        end
        return true
    end

    widget.onDragLeave = function(self, pos)
        return true
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local spellEntry = [[
UIWidget
  background-color: alpha
  text-offset: 18 0
  focusable: true
  height: 16

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 3

  $focus:
    background-color: #00000055

  CheckBox
    id: showTimespell
    anchors.left: enabled.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 15

  $focus:
    background-color: #00000055

  Label
    id: textToSet
    anchors.left: showTimespell.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 20

  Button
    id: remove
    !text: tr('x')
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15
    tooltip: Remove Spell
]]

local widgetConfig = [[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
  text-auto-resize: true
]]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboIcon = setupUI([[
Panel
  height: 20
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Combo

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])

comboInterface = setupUI([[
MainWindow
  text: Combo Panel
  size: 540 312

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.right: sep2.left
    anchors.left: parent.left
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 310 225

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.left: sep2.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 310 225


  TextList
    id: spellList
    anchors.left: parent.left
    anchors.top: parent.top
    padding: 1
    size: 247 205
    margin-top: 11
    margin-left: 11
    vertical-scrollbar: spellListScrollBar

  VerticalScrollBar
    id: spellListScrollBar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  Button
    id: moveUp
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    margin-bottom: 40
    margin-left: 60
    text: Move Up
    size: 60 17
    font: cipsoftFont

  Button
    id: moveDown
    anchors.bottom: parent.bottom
    anchors.left: moveUp.left
    margin-bottom: 40
    margin-left: 65
    text: Move Down
    size: 60 17
    font: cipsoftFont

  VerticalSeparator
    id: sep2
    anchors.top: parent.top
    anchors.bottom: closeButton.top
    anchors.horizontalCenter: parent.horizontalCenter
    margin-left: 15
    margin-bottom: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5

  Label
    id: castSpellLabel
    anchors.left: castSpell.right
    anchors.top: parent.top
    text: Nome da Magia
    margin-top: 19
    margin-left: 15

  TextEdit
    id: castSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-top: 15
    margin-left: 34
    width: 100

  Label
    id: orangeSpellLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: Magia Laranja
    margin-top: 49
    margin-left: 15

  TextEdit
    id: orangeSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-top: 45
    margin-left: 34
    width: 100

  CheckBox
    id: sameSpell
    anchors.left: orangeSpellLabel.right
    anchors.top: parent.top
    margin-top: 49
    margin-left: 8
    tooltip: Same Spell

  Label
    id: onScreenLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: Na Tela
    margin-top: 79
    margin-left: 15

  TextEdit
    id: onScreen
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-left: 34
    margin-top: 75
    width: 100

  Label
    id: cooldownLabel
    anchors.left: cooldown.right
    anchors.top: parent.top
    margin-top: 105
    margin-left: 5
    text: Cooldown

  HorizontalScrollBar
    id: cooldown
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 105
    width: 125
    minimum: 0
    maximum: 60000
    step: 50

  Button
    id: findCD
    anchors.left: cooldownLabel.right
    anchors.top: parent.top
    margin-top: 105
    margin-left: 8
    tooltip: Find CD
    text: !
    size: 15 15

  Label
    id: distanceLabel
    anchors.left: cooldown.right
    anchors.top: parent.top
    margin-top: 135
    margin-left: 5
    text: Distance

  HorizontalScrollBar
    id: distance
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 135
    width: 125
    minimum: 0
    maximum: 10
    step: 1

  Button
    id: insertSpell
    text: Add Spell
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 21
    margin-bottom: 40
    margin-right: 20


  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5

]], g_ui.getRootWidget())
comboInterface:hide();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaIcon = setupUI([[
Panel
  height: 40
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Especiais

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])

fugaInterface = setupUI([[
MainWindow
  text: Especiais Panel
  size: 550 322

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.right: sep2.left
    anchors.left: parent.left
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 320 235

  Panel
    image-source: /images/ui/panel_flat
    anchors.top: parent.top
    anchors.left: sep2.left
    anchors.right: parent.right
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 320 235


  TextList
    id: spellList
    anchors.left: parent.left
    anchors.top: parent.top
    padding: 1
    size: 240 215
    margin-top: 11
    margin-left: 11
    vertical-scrollbar: spellListScrollBar

  VerticalScrollBar
    id: spellListScrollBar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  Button
    id: moveUp
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    margin-bottom: 40
    margin-left: 50
    text: Move Up
    size: 60 17
    font: cipsoftFont

  Button
    id: moveDown
    anchors.bottom: parent.bottom
    anchors.left: moveUp.left
    margin-bottom: 40
    margin-left: 65
    text: Move Down
    size: 60 17
    font: cipsoftFont

  VerticalSeparator
    id: sep2
    anchors.top: parent.top
    anchors.bottom: closeButton.top
    anchors.horizontalCenter: parent.horizontalCenter
    margin-left: 3
    margin-bottom: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5

  Label
    id: castSpellLabel
    anchors.left: castSpell.right
    anchors.top: parent.top
    text: Nome da Magia
    margin-top: 19
    margin-left: 15

  TextEdit
    id: castSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-left: 34
    margin-top: 15
    width: 100

  Label
    id: orangeSpellLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: Magia Laranja
    margin-top: 49
    margin-left: 15

  TextEdit
    id: orangeSpell
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-top: 45
    margin-left: 34
    width: 100

  CheckBox
    id: sameSpell
    anchors.left: orangeSpellLabel.right
    anchors.top: parent.top
    margin-top: 49
    margin-left: 8
    tooltip: Same Spell

  Label
    id: onScreenLabel
    anchors.left: orangeSpell.right
    anchors.top: parent.top
    text: Na Tela
    margin-top: 79
    margin-left: 15

  TextEdit
    id: onScreen
    anchors.left: spellList.right
    anchors.top: parent.top
    margin-left: 34
    margin-top: 75
    width: 100

  Label
    id: hppercentLabel
    anchors.left: hppercent.right
    anchors.top: parent.top
    margin-top: 105
    margin-left: 5
    text: Porcentagem Vida

  HorizontalScrollBar
    id: hppercent
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 105
    width: 125
    minimum: 0
    maximum: 100
    step: 1

  Label
    id: cooldownTotalLabel
    anchors.left: hppercent.right
    anchors.top: parent.top
    margin-top: 135
    margin-left: 5
    text: Tempo Cooldown

  HorizontalScrollBar
    id: cooldownTotal
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 135
    width: 125
    minimum: 0
    maximum: 180
    step: 1

  Label
    id: cooldownActiveLabel
    anchors.left: hppercent.right
    anchors.top: parent.top
    margin-top: 165
    margin-left: 5
    text: Tempo ativo

  HorizontalScrollBar
    id: cooldownActive
    anchors.left: spellList.right
    margin-left: 20
    anchors.top: parent.top
    margin-top: 165
    width: 125
    minimum: 0
    maximum: 180
    step: 1

  CheckBox
    id: reviveOption
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    !text: tr('Revive')
    tooltip: Revive Especiais
    width: 60
    margin-bottom: 65
    margin-left: 40

  CheckBox
    id: lifesOption
    anchors.bottom: parent.bottom
    anchors.left: reviveOption.right
    tooltip: Lifes Especiais
    width: 60
    !text: tr('Lifes')
    margin-bottom: 65
    margin-left: 10

  CheckBox
    id: multipleOption
    anchors.bottom: parent.bottom
    anchors.left: lifesOption.right
    !text: tr('Multiple')
    tooltip: Multiple Scape
    margin-bottom: 65
    width: 80
    margin-left: 5

  SpinBox
    id: lifesValue
    anchors.bottom: parent.bottom
    anchors.left: lifesOption.right
    margin-bottom: 60
    margin-left: 5
    size: 27 20
    minimum: 0
    maximum: 10
    step: 1
    editable: true
    focusable: true

  Button
    id: insertSpell
    text: Add Spell
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 21
    margin-bottom: 40
    margin-right: 20


  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-right: 5

]], g_ui.getRootWidget())
fugaInterface:hide();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyIcon = setupUI([[
Panel
  height: 17
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: Hotkeys

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])

keyInterface = setupUI([[
MainWindow
  text: Especiais Panel
  size: 300 400

  Panel
    image-source: /images/ui/panel_flat
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: separator.top
    margin: 5 5 5 5
    image-border: 6
    padding: 3
    size: 320 235

  TextList
    id: spellList
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    padding: 1
    size: 240 215
    margin-top: 11
    vertical-scrollbar: spellListScrollBar

  Label
    id: castSpellLabel
    anchors.right: parent.right
    anchors.bottom: castSpell.top
    text: Spell Name
    margin-bottom: 5
    margin-right: 75

  TextEdit
    id: castSpell
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    margin-bottom: 60
    margin-right: 14
    width: 125

  Label
    id: keyLabel
    anchors.left: parent.left
    anchors.bottom: castSpell.top
    text: Key
    margin-bottom: 5
    margin-left: 15

  TextEdit
    id: key
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    margin-bottom: 60
    margin-left: 14
    width: 70
    editable: 

  VerticalScrollBar
    id: spellListScrollBar
    anchors.top: spellList.top
    anchors.bottom: spellList.bottom
    anchors.right: spellList.right
    step: 14
    pixels-scroll: true

  Button
    id: insertKey
    text: Insert Key
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 60 25
    margin-right: 5
    margin-bottom: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 5

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    size: 45 25
    margin-left: 4
    margin-bottom: 5

]], g_ui.getRootWidget())
keyInterface:hide();

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboIcon.title:setOn(isOn.comboMacro);
comboIcon.title.onClick = function(widget)
    isOn.comboMacro = not isOn.comboMacro;
    widget:setOn(isOn.comboMacro);
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

comboIcon.settings.onClick = function(widget)
    if not comboInterface:isVisible() then
        comboInterface:show();
        comboInterface:raise();
        comboInterface:focus();
    else
        comboInterface:hide();
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    end
end

comboInterface.closeButton.onClick = function(widget)
    comboInterface:hide();
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.cooldown:setText('0ms')
comboInterface.cooldown.onValueChange = function(widget, value)
    if value >= 1000 then
        widget:setText(value / 1000 .. 's')
    else
        widget:setText(value .. 'ms')
    end
end

comboInterface.distance:setText('0')
comboInterface.distance.onValueChange = function(widget, value)
    widget:setText(value)
end

comboInterface.sameSpell:setChecked(true);
comboInterface.orangeSpell:setEnabled(false);
comboInterface.sameSpell.onCheckChange = function(widget, checked)
    if checked then
        comboInterface.orangeSpell:setEnabled(false)
    else
        comboInterface.orangeSpell:setEnabled(true)
        comboInterface.orangeSpell:setText(comboInterface.castSpell:getText())
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function refreshComboList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy();
        end
        for _, widget in pairs(comboSpellsWidget) do
            widget:destroy()
        end
        for index, entry in ipairs(table) do
            local label = setupUI(spellEntry, list.spellList)
            local newWidget = setupUI(widgetConfig, g_ui.getRootWidget())
            newWidget:setText(firstLetterUpper(entry.spellCast))
            attachSpellWidgetCallbacks(newWidget, entry.index, storageProfiles.comboSpells)
            if not entry.widgetPos then
                entry.widgetPos = {
                    x = 0,
                    y = 50
                }
            end
            newWidget:setPosition(entry.widgetPos)
            comboSpellsWidget[entry.index] = newWidget;
            comboSpellsWidget[entry.index] = newWidget;
            label.onDoubleClick = function(widget)
                local spellTable = entry;
                list.castSpell:setText(spellTable.spellCast);
                list.orangeSpell:setText(spellTable.orangeSpell);
                list.onScreen:setText(spellTable.onScreen);
                list.cooldown:setValue(spellTable.cooldown);
                list.distance:setValue(spellTable.distance);
                for i, v in ipairs(storageProfiles.comboSpells) do
                    if v == entry then
                        removeTable(storageProfiles.comboSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.enabled:setChecked(entry.enabled);
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled;
                label.enabled:setChecked(entry.enabled);
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.showTimespell:setChecked(entry.enableTimeSpell)
            label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
            label.showTimespell.onClick = function(widget)
                entry.enableTimeSpell = not entry.enableTimeSpell;
                label.showTimespell:setChecked(entry.enableTimeSpell);
                label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
                if entry.enableTimeSpell then
                    newWidget:show();
                else
                    newWidget:hide();
                end
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            if entry.enableTimeSpell then
                newWidget:show();
            else
                newWidget:hide();
            end
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.comboSpells) do
                    if v == entry then
                        removeTable(storageProfiles.comboSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.onClick = function(widget)
                comboInterface.moveDown:show();
                comboInterface.moveUp:show();
            end
            label.textToSet:setText(firstLetterUpper(entry.spellCast));
            label:setTooltip('Orange Message: ' .. entry.orangeSpell .. ' | Na Tela: ' .. entry.onScreen ..
                                 ' | Cooldown: ' .. entry.cooldown / 1000 .. 's | Distance: ' .. entry.distance)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.insertSpell.onClick = function(widget)
    local spellName = comboInterface.castSpell:getText():trim():lower();
    local orangeMsg = comboInterface.orangeSpell:getText():trim():lower();
    local onScreen = comboInterface.onScreen:getText();
    orangeMsg = (orangeMsg:len() == 0) and spellName or orangeMsg;
    local cooldown = comboInterface.cooldown:getValue();
    local distance = comboInterface.distance:getValue();
    if (not spellName or spellName:len() == 0) then
        return warn('Invalid Spell Name.');
    end
    if (not comboInterface.sameSpell:isChecked() and comboInterface.orangeSpell:getText():len() == 0) then
        return warn('Invalid Magia Laranja.')
    end
    if (not onScreen or onScreen:len() == 0) then
        return warn('Invalid Text Na Tela')
    end
    if (cooldown == 0) then
        return warn('Invalid Cooldown.')
    end
    if (distance == 0) then
        return warn('Invalid Distance')
    end
    local newSpell = {
        index = #storageProfiles.comboSpells + 1,
        spellCast = spellName,
        onScreen = onScreen,
        orangeSpell = orangeMsg,
        cooldown = cooldown,
        distance = distance,
        enableTimeSpell = true,
        enabled = true
    }
    table.insert(storageProfiles.comboSpells, newSpell)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
    refreshComboList(comboInterface, storageProfiles.comboSpells)
    comboInterface.castSpell:clearText();
    comboInterface.orangeSpell:clearText();
    comboInterface.onScreen:clearText();
    comboInterface.sameSpell:setChecked(true);
    comboInterface.orangeSpell:setEnabled(false);
    comboInterface.cooldown:setValue(0);
    comboInterface.distance:setValue(0);
end

refreshComboList(comboInterface, storageProfiles.comboSpells);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.moveUp.onClick = function()
    local action = comboInterface.spellList:getFocusedChild();
    if (not action) then
        return;
    end
    local index = comboInterface.spellList:getChildIndex(action);
    if (index < 2) then
        return;
    end
    comboInterface.spellList:moveChildToIndex(action, index - 1);
    comboInterface.spellList:ensureChildVisible(action);
    storageProfiles.comboSpells[index].index = index - 1;
    storageProfiles.comboSpells[index - 1].index = index;
    table.sort(storageProfiles.comboSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

comboInterface.moveDown.onClick = function()
    local action = comboInterface.spellList:getFocusedChild()
    if not action then
        return
    end
    local index = comboInterface.spellList:getChildIndex(action)
    if index >= comboInterface.spellList:getChildCount() then
        return
    end
    comboInterface.spellList:moveChildToIndex(action, index + 1);
    comboInterface.spellList:ensureChildVisible(action);
    storageProfiles.comboSpells[index].index = index + 1;
    storageProfiles.comboSpells[index + 1].index = index;
    table.sort(storageProfiles.comboSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

comboInterface.findCD.onClick = function(widget)
    detectOrangeSpell, testSpell = true, true;
    spellTime = {0, ''}
end

macro(10, function()
    if testSpell then
        say(comboInterface.castSpell:getText())
    end
end);

onTalk(function(name, level, mode, text, channelId, pos)
    if not detectOrangeSpell then
        return;
    end
    if player:getName() ~= name then
        return;
    end

    local verifying = comboInterface.orangeSpell:getText():len() > 0 and
                          comboInterface.orangeSpell:getText():lower():trim() or
                          comboInterface.castSpell:getText():lower():trim();

    if text:lower():trim() == verifying then
        if spellTime[2] == verifying then
            comboInterface.cooldown:setValue(now - spellTime[1]);
            spellTime = {now, verifying}
            detectOrangeSpell = false;
            testSpell = false;
        else
            spellTime = {now, verifying}
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

macro(10, function()
    if not (comboSpellsWidget or storageProfiles.comboSpells) then
        return;
    end
    for index, spellConfig in ipairs(storageProfiles.comboSpells) do
        local widget = comboSpellsWidget[spellConfig.index];
        if widget then
            if (not spellConfig.cooldownSpells or spellConfig.cooldownSpells < now) then
                widget:setColor('green')
                widget:setText(firstLetterUpper(spellConfig.onScreen) .. ' |  OK!')
            else
                widget:setColor('red')
                widget:setText(firstLetterUpper(spellConfig.onScreen) .. ' | ' ..
                                   formatRemainingTime(spellConfig.cooldownSpells))
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaIcon.title:setOn(isOn.fugaMacro);
fugaIcon.title.onClick = function(widget)
    isOn.fugaMacro = not isOn.fugaMacro;
    widget:setOn(isOn.fugaMacro);
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

fugaIcon.settings.onClick = function(widget)
    if not fugaInterface:isVisible() then
        fugaInterface:show();
        fugaInterface:raise();
        fugaInterface:focus();
    else
        fugaInterface:hide();
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    end
end

fugaInterface.closeButton.onClick = function(widget)
    fugaInterface:hide();
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaInterface.hppercent:setText('0%')
fugaInterface.hppercent.onValueChange = function(widget, value)
    widget:setText(value .. '%')
end

fugaInterface.cooldownTotal:setText('0s')
fugaInterface.cooldownTotal.onValueChange = function(widget, value)
    local formattedTime = formatTime(value)
    widget:setText(value .. 's')
    -- widget:setText(formattedTime)
end

fugaInterface.cooldownActive:setText('0s')
fugaInterface.cooldownActive.onValueChange = function(widget, value)
    local formattedTime = formatTime(value)
    widget:setText(value .. 's')
    -- widget:setText(formattedTime)
end


fugaInterface.sameSpell:setChecked(true);
fugaInterface.orangeSpell:setEnabled(false);
fugaInterface.sameSpell.onCheckChange = function(widget, checked)
    if checked then
        fugaInterface.orangeSpell:setEnabled(false)
    else
        fugaInterface.orangeSpell:setEnabled(true)
        fugaInterface.orangeSpell:setText(fugaInterface.castSpell:getText())
    end
end

fugaInterface.lifesValue:hide();
fugaInterface.lifesOption.onCheckChange = function(self, checked)
    if checked then
        fugaInterface.multipleOption:hide();
        fugaInterface.lifesValue:show();
    else
        fugaInterface.multipleOption:show();
        fugaInterface.lifesValue:hide();
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function refreshFugaList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy();
        end
        for _, widget in pairs(fugaSpellsWidgets) do
            widget:destroy();
        end
        for index, entry in ipairs(table) do
            local label = setupUI(spellEntry, list.spellList)
            local newWidget = setupUI(widgetConfig, g_ui.getRootWidget())
            newWidget:setText(firstLetterUpper(entry.spellCast))
            attachSpellWidgetCallbacks(newWidget, entry.index, storageProfiles.fugaSpells)

            if not entry.widgetPos then
                entry.widgetPos = {
                    x = 0,
                    y = 50
                }
            end
            if entry.enableTimeSpell then
                newWidget:show();
            else
                newWidget:hide();
            end
            newWidget:setPosition(entry.widgetPos)
            fugaSpellsWidgets[entry.index] = newWidget;
            label.onDoubleClick = function(widget)
                local spellTable = entry;
                list.castSpell:setText(spellTable.spellCast);
                list.orangeSpell:setText(spellTable.orangeSpell);
                list.onScreen:setText(spellTable.onScreen);
                list.hppercent:setValue(spellTable.selfHealth);
                list.cooldownTotal:setValue(spellTable.cooldownTotal);
                list.cooldownActive:setValue(spellTable.cooldownActive);
                for i, v in ipairs(storageProfiles.fugaSpells) do
                    if v == entry then
                        removeTable(storageProfiles.fugaSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.enabled:setChecked(entry.enabled);
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled;
                label.enabled:setChecked(entry.enabled);
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.showTimespell:setChecked(entry.enableTimeSpell)
            label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
            label.showTimespell.onClick = function(widget)
                entry.enableTimeSpell = not entry.enableTimeSpell;
                label.showTimespell:setChecked(entry.enableTimeSpell);
                label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell');
                if entry.enableTimeSpell then
                    newWidget:show();
                else
                    newWidget:hide();
                end
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.fugaSpells) do
                    if v == entry then
                        removeTable(storageProfiles.fugaSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                newWidget:destroy();
                label:destroy();
            end
            label.onClick = function(widget)
                fugaInterface.moveDown:show();
                fugaInterface.moveUp:show();
            end
            label.textToSet:setText(firstLetterUpper(entry.spellCast));
            label:setTooltip('Orange Message: ' .. entry.orangeSpell .. ' | Na Tela: ' .. entry.onScreen ..
                                 ' | Tempo Cooldown: ' .. entry.cooldownTotal .. 's | Tempo ativo: ' ..
                                 entry.cooldownActive .. 's | Hppercent: ' .. entry.selfHealth)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaInterface.moveUp.onClick = function()
    local action = fugaInterface.spellList:getFocusedChild();
    if (not action) then
        return;
    end
    local index = fugaInterface.spellList:getChildIndex(action);
    if (index < 2) then
        return;
    end
    fugaInterface.spellList:moveChildToIndex(action, index - 1);
    fugaInterface.spellList:ensureChildVisible(action);
    storageProfiles.fugaSpells[index].index = index - 1;
    storageProfiles.fugaSpells[index - 1].index = index;
    table.sort(storageProfiles.fugaSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

fugaInterface.moveDown.onClick = function()
    local action = fugaInterface.spellList:getFocusedChild()
    if not action then
        return;
    end
    local index = fugaInterface.spellList:getChildIndex(action)
    if index >= fugaInterface.spellList:getChildCount() then
        return
    end
    fugaInterface.spellList:moveChildToIndex(action, index + 1);
    fugaInterface.spellList:ensureChildVisible(action);
    storageProfiles.fugaSpells[index].index = index + 1;
    storageProfiles.fugaSpells[index + 1].index = index;
    table.sort(storageProfiles.fugaSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fugaInterface.insertSpell.onClick = function(widget)
    local spellName = fugaInterface.castSpell:getText():trim():lower();
    local orangeMsg = fugaInterface.orangeSpell:getText():trim():lower();
    local onScreen = fugaInterface.onScreen:getText();
    orangeMsg = (orangeMsg:len() == 0) and spellName or orangeMsg;
    local hppercent = fugaInterface.hppercent:getValue();
    local cooldownTotal = fugaInterface.cooldownTotal:getValue();
    local cooldownActive = fugaInterface.cooldownActive:getValue();

    if spellName:len() == 0 then
        return warn('Invalid Spell Name.');
    end
    if not fugaInterface.sameSpell:isChecked() and orangeMsg:len() == 0 then
        return warn('Invalid Magia Laranja.')
    end
    if onScreen:len() == 0 then
        return warn('Invalid Text Na Tela')
    end
    if hppercent == 0 then
        return warn('Invalid Hppercent.')
    end
    if cooldownTotal == 0 then
        return warn('Invalid Cooldown Total.')
    end

    local spellConfig = {
        index = #storageProfiles.fugaSpells + 1,
        spellCast = spellName,
        orangeSpell = orangeMsg,
        onScreen = onScreen,
        selfHealth = hppercent,
        cooldownActive = cooldownActive,
        cooldownTotal = cooldownTotal,
        enableTimeSpell = true,
        enabled = true
    }

    if fugaInterface.lifesOption:isChecked() then
        spellConfig.lifes = 0;
        spellConfig.enableLifes = true;
        if fugaInterface.lifesValue:getValue() == 0 then
            return warn('Invalid Life Value.')
        end
        spellConfig.amountLifes = fugaInterface.lifesValue:getValue();
    end
    if fugaInterface.reviveOption:isChecked() then
        spellConfig.enableRevive = true;
        spellConfig.alreadyChecked = false;
    end
    if fugaInterface.multipleOption:isChecked() then
        spellConfig.enableMultiple = true;
        spellConfig.count = 3;
    end
    table.insert(storageProfiles.fugaSpells, spellConfig)
    refreshFugaList(fugaInterface, storageProfiles.fugaSpells)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)

    fugaInterface.castSpell:clearText()
    fugaInterface.orangeSpell:clearText()
    fugaInterface.onScreen:clearText()
    fugaInterface.cooldownTotal:setValue(0)
    fugaInterface.cooldownActive:setValue(0)
    fugaInterface.hppercent:setValue(0)
    fugaInterface.reviveOption:setChecked(false);
    fugaInterface.lifesOption:setChecked(false);
    fugaInterface.multipleOption:setChecked(false);
    fugaInterface.multipleOption:show();
    fugaInterface.lifesValue:hide();
end

refreshFugaList(fugaInterface, storageProfiles.fugaSpells);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

storage.widgetPos = storage.widgetPos or {};
informationWidget = {};

local widgetNames = {'showText'}

for i, widgetName in ipairs(widgetNames) do
    informationWidget[widgetName] = setupUI(widgetConfig, g_ui.getRootWidget())
end

local function attachSpellWidgetCallbacks(key)
    informationWidget[key].onDragEnter = function(widget, mousePos)
        if not modules.corelib.g_keyboard.isCtrlPressed() then
            return false
        end
        widget:breakAnchors()
        widget.movingReference = {
            x = mousePos.x - widget:getX(),
            y = mousePos.y - widget:getY()
        }
        return true
    end

    informationWidget[key].onDragMove = function(widget, mousePos, moved)
        local parentRect = widget:getParent():getRect()
        local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x),
            parentRect.x + parentRect.width - widget:getWidth())
        local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(),
            mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight())
        widget:move(x, y)
        return true
    end

    informationWidget[key].onDragLeave = function(widget, pos)
        storage.widgetPos[key] = {}
        storage.widgetPos[key].x = widget:getX();
        storage.widgetPos[key].y = widget:getY();
        return true
    end
end

for key, value in pairs(informationWidget) do
    attachSpellWidgetCallbacks(key)
    informationWidget[key]:setPosition(storage.widgetPos[key] or {0, 50})
end

local toShow = informationWidget['showText'];

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macro(10, function()
    if not (fugaSpellsWidgets and storageProfiles.fugaSpells) then
        return;
    end

    for index, spellConfig in ipairs(storageProfiles.fugaSpells) do
        local widget = fugaSpellsWidgets[spellConfig.index];
        if widget then
            local textToSet = firstLetterUpper(spellConfig.onScreen)
            local color = 'green'
            if spellConfig.activeCooldown and spellConfig.activeCooldown > os.time() then
                textToSet = textToSet .. ' | ' .. formatOsTime(spellConfig.activeCooldown)
                color = 'blue'
                if spellConfig.enableLifes and spellConfig.lifes == 0 then
                    spellConfig.activeCooldown = nil;
                end
            elseif spellConfig.totalCooldown and spellConfig.totalCooldown > os.time() then
                textToSet = textToSet .. ' | ' .. formatOsTime(spellConfig.totalCooldown)
                color = 'red'
            else
                textToSet = textToSet .. ' | OK!'
                if spellConfig.enableMultiple and spellConfig.canReset then
                    spellConfig.count = 3;
                    spellConfig.canReset = false;
                end
                if spellConfig.enableLifes then
                    spellConfig.lifes = 0;
                end
                if spellConfig.enableRevive then
                    spellConfig.alreadyChecked = false;
                end
            end
            if spellConfig.enableMultiple and spellConfig.count > 0 then
                textToSet = 'COUNT: ' .. spellConfig.count .. ' | ' .. textToSet
            end
            if spellConfig.enableLifes and spellConfig.lifes > 0 then
                textToSet = 'VIDAS: ' .. spellConfig.lifes .. ' | ' .. textToSet
            end
            widget:setText(textToSet)
            widget:setColor(color)
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyIcon.title:setOn(isOn.keyMacro);
keyIcon.title.onClick = function(widget)
    isOn.keyMacro = not isOn.keyMacro;
    widget:setOn(isOn.keyMacro);
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

keyIcon.settings.onClick = function(widget)
    if not keyInterface:isVisible() then
        keyInterface:show();
        keyInterface:raise();
        keyInterface:focus();
    else
        keyInterface:hide();
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    end
end

keyInterface.closeButton.onClick = function(widget)
    keyInterface:hide();
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyInterface.key.onHoverChange = function(widget, hovered)
    if hovered then
        x = true;
        onKeyPress(function(key)
            if not x then
                return;
            end
            widget:setText(key)
        end)
    else
        x = false;
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function refreshKeyList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy();
        end
        for index, entry in ipairs(table) do
            local label = setupUI(spellEntry, list.spellList)
            label.showTimespell:hide();
            label.onDoubleClick = function(widget)
                local spellTable = entry;
                list.key:setText(spellTable.keyPress);
                list.castSpell:setText(spellTable.spellCast);
                for i, v in ipairs(storageProfiles.keySpells) do
                    if v == entry then
                        removeTable(storageProfiles.keySpells, i)
                    end
                end
                scriptFuncs.reindexTable(table);
                label:destroy();
            end
            label.enabled:setChecked(entry.enabled);
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled;
                label.enabled:setChecked(entry.enabled);
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell');
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
            end
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.keySpells) do
                    if v == entry then
                        removeTable(storageProfiles.keySpells, i)
                    end
                end
                scriptFuncs.reindexTable(storageProfiles.keySpells);
                label:destroy();
            end
            label.textToSet:setText(firstLetterUpper(entry.spellCast) .. ' | Key: ' .. entry.keyPress);
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

keyInterface.insertKey.onClick = function(widget)
    local keyPressed = keyInterface.key:getText();
    local spellName = keyInterface.castSpell:getText():lower():trim();

    if not keyPressed or keyPressed:len() == 0 then
        return warn('Invalid Key.')
    end
    for _, config in ipairs(storageProfiles.keySpells) do
        if config.keyPress == keyPressed then
            return warn('Key Already Added.')
        end
    end
    table.insert(storageProfiles.keySpells, {
        index = #storageProfiles.keySpells + 1,
        spellCast = spellName,
        keyPress = keyPressed,
        enabled = true
    });
    refreshKeyList(keyInterface, storageProfiles.keySpells)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles);
    keyInterface.key:clearText();
    keyInterface.castSpell:clearText();
end

refreshKeyList(keyInterface, storageProfiles.keySpells);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

os = os or modules.os;
local playerName = player:getName()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macro combo
macro(10, function()
    if (not comboIcon.title:isOn()) then
        return;
    end
    if stopToCast() then
        return;
    end
    if isAnySelectedKeyPressed() then
        return;
    end
    local playerPos = player:getPosition();
    local target = g_game.getAttackingCreature();
    if not g_game.isAttacking() then
        return;
    end
    local targetPos = target:getPosition();
    if not targetPos then
        return;
    end
    local targetDistance = getDistanceBetween(playerPos, targetPos);
    for index, value in ipairs(storageProfiles.comboSpells) do
        if value.enabled and targetDistance <= value.distance then
            if (not value.cooldownSpells or value.cooldownSpells <= now) then
                say(value.spellCast)
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macro fuga
local selfPlayer = g_game.getLocalPlayer();

macro(100, function()
    if not fugaIcon.title:isOn() then
        return;
    end
    if isInPz() then
        return;
    end
    local time = os.time();
    local selfHealth = selfPlayer:getHealthPercent();
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if value.enabled and selfHealth <= calculatePercentage(value.selfHealth) then
            if (not value.totalCooldown or value.totalCooldown <= time) and not canCastFuga() then
                say(value.spellCast)
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macro key
macro(10, function()
    if not keyIcon.title:isOn() then
        return;
    end
    if modules.game_console:isChatEnabled() then
        return;
    end
    for index, value in ipairs(storageProfiles.keySpells) do
        if value.enabled and (modules.corelib.g_keyboard.areKeysPressed(value.keyPress)) then
            say(value.spellCast)
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onTalk(function(name, level, mode, text, channelId, pos)
    text = text:lower();
    if name ~= player:getName() then
        return;
    end

    for index, value in ipairs(storageProfiles.comboSpells) do
        if text == value.orangeSpell then
            value.cooldownSpells = now + value.cooldown;
            -- warn('Combo OK.')
            break
        end
    end
    for index, value in ipairs(storageProfiles.fugaSpells) do
        if text == value.orangeSpell then
            if value.enableLifes then
                value.activeCooldown = os.time() + (value.cooldownActive);
                value.totalCooldown = os.time() + (value.cooldownTotal);
                value.lifes = value.amountLifes;
                -- warn('1 IF: ' .. value.orangeSpell)
            end
            if value.enableRevive and not value.alreadyChecked then
                value.totalCooldown = os.time() + (value.cooldownTotal);
                value.activeCooldown = os.time() + (value.cooldownActive);
                value.alreadyChecked = true;
                -- warn('2 IF: ' .. value.orangeSpell)
            end
            if value.enableMultiple then
                if value.count > 0 then
                    value.count = value.count - 1
                    value.activeCooldown = os.time() + (value.cooldownActive);
                    if value.count == 0 then
                        value.totalCooldown = os.time() + (value.cooldownTotal);
                        value.canReset = true;
                    end
                end
            end
            if not (value.enableLifes or value.enableRevive or value.enableMultiple) then
                value.activeCooldown = os.time() + (value.cooldownActive);
                value.totalCooldown = os.time() + (value.cooldownTotal);
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onTextMessage(function(mode, text)
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if value.enableLifes then
            if text:lower():find('morreu e renasceu') and value.activeCooldown and value.activeCooldown >= os.time() then
                value.lifes = value.lifes - 1;
            end
        end
    end
end);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

onPlayerPositionChange(function(newPos, oldPos)
    local izanagiPos = {
        x = 1214,
        y = 686,
        z = 6
    };
    for key, value in ipairs(storageProfiles.fugaSpells) do
        if value.enableRevive and value.spellCast == 'izanagi' then
            if newPos.x == izanagiPos.x and newPos.y == izanagiPos.y and newPos.z == izanagiPos.z then
                value.activeCooldown = nil;
                value.alreadyChecked = true;
            end
        end
    end
end);

