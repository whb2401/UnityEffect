Shader "Custom/Water"
{
    Properties
    {
        _MainTex("MainTex",2D) = ""{}
        _Effect("Effect", Range(0, 1)) = 0
        _Color("color", color) = (1,1,1,1)
        _Wave("Wave", Range(0, 0.1)) = 0
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
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPose : WORLDPOSE;
                float4 uv0 : TEXCOORD1;
                float3 worldNormal : NORMAL;
            };

            float _Effect;
            sampler2D _GrabTempTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Wave;
            v2f vert (appdata_base v)
            {
                float4 vertex = v.vertex; 
                v2f o;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                float4 worldPose = mul(UNITY_MATRIX_M, v.vertex);
                float4 viewPose = mul(UNITY_MATRIX_V, worldPose);
                float4 clipPose =  mul(UNITY_MATRIX_P, viewPose);
                o.worldPose = worldPose;
                o.uv0 = ComputeGrabScreenPos(clipPose);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                half4 cubeCol = tex2Dlod(_MainTex, v.texcoord + float4(0.0, -_Time.x * _Effect,0.0,0.0)) * _Wave;
                o.vertex = UnityObjectToClipPos(v.vertex + cubeCol);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 cubeCol = tex2D(_MainTex, i.uv + float2(0.0, -_Time.x * _Effect));

                float2 uv0 = i.uv0.xy / i.uv0.w + float2(0.0, cubeCol.y * _Wave);
                
                float4 grabCol = tex2D(_GrabTempTex, uv0);


                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPose));
                
                half3 worldRefl = reflect(-worldViewDir, i.worldNormal + cubeCol * _Wave);

                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
                half4 skyColor = half4(DecodeHDR (skyData, unity_SpecCube0_HDR), 1);

                fixed4 col = 1;

                col.rgb = (grabCol + skyColor)/2;
                return  col * _Color;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
