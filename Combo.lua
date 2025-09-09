scriptFuncs = {}
comboSpellsWidget = {}

-- Utility functions
scriptFuncs.readProfile = function(filePath, callback)
    if g_resources.fileExists(filePath) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(filePath))
        end)
        if not status then
            return warn("Error: ".. result)
        end
        callback(result)
    end
end

scriptFuncs.saveProfile = function(configFile, content)
    local status, result = pcall(function()
        return json.encode(content, 2)
    end)

    if not status then
        return warn("Error:" .. result)
    end
    g_resources.writeFileContents(configFile, result)
end

-- Storage profiles
storageProfiles = {
    comboSpells = {}
}

-- Directory setup
MAIN_DIRECTORY = "/bot/" .. modules.game_bot.contentsPanel.config:getCurrentOption().text .. "/storage/"
STORAGE_DIRECTORY = "" .. MAIN_DIRECTORY .. g_game.getWorldName() .. '.json'

if not g_resources.directoryExists(MAIN_DIRECTORY) then
    g_resources.makeDir(MAIN_DIRECTORY)
end

-- Load profile
scriptFuncs.readProfile(STORAGE_DIRECTORY, function(result)
    storageProfiles = result
    if (type(storageProfiles.comboSpells) ~= 'table') then
        storageProfiles.comboSpells = {}
    end
end)

-- Utility functions
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

-- Storage for icon state
storage['iconScripts'] = storage['iconScripts'] or {
    comboMacro = false
}

local isOn = storage['iconScripts']

function removeTable(tbl, index)
    table.remove(tbl, index)
end

formatRemainingTime = function(time)
    local remainingTime = (time - now) / 1000
    local timeText = string.format("%.0f", (time - now) / 1000) .. "s"
    return timeText
end

-- Widget callback functions
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

-- UI Templates
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

-- Main Combo Icon
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

-- Combo Interface
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
comboInterface:hide()

-- Event handlers for main icon
comboIcon.title:setOn(isOn.comboMacro)
comboIcon.title.onClick = function(widget)
    isOn.comboMacro = not isOn.comboMacro
    widget:setOn(isOn.comboMacro)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
end

comboIcon.settings.onClick = function(widget)
    if not comboInterface:isVisible() then
        comboInterface:show()
        comboInterface:raise()
        comboInterface:focus()
    else
        comboInterface:hide()
        scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
    end
end

comboInterface.closeButton.onClick = function(widget)
    comboInterface:hide()
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
end

-- Interface controls setup
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

comboInterface.sameSpell:setChecked(true)
comboInterface.orangeSpell:setEnabled(false)
comboInterface.sameSpell.onCheckChange = function(widget, checked)
    if checked then
        comboInterface.orangeSpell:setEnabled(false)
    else
        comboInterface.orangeSpell:setEnabled(true)
        comboInterface.orangeSpell:setText(comboInterface.castSpell:getText())
    end
end

-- Refresh combo list function
function refreshComboList(list, table)
    if table then
        for i, child in pairs(list.spellList:getChildren()) do
            child:destroy()
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
            comboSpellsWidget[entry.index] = newWidget
            
            label.onDoubleClick = function(widget)
                local spellTable = entry
                list.castSpell:setText(spellTable.spellCast)
                list.orangeSpell:setText(spellTable.orangeSpell)
                list.onScreen:setText(spellTable.onScreen)
                list.cooldown:setValue(spellTable.cooldown)
                list.distance:setValue(spellTable.distance)
                for i, v in ipairs(storageProfiles.comboSpells) do
                    if v == entry then
                        removeTable(storageProfiles.comboSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table)
                newWidget:destroy()
                label:destroy()
            end
            
            label.enabled:setChecked(entry.enabled)
            label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell')
            label.enabled.onClick = function(widget)
                entry.enabled = not entry.enabled
                label.enabled:setChecked(entry.enabled)
                label.enabled:setTooltip(not entry.enabled and 'Enable Spell' or 'Disable Spell')
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
            end
            
            label.showTimespell:setChecked(entry.enableTimeSpell)
            label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell')
            label.showTimespell.onClick = function(widget)
                entry.enableTimeSpell = not entry.enableTimeSpell
                label.showTimespell:setChecked(entry.enableTimeSpell)
                label.showTimespell:setTooltip(not entry.enableTimeSpell and 'Enable Time Spell' or 'Disable Time Spell')
                if entry.enableTimeSpell then
                    newWidget:show()
                else
                    newWidget:hide()
                end
                scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
            end
            
            if entry.enableTimeSpell then
                newWidget:show()
            else
                newWidget:hide()
            end
            
            label.remove.onClick = function(widget)
                for i, v in ipairs(storageProfiles.comboSpells) do
                    if v == entry then
                        removeTable(storageProfiles.comboSpells, i)
                    end
                end
                scriptFuncs.reindexTable(table)
                newWidget:destroy()
                label:destroy()
            end
            
            label.onClick = function(widget)
                comboInterface.moveDown:show()
                comboInterface.moveUp:show()
            end
            
            label.textToSet:setText(firstLetterUpper(entry.spellCast))
            label:setTooltip('Orange Message: ' .. entry.orangeSpell .. ' | Na Tela: ' .. entry.onScreen ..
                                 ' | Cooldown: ' .. entry.cooldown / 1000 .. 's | Distance: ' .. entry.distance)
        end
    end
end

-- Insert spell function
comboInterface.insertSpell.onClick = function(widget)
    local spellName = comboInterface.castSpell:getText():trim():lower()
    local orangeMsg = comboInterface.orangeSpell:getText():trim():lower()
    local onScreen = comboInterface.onScreen:getText()
    orangeMsg = (orangeMsg:len() == 0) and spellName or orangeMsg
    local cooldown = comboInterface.cooldown:getValue()
    local distance = comboInterface.distance:getValue()
    
    if (not spellName or spellName:len() == 0) then
        return warn('Invalid Spell Name.')
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
    
    comboInterface.castSpell:clearText()
    comboInterface.orangeSpell:clearText()
    comboInterface.onScreen:clearText()
    comboInterface.sameSpell:setChecked(true)
    comboInterface.orangeSpell:setEnabled(false)
    comboInterface.cooldown:setValue(0)
    comboInterface.distance:setValue(0)
end

-- Move up/down functions
comboInterface.moveUp.onClick = function()
    local action = comboInterface.spellList:getFocusedChild()
    if (not action) then
        return
    end
    local index = comboInterface.spellList:getChildIndex(action)
    if (index < 2) then
        return
    end
    comboInterface.spellList:moveChildToIndex(action, index - 1)
    comboInterface.spellList:ensureChildVisible(action)
    storageProfiles.comboSpells[index].index = index - 1
    storageProfiles.comboSpells[index - 1].index = index
    table.sort(storageProfiles.comboSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
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
    comboInterface.spellList:moveChildToIndex(action, index + 1)
    comboInterface.spellList:ensureChildVisible(action)
    storageProfiles.comboSpells[index].index = index + 1
    storageProfiles.comboSpells[index + 1].index = index
    table.sort(storageProfiles.comboSpells, function(a, b)
        return a.index < b.index
    end)
    scriptFuncs.saveProfile(STORAGE_DIRECTORY, storageProfiles)
end

-- Find cooldown function
comboInterface.findCD.onClick = function(widget)
    detectOrangeSpell, testSpell = true, true
    spellTime = {0, ''}
end

-- Initialize combo list
refreshComboList(comboInterface, storageProfiles.comboSpells)

-- Test spell macro
macro(10, function()
    if testSpell then
        say(comboInterface.castSpell:getText())
    end
end)

-- Cooldown detection
onTalk(function(name, level, mode, text, channelId, pos)
    if not detectOrangeSpell then
        return
    end
    if player:getName() ~= name then
        return
    end

    local verifying = comboInterface.orangeSpell:getText():len() > 0 and
                          comboInterface.orangeSpell:getText():lower():trim() or
                          comboInterface.castSpell:getText():lower():trim()

    if text:lower():trim() == verifying then
        if spellTime[2] == verifying then
            comboInterface.cooldown:setValue(now - spellTime[1])
            spellTime = {now, verifying}
            detectOrangeSpell = false
            testSpell = false
        else
            spellTime = {now, verifying}
        end
    end
end)

-- Widget update macro
macro(10, function()
    if not (comboSpellsWidget or storageProfiles.comboSpells) then
        return
    end
    for index, spellConfig in ipairs(storageProfiles.comboSpells) do
        local widget = comboSpellsWidget[spellConfig.index]
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
end)

-- Main combo macro
macro(10, function()
    if (not comboIcon.title:isOn()) then
        return
    end
    
    local playerPos = player:getPosition()
    local target = g_game.getAttackingCreature()
    if not g_game.isAttacking() then
        return
    end
    local targetPos = target:getPosition()
    if not targetPos then
        return
    end
    local targetDistance = getDistanceBetween(playerPos, targetPos)
    
    for index, value in ipairs(storageProfiles.comboSpells) do
        if value.enabled and targetDistance <= value.distance then
            if (not value.cooldownSpells or value.cooldownSpells <= now) then
                say(value.spellCast)
            end
        end
    end
end)

-- Orange message detection for cooldowns
onTalk(function(name, level, mode, text, channelId, pos)
    text = text:lower()
    if name ~= player:getName() then
        return
    end

    for index, value in ipairs(storageProfiles.comboSpells) do
        if text == value.orangeSpell then
            value.cooldownSpells = now + value.cooldown
            break
        end
    end
end)
