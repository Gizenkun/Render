using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomExample : MonoBehaviour
{
    private int seed = 0;

    private uint[] MT = new uint[624];
    private int index = 0;

    [SerializeField]
    private AnimationCurve curve;

    private void OnGUI()
    {
        GUILayout.Space(10);
        string inputSeed = GUILayout.TextField(seed.ToString(), GUILayout.Width(200));
        if(!string.IsNullOrEmpty(inputSeed))
        {
            seed = int.Parse(inputSeed);
        }

        if (GUILayout.Button("线性同余法", GUILayout.Width(200)))
        {
            Congruence(seed);
        }
        else if(GUILayout.Button("梅森旋转法", GUILayout.Width(200)))
        {
            MersenneTwister(seed);
        }
        else if(GUILayout.Button("简单函数衍化", GUILayout.Width(200)))
        {
            Hash(seed);
        }
    }


    //线性同余法
    private void Congruence(int seed)
    {
        curve = new AnimationCurve();
        int m = 100000;
        int a = 97;
        int b = 71;
        int random = seed;
        for (int i = 0; i < 1000; i++)
        {
            random = (a * random + b) % m;
            Debug.Log("<color=red>" + (float)random / m + "</color>");
            curve.AddKey(i / 0.1f, (float)random / m);
        }
    }

    //梅森旋转法
    private void MersenneTwister(int seed)
    {
        curve = new AnimationCurve();
        MT[0] = (uint)seed;
        Init();

        for (int i = 0; i < 1000; i++)
        {
            uint random = Rand();
            Debug.Log("<color=red>" + (float)random / uint.MaxValue + "</color>");
            curve.AddKey(i / 0.1f, (float)random / uint.MaxValue);
        }
    }

    //对旋转链进行初始化
    private void Init()
    {
        for (int i = 1; i < 624; i++)
        {
            uint t = 1812433253 * (MT[i - 1] ^ (MT[i - 1] >> 30)) + 1;
            MT[i] = t & 0xffffffff;
        }
    }

    //使用旋转算法处理旋转链
    private void Twist()
    {
        for (int i = 0; i < 624; i++)
        {
            uint y = (MT[i] & 0x80000000) + (MT[(i + 1) % 624] & 0x7fffffff);
            MT[i] = MT[(i + 397) % 624] ^ (y >> 1);
            if ((y & 1) == 1)
            {
                MT[i] ^= 2567483615;
            }
        }
        index = 0;
    }

    private uint Rand()
    {
        int i = index;
        index = i + 1;
        if (index >= 624)
        {
            Twist();
            i = index;
        }
        uint random = MT[i];
        random = random ^ (random >> 11);
        random = random ^ ((random << 7) & 2636928640);
        random = random ^ ((random << 15) & 4022730752);
        random = random ^ (random >> 18);

        return random;
    }

    //简单函数衍化法
    private void Hash(int seed)
    {
        curve = new AnimationCurve();
        float random = seed;

        for (int i = 0; i < 1000; i++)
        {
            random = Mathf.Abs(((Mathf.Sin(random) * 44653.78221f) % 1));
            Debug.Log("<color=red>" + (float)random + "</color>");
            curve.AddKey(i / 0.1f, random);
        }
    }
}
