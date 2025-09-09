
local nextTransformationLevel;
local blockTransform;
local waitingMsg;




macro(200, function()
	if (not hasProtections()) then return; end
	if (blockTransform) then return; end
	
	
	local level = player:getLevel();
	if (not nextTransformationLevel or nextTransformationLevel <= level) then
		NPC.say("!transformar");
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
