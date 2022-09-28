local addEvent = addEvent
local addEventHandler = addEventHandler
local executeCommandHandler = executeCommandHandler
local triggerClientEvent = triggerClientEvent
local getCommandHandlers = getCommandHandlers
local ipairs = ipairs
local pairs = pairs
local getResourceName = getResourceName
local getResources = getResources

addEvent('adm.interface.load.server', true)
addEventHandler('adm.interface.load.server', root, function()
	if source then
		local commandsTable = {}
		for index, theResource in ipairs(getResources()) do
		    local commands = getCommandHandlers(theResource)
		    for _, command in pairs(commands) do
		    	table.insert(commandsTable, {getResourceName(theResource), command})
		    end
		end
		triggerClientEvent(source, 'adm.interface.load.client', source, commandsTable)
	end
end)

addEvent('adm.interface.execute', true)
addEventHandler('adm.interface.execute', root, function(command, arg1)
	executeCommandHandler(command, source, arg1)
end)

addEventHandler('onPlayerCommand',root, function(command)
	local name = source.name
	triggerClientEvent(source, 'adm.interface.add.client', source, name, command)
end)