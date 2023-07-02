// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Example/Drapeau" 
    {
    Properties 
        {
        _MainTex ("Texture", 2D) = "white" {}
        _Amount ("Extrusion Amount", Range(0, 0.5)) = 0.4
        _LentWave ("LentWave", Range(0,1000)) = 0.5
        _Frenquence ("Frenquence", Range(0,1000)) = 0.5
        }
    SubShader 
        {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert addshadow        

        struct Input 
            {
            float2 uv_MainTex;
            };

        float _Amount;
        float _LentWave;
        float _Frenquence;
        float4 _objPos;

        float3x3 AngleAxis3x3(float angle, float3 axis)
		    {
		    float c, s;
		    sincos(angle, s, c);

		    float t = 1 - c;
		    float x = axis.x;
		    float y = axis.y;
		    float z = axis.z;

		    return float3x3
			    (
			    t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			    t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			    t * x * z - s * y, t * y * z + s * x, t * z * z + c
			    );
		    }

        void vert (inout appdata_full v) 
            {
            float3 oldVextex = v.vertex;
            float3 posObject = float3 (unity_ObjectToWorld [0] .w, unity_ObjectToWorld [1] .w, unity_ObjectToWorld [2] .w);
            float2 camDir = (_WorldSpaceCameraPos - posObject).xz;
            float angle = atan2(camDir.y, camDir.x );
            float rotZ = atan2(unity_ObjectToWorld[0].x, unity_ObjectToWorld[0].y);
            float3x3 lookatMatrix = AngleAxis3x3( angle + rotZ - 105, float3(0, 0, 1) );

            float f = clamp( sin( v.vertex.y * _LentWave + _Time.x * _Frenquence) * _Amount * v.vertex.y, -1, 1) ;
            v.vertex.xyz += float4(1, 0, 0, 0) * f;
            v.vertex.xyz = mul(v.vertex.xyz, lookatMatrix);

            float d = f;

            float3 v0 = v.vertex.xyz;
            float3 bitangent = cross(v.normal, v.tangent.xyz);
            float3 v1 = v0 + (v.tangent.xyz * 0.01);
            float3 v2 = v0 + (bitangent * 0.01);
 
            float ns0 = v0.y + d;
            float ns1 = v1.y + d;
            float ns2 = v2.y + d;
 
            v0.xyz += ns0 * v.normal;
            v1.xyz += ns1 * v.normal;
            v2.xyz += ns2 * v.normal;
 
            float3 modifiedNormal = cross(v2-v0, v1-v0);
 
            v.normal = normalize(-modifiedNormal);

            }
      sampler2D _MainTex;
      void surf (Input IN, inout SurfaceOutput o) 
        {
        o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
        o.Emission = o.Albedo;
        }
      ENDCG
        } 
    Fallback "Diffuse"
    }

    //commentarii