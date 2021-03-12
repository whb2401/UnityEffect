Shader "Custom/EdgeDetection"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Pixel ("Pixel", Range(1, 10)) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        GrabPass{
            "_GrabTempTex"
        }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 grabPos:COLOR0;
            };

            sampler2D _GrabTempTex;
            float4 _GrabTempTex_ST;
            float4 _Color;
            float _Pixel;

            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i)
            {
                const float PI = 3.1415926;
                const half gx[8] = {-1,-2,-2,-1,1,2,2,1};
                const half gy[8] = {1,2,2,1,-1,-2,-2,-1};
                half texColor = 0;
                half edgeX = 0;
                half edgeY = 0;
                float2 uv = i.grabPos.xy/i.grabPos.w;
                for(float x = 0; x < 8; x += 1)
                {
                    float angle = lerp(-PI, PI, x / 8);
                    texColor = luminance(tex2D(_GrabTempTex, uv + (float2(cos(angle), sin(angle)) / _ScreenParams.xy * _Pixel)));
                    edgeX += texColor * gx[x];
                    edgeY += texColor * gy[x];
                }
                half edge = abs(edgeX) + abs(edgeY);
                return edge;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
                col.a = Sobel(i);
                return col;
            }
            ENDCG
        }
    }
}
