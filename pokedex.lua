local multiplier = 5 -- how many times more exp than killing the monster the player will get when using dex on it for the first time
local pokedexId = 2263

function Monster.getSummonStatus(self)
	local output = "Name: " .. self:getName()
	local monsterType = MonsterType(self:getName())
	output = output .. "\nType: " .. monsterType:getRaceName() .. "\nLevel: " .. self:getLevel()
	output = output .. "\nRequired level: " .. monsterType:getRequiredLevel() .. "\n"

	local evolutionList = monsterType:getEvolutionList()
	if #evolutionList > 0 then
		output = output .. "\nEvolutions:\n"
		for _, evolution in ipairs(evolutionList) do
			output = output .. evolution.name .. " at level " .. evolution.level .. " with probability " .. evolution.chance .. "%\n"
		end
	else
		output = output .. "No evolutions\n"
	end

	local moves = monsterType:getMoveList()
	if #moves > 0 then
		output = output .. "\nMoves:\n"
		for _, move in ipairs(moves) do
			output = output .. move.name .. " (Cooldown: " .. (move.speed / 1000) .. " seconds)\n"
		end
	else
		output = output .. "No moves\n"
	end

	local abilities = ""
	if monsterType:isFlyable() then abilities = abilities .. "Fly, " end
	if monsterType:isRideable() then abilities = abilities .. "Ride, " end
	if monsterType:isSurfable() then abilities = abilities .. "Surf, " end
	if monsterType:canTeleport() then abilities = abilities .. "Teleport, " end
	if abilities ~= "" then
		abilities = abilities:sub(1, -3)
	else
		abilities = "No abilities"
	end
	output = output .. "\nAbility:\n" .. abilities

	return output
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or not target:isCreature() then
		local text = player:getPokedexStatus(baseStorageDex)
		player:showTextDialog(pokedexId, text)
		return true
	end

	if target:isMonster() then
		local monsterNumber = MonsterType(target:getName()):dexEntry()
		if monsterNumber == 0 then
			player:sendCancelMessage("This monster has no Pokédex entry.")
			return true
		end

		local storage = baseStorageDex + monsterNumber
		if player:getStorageValue(storage) == -1 then
			player:setStorageValue(storage, 0)
			player:addExperience(target:getExperience() * multiplier, true)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Added to your Pokédex!")
		end

		local monsterStatus = target:getSummonStatus()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, monsterStatus)
		return true
	end

	return false
end
