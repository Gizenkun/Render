using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScatteringManager : MonoBehaviour
{
    [SerializeField]
    private Material scatteringMat;

    [SerializeField]
    private float speed;
	// Use this for initialization
	void Start ()
    {
        scatteringMat.SetFloat("_Speed", 0);
    }
	
	// Update is called once per frame
	void Update ()
    {
		
	}

    float playTime = 0;
    bool isPlaying = false;

    void OnGUI()
    {
        if(GUILayout.Button("Play", GUILayout.Width(60f), GUILayout.Height(30f)))
        {
            isPlaying = true;
            playTime = Time.time;
            scatteringMat.SetFloat("_StartTime", Time.time);
            scatteringMat.SetFloat("_Speed", speed);
        }

        if(GUILayout.Button("Rewind", GUILayout.Width(60f), GUILayout.Height(30f)))
        {
            if (isPlaying)
            {
                scatteringMat.SetFloat("_MoveTime", Time.time - playTime);
                scatteringMat.SetFloat("_StartTime", Time.time);
                scatteringMat.SetFloat("_Speed", -speed);
                isPlaying = false;
            }
        }

        if(GUILayout.Button("Reset", GUILayout.Width(60f), GUILayout.Height(30f)))
        {
            playTime = Time.time;
            scatteringMat.SetFloat("_MoveTime", 0);
            scatteringMat.SetFloat("_StartTime", 0);
            scatteringMat.SetFloat("_Speed", -0);
            isPlaying = false;
        }
    }
}
