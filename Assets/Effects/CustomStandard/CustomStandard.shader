Shader "Custom/Standard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("MainColor", color) = (1,1,1,1)
        _Ambient("Ambient", color) = (0,0,0,0)
        _Specular("Specular", color) = (1,1,1,1)
        _Shininess("Shininess", range(1,10)) = 1
        _HDR("HDR", Range(0, 1)) = 0
        _Reflectivity("Reflectivity", Range(0, 1)) = 1
        _Illuminating("self-illuminating", Range(0, 1)) = 0
    }

    SubShader
    {
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
        cull off
        Pass
        {
            Tags{"LightMode" = "ForwardBase" "RenderType"="Opaque"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma multi_compile_fog
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(2)
                fixed4 diff : COLOR0;
                fixed4 ambient : COLOR1;
                float4 pos : SV_POSITION;
                half3 worldRefl : NORMAL;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float4 _Specular;
            float4 _Ambient;
            float _Shininess;
            float _HDR;
            float _Reflectivity;
            float _Illuminating;
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex).xyz));
                o.worldRefl = reflect(-worldViewDir, worldNormal);
                half nl = pow(max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz)), _Shininess);
                o.diff = nl * _LightColor0;
                
                o.ambient = _Ambient;
                o.ambient.rgb *= ShadeSH9(half4(worldNormal,1));

                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_SHADOW(o)
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
                half4 skyColor = half4(DecodeHDR (skyData, unity_SpecCube0_HDR), 1);
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= (i.ambient +  _LightColor0 * _Reflectivity).rgb;
                col.rgb += (i.diff * _Specular * shadow).rgb;
                col.rgb += (skyColor * _HDR * _LightColor0).rgb;
                col.rgb *= (1 + _Illuminating);
                col.a = 1.0f;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col * _Color;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
