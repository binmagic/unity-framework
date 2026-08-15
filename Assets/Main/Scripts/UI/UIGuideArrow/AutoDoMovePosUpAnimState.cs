/**
 * [INPUT]: 继承 BaseAutoDoMovePosState,依赖 AutoDoMovePos 定位到终点,依赖 GameEntry.Event 广播抬起动画事件
 * [OUTPUT]: 对外提供 AutoDoMovePosUpAnimState 状态(箭头停终点并触发"抬起手指"表现,超时后回到 DownAnim)
 * [POS]: UIGuideArrow 状态机三态中的"抬起"态,是循环的收尾,完成后重启到 DownAnim 形成无限点击演示
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

public class AutoDoMovePosUpAnimState : BaseAutoDoMovePosState
{
    private float _time;
    private float _allTime;
    private float _doAnimTime;
    public AutoDoMovePosUpAnimState(AutoDoMovePos autoDo, AutoDoMovePosMachine autoMachine) : base(autoDo, autoMachine)
    {
    }

    public override void OnEnter()
    {
        _time = 0;
        _allTime = autoDoMovePos.GetUpTime();
        _doAnimTime = _allTime / 3;
        autoDoMovePos.ChangeEndPos();
    }

    public override void OnUpdate(float deltaTime)
    {
        _time += Time.deltaTime;
        if (_time > _allTime)
        {
            machine.ChangeState(AutoDoMovePosState.DownAnim);
        }
        else if(_time > _doAnimTime)
        {
            GameEntry.Event.Fire(EventId.GuideMoveArrowPlayAnim, (int) AutoDoMovePos.PlayAnimName.Up);
            _doAnimTime = _allTime;
        }
    }

    public override void OnLeave()
    {
        
    }
}





