Shader "Custom/Bloom"
{
    Properties
    {
        _Effect("Effect", Range(0, 1)) = 0
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Effect;
            sampler2D _GrabTempTex;
            float4 _GrabTempTex_ST;

            float ave(fixed4 col)
            {
                return (col.r + col.g + col.b)/3;
            }

            fixed4 FindLightColorWithCircle(sampler2D img, float2 uv, float r, float pixel)
            {
                fixed4 col = 0.0;
                float PI = 3.1415926;
                for(float x = 0; x < r * pixel * 8.0; x += pixel)
                {
                    float angle = lerp(-PI, PI, x / (r * pixel * 8.0));
                    float2 uv0 = uv + (float2(cos(angle)/_ScreenParams.x , sin(angle)/_ScreenParams.y) * r * pixel);

                    fixed4 samplerCol = tex2D(img, uv0);

                    if(ave(col) < ave(samplerCol))
                    {
                        col = samplerCol;
                    }
                }
                return col;
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
                float2 uv0 = i.grabPos.xy / i.grabPos.w;

                fixed4 col = tex2D(_GrabTempTex, uv0);

                fixed4 lightCol = col;
                float samplerR = 1;
                for(float idx = 1; idx < 5; idx ++)
                {
                    fixed4 samplerCol = FindLightColorWithCircle(_GrabTempTex, uv0, idx, 3);
                    if(ave(lightCol) < ave(samplerCol))
                    {
                        lightCol = samplerCol;
                        samplerR = idx;
                    }
                }

                return col + lerp(0 , lightCol - col, _Effect);
            }
            ENDCG
        }
    }
}
