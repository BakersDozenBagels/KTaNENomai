Shader "KT/Mobile/TexLerp"{
	Properties {
		_MainTex("Main Tex (Blend 0) (RGB)", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 100
		Lighting Off

		Pass {
			CGPROGRAM

	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LerpTex;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 tex1Col = tex2D(_MainTex, i.texcoord);
				fixed4 tex2Col = tex2D(_LerpTex, i.texcoord);

				fixed4 c;
				c = lerp((0,0,0,0), tex1Col, tex2Col.r);

				return c;
			}
			ENDCG
		}
	}
}
