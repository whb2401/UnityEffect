Shader "Custom/HotAir"
{
     Properties
    {
        _MainTex("MainTex",2D) = ""{}
        _Effect("Effect", Range(0, 1)) = 0
        _Color("color", color) = (1,1,1,1)
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

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 uv0 : TEXCOORD1;
                float2 uv1 : TEXCOORD2;
                float3 viewDir : VIEWDIR;
            };

            float _Effect;
            sampler2D _GrabTempTex;
            sampler2D _MainTex;
            float4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv0 = ComputeGrabScreenPos(o.vertex);
                float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                float3 r = reflect(-viewDir, v.normal);
                r = mul((float3x3)UNITY_MATRIX_MV, r);
                r.z += 1;
                float m = 2 * length(r);
                o.uv1 = r.xy / m + 0.5;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 cubeCol = tex2D(_MainTex, i.uv1 + float2(0, -_Time.y * _Effect));

                float2 uv0 = i.uv0.xy / i.uv0.w;

                fixed4 grabCol = tex2D(_GrabTempTex, uv0 + cubeCol * 0.01);

                return grabCol;
            }
            ENDCG
        }
    }
}
