// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomShader/Tessellation_Wave"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_WaveDirection ("WaveDirection", Vector) = (1,0,0,1)
		_AmplitudeH ("AmplitudeH", Float) = 0.5
		_AmplitudeW ("AmplitudeW", Float) = 0.5
		_Phase ("Phase", Float) = 20.0
		_W ("W", Float) = 20.0
		_F ("F", Float) = 1.0
		_TessellationFactors("TessellationFactors", Vector) = (1, 1, 1, 1)
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

			float4 _Color;
			float4 _WaveDirection;
			float _AmplitudeH;
			float _AmplitudeW;
			float _Phase;
			float _W;
			float _F;
			float4 _TessellationFactors;

			tessellation_appdata vert(vertex_appdata v)
			{
				tessellation_appdata o;
				//float2 direction = normalize(_WaveDirection.xy);
				//v.vertex.y += _AmplitudeH * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				//v.vertex.xz -= direction *_AmplitudeW * sin(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);

				//float3 T;
				//T.y = -_AmplitudeH * direction.x * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				//T.x = 1 - direction * _AmplitudeW * direction.x * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				//T.z = -direction * _AmplitudeW * direction.x * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);

				//float3 B;
				//B.y = -_AmplitudeH * direction.y * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				//B.x = -direction * _AmplitudeW * direction.y * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				//B.z = 1 - direction * _AmplitudeW * direction.y * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);

				//float3 normal = normalize(cross(B, T));
				o.normal = v.normal;//mul(normal, (float3x3)unity_WorldToObject);
				o.vertex = v.vertex;//UnityObjectToClipPos(v.vertex);
				return o;
			}

			UnityTessellationFactors hsconst(InputPatch<tessellation_appdata, 3> v)
			{
				//UnityTessellationFactors o;
				//float4 tf = UnityDistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, 5, 100, 10);
				//o.edge[0] = tf.x;
				//o.edge[1] = tf.y;
				//o.edge[2] = tf.z;
				//o.inside = tf.w;

				UnityTessellationFactors o;
				o.edge[0] = _TessellationFactors.x;
				o.edge[1] = _TessellationFactors.y;
				o.edge[2] = _TessellationFactors.z;
				o.inside = _TessellationFactors.w;

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
				vertex_appdata v;
				v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
				v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
				v.tangent = vi[0].tangent * bary.x + vi[1].tangent * bary.y + vi[2].tangent * bary.z;
				v.texcoord = vi[0].texcoord * bary.x + vi[1].texcoord * bary.y + vi[2].texcoord * bary.z;

				float2 direction = normalize(_WaveDirection.xy);
				v.vertex.y += _AmplitudeH * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				v.vertex.xz -= direction *_AmplitudeW * sin(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);

				float3 B;//对X轴求偏导
				B.y = -_AmplitudeH * direction.x * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				B.x = 1 - direction * _AmplitudeW * direction.x * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				B.z = -direction * _AmplitudeW * direction.x * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);

				float3 T;//对Z轴求偏导
				T.y = -_AmplitudeH * direction.y * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				T.x = -direction * _AmplitudeW * direction.y * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);
				T.z = 1 - direction * _AmplitudeW * direction.y * cos(dot(v.vertex.xz, direction) * _F + _Phase + _W * _Time.y);

				float3 normal = normalize(cross(B, T));

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(normal, unity_WorldToObject);

				//o.worldNormal = mul(v.normal, unity_WorldToObject);
				o.uv = v.texcoord;
				
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float diffuse = 0.5 * dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0.xyz)) + 0.5;
				return float4(ambient + _Color.rgb * diffuse * _LightColor0.rgb, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
//wave : h = baseH + offsetHMag * cos(a + wt)   w = baseWidth + offsetWMag * sin(a + wt)
