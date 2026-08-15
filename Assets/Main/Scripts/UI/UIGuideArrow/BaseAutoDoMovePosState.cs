/**
 * [INPUT]: 持有 AutoDoMovePos 宿主与 AutoDoMovePosMachine 引用
 * [OUTPUT]: 对外提供 BaseAutoDoMovePosState 抽象基类(定义 OnEnter/OnUpdate/OnLeave 生命周期契约)
 * [POS]: UIGuideArrow 模块状态的共同父类,DownAnim/Move/UpAnim 三个具体状态由它派生,统一状态与宿主/状态机的持有方式
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
public abstract class BaseAutoDoMovePosState
{
    public AutoDoMovePos autoDoMovePos;
    public AutoDoMovePosMachine machine;

    public BaseAutoDoMovePosState(AutoDoMovePos autoDo,AutoDoMovePosMachine autoMachine)
    {
        autoDoMovePos = autoDo;
        machine = autoMachine;
    }
    public abstract void OnEnter();

    public abstract void OnUpdate(float deltaTime);

    public abstract void OnLeave();
}





