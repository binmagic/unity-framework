using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectRandRotation : MonoBehaviour
{
    public float axisX = 1;
    public float axisY = 1;  
    public float axisZ = 1;   
    public float speed = 1;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.Rotate(new Vector3(axisY, axisX, axisZ) * speed, Space.World);

    }
}





