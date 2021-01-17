Shader "TexGen/SphereMap" {
Properties {
    _MainTex ("Texture", 2D) = "" { /* used to be TexGen SphereMap */ }
}
SubShader { 
    Pass { 
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        
        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert (float4 v : POSITION, float3 n : NORMAL)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v);

            // TexGen SphereMap
            float3 viewDir = normalize(ObjSpaceViewDir(v));
            float3 r = reflect(-viewDir, n);
            r = mul((float3x3)UNITY_MATRIX_MV, r);
            r.z += 1;
            float m = 2 * length(r);
            o.uv = r.xy / m + 0.5;

            return o;
        }

        sampler2D _MainTex;
        half4 frag (v2f i) : SV_Target
        {
            return tex2D(_MainTex, i.uv);
        }
        ENDCG 
    } 
}
}