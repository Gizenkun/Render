Shader "Unlit/Example_PhongTessellation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Phong("Phong", Range(0, 1)) = 0
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma hull hs
#pragma domain ds

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "Tessellation.cginc"

	struct vertex_appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 texcoord :TEXCOORD0;
	};

	struct tessellation_appdata
	{
		float4 vertex : INTERNALTESSPOS;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float3 worldNormal : TEXCOORD0;
		float2 uv : TEXCOORD1;
	};

	float _Phong;

	tessellation_appdata vert(vertex_appdata v)
	{
		tessellation_appdata o;
		o.normal = v.normal;//mul(normal, (float3x3)unity_WorldToObject);
		o.vertex = v.vertex;//UnityObjectToClipPos(v.vertex);
		return o;
	}

	UnityTessellationFactors hsconst(InputPatch<tessellation_appdata, 3> v)
	{
		UnityTessellationFactors o;
		o.edge[0] = 6;
		o.edge[1] = 6;
		o.edge[2] = 6;
		o.inside = 6;

		return o;
	}

	[UNITY_domain("tri")]
	[UNITY_partitioning("integer")]
	[UNITY_outputtopology("triangle_cw")]
	[UNITY_patchconstantfunc("hsconst")]
	[UNITY_outputcontrolpoints(3)]
	tessellation_appdata hs(InputPatch<tessellation_appdata, 3> vi, uint id : SV_OutputControlPointID)
	{
		return vi[id];
	}

	[UNITY_domain("tri")]
	v2f ds(UnityTessellationFactors tessFactors, OutputPatch<tessellation_appdata, 3> vi, float3 bary : SV_Domainlocation)
	{
		float3 offset[3];

		float4 pos = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;

		for (int i = 0; i < 3; i++)
		{
			float3 normal = normalize(vi[i].normal);
			offset[i] = normal * (dot(normal, pos.xyz) - dot(normal, vi[i].vertex.xyz));
		}

		vertex_appdata v;
		v.vertex = lerp(pos, pos - float4((offset[0] * bary.x + offset[1] * bary.y + offset[2] * bary.z), 1), _Phong);
		v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
		v.tangent = vi[0].tangent * bary.x + vi[1].tangent * bary.y + vi[2].tangent * bary.z;
		v.texcoord = vi[0].texcoord * bary.x + vi[1].texcoord * bary.y + vi[2].texcoord * bary.z;

		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = mul(v.normal, unity_WorldToObject);

		o.uv = v.texcoord;
		return o;
	}

	float4 frag(v2f i) : SV_Target
	{
		float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		float diffuse = 0.5 * dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0.xyz)) + 0.5;
		return float4(ambient + diffuse * _LightColor0.rgb, 1.0);
	}

		ENDCG
	}
	}
	FallBack "Diffuse"
}
