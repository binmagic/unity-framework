using UnityEngine;

public class WaterBob : MonoBehaviour
{
    [SerializeField]
    float height = 0.1f;

    [SerializeField]
    float period = 1;

    private Vector3 initialPosition;
    private float offset;
    private Transform tran;

    private void Awake()
    {
        tran = transform;
        initialPosition = transform.position;

        offset = 1 - (Random.value * 2);
    }

    private void FixedUpdate()
    {
        tran.position = initialPosition - Vector3.up * Mathf.Sin((Time.time + offset) * period) * height;
    }
}





