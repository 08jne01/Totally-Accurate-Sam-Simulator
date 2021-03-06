#version 460 core
#define MAX_STEPS 2000
#define MAX_DIST 5000.
#define SURF_DIST .001
#define PI 3.14159

out vec4 FragColor;

in vec2 fragCoord;

uniform vec2 arrows;
uniform vec2 res;
uniform mat4 cam_rot;
uniform mat4 cam_trans;

mat4 rotationMatrix(vec3 axis, float angle)

{
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;

	return mat4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
		oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
		oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
		0.0, 0.0, 0.0, 1.0);
}

float tetra(vec3 p, float  r)

{
	float md = max(max(-p.x - p.y - p.z, p.x + p.y - p.z), max(-p.x + p.y + p.z, p.x - p.y + p.z));
	return (md - r) / sqrt(3.0);
}

float sphere(vec3 p, vec4 n)

{
	return length(p - n.xyz) - n.w;
}

float plane(vec3 p, vec4 n)

{
	return dot(p, n.xyz) + n.w;
}

float box(vec3 p, vec3 b, vec3 pos)

{
	p -= pos;
	vec3 d = abs(p) - b;
	return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float cube(vec3 p, vec4 b)

{
	p -= b.xyz;
	vec3 d = abs(p) - b.w;
	return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float cubeCross(vec3 p, vec4 n, float t)

{
	float arm1 = box(p, vec3(n.w, t, t), n.xyz);
	float arm2 = box(p, vec3(t, n.w, t), n.xyz);
	float arm3 = box(p, vec3(t, t, n.w), n.xyz);

	return min(arm1, min(arm2, arm3));
}

vec4 GetDist(vec3 p)

{
	float d = plane(p + vec3(0., 0.0, 0.), vec4(0, 1, 0, 0.0));
	float s = box(p, vec3(1.0, 5.0, 1.0), vec3(0.0, 5.0, 0.0));
	vec3 color = vec3(0.5, 1.0, 0.5);

	if (d < s)

	{
		color = vec3(1.0);
	}

	return vec4(color, min(s,d));
}

vec3 RayMarch(vec3 ro, vec3 rd)

{
	float dO = 0.;
	float breakout = -1.0;
	float minDist = 10.;

	for (int i = 0; i < MAX_STEPS; i++)

	{
		vec3 p = ro + rd * dO;
		float ds = GetDist(p).w;
		dO += ds;
		
		minDist = min(minDist, ds);

		if (ds < SURF_DIST)

		{
			breakout = i;
			break;
		}

		if (dO > MAX_DIST)

		{
			breakout = MAX_STEPS;
			break;
		}
	}

	if (breakout < 0.0) breakout = MAX_STEPS;

	return vec3(dO, breakout, minDist);
}

float vignette(float mag, vec2 uv)

{
	return 1.0 - (pow(uv.x, 2) + pow(uv.y,2))*mag;
}


float RayMarchShadow(vec3 ro, vec3 rd, float length)

{
	float res = 1.0;

	for (float dO = SURF_DIST; dO < length;)

	{
		vec3 p = ro + rd * dO;
		float ds = GetDist(p).w;
		dO += ds;

		if (ds < SURF_DIST)

		{
			res = 0.1;
			return res;
		}

		res = min(res, 100 * ds / dO);
	}

	res = clamp(res, 0.1, 1.0);

	return res;
}

vec3 GetNormal(vec3 p)

{
	float d = GetDist(p).w;
	vec2 e = vec2(SURF_DIST*2, 0);

	vec3 n = d - vec3(
		GetDist(p - e.xyy).w,
		GetDist(p - e.yxy).w,
		GetDist(p - e.yyx).w);
	return normalize(n);
}

float GetLight(vec3 p, float surfCom, vec3 lightPos)

{
	vec3 l = normalize(lightPos - p);
	vec3 n = GetNormal(p);
	float lightDist = length(lightPos - p);
	float dif = clamp(dot(n, l), 0.3, 1.);

	float occDark = 1.0;
	if (surfCom > 5) occDark = pow(0.99, surfCom - 6);
	dif *= clamp(occDark, 0.02, 1.0);

	dif *= RayMarchShadow(p + n * SURF_DIST*3.0, l, lightDist);
	return dif;
}

void main()

{
	float ratio = res.x / res.y;
	vec2 uv = vec2(fragCoord.x, fragCoord.y / ratio);

	vec3 col = vec3(0);
	
	vec3 ro = (cam_trans*vec4(0, 1.0, 0, 1.0)).xyz;
	//vec3 rd = normalize(vec3(uv.x, uv.y - 0.3, 1));
	vec4 cam = cam_rot * vec4(uv.x, uv.y, 1.0, 1.0);
	vec3 rd = normalize(cam.xyz);

	vec3 d = RayMarch(ro, rd);

	vec3 p = ro + rd * d.x;

	vec3 lightPos = vec3(0.0, 3000.0, 800.0);

	

	float dif = GetLight(p, d.y, lightPos);

	

	//dif += GetLight(p, d.y, vec3(100.0, 0.0, 0.0));

	//dif /= 2.0;

	//dif = clamp(dif, 0.0, 1.0);

	//vec3 n = GetNormal(p);

	vec3 hue = normalize(vec3(0.01, 0.05, 0.12) / 2.);

	float dotp = dot(normalize(rd), normalize(lightPos - ro));

	
	//col = vec3(dif);
	col = dif * GetDist(p).xyz;

	if (d.y > MAX_STEPS - 1)

	{
		col = hue;
	}

	else if (d.x > MAX_DIST / 2.0)

	{
		col -= 2.*(col - hue)*pow((d.x - MAX_DIST / 2.) / MAX_DIST, 1);
	}

	if (dotp > 0.999)

	{
		dif += (1 / pow(1 - 0.999, 4))*pow(dotp - 0.999, 4);
		col += dif*vec3(0.9, 0.7, -0.5);
	}


	col *= vignette(0.5, uv.xy);

	clamp(col, 0.0, 1.0);

	//col = GetNormal(p)*dif;
	FragColor = vec4(col, 1.0f);
	//FragColor = vec4(1.0, 1.0, 0.0, 1.0);
}