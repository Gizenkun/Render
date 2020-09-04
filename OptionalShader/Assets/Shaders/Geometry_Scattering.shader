// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomShader/Geometry_Scattering"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_Length("Length", Float) = 0.5
		_Distance("Distance", Float) = 0.2
		_Speed("Speed", Float) = 1
	}

	SubShader
	{
		Tags {"RenderType" = "Opaque"}

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2g
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			sampler2D _MainTex;
			float _Length;
			float _Distance;
			float _Speed;
			float _StartTime;
			float _MoveTime;

			v2g vert(appdata v)
			{
				v2g o;
				o.pos = v.vertex;
				o.uv = v.texcoord;
				return o;
			}

#define CALCULATE_NORMAL(p0, p1, p2)  normalize(cross(p1 - p0, p2 - p0))

#define ADD_VERTEX(v, g2fNormal) o.pos = UnityObjectToClipPos(v); o.normal = mul(g2fNormal, (float3x3)unity_WorldToObject); triStream.Append(o);

#define ADD_TRIANGLE(p0, p1, p2) ADD_VERTEX(p0, CALCULATE_NORMAL(p0, p1, p2)); ADD_VERTEX(p1, CALCULATE_NORMAL(p0, p1, p2)); ADD_VERTEX(p2, CALCULATE_NORMAL(p0, p1, p2)); triStream.RestartStrip();

			[maxvertexcount(18)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				g2f o;

				o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

				float3 edge1 = IN[1].pos - IN[0].pos;
				float3 edge2 = IN[2].pos - IN[0].pos;

				float3 normalFace = normalize(cross(edge1, edge2));

				float3 centerPos = (IN[0].pos + IN[1].pos + IN[2].pos) / 3;

				float distance = max(0, lerp(_Distance + _MoveTime * abs(_Speed) + (_Time.y - _StartTime) * _Speed, _Distance +(_Time.y - _StartTime) * _Speed, step(0, _Speed)));
				float length = max(0, lerp(_Length + min(_MoveTime * abs(_Speed) + (_Time.y - _StartTime) * _Speed, 1), _Length + min((_Time.y - _StartTime) * _Speed, 1), step(0, _Speed)));

				float3 buttonPos = centerPos + normalFace * distance;
				float3 topPos = centerPos + normalFace * length + normalFace * distance;

				float3 offset = normalFace * length / 2 + normalFace * distance;


				ADD_TRIANGLE(IN[0].pos + offset, IN[2].pos + offset, buttonPos)
				ADD_TRIANGLE(IN[2].pos + offset, IN[1].pos + offset, buttonPos)
				ADD_TRIANGLE(IN[1].pos + offset, IN[0].pos + offset, buttonPos)
				ADD_TRIANGLE(IN[0].pos + offset, IN[1].pos + offset, topPos)
				ADD_TRIANGLE(IN[1].pos + offset, IN[2].pos + offset, topPos)
				ADD_TRIANGLE(IN[2].pos + offset, IN[0].pos + offset, topPos)
			}

			float4 frag(g2f i) : SV_Target
			{
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _LightColor0.rgb;

				float diffuse = 0.5 + 0.5 * saturate(dot(normalize(i.normal), _WorldSpaceLightPos0));

				return float4(ambient + diffuse * _LightColor0.rgb * tex2D(_MainTex, i.uv), 1);
			}

			ENDCG
		}
	}
}
