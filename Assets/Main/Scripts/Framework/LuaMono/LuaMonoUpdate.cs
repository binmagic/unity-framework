/**
 * [INPUT]: 依赖基类 LuaMonoConfig 的消息转发能力与 _Update 函数引用
 * [OUTPUT]: 对外提供 LuaMonoUpdate，额外把每帧 Update 转发到绑定 Lua table
 * [POS]: Framework LuaMono 子系统中带 Update 的变体，与父类 LuaMonoConfig 分离是为按需挂载(Update 每帧开销较高，仅需逐帧逻辑的对象才用它)
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
// Update特殊处理一下，因为带有Update的Mono相对耗一点
public class LuaMonoUpdate : LuaMonoConfig
{
    void Update()
    {
        CallLuaFunc("Update", ref _Update);
    }
}





