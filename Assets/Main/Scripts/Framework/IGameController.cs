/**
 * [INPUT]: 无外部依赖
 * [OUTPUT]: 对外提供 IGameController 接口，约定 OnUpdate 轮询与 Shutdown 清理
 * [POS]: Framework 层各托管子系统(EventComponent/TimerComponent/SDKManager 等)的统一生命周期契约，由 GameEntry 在 Update/Shutdown 中集中驱动
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
public interface IGameController
{
    /// <summary>
    /// 游戏框架模块轮询。
    /// </summary>
    /// <param name="elapseSeconds">逻辑流逝时间，以秒为单位。</param>
    /// <param name="realElapseSeconds">真实流逝时间，以秒为单位。</param>
    void OnUpdate(float elapseSeconds);

    /// <summary>
    /// 关闭并清理游戏框架模块。
    /// </summary>
    void Shutdown();
}





