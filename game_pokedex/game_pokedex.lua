pokedexWindow = nil

Painel = {
	pokedex = {
		['pnlDescricao'] = "",
		['pnlAtaques'] = "",
		['pnlHabilidades'] = "",		
	}
}

function init()
	connect(g_game, { onTextMessage = onTextMessage, onGameEnd = hide })
end

function showPokedex()
	if pokedexWindow then
		pokedexWindow:destroy()
	end
	pokedexWindow = g_ui.displayUI('game_pokedex')
end

function terminate()
	disconnect(g_game, { onTextMessage = onTextMessage, onGameEnd = hide })
end

function hide()
	if pokedexWindow then
		pokedexWindow:destroy()
	end
end

function Painel.show(childName)	
	pokedexWindow:getChildById('pnlDescricao'):getChildById('lblConteudo'):setText(Painel.pokedex['pnlDescricao'])
	pokedexWindow:getChildById('pnlAtaques'):getChildById('lblConteudo'):setText(Painel.pokedex['pnlAtaques'])
	pokedexWindow:getChildById('pnlHabilidades'):getChildById('lblConteudo'):setText(Painel.pokedex['pnlHabilidades'])
	pokedexWindow:getChildById('pnlDescricao'):setVisible(false)
	pokedexWindow:getChildById('scrDescricao'):setVisible(false)
	pokedexWindow:getChildById('pnlAtaques'):setVisible(false)
	pokedexWindow:getChildById('scrAtaques'):setVisible(false)
	pokedexWindow:getChildById('pnlHabilidades'):setVisible(false)
	pokedexWindow:getChildById('scrHabilidades'):setVisible(false)
	
	pokedexWindow:getChildById(childName):setVisible(true)
	pokedexWindow:getChildById('scr'..childName:sub(4, #childName)):setVisible(true)
end

function onTextMessage(mode, text)
	if not g_game.isOnline() then return end
	
	local name = text:match('Name: (.-)\n')
	local type = text:match('Type: (.-)\n')
	if name and type then 
		showPokedex()
		
		local level = text:match('Level: (.-)\n')
		local requiredLevel = text:match('Required level: (.-)\n')
		local evoDesc = text:match('Evolutions:\n(.-)\nMoves:')
		local moves = text:match('Moves:\n(.-)\nAbility:')
		local ability = text:match('Ability:\n(.*)')
		
		pokedexWindow:getChildById('lblPokeName'):setText(name)
		if name:find("Shiny") then
			name = name:sub(7, #name)
			pokedexWindow:getChildById('lblPokeName'):setColor("red")
		end
		
		local f = io.open("modules/game_pokedex/imagens/pokemons/"..name..".png", "r")
		if not f then
			print("Not found poke image called "..name)
		else
			f:close()
			pokedexWindow:getChildById('imgPokemon'):setImage("/game_pokedex/imagens/pokemons/"..name..".png")
		end

		Painel.pokedex["pnlDescricao"] = "Type: "..type.."\nLevel: "..level.."\nRequired Level: "..requiredLevel.."\n\nEvolutions:\n"..(evoDesc or "No evolutions")
		Painel.pokedex["pnlAtaques"] = moves or "No moves"
		Painel.pokedex["pnlHabilidades"] = ability or "No abilities"
		Painel.show('pnlDescricao')
	end
end
