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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPose : WORLDPOSE;
                float4 uv0 : TEXCOORD1;
                float4 uv1 : TEXCOORD2;
                float3 worldNormal : NORMAL;
            };

            float _Effect;
            sampler2D _GrabTempTex;
            sampler2D _MainTex;
            float4 _Color;
            float _Wave;
            v2f vert (appdata_base v)
            {
                float4 vertex = v.vertex; 
                v2f o;
                o.uv = v.texcoord;
                float4 worldPose = mul(UNITY_MATRIX_M, v.vertex);
                float4 viewPose = mul(UNITY_MATRIX_V, worldPose);
                float4 clipPose =  mul(UNITY_MATRIX_P, viewPose);
                o.vertex = clipPose;
                o.worldPose = worldPose;
                o.uv0 = ComputeGrabScreenPos(clipPose);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - worldPose);
                float cosAngle = dot(o.worldNormal, viewDir);

                float3 viewNromal = mul(UNITY_MATRIX_MV, v.normal);
                float3 cosAngle1 = dot(-viewNromal, float3(0.0,0.0,1.0));
                float deltay = 0;
                deltay = viewPose.y + cosAngle;
                viewPose.y = deltay;
                clipPose =  mul(UNITY_MATRIX_P, viewPose);
                o.uv1 = ComputeGrabScreenPos(clipPose);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 cubeCol = tex2D(_MainTex, i.uv + float2(0, -_Time.x * _Effect));

                float2 uv0 = i.uv0.xy / i.uv0.w;
                float2 uv1 = i.uv1.xy / i.uv1.w;

                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPose));
                
                half3 worldRefl = reflect(-worldViewDir, i.worldNormal);
                float angle = dot(-worldViewDir, i.worldNormal);
                float4 grabCol = tex2D(_GrabTempTex, uv0 + float2(0.0, (cubeCol * _Wave).g));

                
                float4 reflectCol = tex2D(_GrabTempTex, uv1 + float2(0.0, _Wave - (cubeCol * _Wave).g));

                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl - cubeCol * _Wave);
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
