/**
 * [INPUT]: 继承 BaseAutoDoMovePosState,依赖 AutoDoMovePos 定位到起点,依赖 GameEntry.Event 广播按下动画事件
 * [OUTPUT]: 对外提供 AutoDoMovePosDownAnimState 状态(箭头归位起点并触发"按下手指"表现,超时后转 Move)
 * [POS]: UIGuideArrow 状态机三态中的"按下"态,是循环的起点,与 UpAnimState 首尾呼应构成完整点击手势演示
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

public class AutoDoMovePosDownAnimState : BaseAutoDoMovePosState
{
    private float _time;
    private float _allTime;
    private float _doAnimTime;
    public AutoDoMovePosDownAnimState(AutoDoMovePos autoDo, AutoDoMovePosMachine autoMachine) : base(autoDo, autoMachine)
    {
    }

    public override void OnEnter()
    {
        _time = 0;
        _allTime = autoDoMovePos.GetDownTime();
        _doAnimTime = _allTime / 3;
        autoDoMovePos.ChangeStartPos();
    }

    public override void OnUpdate(float deltaTime)
    {
        _time += Time.deltaTime;
        if (_time > _allTime)
        {
            machine.ChangeState(AutoDoMovePosState.Move);
        }
        else if(_time > _doAnimTime)
        {
            GameEntry.Event.Fire(EventId.GuideMoveArrowPlayAnim, (int) AutoDoMovePos.PlayAnimName.Down);
            _doAnimTime = _allTime;
        }
    }

    public override void OnLeave()
    {
        
    }
}





