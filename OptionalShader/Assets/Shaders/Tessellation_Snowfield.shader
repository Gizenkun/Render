// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomShader/Tessellation_Snowfield"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_HeightMap("HeightMap", 2D) = "white" {}
		_DecalTex("DecalTex", 2D) = "white"{}
		_BumpTex("BumpTex", 2D) = "white"{}
		_FootprintMap("FootprintMap", 2D) = "white"{}
		//_DecalControl("DecalContol", Vector) = (1, 1, 1, 1)
		_BumpScale ("BumpScale", Float) = 0.5
		_FootprintDepthMag ("FootprintDepthMag", Float) = 10
		_SnowDepth ("SnowDepth", Float) = 0.5
	}

	SubShader
	{
		Tags {"RenderType" = "Opaque"}
		Cull off

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma hull hs
			#pragma domain ds
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			//#include "Tessellation.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
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
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 worldTangent : TEXCOORD3;
				float3 worldBinormal : TEXCOORD4;
				SHADOW_COORDS(5)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DecalTex;
			float4 _DecalControl;
			sampler2D _HeightMap;
			sampler2D _BumpTex;
			float _BumpScale;
			float _FootprintDepthMag;
			sampler2D _FootprintMap;
			float _SnowDepth;

			tessellation_appdata vert(appdata v)
			{

				//float2 decalUV = (v.texcoord - _DecalControl.xy) / _DecalControl.zw;
				//if (!any(decalUV - frac(decalUV)))
				//{
				//	//v.vertex.y -= 20;
				//	float4 decal = tex2Dlod(_DecalTex, float4(decalUV, 0, 0));
				//	v.vertex.y -= (1 - (decal.x + 0.5)) * 20;
				//}

				//v2f o;
				//o.pos = UnityObjectToClipPos(v.vertex);
				//o.uv = v.texcoord;
				//o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//o.worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
				//o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				//float3 binormal = cross(o.worldNormal, o.worldTangent.xyz) * v.tangent.w;

				//o.worldBinormal = binormal;

				//TRANSFER_SHADOW(o);
				//return o;

				tessellation_appdata o;
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.texcoord = v.texcoord;
				return o;
			}

			UnityTessellationFactors hsconst(InputPatch<tessellation_appdata, 3> vi)
			{
				UnityTessellationFactors o;
				o.edge[0] = 12;
				o.edge[1] = 12;
				o.edge[2] = 12;
				o.inside = 12;

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
				appdata v;
				v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
				v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
				v.tangent = vi[0].tangent * bary.x + vi[1].tangent * bary.y + vi[2].tangent * bary.z;
				v.texcoord = vi[0].texcoord * bary.x + vi[1].texcoord * bary.y + vi[2].texcoord * bary.z;

				//float2 decalUV = (v.texcoord - _DecalControl.xy) / _DecalControl.zw;
				//if (!any(decalUV - frac(decalUV)))
				//{
				//	//v.vertex.y -= 20;
				//	float4 decal = tex2Dlod(_DecalTex, float4(decalUV, 0, 0));
				//	v.vertex.y += ((decal.x * 2 - 1)) * _FootprintDepthMag;
				//}

				float4 heightMap = tex2Dlod(_HeightMap, float4(v.texcoord, 0, 0));
				v.vertex.y += _SnowDepth + (heightMap.x * 2 - 1) * _FootprintDepthMag * heightMap.w;

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				float3 binormal = cross(o.worldNormal, o.worldTangent.xyz) * v.tangent.w;

				o.worldBinormal = binormal;

				TRANSFER_SHADOW(o);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _LightColor0.rgb;

				float4 mainColor = tex2D(_MainTex, i.uv);

				//float2 decalUV = (i.uv - _DecalControl.xy) / (_DecalControl.zw);
				float4 decalColor = float4(1, 1, 1, 0);
				//float3 bump = UnpackNormal(tex2D(_BumpTex, decalUV));
				//bump.xy *= _BumpScale;
				//bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
				//float3 worldNormal = i.worldNormal;
				//if (!any(decalUV - frac(decalUV)))
				//{
				//	worldNormal.x = (bump.x * i.worldTangent.x + bump.y * i.worldBinormal.x + bump.z * i.worldNormal.x);
				//	worldNormal.y = (bump.x * i.worldTangent.y + bump.y * i.worldBinormal.y + bump.z * i.worldNormal.y);
				//	worldNormal.z = (bump.x * i.worldTangent.z + bump.y * i.worldBinormal.z + bump.z * i.worldNormal.z);
				//	worldNormal = normalize(worldNormal);
				//}

				float3 bump = UnpackNormal(tex2D(_FootprintMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
				float3 worldNormal = i.worldNormal;
				if (any(tex2D(_FootprintMap, i.uv).a))
				{
					worldNormal.x = (bump.x * i.worldTangent.x + bump.y * i.worldBinormal.x + bump.z * i.worldNormal.x);
					worldNormal.y = (bump.x * i.worldTangent.y + bump.y * i.worldBinormal.y + bump.z * i.worldNormal.y);
					worldNormal.z = (bump.x * i.worldTangent.z + bump.y * i.worldBinormal.z + bump.z * i.worldNormal.z);
					worldNormal = normalize(worldNormal);
				}

				float diffuse = 0.5 + 0.5 * dot(normalize(worldNormal), normalize(_WorldSpaceLightPos0));

				float shadow = SHADOW_ATTENUATION(i);
				//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return float4((ambient + _LightColor0.rgb * shadow * diffuse * lerp(mainColor, decalColor, decalColor.a).xyz), 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma hull hs
			#pragma domain ds
			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct tessellation_appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord :TEXCOORD0;
			};

			struct v2f
			{
				V2F_SHADOW_CASTER;
			};

			sampler2D _DecalTex;
			float4 _DecalControl;
			sampler2D _HeightMap;
			float _FootprintDepthMag;
			float _SnowDepth;

			tessellation_appdata vert(appdata v)
			{
				tessellation_appdata o;
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.texcoord = v.texcoord;
				return o;
			}

			UnityTessellationFactors hsconst(InputPatch<tessellation_appdata, 3> vi)
			{
				UnityTessellationFactors o;
				o.edge[0] = 12;
				o.edge[1] = 12;
				o.edge[2] = 12;

				o.inside = 12;
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
				appdata v;
				v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
				v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
				v.texcoord = vi[0].texcoord * bary.x + vi[1].texcoord * bary.y + vi[2].texcoord * bary.z;

				v2f o;
				//float2 decalUV = (v.texcoord - _DecalControl.xy) / _DecalControl.zw;
				//if (!any(decalUV - frac(decalUV)))
				//{
				//	//v.vertex.y -= 20;
				//	float4 decal = tex2Dlod(_DecalTex, float4(decalUV, 0, 0));
				//	v.vertex.y += ((decal.x * 2 - 1)) * _FootprintDepthMag;
				//}

				float4 heightMap = tex2Dlod(_HeightMap, float4(v.texcoord, 0, 0));
				v.vertex.y += _SnowDepth + (heightMap.x * 2 - 1) * _FootprintDepthMag * heightMap.w;

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i);
			}

			ENDCG
		}
	}
}
