using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestObj
{
    public int[] name = new int[10000];
    public TestObj(string name)
    {
        Debug.Log(">>>static add");
    }

    ~TestObj()
    {
        Debug.Log(">>>static delete");
    }
}





