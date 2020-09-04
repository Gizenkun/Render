using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ComputMode
{
    CPU,
    GPU
}

public struct InputData
{
    public Vector4 vertex;
    public Matrix4x4 transformMatrix;
}

public class TransformManager : MonoBehaviour
{
    [SerializeField]
    private ComputeShader computeShader;
    [SerializeField]
    private int transformCount = 1000;

    [SerializeField]
    private ComputMode currentMode = ComputMode.CPU;


    private int kernel;
    private InputData[] inputData;
    private Vector3[] outputData; 
    private ComputeBuffer inputBuffer;
    private ComputeBuffer outputBuffer;

    void Start ()
    {
        inputData = new InputData[transformCount];

        for(int i=0; i< transformCount; i++)
        {
            inputData[i].vertex = Vector4.one;
            inputData[i].transformMatrix = Matrix4x4.Rotate(Quaternion.AngleAxis(30f, Vector3.up));
        }

        outputData = new Vector3[transformCount];

        kernel = computeShader.FindKernel("CSMain");

        inputBuffer = new ComputeBuffer(transformCount, (16 + 4) * 4);
        outputBuffer = new ComputeBuffer(transformCount, 3 * 4);

        inputBuffer.SetData(inputData);
        outputBuffer.SetData(outputData);

        computeShader.SetBuffer(kernel, "inputData", inputBuffer);
        computeShader.SetBuffer(kernel, "outputData", outputBuffer);
    }
	
	void Update ()
    {
        switch (currentMode)
        {
            case ComputMode.CPU:

                for (int i = 0; i < transformCount; i++)
                {
                    outputData[i] = inputData[i].transformMatrix * inputData[i].vertex;
                }

                break;
            case ComputMode.GPU:

                computeShader.Dispatch(kernel, 64, 1, 1);

                outputBuffer.GetData(outputData);

                break;
            default:
                break;
        }

        Debug.Log(outputData[100]);
    }

    private void OnDestroy()
    {
        inputBuffer.Release();
        outputBuffer.Release();
    }
}
