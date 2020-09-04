Shader "Unlit/DecalShader"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
	}

	SubShader
	{
		Tags {"RenderType" = "Opaque"}

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
		};

		float4 _InitColor;

		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		float4 frag(v2f i) : SV_Target
		{
			return _InitColor;
		}

		ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _DecalTex;
			float4 _DecalControl;
			float _Angle;

			float2 calculateRotation(float2 uv, float2 offset)
			{
				uv -= offset;
				float s, c;
				sincos(radians(_Angle), s, c);
				float2x2 rotationMatrix = float2x2(c, -s, s, c);
				uv = mul(rotationMatrix, uv);
				uv += offset;
				return uv;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord;
				o.uv.zw = (calculateRotation(v.texcoord, _DecalControl.xy + _DecalControl.zw / 2) - _DecalControl.xy) / (_DecalControl.zw);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 mainColor = tex2D(_MainTex, i.uv.xy);
				float4 decalColor = float4(1, 1, 1, 0);

				if (!any(i.uv.zw - frac(i.uv.zw)))
				{
					float4 decal = tex2D(_DecalTex, i.uv.zw);
					decal.w = 1;

					float3 decalHeightOffset = abs(decal.xyz * 2 - 1);

					float3 mainHeightOffset = abs(mainColor.xyz * 2 - 1);

					decalColor = lerp(decal, lerp(mainColor, decal, smoothstep(0, mainHeightOffset.x, decalHeightOffset.x)), mainColor.a);//lerp(decal, lerp(mainColor, decal, step(mainHeightOffset.x, decalHeightOffset.x)), mainColor.a);
				}

				return lerp(mainColor, decalColor, decalColor.a);
			}

			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _DecalTex;
			float4 _DecalControl;
			float _Angle;

			float2 calculateRotation(float2 uv, float2 offset)
			{
				uv -= offset;
				float s, c;
				sincos(radians(_Angle), s, c);
				float2x2 rotationMatrix = float2x2(c, -s, s, c);
				uv = mul(rotationMatrix, uv);
				uv += offset;
				return uv;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord;
				o.uv.zw = (calculateRotation(v.texcoord, _DecalControl.xy + _DecalControl.zw / 2) - _DecalControl.xy) / (_DecalControl.zw);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 mainColor = tex2D(_MainTex, i.uv.xy);
				float4 decalColor = float4(1, 1, 1, -0.1);

				if (!any(i.uv.zw - frac(i.uv.zw)))
				{
					float4 decal = tex2D(_DecalTex, i.uv.zw);
					//decal.a = 1;

					float3 decalTexNormal = UnpackNormal(decal);
					//float3 mainTexNormal = UnpackNormal(mainColor);

					decalColor = lerp(decal, mainColor, step(0, decal.g - 0.494));//lerp(mainColor, decal, step(0, dot(decalTexNormal, decalTexNormal) - 1));//lerp(lerp(decal, lerp(mainColor, decal, step(mainTexNormal.z, decalTexNormal.z)), mainColor.a));
				}

				return lerp(decalColor, mainColor, step(decalColor.a, -0.1));
			}

			ENDCG
		}
	}
}
