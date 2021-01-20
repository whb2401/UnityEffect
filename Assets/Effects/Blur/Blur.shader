Shader "Custom/Blur"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white"{}
        _Factor ("Factor", Range(1,10)) = 1
        _Pixel ("Pixel", Range(1, 10)) = 1
        _CutOff("CutOff", Range(0,1)) = 0.4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        LOD 100
        
        GrabPass
        {
            "_GrabTempTex"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            int _Factor;
            sampler2D _GrabTempTex;
            float4 _GrabTempTex_ST;
            float _CutOff;
            int _Pixel;

            fixed4 blurImageCircle(sampler2D img, float2 uv, float r, float pixel)
            {
                fixed4 col = 0.0;
                float PI = 3.1415926;
                for(float x = 0; x < r * pixel * 8; x += pixel)
                {
                    float angle = lerp(-PI, PI, x / (r * pixel * 8));
                    col += tex2D(img, uv +(float2(cos(angle), sin(angle)) / _ScreenParams.xy *  r * pixel));
                }
                return col / (r * 8);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainCol = tex2D(_MainTex, i.uv);

                if(mainCol.a <= _CutOff)
                    discard;

                mainCol *= _Color;
                float2 uv0 = i.grabPos.xy / i.grabPos.w;
                fixed4 col = 0;
                float total = 0;
                for(int idx = 1; idx < _Factor; idx++)
                {
                    total += float(idx) / float(_Factor);
                    col += blurImageCircle(_GrabTempTex, uv0, idx, _Pixel) * idx / _Factor;
                }
                if(total != 0)
                {
                    col /= total;
                }
                col.rgb = col.rgb * (1 - mainCol.a) + mainCol.rgb * mainCol.a;

                return col;
            }
            ENDCG
        }
    }
}
