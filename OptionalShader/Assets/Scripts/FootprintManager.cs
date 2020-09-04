using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FootprintManager : MonoBehaviour
{
    [SerializeField]
    private Transform leftFoot;
    [SerializeField]
    private Transform rightFoot;
    [SerializeField]
    private Snowfield snowfield;

    [SerializeField]
    private float checkDistance = 0.1f;

    private bool leftMotionless = false;
    private bool rightMotionless = false;

    private void Start()
    {
    }

    private void Update()
    {
        RaycastHit rayHit1;
        if (Physics.Raycast(new Ray(leftFoot.position, -Vector3.up), out rayHit1, checkDistance))
        {
            if(!leftMotionless)
            {
                float leftAngle = leftFoot.rotation.eulerAngles.y - 90;
                snowfield.AddFootprint(rayHit1.textureCoord, leftAngle);
                leftMotionless = true;
            }
        }
        else
        {
            leftMotionless = false;
        }

        RaycastHit rayHit2;
        if (Physics.Raycast(new Ray(rightFoot.position, -Vector3.up), out rayHit2, checkDistance))
        {
            if (!rightMotionless)
            {
                float rightAngle = rightFoot.rotation.eulerAngles.y - 90;
                snowfield.AddFootprint(rayHit2.textureCoord, rightAngle);
                rightMotionless = true;
            }
            //Debug.Log("rightFoot : " + rayHit.point);
        }
        else
        {
            rightMotionless = false;
        }
    }
}
