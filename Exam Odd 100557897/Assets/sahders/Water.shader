Shader "Custom/Water"
{
   Properties
    {
       _MainTex("Diffuse", 2D) = "white" {}
       _Tint("Colour Tint", Color) = (1,1,1,1)
       _Freq("Frequency", Range(0,5)) = 3
       _Speed("Speed", Range (0,100)) = 100
       _Amp("Amplitude", Range(0,1)) = 0.5
       _FoamTex("Foam", 2D) = "white" {}
       _ScorllX("Scroll X", Range(-5,5)) = 1
       _ScorllY("Scroll Y", Range(-5,5)) = 1
       _BumpMap("Normal Map", 2D) = "bump" {}
       _BumpScale("Normal Map Scale", Range(0, 1)) = 0.5
    }
    SubShader
    {
       Tags { "RenderType"="Opaque" }
       LOD 200
       CGPROGRAM
       #pragma surface surf Lambert vertex:vert

       struct Input {
           float2 uv_MainTex;
           float2 uv_FoamTex;
           float2 uv_BumpMap;  // For normal mapping
           float3 vertColor;
       };

       float4 _Tint;
       float _Freq;
       float _Speed;
       float _Amp;
       sampler2D _MainTex;
       sampler2D _FoamTex;
       sampler2D _BumpMap;
       float _ScorllX;
       float _ScorllY;
       float _BumpScale;

       struct appdata {
           float4 vertex : POSITION;
           float3 normal : NORMAL;
           float4 texcoord : TEXCOORD0;
           float4 texcoord1 : TEXCOORD1;  // Added texcoord1 for foam
           float4 texcoord2 : TEXCOORD2;  // Added texcoord2 for normal map
           float4 tangent : TANGENT;      // Added tangent for normal mapping
       };

       void vert (inout appdata v, out Input o) {
           UNITY_INITIALIZE_OUTPUT(Input, o);
           float t = _Time.y * _Speed;
           float waveHeight = sin(t + v.vertex.x * _Freq) * _Amp +
                              sin(t * 2 + v.vertex.x * _Freq * 2) * _Amp;
           v.vertex.y += waveHeight;
           o.vertColor = waveHeight + 2;
       }

       void surf (Input IN, inout SurfaceOutput o) {
           // Sample the main texture and apply color tint
           float4 mainColor = tex2D(_MainTex, IN.uv_MainTex) * _Tint;

           // Calculate scrolling foam texture coordinates
           float2 foamUV = IN.uv_MainTex + float2(_ScorllX * _Time.y, _ScorllY * _Time.y);
           float4 foamColor = tex2D(_FoamTex, foamUV);

           // Sample and apply the normal map
           float3 normalMap = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)) * _BumpScale;
           o.Normal = normalize(o.Normal + normalMap);  // Apply normal map to the surface normal

           // Blend main texture color with foam
           float3 blendedColor = lerp(mainColor.rgb, foamColor.rgb, 0.5);

           // Assign to Albedo with the vertex color effect
           o.Albedo = blendedColor * IN.vertColor;
       }
       ENDCG
    }
    Fallback "Diffuse"
}