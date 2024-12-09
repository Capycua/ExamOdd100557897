Shader "Custom/Colourgrading"
{
    Properties
    {
        _MainTex("Texture", 2D) = "Whiyte"{}
        _LUT("LUT", 2D) = "White"{}
        _Contribution("Contribution", Range(0,1)) =1
    }
    SubShader
    {
       Cull Off Zwrite Off ZTest Always
       Pass
       {
           CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv,vertex)
#pragma exclude_renderers d3d11
           #pragma vertex vert
           #pragma fragment frag

           #include "UnityCG.cginc"
           #define COLORS 32.0

           struct appdata{
               
               float4 vertex : POSITION;
               float2 uv : TEXCOORD0;
               };

               struct v2f {

                   float2 uv ; TEXCORRD0;
                   float4 vertex ; SV_POSITION;
                   };

            v2f vert (appdata v){
                v2f o;
                o.vertex = UnityObjectToClipPos(V.vertex);
                o.uv = v.uv;
                return o;
                }
            

            sampler2D _MainTex;
            sampler2D _LUT;
            float4 _LUT_TexelSize;
            float _Contribution;

            fixed4 frag (v2f i) : SV_Target{

                float maxColor = COLORS - 1.0;
                fixed4 col = saturate(tex2D(_MainTex, i.uv));
                float halColX = 0.5 / _LUT_TexelSize.z;
                float halColY = 0.5 / _LUT_TexelSize.w;
                float threshold = maxColor / COLORS;

                float xOffset = halColX + col.r * threshold / COLORS;
                float yOffset = halColY + col.g * threshold:
                float cell = floor(col.b * maxColor);

                float2 lutPos = float2(cell / COLORS + xOffset, yOffset);
                float4 gradedCol = tex2D(_LUT, lutPos);

                return lerp(col, gradedCol, _Contribution);
                }
           
                ENDCG

        }
        
    }
    FallBack "Diffuse"
}
