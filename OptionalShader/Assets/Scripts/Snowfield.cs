using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Snowfield : MonoBehaviour
{
    [SerializeField]
    private Shader decalShader;
    [SerializeField]
    private Texture heightTex;
    [SerializeField]
    private Texture footprintTex;
    [SerializeField]
    private Material snowfieldMat;

    [SerializeField]
    private List<FootprintInfo> footprintList = new List<FootprintInfo>();

    [SerializeField]
    private Vector2 footprintSize = new Vector2(0.5f, 0.5f);

    [SerializeField]
    private float angle = 0;
	// Use this for initialization
	private void Start ()
    {
        InitRenderTexture();
    }

    // Update is called once per frame
    private void Update ()
    {
		if(Input.GetKeyDown(KeyCode.Mouse0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if(Physics.Raycast(ray, out hit, 1000f))
            {
                //AddFootprint(hit.textureCoord);
                //Debug.Log(hit.textureCoord);
            }
        }
	}

    public void AddFootprint(Vector2 uv, float angle)
    {
        FootprintInfo newFootprint = new FootprintInfo() { position = new Vector2(uv.x - (footprintSize.x * 0.5f), uv.y - (footprintSize.y * 0.5f)), size = footprintSize, angle = angle };
        //snowfieldMat.SetVector("_DecalControl", new Vector4(uv.x - (footprintSize.x * 0.5f), uv.y - (footprintSize.y * 0.5f), footprintSize.x, footprintSize.y));
        footprintList.Add(newFootprint);//设置原点的偏移
        AddFootprint(newFootprint);
        //GenerateHeightMap();
    }
    RenderTexture rt1;
    RenderTexture rt2;

    Material decalMat;

    //private void GenerateHeightMap()
    //{
    //    Material decalMat = new Material(decalShader);
    //    RenderTexture.ReleaseTemporary(rt1);
    //    RenderTexture.ReleaseTemporary(rt2);
    //    rt1 = RenderTexture.GetTemporary(1024, 1024, 0);
    //    rt2 = RenderTexture.GetTemporary(1024, 1024, 0);
    //    decalMat.SetTexture("_DecalTex", heightTex);
    //    //decalMat.SetFloat("_Angle", angle);
    //    decalMat.SetColor("_InitColor", (heightTex as Texture2D).GetPixel(0, 0));
    //    Graphics.Blit(rt1, rt1, decalMat, 0);
    //    //decalMat.SetVector("_DecalControl", new Vector4(uv.x - (footprintSize.x * 0.5f), uv.y - (footprintSize.y * 0.5f), footprintSize.x, footprintSize.y));
    //    foreach (var footprint in footprintList)
    //    {
    //        RenderTexture temp = RenderTexture.GetTemporary(1024, 1024, 0);
    //        decalMat.SetVector("_DecalControl", footprint.GetFootprintPosition());
    //        decalMat.SetFloat("_Angle", footprint.angle);
    //        Graphics.Blit(rt1, temp, decalMat, 1);
    //        RenderTexture.ReleaseTemporary(rt1);
    //        rt1 = temp;
    //    }

    //    decalMat.SetTexture("_DecalTex", footprintTex);
    //    decalMat.SetColor("_InitColor", (footprintTex as Texture2D).GetPixel(0, 0));
    //    Debug.Log((footprintTex as Texture2D).GetPixel(0, 0));
    //    Debug.Log((footprintTex as Texture2D).GetPixel(512, 512));
    //    Graphics.Blit(rt2, rt2, decalMat, 0);

    //    foreach (var footprint in footprintList)
    //    {
    //        RenderTexture temp = RenderTexture.GetTemporary(1024, 1024, 0);
    //        decalMat.SetVector("_DecalControl", footprint.GetFootprintPosition());
    //        decalMat.SetFloat("_Angle", footprint.angle);
    //        Graphics.Blit(rt2, temp, decalMat, 2);
    //        RenderTexture.ReleaseTemporary(rt2);
    //        rt2 = temp;
    //    }

    //    //RenderTexture currentRT = RenderTexture.active;
    //    //RenderTexture.active = rt1;

    //    //Texture2D texture = new Texture2D(1024, 1024);
    //    //texture.ReadPixels(new Rect(0, 0, 1024, 1024), 0, 0);
    //    //System.IO.File.WriteAllBytes(Application.dataPath + "/test.png", texture.EncodeToPNG());


    //    //RenderTexture.active = rt2;
    //    //Texture2D texture2 = new Texture2D(1024, 1024);
    //    //texture2.ReadPixels(new Rect(0, 0, 1024, 1024), 0, 0);
    //    //System.IO.File.WriteAllBytes(Application.dataPath + "/test2.png", texture2.EncodeToPNG());
    //    //RenderTexture.active = currentRT;
    //    snowfieldMat.SetTexture("_HeightMap", rt1);
    //    snowfieldMat.SetTexture("_FootprintMap", rt2);
    //}

    private void InitRenderTexture()
    {
        decalMat = new Material(decalShader);
        RenderTexture.ReleaseTemporary(rt1);
        RenderTexture.ReleaseTemporary(rt2);
        rt1 = RenderTexture.GetTemporary(1024, 1024, 0);
        rt2 = RenderTexture.GetTemporary(1024, 1024, 0);
        decalMat.SetTexture("_DecalTex", heightTex);
        decalMat.SetColor("_InitColor", (heightTex as Texture2D).GetPixel(0, 0));
        Graphics.Blit(rt1, rt1, decalMat, 0);

        decalMat.SetTexture("_DecalTex", footprintTex);
        decalMat.SetColor("_InitColor", (footprintTex as Texture2D).GetPixel(0, 0));
        Graphics.Blit(rt2, rt2, decalMat, 0);

        snowfieldMat.SetTexture("_HeightMap", rt1);
        snowfieldMat.SetTexture("_FootprintMap", rt2);
    }

    private void AddFootprint(FootprintInfo footprintInfo)
    {
        decalMat.SetVector("_DecalControl", footprintInfo.GetFootprintPosition());
        decalMat.SetFloat("_Angle", footprintInfo.angle);

        decalMat.SetTexture("_DecalTex", heightTex);
        RenderTexture temp = RenderTexture.GetTemporary(1024, 1024, 0);
        Graphics.Blit(rt1, temp, decalMat, 1);
        RenderTexture.ReleaseTemporary(rt1);
        rt1 = temp;

        decalMat.SetTexture("_DecalTex", footprintTex);
        temp = RenderTexture.GetTemporary(1024, 1024, 0);
        Graphics.Blit(rt2, temp, decalMat, 2);
        RenderTexture.ReleaseTemporary(rt2);
        rt2 = temp;

        snowfieldMat.SetTexture("_HeightMap", rt1);
        snowfieldMat.SetTexture("_FootprintMap", rt2);
    }
}

[System.Serializable]
public class FootprintInfo
{
    public Vector2 position;
    public Vector2 size;
    public float angle;

    public Vector4 GetFootprintPosition()
    {
        return new Vector4(position.x, position.y, size.x, size.y);
    }
}
