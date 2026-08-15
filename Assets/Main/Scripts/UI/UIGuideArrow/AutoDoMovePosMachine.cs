/**
 * [INPUT]: 依赖 AutoDoMovePos 宿主,依赖三个 BaseAutoDoMovePosState 子状态(Down/Move/Up)
 * [OUTPUT]: 对外提供 AutoDoMovePosMachine 状态机与 AutoDoMovePosState 枚举(管理按下→移动→抬起循环)
 * [POS]: UIGuideArrow 模块的有限状态机核心,持有并切换三个具体状态,是 AutoDoMovePos 与各 State 之间的调度中枢
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections.Generic;
using UnityEngine;

public enum AutoDoMovePosState
{
    DownAnim,//按下
    Move,//移动
    UpAnim,//抬起
}
public class AutoDoMovePosMachine
{
    public AutoDoMovePosMachine(AutoDoMovePos autoDo)
    {
        _autoDo = autoDo;
        InitAllState();
        _curState = AutoDoMovePosState.DownAnim;
        GetCurState()?.OnEnter();
    }
    private Dictionary<AutoDoMovePosState, BaseAutoDoMovePosState> _allState;//所有状态
    private AutoDoMovePosState _curState;//当前状态
    private AutoDoMovePos _autoDo;

    public void UnInit()
    {
        GetCurState()?.OnLeave();
    }
    public void ChangeState(AutoDoMovePosState state)
    {
        GetCurState()?.OnLeave();
        _curState = state;
        GetCurState()?.OnEnter();
    }

    private void InitAllState()
    {
        _allState = new Dictionary<AutoDoMovePosState, BaseAutoDoMovePosState>();
        _allState.Add(AutoDoMovePosState.DownAnim, new AutoDoMovePosDownAnimState(_autoDo,this));
        _allState.Add(AutoDoMovePosState.Move, new AutoDoMovePoMoveState(_autoDo,this));
        _allState.Add(AutoDoMovePosState.UpAnim, new AutoDoMovePosUpAnimState(_autoDo, this));
    }

    public BaseAutoDoMovePosState GetCurState()
    {
        if (_allState.ContainsKey(_curState))
        {
            return _allState[_curState];
        }

        return null;
    }

    public void OnUpdate(float deltaTime)
    {
        GetCurState()?.OnUpdate(deltaTime);
    }




}





