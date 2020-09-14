//线性同余法
float Congruence21(float2 p)
{
	float f = dot(p, float2(323, 123));
	int m = 100000;
	int a = 97;
	int b = 71;

	float random = f;
	for(int i=0; i<10; i++)
	{
		random = (a * random + b) % m;
	}
	return random / m;
}

uint MT[624];
//梅森旋转法
float MersenneTwister21(float2 p)
{
	uint f = dot(p, float2(323, 123));

	MT[0] = f;

	//对旋转链进行初始化
	for(int i=1; i<624; i++)
	{
		uint t = 1812433253 * (MT[i - 1] ^ (MT[i - 1] >> 30)) + 1;
		MT[i] = t & 0xffffffff;
	}

	//使用旋转算法处理旋转链
	for(int j=0; j<624; j++)
	{
		uint y = (MT[j] & 0x80000000) + (MT[(j + 1) % 624] & 0x7fffffff);
		MT[j] = MT[(j + 397) % 624] ^ (y >> 1);
		if(y & 1)
		{
			MT[j] ^= 2567483615;
		} 
	}

	//对结果进行处理
	uint random = MT[f];
	random = random ^ (random >> 11);
	random = random ^ ((random << 7) & 2636928640);
	random = random ^ ((random << 15) & 4022730752);
	random = random ^ (random >> 18);
	return random / (float)(pow(2, 32) - 1);
}


float Hash21(float2 p)
{
	float h = dot(p, float2(127.1, 311.7));

	return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

float2 Hash22(float2 p)
{
	p = float2(dot(p, float2(127.1, 311.7)),
		dot(p, float2(269.5, 183.3)));

	return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float3 Hash23(float2 p)
{
	float3 h = float3(dot(p, float2(127.1, 311.7)),
		dot(p, float2(269.5, 183.3)),
		dot(p, float2(173.3, 311.1)));

	return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
}

float3 Hash33(float3 p)
{
	p = float3(dot(p, float3(127.1, 311.7, 212.3)),
		dot(p, float3(269.5, 183.3, 542.1)),
		dot(p, float3(173.3, 311.1, 121.5)));

	return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float4 Hash44(float4 p)
{
	p = float4(dot(p, float4(127.1, 311.7, 212.3, 432.1)),
		dot(p, float4(269.5, 183.3, 542.1, 561.1)),
		dot(p, float4(173.3, 311.1, 121.5, 313.1)),
		dot(p, float4(233.7, 317.3, 712.1, 233.3)));

	return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}