
  
  
  
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



onTalk(function(name, level, mode, text, channelId, pos)
    if (name ~= 'Blessed Tapion') then return; end              
    if (text:find('Estou aqui para oferecer')) then
    --say('!bless')
    schedule(200, function()
    NPC.say("bless");
    schedule(400, function()
        NPC.say('yes');
    end)
    end)
    end
end);


modules.corelib.HTTP.get('https://raw.githubusercontent.com/Mannax002/Custom-mobile-NTO/refs/heads/main/Linhadotempo.lua', function(script)
    assert(loadstring(script))()
    end);
    
    
    
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
    
    macro(100, "Mobs", function() 
        local battlelist = getSpectators();
        local closest = 10
        local lowesthpc = 101
        for key, val in pairs(battlelist) do
          if val:isMonster() then
            if getDistanceBetween(player:getPosition(), val:getPosition()) <= closest then
              closest = getDistanceBetween(player:getPosition(), val:getPosition())
              if val:getHealthPercent() < lowesthpc then
                lowesthpc = val:getHealthPercent()
              end
            end
          end
        end
        for key, val in pairs(battlelist) do
          if val:isMonster() then
            if getDistanceBetween(player:getPosition(), val:getPosition()) <= closest then
              if g_game.getAttackingCreature() ~= val and val:getHealthPercent() <= lowesthpc then 
                g_game.attack(val)
           delay(100)
                break
              end
            end
          end
        end
      end)
    
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

        
