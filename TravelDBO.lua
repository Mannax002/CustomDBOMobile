local windowUI = setupUI([[
MainWindow
  id: main
  !text: tr('Linhadotempo')
  size: 230 310
  scrollable: true
    
  ScrollablePanel
    id: TpList
    anchors.top: parent.top
    anchors.left: parent.left
    size: 190 225
    vertical-scrollbar: mainScroll

    Button
      !text: ('0000923151')
      anchors.top: parent.top
      anchors.left: parent.left
      width: 165

    Button
      !text: ('00200926615')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: ('00300926616')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: ('00000000616')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165
    Button
      !text: ('000000440016')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: ('000000700045')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165

    Button
      !text: ('00000000001')
      anchors.top: prev.bottom
      anchors.left: parent.left
      margin-top: 5
      width: 165


  VerticalScrollBar  
    id: mainScroll
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    step: 48
    pixels-scroll: true
    
  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
    margin-right: 15

]], g_ui.getRootWidget());
windowUI:hide();

TpLtempo = {};
TpLtempo.macro = macro(100, function() end);
local TpList = windowUI.TpList;

TpLtempo.close = function()
  windowUI:hide()
  NPC.say('bye');
end

TpLtempo.show = function()
    windowUI:show();
    windowUI:raise();
    windowUI:focus();
end

windowUI.closeButton.onClick = function()
  TpLtempo.close();
end

TpLtempo.tpToCity = function(city)
  NPC.say('linha do tempo');
  schedule(600, function()
    NPC.say(city);
    TpLtempo.close()
  end)
end


for i, child in pairs(TpList:getChildren()) do
    child.onClick = function()
      TpLtempo.tpToCity(child:getText())
    end
end

onTalk(function(name, level, mode, text, channelId, pos)
  if (TpLtempo.macro.isOff()) then return; end
  if (name ~= 'Mirai Trunks') then return; end         
  if (mode ~= 51) then return; end
  if (text:find('Diversas')) then
    print(text)
    TpLtempo.show();
  else
    TpLtempo.close();
  end
end);

onKeyDown(function(keys)
    if (keys == 'Escape' and windowUI:isVisible())  then
      TpLtempo.close();
    end
end);








-- Lista de cidades
local cities = {
  'Earth',       -- FREE
  'M2',
  'Tsufur',
  'Zelta',
  'Vegeta',
  'Namek',
  'Gardia',
  'Lude',
  'Premia',
  'City 17',
  'Ruudese',
  'Kanassa',
  'Gelbo',
  'Tritek',
  'Rygol',
  'CC21',        -- FREE
  'Yardratto'
}

-- Nome do NPC
local npcName = 'Gate Keaper'

-- Variáveis de controle
local lastTravel = 0
local travelDelay = 3000 -- 3 segundos

-- Cria a interface
travelUI = setupUI([[  
UIWindow
  !text: tr('viajar')
  color: #99d6ff
  font: sans-bold-16px
  size: 100 100
  background-color: black
  opacity: 0.85
  anchors.left: parent.left
  anchors.top: parent.top
  margin-left: 600
  margin-top: 150

  ComboBox
    id: travelOptions
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center
    opacity: 1.0
    color: yellow
    font: sans-bold-16px
    margin-top: 25
    @onSetup: |
      self:addOption("None")

  Button
    id: closeButton
    text: X
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: #99d6ff
    size: 15 15
    margin-bottom: 10
    margin-right: 10
]], g_ui.getRootWidget())

travelUI:hide()

-- Adiciona as cidades ao combo
for _, city in ipairs(cities) do
  travelUI.travelOptions:addOption(city)
end

-- Fecha a janela ao clicar no X
travelUI.closeButton.onClick = function()
  travelUI:hide()
end

-- Envia mensagem ao NPC
NPC.talk = function(text)
  if g_game.getClientVersion() >= 810 then
    g_game.talkChannel(11, 0, text)
  else
    return say(text)
  end
end

-- Mostra a UI se o NPC estiver por perto
macro(100, function()
  local findNpc = getCreatureByName(npcName)
  if findNpc and getDistanceBetween(pos(), findNpc:getPosition()) <= 2 then
  travelUI:show()
  else
  travelUI:hide()
  end
end)

travelUI.travelOptions.onOptionChange = function(widget, option, data)
  say('hi')
  schedule(800, function()
  NPC.talk(option)
  end)
  schedule(1600, function()
  NPC.talk('yes')
  end)
end
