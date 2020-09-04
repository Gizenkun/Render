Shader "CustomShader/PhongTessellation"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_Phong("Phong", Range(0, 1)) = 0.5
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
			#pragma hull hs
			#pragma domain ds

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct tess_appdata
			{
				float4 pos : INTERNALTESSPOS;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			float _Phong;

			tess_appdata vert(appdata v)
			{
				tess_appdata o;
				o.pos = v.vertex;
				o.normal = v.normal;
				o.uv = v.texcoord;

				return o;
			}

			UnityTessellationFactors hsconst(InputPatch<tess_appdata, 3> vi)
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
			[UNITY_patchconstantfunc("hsconst")]
			[UNITY_outputtopology("triangle_cw")]
			[UNITY_outputcontrolpoints(3)]
			tess_appdata hs(InputPatch<tess_appdata, 3> vi, uint id : SV_OutputControlPointID)
			{
				return vi[id];
			}

			[UNITY_domain("tri")]
			v2f ds(UnityTessellationFactors factors, OutputPatch<tess_appdata, 3> vi, float3 bary : SV_DomainLocation)
			{

				float4 originVertex = vi[0].pos * bary.x + vi[1].pos * bary.y + vi[2].pos * bary.z;
				float3 offset[3];

				for (int i = 0; i < 3; i++)
				{
					float3 normal = normalize(vi[i].normal);
					offset[i] = normal * (dot(originVertex.xyz, normal) - dot(vi[i].pos.xyz, normal));
				}

				appdata v;
				v.vertex = lerp(originVertex, originVertex - float4(offset[0] * bary.x + offset[1] * bary.y + offset[2] * bary.z, 0), _Phong);
				v.normal = normalize(vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z);
				v.texcoord = vi[0].uv * bary.x + vi[1].uv * bary.y + vi[2].uv * bary.z;

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.uv = v.texcoord;

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _LightColor0.xyz;

				float diffuse = 0.5 + 0.5 * saturate(dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0.xyz)));
				return float4(ambient + diffuse * _LightColor0.xyz * float3(1, 1, 1), 1);
			}

			ENDCG
		}
	}
}
