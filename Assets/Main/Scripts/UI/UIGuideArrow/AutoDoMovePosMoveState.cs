/**
 * [INPUT]: 继承 BaseAutoDoMovePosState,依赖 AutoDoMovePos 提供路径点与速度,依赖状态机切换到 UpAnim
 * [OUTPUT]: 对外提供 AutoDoMovePoMoveState 状态(按速度在相邻路径点间线性插值移动箭头)
 * [POS]: UIGuideArrow 状态机三态中的"移动"态,承接 DownAnim 之后、遍历完路径点后转入 UpAnim
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections.Generic;
using UnityEngine;

public class AutoDoMovePoMoveState : BaseAutoDoMovePosState
{
    private float _time;
    private float _allTime;
    private int _useIndex;//正在使用的index
    private float _speed;
    private int _allCount;
    public AutoDoMovePoMoveState(AutoDoMovePos autoDo, AutoDoMovePosMachine autoMachine) : base(autoDo, autoMachine)
    {
    }

    public override void OnEnter()
    {
        _time = 0;
        _useIndex = 0;
        _speed = autoDoMovePos.GetMoveSpeed();
        _allCount = autoDoMovePos.GetMovePosListCount();
        _allTime = GetAllTime();
    }

    public override void OnUpdate(float deltaTime)
    {
        _time += Time.deltaTime;
        autoDoMovePos.transform.position = Vector3.Lerp(GetStartScreenPos(), GetEndScreenPos(), _time / _allTime);
        if (_time > _allTime)
        {
            _time = 0;
            ++_useIndex;
            if (_useIndex >= _allCount - 1)
            {
                machine.ChangeState(AutoDoMovePosState.UpAnim);
            }
            else
            {
                _allTime = GetAllTime();
            }
        }
    }

    public override void OnLeave()
    {
        
    }

    private Vector3 GetStartScreenPos()
    {
        return autoDoMovePos.GetScreenPos(_useIndex);
    }
    
    private Vector3 GetEndScreenPos()
    {
        return autoDoMovePos.GetScreenPos(_useIndex + 1);
    }

    private float GetAllTime()
    {
        return Vector3.Distance(GetStartScreenPos(), GetEndScreenPos()) / _speed;
    }
}





