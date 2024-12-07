/*
   Hyllian's 5xBR v3.5a Shader
   
   Copyright (C) 2011 Hyllian/Jararaca - sergiogdb@gmail.com

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

// The name of this effect
string name : NAME = "FiveXBR3";
float2 ps : TEXELSIZE;

float4x4 World			: WORLD;
float4x4 View			: VIEW;
float4x4 Projection		: PROJECTION;
float4x4 Worldview		: WORLDVIEW;			// world * view
float4x4 ViewProjection		: VIEWPROJECTION;		// view * projection
float4x4 WorldViewProjection	: WORLDVIEWPROJECTION;		// world * view * projection

string combineTechique		: COMBINETECHNIQUE = "FiveTimesBR3";

texture SourceTexture		: SOURCETEXTURE;
texture WorkingTexture		: WORKINGTEXTURE;

sampler	decal = sampler_state
{
	Texture	  = (SourceTexture);
	MinFilter = POINT;
	MagFilter = POINT;
};


const static float coef           = 2.0;
const static float3 dtt           = float3(65536,255,1);
const static float y_weight        = 48.0;
const static float u_weight        = 7.0;
const static float v_weight        = 6.0;
const static float3x3 yuv          = float3x3(0.299, 0.587, 0.114, -0.169, -0.331, 0.499, 0.499, -0.418, -0.0813);
const static float3x3 yuv_weighted = float3x3(y_weight*yuv[0], u_weight*yuv[1], v_weight*yuv[2]);


float4 RGBtoYUV(float4x3 mat_color)
{
	float a= abs(mul(yuv_weighted, mat_color[0]));
	float b= abs(mul(yuv_weighted, mat_color[1]));
	float c= abs(mul(yuv_weighted, mat_color[2]));
	float d= abs(mul(yuv_weighted, mat_color[3]));

	return float4(a, b, c, d);
}

float4 df(float4 A, float4 B)
{
	return float4(abs(A-B));
}


float4 weighted_distance(float4 a, float4 b, float4 c, float4 d, float4 e, float4 f, float4 g, float4 h)
{
	return (df(a,b) + df(a,c) + df(d,e) + df(d,f) + 4.0*df(g,h));
}

struct input
{
   float2 video_size;
   float2 texture_size;
   float2 output_size;
   float frame_count;
};

struct out_vertex
{
	float4 position : POSITION;
	float2 texCoord : TEXCOORD0;
	float4 t1 : TEXCOORD1;
};

 
input IN : VIDPARAMS;
 
//
// Vertex Shader
//

out_vertex  VS_VERTEX(float4 position : POSITION, float2 texCoord : TEXCOORD0 )
{
	 
	out_vertex OUT;

	OUT.position = position;

	half2 ps = float2(1.0/IN.texture_size.x, 1.0/IN.texture_size.y);
	half dx = ps.x;
  	half dy = ps.y;

  	OUT.texCoord = texCoord;
  	OUT.t1.xy = half2( dx,  0); // F
  	OUT.t1.zw = half2(  0, dy); // H

	return OUT;

 
}


float4 PS_FRAGMENT (in out_vertex VAR) : COLOR
{	
	bool4 edr, edr_left, edr_up, px; // px = pixel, edr = edge detection rule
	bool4 interp_restriction_lv1, interp_restriction_lv2_left, interp_restriction_lv2_up;
	bool4 nc; // new_color
	bool4 fx, fx_left, fx_up; // inequations of straight lines.
   
	float2 fp = frac(VAR.texCoord/ps);

	float2 dx = VAR.t1.xy;
	float2 dy = VAR.t1.zw;

	float3 A = tex2D(decal, VAR.texCoord -dx -dy).xyz;
	float3 B = tex2D(decal, VAR.texCoord     -dy).xyz;
	float3 C = tex2D(decal, VAR.texCoord +dx -dy).xyz;
	float3 D = tex2D(decal, VAR.texCoord -dx    ).xyz;
	float3 E = tex2D(decal, VAR.texCoord        ).xyz;
	float3 F = tex2D(decal, VAR.texCoord +dx    ).xyz;
	float3 G = tex2D(decal, VAR.texCoord -dx +dy).xyz;
	float3 H = tex2D(decal, VAR.texCoord     +dy).xyz;
	float3 I = tex2D(decal, VAR.texCoord +dx +dy).xyz;

	float3  A1 = tex2D(decal, VAR.texCoord     -dx -2.0*dy).xyz;
	float3  C1 = tex2D(decal, VAR.texCoord     +dx -2.0*dy).xyz;
	float3  A0 = tex2D(decal, VAR.texCoord -2.0*dx     -dy).xyz;
	float3  G0 = tex2D(decal, VAR.texCoord -2.0*dx     +dy).xyz;
	float3  C4 = tex2D(decal, VAR.texCoord +2.0*dx     -dy).xyz;
	float3  I4 = tex2D(decal, VAR.texCoord +2.0*dx     +dy).xyz;
	float3  G5 = tex2D(decal, VAR.texCoord     -dx +2.0*dy).xyz;
	float3  I5 = tex2D(decal, VAR.texCoord     +dx +2.0*dy).xyz;
	float3  B1 = tex2D(decal, VAR.texCoord         -2.0*dy).xyz;
	float3  D0 = tex2D(decal, VAR.texCoord -2.0*dx        ).xyz;
	float3  H5 = tex2D(decal, VAR.texCoord         +2.0*dy).xyz;
	float3  F4 = tex2D(decal, VAR.texCoord +2.0*dx        ).xyz;

	float4 a = RGBtoYUV( float4x3(A, G, I, C) );
	float4 b = RGBtoYUV( float4x3(B, D, H, F) );
	float4 c = RGBtoYUV( float4x3(C, A, G, I) );
	float4 d = RGBtoYUV( float4x3(D, H, F, B) );
	float4 e = RGBtoYUV( float4x3(E, E, E, E) );
	float4 f = RGBtoYUV( float4x3(F, B, D, H) );
	float4 g = RGBtoYUV( float4x3(G, I, C, A) );
	float4 h = RGBtoYUV( float4x3(H, F, B, D) );
	float4 i = RGBtoYUV( float4x3(I, C, A, G) );

	float4 a1 = RGBtoYUV( float4x3(A1, G0, I5, C4) );
	float4 c1 = RGBtoYUV( float4x3(C1, A0, G5, I4) );
	float4 a0 = RGBtoYUV( float4x3(A0, G5, I4, C1) );
	float4 g0 = RGBtoYUV( float4x3(G0, I5, C4, A1) );
	float4 c4 = RGBtoYUV( float4x3(C4, A1, G0, I5) );
	float4 i4 = RGBtoYUV( float4x3(I4, C1, A0, G5) );
	float4 g5 = RGBtoYUV( float4x3(G5, I4, C1, A0) );
	float4 i5 = RGBtoYUV( float4x3(I5, C4, A1, G0) );
	float4 b1 = RGBtoYUV( float4x3(B1, D0, H5, F4) );
	float4 d0 = RGBtoYUV( float4x3(D0, H5, F4, B1) );
	float4 h5 = RGBtoYUV( float4x3(H5, F4, B1, D0) );
	float4 f4 = RGBtoYUV( float4x3(F4, B1, D0, H5) );

	float4 Ao = float4( 1.0, -1.0, -1.0, 1.0 );
	float4 Bo = float4( 1.0,  1.0, -1.0,-1.0 );
	float4 Co = float4( 1.5,  0.5, -0.5, 0.5 );
	float4 Ax = float4( 1.0, -1.0, -1.0, 1.0 );
	float4 Bx = float4( 0.5,  2.0, -0.5,-2.0 );
	float4 Cx = float4( 1.0,  1.0, -0.5, 0.0 );
	float4 Ay = float4( 1.0, -1.0, -1.0, 1.0 );
	float4 By = float4( 2.0,  0.5, -2.0,-0.5 );
	float4 Cy = float4( 2.0,  0.0, -1.0, 0.5 );

	// These inequations define the line below which interpolation occurs.
	fx      = (Ao*fp.y+Bo*fp.x > Co); 
	fx_left = (Ax*fp.y+Bx*fp.x > Cx);
	fx_up   = (Ay*fp.y+By*fp.x > Cy);

	interp_restriction_lv1      = ((e!=f) && (e!=h));
	interp_restriction_lv2_left = ((e!=g) && (d!=g));
	interp_restriction_lv2_up   = ((e!=c) && (b!=c));

	edr      = (weighted_distance( e, c, g, i, h5, f4, h, f) < weighted_distance( h, d, i5, f, i4, b, e, i)) && interp_restriction_lv1;
	edr_left = ((coef*df(f,g)) <= df(h,c)) && interp_restriction_lv2_left;
	edr_up   = (df(f,g) >= (coef*df(h,c))) && interp_restriction_lv2_up;

	nc = ( edr && (fx || edr_left && fx_left || edr_up && fx_up) );

	px = (df(e,f) <= df(e,h));

	float3 res = nc.x ? px.x ? F : H : nc.y ? px.y ? B : F : nc.z ? px.z ? D : B : nc.w ? px.w ? H : D : E;

	return float4(res, 1.0);

}


//
// Technique
//

technique FiveTimesBR3
{
    pass P0
    {
        // shaders		
        VertexShader = compile vs_3_0 VS_VERTEX();
        PixelShader  = compile ps_3_0 PS_FRAGMENT(); 
    }  
}