--[[
-- [INPUT]: 依赖 Lua debug.getlocal 推断调用者模块名,依赖 string.split 与 package 表
-- [OUTPUT]: 对外提供全局函数 import(相对/绝对路径 require)与 reimport(清缓存重新 require)
-- [POS]: Common/Tools 的模块加载辅助,支持以 "." 前缀相对定位模块并提供热重载入口,是热更调试期替换单文件的基础设施
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

-- 加载模块
function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

--重新require一个lua文件，替代系统文件。
function reimport(name)
    local package = package
    package.loaded[name] = nil
    package.preload[name] = nil
    return require(name)    
end