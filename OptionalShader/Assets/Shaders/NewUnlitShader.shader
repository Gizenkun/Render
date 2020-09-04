// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Shader "Unlit/NewUnlitShader"
//{
//	Properties
//	{
//		_MainTex ("Texture", 2D) = "white" {}
//		_BumpTex("BumpTex", 2D) = "white"{}
//		_BumpScale("BumpScale", Float) = 0.5
//	}
//	SubShader
//		{
//				Tags{ "RenderType" = "Opaque" }
//			Pass
//			{
//				Tags{ "LightMode" = "ForwardBase" }
//				CGPROGRAM
//		#pragma vertex vert
//		#pragma fragment frag
//		#pragma multi_compile_fwdbase
//
//		#include "UnityCG.cginc"
//		#include "Lighting.cginc"
//		#include "AutoLight.cginc"
//
//			struct appdata
//			{
//				float4 vertex : POSITION;
//				float3 normal : NORMAL;
//				float4 tangent : TANGENT;
//				float2 texcoord : TEXCOORD0;
//			};
//
//			struct v2f
//			{
//				float4 pos : SV_POSITION;
//				float3 worldPos : TEXCOORD0;
//				float3 worldNormal : TEXCOORD1;
//				float3 worldTangent : TEXCOORD2;
//				float3 worldBinormal : TEXCOORD3;
//				float2 uv : TEXCOORD4;
//				SHADOW_COORDS(5)
//			};
//
//			sampler2D _BumpTex;
//			float _BumpScale;
//
//
//			v2f vert(appdata v)
//			{
//				v2f o;
//				o.pos = UnityObjectToClipPos(v.vertex);
//				o.uv = v.texcoord;
//				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
//				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);//mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
//				o.worldNormal = UnityObjectToWorldNormal(v.normal);//mul(v.normal, (float3x3)unity_WorldToObject);
//				float3 binormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
//				o.worldBinormal = binormal;
//				o.uv = v.texcoord;
//				return o;
//			}
//
//			float4 frag(v2f i) : SV_Target
//			{
//				float3 bump = UnpackNormal(tex2D(_BumpTex, i.uv));
//				bump.xy *= _BumpScale;
//				bump.z = sqrt(1 - dot(bump.xy, bump.xy));
//				float3 worldNormal;
//				worldNormal.x = (bump.x * i.worldTangent.x + bump.y * i.worldBinormal.x, bump.z * i.worldNormal.x);
//				worldNormal.y = (bump.x * i.worldTangent.y + bump.y * i.worldBinormal.y, bump.z * i.worldNormal.y);
//				worldNormal.z = (bump.x * i.worldTangent.z + bump.y * i.worldBinormal.z, bump.z * i.worldNormal.z);
//				worldNormal = normalize(worldNormal);
//				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//
//				float diffuse = 0.5 + 0.5 * dot(normalize(worldNormal), normalize(_WorldSpaceLightPos0));
//
//				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
//
//				return float4((ambient + atten * diffuse * float3(1, 1, 1)), 1.0);
//			}
//
//				ENDCG
//			}
//		}
//		Fallback "Specular"
//}

//Shader "Custom/NewSurfaceShader"
//{
//
//	Properties{
//
//		_MainText("MainText",2D) = "white"{}
//
//	_BumpMap("BumpMap",2D) = "white"{}
//
//	}
//
//		SubShader{
//
//		pass {
//
//		Tags{ "LightMode" = "ForwardBase" }
//
//			CGPROGRAM
//
//#pragma vertex vert
//
//#pragma fragment frag
//
//#include "UnityCG.cginc"
//
//
//
//			float4 _LightColor0;
//
//		sampler2D _BumpMap;
//
//		sampler2D _MainText;
//
//		struct
//			v2f {
//
//			float4 pos:SV_POSITION;
//
//			float2 uv:TEXCOORD0;
//
//			float3 lightDir:TEXCOORD1;
//
//		};
//
//
//
//		v2f vert(appdata_full v) {
//
//			v2f o;
//
//			o.pos = UnityObjectToClipPos(v.vertex);
//
//			o.uv = v.texcoord.xy;
//
//			TANGENT_SPACE_ROTATION;
//
//			o.lightDir = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;//Direction Light
//
//			o.lightDir = mul(rotation,o.lightDir);
//
//			return o;
//
//		}
//
//		float4 frag(v2f i) :COLOR
//
//		{
//
//			float4 c = 1;
//
//			float3 N = UnpackNormal(tex2D(_BumpMap,i.uv));
//
//			float diff = max(0,dot(N,i.lightDir));
//
//			c = _LightColor0*diff;
//
//			c *= tex2D(_MainText,i.uv);
//
//			return c;
//
//		}
//
//			ENDCG
//
//	}
//
//	}
//
//}

Shader "CustomShader/Texture/BumpWorldSpaceShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	_BumpTex("Normal Map", 2D) = "bump" {}
	_BumpScale("Bump Scale", Float) = 1.0
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
		SubShader
	{
		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _BumpTex;
	float4 _BumpTex_ST;
	float _BumpScale;
	fixed4 _Color;
	fixed4 _Specular;
	float _Gloss;

	struct appdata
	{
		float4 vertex : POSITION;
		float4 uv : TEXCOORD0;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
	};

	struct v2f
	{
		float4 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float4 TtoW0 : TEXCOORD1;
		float4 TtoW1 : TEXCOORD2;
		float4 TtoW2 : TEXCOORD3;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);

		o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
		o.uv.zw = TRANSFORM_TEX(v.uv.xy, _BumpTex);

		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
		fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
		fixed3 binormal = cross(worldNormal, worldTangent) * v.tangent.w;

		o.TtoW0 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
		o.TtoW1 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
		o.TtoW2 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

		fixed3 lightDir = normalize(_WorldSpaceLightPos0);
		//fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

		fixed4 bumpColor = tex2D(_BumpTex, i.uv.zw);
		fixed3 tangentNormal;
		//				tangentNormal.xy = (bumpColor.xy * 2 - 1) * _BumpScale;
		//				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
		tangentNormal = UnpackNormal(bumpColor);
		//tangentNormal.xy *= _BumpScale;
		//tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

		float3x3 t2wMatrix = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
		//tangentNormal = normalize(half3(mul(t2wMatrix, tangentNormal)));

		float3 worldNormal;
		worldNormal.x = (tangentNormal.x * i.TtoW0.x + tangentNormal.y * i.TtoW0.y + tangentNormal.z * i.TtoW0.z);
		worldNormal.y = (tangentNormal.x * i.TtoW1.x + tangentNormal.y * i.TtoW1.y + tangentNormal.z * i.TtoW1.z);
		worldNormal.z = (tangentNormal.x * i.TtoW2.x + tangentNormal.y * i.TtoW2.y + tangentNormal.z * i.TtoW2.z);
		worldNormal = normalize(worldNormal);
		tangentNormal = worldNormal;
		fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;// *albedo;

		fixed3 diffuse = _LightColor0.rgb * max(0, dot(tangentNormal, lightDir));

		//fixed3 halfDir = normalize(viewDir + lightDir);
		//fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

		return fixed4(ambient + diffuse, 1.0);
	}
		ENDCG
	}
	}

		FallBack "Specular"
}
