// Update特殊处理一下，因为带有Update的Mono相对耗一点
public class LuaMonoUpdate : LuaMonoConfig
{
    void Update()
    {
        CallLuaFunc("Update", ref _Update);
    }
}





