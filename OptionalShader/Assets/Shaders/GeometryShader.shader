Shader "Custom/GeometryShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags {"RenderType" = "Opaque"}

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2g
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			float _Color[4];

			v2g vert(appdata v)
			{
				v2g o;
				o.pos = v.vertex;
				o.normal = v.normal;
				o.uv = v.texcoord;
				return o;
			}

			[maxvertexcount(1)]
			void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream)
			{
				g2f o;

				o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
				float3 normal = cross(IN[2].pos - IN[0].pos, IN[1].pos - IN[0].pos);
				float4 pos = (IN[0].pos + IN[1].pos + IN[2].pos) / 3;

				o.worldNormal = mul(normal, (float3x3)unity_WorldToObject);

				o.pos = UnityObjectToClipPos(pos);

				pointStream.Append(o);
				pointStream.RestartStrip();
			}

			float4 frag(g2f i) : SV_Target
			{
				return float4(_Color[0], _Color[1], _Color[2], _Color[3]);
			}

			ENDCG
		}
	}
}
