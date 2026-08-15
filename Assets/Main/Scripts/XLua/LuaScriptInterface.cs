/**
 * [INPUT]: 依赖 XLua 的接口映射能力
 * [OUTPUT]: 对外提供 LuaScriptInterface 命名空间下的接口(如 UIManager),声明 C# 侧可调用的 Lua 方法契约
 * [POS]: XLua 的 C#→Lua 接口边界,以强类型接口代理 Lua 表方法,让 C# 以类型安全方式调 Lua 模块
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections.Generic;
using XLua;

namespace LuaScriptInterface
{
    public interface UIManager
    {
        void OpenWindow(string uiName, params object[] args);
        void DestroyWindow(string uiName, params object[] args);
        bool IsWindowOpen(string uiName);
    }
    
}





