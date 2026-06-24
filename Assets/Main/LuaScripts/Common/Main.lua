-- added by wsh @ 2017-12-27
-- 1、Unity侧部分功能的Lua代码实现用来降低与cs代码的交互来提供性能---移植自tolua
-- 2、这里的模块在游戏逻辑跑之前开始启动，雷同Unity中的Plugin下脚本
-- 3、这里的全局模块一般用于提供对lua语言级别的支持和扩展，和游戏框架以及逻辑无关

--print("Common main start...")

-- 加载全局模块
require "Common.Tools.import"
require "Common.LuaUtil"
require "Common.TableUtil"
require "Common.TableAdvUtil"
require "Common.StringUtil"
require "Common.FuncUtil"
require "Common.LuaProfiler"

Mathf		= require "Common.Tools.UnityEngine.Mathf"
Vector2		= require "Common.Tools.UnityEngine.Vector2"
Vector3 	= require "Common.Tools.UnityEngine.Vector3"
Vector4		= require "Common.Tools.UnityEngine.Vector4"
Quaternion	= require "Common.Tools.UnityEngine.Quaternion"
Color		= require "Common.Tools.UnityEngine.Color"
Ray			= require "Common.Tools.UnityEngine.Ray"
Bounds		= require "Common.Tools.UnityEngine.Bounds"
RaycastHit	= require "Common.Tools.UnityEngine.RaycastHit"
Touch		= require "Common.Tools.UnityEngine.Touch"
LayerMask	= require "Common.Tools.UnityEngine.LayerMask"
Plane		= require "Common.Tools.UnityEngine.Plane"
Time		= require "Common.Tools.UnityEngine.Time"
Object		= require "Common.Tools.UnityEngine.Object"
Color32		= require "Common.Tools.UnityEngine.Color32"

list		= require "Common.Tools.list"
queue       = require "Common.Tools.queue"

require "Common.Tools.event"

--package.cpath = package.cpath .. ';C:/Users/a/AppData/Roaming/JetBrains/Rider2024.3/plugins/EmmyLua/debugger/emmy/windows/x64/?.dll'
--local dbg = require('emmy_core')
--dbg.tcpConnect('localhost', 9966)

function GetBuildCfgForEditor(buildId)
    local tbl = require('LuaDatatable.building')
    local row = tbl['data'][buildId]
    if row == nil then
        error('GetBuildCfgForEditor Error!!!! row is not exist! buildId: ' .. tostring(buildId))
        return "{tiles:1, overlap:0}"
    end
    
    local tileCol = tbl['index']['tiles'][1]
    local overlapCol = 0--tbl['index']['overlap'][1]
    
    local dt = {
        tiles = row[tileCol],
        overlap = row[overlapCol]
    }

    print(string.format('buildId:%s, tileCol:%s, overlapCol:%s, tiles:%s', buildId, tileCol, overlapCol, row[tileCol]))

    local rapidjson = require "rapidjson"
    local jsonStr = rapidjson.encode(dt)
    return jsonStr
end


function GetCfgForEditor(tableName, id)
    local tbl = require('LuaDatatable.' .. tableName)
    local row = tbl['data'][id]
    if row == nil then
        error('GetCfgForEditor Error!!!! row is not exist! tableName:' .. tableName .. ', id: ' .. tostring(id))
        return "{}"
    end
    
    local retTable = {}
    for k, v in pairs(tbl['index']) do
        retTable[k] = row[v[1]]
    end
    
    local rapidjson = require "rapidjson"
    local jsonStr = rapidjson.encode(retTable)
    return jsonStr
end