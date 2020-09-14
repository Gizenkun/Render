Shader "Custom/Noise"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cell ("Cell", Float) = 3
		_VoronoiU ("VoronoiU", Range(0, 1.0)) = 1.0
		_VoronoiV ("VoronoiV", Range(0, 1.0)) = 0.0
		[KeywordEnum(Perlin,Value,Simplex,Seamless,Worley,Voronoi)]_NoiseType ("NoiseType", Float) = 0
		[KeywordEnum(Itself,Sum,SumAbs,SumAbsSin)]_FractalType ("FractalType", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _NOISETYPE_PERLIN _NOISETYPE_VALUE _NOISETYPE_SIMPLEX _NOISETYPE_SEAMLESS _NOISETYPE_WORLEY _NOISETYPE_VORONOI
			#pragma multi_compile _FRACTALTYPE_ITSELF _FRACTALTYPE_SUM _FRACTALTYPE_SUMABS _FRACTALTYPE_SUMABSSIN
			
			#include "UnityCG.cginc"
			#include "Random.cginc"

//#define WORLEY

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex; float4 _MainTex_ST;
			int _Cell;
			float _VoronoiU;
			float _VoronoiV;

			//返回值范围-1 - 1
			float PerlinNoise_2D(float2 p)
			{
				float2 pi = floor(p);
				float2 pf = p - pi;

				//缓和曲线
				float2 w = pf * pf * (3.0 - 2.0 * pf);
				//float2 w = pf * pf * pf * (6 * pf * pf - 15 * pf + 10);
				
				return lerp(
					lerp(
						dot(Hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
						dot(Hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)),
						w.x),
					lerp(
						dot(Hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
						dot(Hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)),
						w.x),
					w.y);
			}

			float PerlinNoise_3D(float3 p)
			{
				float3 pi = floor(p);
				float3 pf = p - pi;

				float3 w = pf * pf * (3.0 - 2.0 * pf);

				return lerp(
					lerp(
						lerp(dot(Hash33(pi + float3(0.0, 0.0, 0.0)), pf - float3(0.0, 0.0, 0.0)),
							dot(Hash33(pi + float3(1.0, 0.0, 0.0)), pf - float3(1.0, 0.0, 0.0)),
							w.x),
						lerp(dot(Hash33(pi + float3(0.0, 1.0, 0.0)), pf - float3(0.0, 1.0, 0.0)),
							dot(Hash33(pi + float3(1.0, 1.0, 0.0)), pf - float3(1.0, 1.0, 0.0)),
							w.x),
						w.y),
					lerp(
						lerp(dot(Hash33(pi + float3(0.0, 0.0, 1.0)), pf - float3(0.0, 0.0, 1.0)),
							dot(Hash33(pi + float3(1.0, 0.0, 1.0)), pf - float3(1.0, 0.0, 1.0)),
							w.x),
						lerp(dot(Hash33(pi + float3(0.0, 1.0, 1.0)), pf - float3(0.0, 1.0, 1.0)),
							dot(Hash33(pi + float3(1.0, 1.0, 1.0)), pf - float3(1.0, 1.0, 1.0)),
							w.x),
						w.y),
					w.z);
			}

			float PerlinNoise_4D(float4 p)
			{
				float4 pi = floor(p);
				float4 pf = p - pi;

				float4 w = pf * pf * (3.0 - 2.0 * pf);
				return lerp(
					lerp
					(
						lerp(
							lerp(dot(Hash44(pi + float4(0.0, 0.0, 0.0, 0.0)), pf - float4(0.0, 0.0, 0.0, 0.0)),
								dot(Hash44(pi + float4(1.0, 0.0, 0.0, 0.0)), pf - float4(1.0, 0.0, 0.0, 0.0)),
								w.x),
							lerp(dot(Hash44(pi + float4(0.0, 1.0, 0.0, 0.0)), pf - float4(0.0, 1.0, 0.0, 0.0)),
								dot(Hash44(pi + float4(1.0, 1.0, 0.0, 0.0)), pf - float4(1.0, 1.0, 0.0, 0.0)),
								w.x),
							w.y),
						lerp(
							lerp(dot(Hash44(pi + float4(0.0, 0.0, 1.0, 0.0)), pf - float4(0.0, 0.0, 1.0, 0.0)),
								dot(Hash44(pi + float4(1.0, 0.0, 1.0, 0.0)), pf - float4(1.0, 0.0, 1.0, 0.0)),
								w.x),
							lerp(dot(Hash44(pi + float4(0.0, 1.0, 1.0, 0.0)), pf - float4(0.0, 1.0, 1.0, 0.0)),
								dot(Hash44(pi + float4(1.0, 1.0, 1.0, 0.0)), pf - float4(1.0, 1.0, 1.0, 0.0)),
								w.x),
							w.y),
						w.z),
					lerp
					(
						lerp(
							lerp(dot(Hash44(pi + float4(0.0, 0.0, 0.0, 1.0)), pf - float4(0.0, 0.0, 0.0, 1.0)),
								dot(Hash44(pi + float4(1.0, 0.0, 0.0, 1.0)), pf - float4(1.0, 0.0, 0.0, 1.0)),
								w.x),
							lerp(dot(Hash44(pi + float4(0.0, 1.0, 0.0, 1.0)), pf - float4(0.0, 1.0, 0.0, 1.0)),
								dot(Hash44(pi + float4(1.0, 1.0, 0.0, 1.0)), pf - float4(1.0, 1.0, 0.0, 1.0)),
								w.x),
							w.y),
						lerp(
							lerp(dot(Hash44(pi + float4(0.0, 0.0, 1.0, 1.0)), pf - float4(0.0, 0.0, 1.0, 1.0)),
								dot(Hash44(pi + float4(1.0, 0.0, 1.0, 1.0)), pf - float4(1.0, 0.0, 1.0, 1.0)),
								w.x),
							lerp(dot(Hash44(pi + float4(0.0, 1.0, 1.0, 1.0)), pf - float4(0.0, 1.0, 1.0, 1.0)),
								dot(Hash44(pi + float4(1.0, 1.0, 1.0, 1.0)), pf - float4(1.0, 1.0, 1.0, 1.0)),
								w.x),
							w.y),
						w.z),
					w.w);

			}

			float SeamlessNoise(float2 p, float2 radians)
			{
				float pi2 = 3.1415926535897931 * 2;
				float x = cos(p.x * pi2) * radians.x;// / pi2;
				float y = sin(p.x * pi2) * radians.x;// / pi2;
				float z = cos(p.y * pi2) * radians.y;// / pi2;
				float w = sin(p.y * pi2) * radians.y;// / pi2;

				return PerlinNoise_4D(float4(x, y, z, w) * 5.0);
			}

			float ValueNoise(float2 p)
			{
				float2 pi = floor(p);
				float2 pf = p - pi;

				float2 w = pf * pf * (3.0 - 2.0 * pf);

				return lerp(
					lerp(Hash21(pi + float2(0.0, 0.0)), Hash21(pi + float2(1.0, 0.0)), w.x),
					lerp(Hash21(pi + float2(0.0, 1.0)), Hash21(pi + float2(1.0, 1.0)), w.x),
					w.y);
			}

			float SimplexNoise(float2 p)
			{
				float k1 = 0.366025404;//(sqrt(3)-1)/2
				float k2 = 0.211324865;//(3-sqrt(3))/6;

				float2 i = floor(p + (p.x + p.y) * k1);
				float2 a = p - (i - (i.x + i.y) * k2);
				float2 o = (a.x < a.y) ? float2(0.0, 1.0) : float2(1.0, 0.0);
				float2 b = a - (o - 1.0 * k2);
				float2 c = a - (1.0 - 2.0 * k2);

				float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
				float3 n = h * h * h * h * float3(dot(a, Hash22(i)), dot(b, Hash22(i + o)), dot(c, Hash22(i + 1.0)));

				return dot(float3(70, 70, 70), n);//把范围映射到(-1, 1); r^2取0.6时取24.51， 三维下r^2取0.5时取31.32
			}

			float WorleyNoise(float2 p)
			{
				float2 pi = floor(p);
				float2 pf = frac(p);

				float res = 0.0;

				for (int i = -2; i <= 2; i++)
					for (int j = -2; j <= 2; j++)
					{
						float2 b = float2(i, j);
						float2 r = b + Hash22(b + pi) - pf;
						//float d = dot(r, r);
						float d = length(r);

						res += exp(-32.0 * d);
						//res += 1 / pow(d, 8.0);
						//res = min(res, d);
					}

				return -(1.0 / 32.0) * log(res);
				//return pow(1.0 / res, 1.0 / 16.0);
				//return sqrt(res);
			}

			float VoronoiNoise(float2 p, float u, float v)
			{
				float2 pi = floor(p);
				float2 pf = frac(p);

				float k = 1.0 + 31.0 * pow(1.0 - v, 4.0);
				float va = 0.0;
				float wt = 0.0;
				for (int i = -2; i <= 2; i++)
					for (int j = -2; j <= 2; j++)
					{
						float2 g = float2(i, j);
						float3 o = Hash23(pi + g) * float3(u, u, 1.0);
						float2 r = g - pf + o.xy;
						float d = dot(r, r);
						float w = pow(1.0 - smoothstep(0.0, 1.414, sqrt(d)), k);
						va += w * o.z;
						wt += w;
					}

				return va / wt;
			}

			float Noise(float2 p)
			{
#if _NOISETYPE_PERLIN
				return PerlinNoise_2D(p);
#elif _NOISETYPE_VALUE
				return ValueNoise(p);
#elif _NOISETYPE_SIMPLEX
				return SimplexNoise(p);
#elif _NOISETYPE_SEAMLESS
				return SeamlessNoise(p, float2(0.3, 0.3));
#elif _NOISETYPE_WORLEY
				return WorleyNoise(p);
#elif _NOISETYPE_VORONOI
				return VoronoiNoise(p, _VoronoiU, _VoronoiV);
#else
				return 1;
#endif
			}

			float Noise_Itself(float2 p)
			{
				return Noise(p);
			}

			float Noise_Sum(float2 p)
			{
				float f = 0.0;
				f += 1.0 * Noise(p); p *= 2.0;
				f += 0.5 * Noise(p); p *= 2.0;
				f += 0.25 * Noise(p); p *= 2.0;
				f += 0.125 * Noise(p); p *= 2.0;
				f += 0.0625 * Noise(p);
				return f;
			}

			float Noise_Sum_Abs(float2 p)
			{
				float2 f = 0.0;
				f += 1.0 * abs(Noise(p)); p *= 2.0;
				f += 0.5 * abs(Noise(p)); p *= 2.0;
				f += 0.25 * abs(Noise(p)); p *= 2.0;
				f += 0.125 * abs(Noise(p)); p *= 2.0;
				f += 0.0625 * abs(Noise(p));
				return f;
			}

			float Noise_Sum_Abs_Sin(float2 p)
			{
				float2 f = 0.0;
				f += 1.0 * abs(Noise(p)); p *= 2.0;
				f += 0.5 * abs(Noise(p)); p *= 2.0;
				f += 0.25 * abs(Noise(p)); p *= 2.0;
				f += 0.125 * abs(Noise(p)); p *= 2.0;
				f += 0.0625 * abs(Noise(p));
				return sin(f + p.x / 32.0);
			}
			
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
#if _FRACTALTYPE_ITSELF
				return Noise_Itself(i.uv * _Cell) * 0.5 + 0.5;
#elif _FRACTALTYPE_SUM
				return Noise_Sum(i.uv * _Cell) * 0.5 + 0.5;
#elif _FRACTALTYPE_SUMABS
				return Noise_Sum_Abs(i.uv * _Cell) * 0.5 + 0.5;
#elif _FRACTALTYPE_SUMABSSIN
				return Noise_Sum_Abs_Sin(i.uv * _Cell) * 0.5 + 0.5;
#else
				return 1;
#endif
			}

			ENDCG
		}
	}
}
