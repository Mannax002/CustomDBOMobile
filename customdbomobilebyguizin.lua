
  
  xtela, ytela = 300, 200

  local widget = setupUI([[
  Panel
	height: 400
	width: 900
  ]], modules.game_interface.getMapPanel())
  
  
  local TempoPK = 15 -- tempo em minutos
  
  if type(storage.att) ~= 'table' or storage.id ~= player:getId() then
  storage.TimeRemain = 0
  storage.att = {}
  storage.id = player:getId()
  end
  
  onTextMessage(function(mode, text)
  
  o = text:lower()
  
  if o:find('was not justified') then
  storage.TimeRemain = now + (TempoPK * 60 * 1000)
  end
  if not o:find('due to your') and not o:lower():find('you deal') then return end
  for _, x in ipairs(getSpectators(posz())) do
  if x:isPlayer() and text:find(x:getName()) then
  for v, u in pairs(storage.att) do
  
  if x:getName() == u.nk then
  table.remove(storage.att, v)
  end
  
  end
  
  table.insert(storage.att, {nk = x:getName(), t = now + 60000, i = x:getId()})
  
  end
  end
  
  end)
  
  local function doFormatMin(v)
  
  if v < 1000 then
  return '00:00'
  end
  
  v = v/1000
  local mins = 00
  local seconds = 00
  
  if v >= 60 then
  mins = string.format("%02.f", math.floor(v / 60))
  end
  
  seconds = string.format("%02.f", math.abs(math.floor(math.mod(v, 60))))
  
  return mins .. ":" .. seconds
  
  end
  
  local timepk = g_ui.loadUIFromString([[
  Label
	color: white
	opacity: 0.85
	text-horizontal-auto-resize: true
  ]], widget)
  
  macro(1, function()
  
  for c, q in ipairs(storage.att) do
  for _, x in ipairs(getSpectators(true)) do
  if x:isPlayer() and q.nk == x:getName() then
  
  if x:getHealthPercent() == 0 then
  storage.TimeRemain = now + (TempoPK * 60 * 1000)
  table.remove(storage.att, c)
  end
  
  end
  
  if q.t < now or q.t - now > 60000 or (q.nk == x:getName() and q.i ~= x:getId()) then
  table.remove(storage.att, c)
  end
  
  end
  end
  
  timepk:setPosition({y = ytela-150, x =  xtela-97})
  
  if storage.TimeRemain < now then
  
  timepk:setText('PZ: 00:00')
  timepk:setColor('green')
  
  else
  
  timepk:setText('PZ: ' ..doFormatMin(math.abs(now - storage.TimeRemain))..'')
  timepk:setColor('red')
  
  end
  
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
  
  FollowAttack = {
	  flags = { ignoreNonPathable = true, precision = 0, ignoreCreatures = true },
	};
	
	FollowAttack.getDirection = function(playerPos, direction) -- Function to get a direction and sum the equivalent to the position sent to the function
	  if (direction == 0) then playerPos.y = playerPos.y - 1;
	  elseif (direction == 1) then playerPos.x = playerPos.x + 1;
	  elseif (direction == 2) then playerPos.y = playerPos.y + 1;
	  elseif (direction == 3) then playerPos.x = playerPos.x - 1;
	  end
	  return playerPos;
	end
	
	FollowAttack.Icon = addIcon("Follow Attack", {item=7657, text="Follow Attack"}, macro(1, function()
	  if (not g_game.isAttacking() or g_game.isAttacking() and not g_game.getAttackingCreature():isPlayer()) then return; end
	
	  local playerPos = pos();
	  local target = g_game.getAttackingCreature();
	  local targetPosition = target:getPosition();
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
	end));
  

  
  
  

  
  
  
  
  local bugMapMobile = {};
  
  local cursorWidget = g_ui.getRootWidget():recursiveGetChildById('pointer');
  
  local initialPos = { x = cursorWidget:getPosition().x / cursorWidget:getWidth(), y = cursorWidget:getPosition().y / cursorWidget:getHeight() };
  
  local availableKeys = {
	  ['Up'] = { 0, -6 },
	  ['Down'] = { 0, 6 },
	  ['Left'] = { -7, 0 },
	  ['Right'] = { 7, 0 }
  };
  
  function bugMapMobile.logic()
	  local pos = pos();
	  local keypadPos = { x = cursorWidget:getPosition().x / cursorWidget:getWidth(), y = cursorWidget:getPosition().y / cursorWidget:getHeight() };
	  local diffPos = { x = initialPos.x - keypadPos.x, y = initialPos.y - keypadPos.y };
  
	  if (diffPos.y < 0.46 and diffPos.y > -0.46) then
		  if (diffPos.x > 0) then
			  pos.x = pos.x + availableKeys['Left'][1];
		  elseif (diffPos.x < 0) then
			  pos.x = pos.x + availableKeys['Right'][1];
		  else return end
	  elseif (diffPos.x < 0.46 and diffPos.x > -0.46) then
		  if (diffPos.y > 0) then
			  pos.y = pos.y + availableKeys['Up'][2];
		  elseif (diffPos.y < 0) then
			  pos.y = pos.y + availableKeys['Down'][2];
		  else return; end
	  end
	  local tile = g_map.getTile(pos);
	  if (not tile) then return; end
  
	  g_game.use(tile:getTopUseThing());
  end
  
  testMacro = macro(1, bugMapMobile.logic); 
  
  test1 = addIcon("BugMap", {item = 3074, text = "BugMap"}, testMacro )
  test1:breakAnchors()
  test1:move(10, 100) 
  
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
  
  
  
  
  
  local dropItems = { 3031, 3035 }
  local maxStackedItems = 10000000
  local dropDelay = 200
  
  gpAntiPushDrop = macro(dropDelay , "Anti-Push", function ()
  antiPush()
  end)
  
  onPlayerPositionChange(function()
  antiPush()
  end)
  
  function antiPush()
  if gpAntiPushDrop:isOff() then
  return
  end
  
  local tile = g_map.getTile(pos())
  if tile and tile:getThingCount() < maxStackedItems then
  local thing = tile:getTopThing()
  if thing and not thing:isNotMoveable() then
	for i, item in pairs(dropItems) do
	  if item ~= thing:getId() then
		  local dropItem = findItem(item)
		  if dropItem then
			g_game.move(dropItem, pos(), 1)
		  end
	  end
	end
  end
  end
  end
  
  
  
  
  local moveIds = {3031, 3035, 3043, 21907};
  macro(1, "Push-Max", function()
  local moveItem;
  local playerPos = player:getPosition();
  for x = -1, 1 do
	  for y = -1, 1 do
		  if (moveItem) then
			  break;
		  end
		  local tile = g_map.getTile({x=playerPos.x+x,y=playerPos.y+y,z=playerPos.z});
		  if (tile ~= nil) then
			  local item = tile:getTopUseThing();
			  if (item ~= nil and item:isPickupable()) then
				  -- local itemId = item:getId();
				  -- if (table.find(moveIds, itemId)) then
					  moveItem = item;
					  break;
				  -- end
			  end
		  end
	  end
  end
  if (moveItem == nil) then return; end
  moveItem:setMarked("green");
  local movePos;
  for _, container in pairs(g_game.getContainers()) do
	  if (container:getCapacity() > #container:getItems()) then
		  movePos = container:getSlotPosition(0);
		  break;
	  end
  end
  if (not movePos) then return; end
  g_game.move(moveItem, movePos, moveItem:getCount());
  end).timeout = 1;
  
  
  
  

  
  
