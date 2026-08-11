local HttpService = game:GetService("HttpService")

local ConfigSystem = {}
ConfigSystem.CurrentConfig = nil
ConfigSystem.CurrentTheme = "Default"
ConfigSystem.CONFIG_FOLDER = "OrvionConfigs"

local function EnsureFolder()
    if not isfolder or not isfolder(ConfigSystem.CONFIG_FOLDER) then
        if makefolder then pcall(makefolder, ConfigSystem.CONFIG_FOLDER) end
    end
end

function ConfigSystem:Save(name, data)
    EnsureFolder()
    local cfg = {Name = name, Theme = self.CurrentTheme, Data = data or {}, SavedAt = os.time()}
    local ok, enc = pcall(function() return HttpService:JSONEncode(cfg) end)
    if ok then writefile(self.CONFIG_FOLDER .. "/" .. name .. ".json", enc); self.CurrentConfig = name; return true end
    return false
end

function ConfigSystem:Load(name)
    EnsureFolder()
    local path = self.CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile and isfile(path) then
        local ok, c = pcall(function() return readfile(path) end)
        if ok then
            local dok, cfg = pcall(function() return HttpService:JSONDecode(c) end)
            if dok and cfg then
                if cfg.Theme then self.CurrentTheme = cfg.Theme end
                self.CurrentConfig = name
                return true, cfg.Data
            end
        end
    end
    return false, nil
end

function ConfigSystem:Delete(name)
    EnsureFolder()
    local path = self.CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile and isfile(path) then pcall(delfile, path) end
    if self.CurrentConfig == name then self.CurrentConfig = nil end
end

function ConfigSystem:List()
    EnsureFolder()
    local list = {}
    if listfiles then
        for _, f in ipairs(listfiles(self.CONFIG_FOLDER)) do
            local n = f:match("([^/\\]+)%.json$")
            if n then table.insert(list, n) end
        end
    end
    return list
end

return ConfigSystem
