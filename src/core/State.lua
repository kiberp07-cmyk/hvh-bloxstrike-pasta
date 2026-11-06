-- src/core/State.lua
local State = {
    Running = true,
    Connections = {},
    Entries = {},
    LastError = nil
}

function State:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function State:DisconnectAll()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.Connections)
end

return State
