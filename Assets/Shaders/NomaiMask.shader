Shader "KT/Mobile/NomaiMask" {
	SubShader {
		Tags { "RenderType"="NomaiRender" }
		Pass {
			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment main_frag

			uniform sampler2D _MainTex; 
			uniform fixed4 _Color;
			uniform float4 _Angle;

			struct vert2frag {
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				half2 viewDir : TEXCOORD1;
				float4 objectPos : TEXCOORD2;
				float4 normal : NORMAL;
			};
		
			struct frag2screen {
				float4 color : COLOR;
			};

			struct input {
				 float4 pos : POSITION;
				 half2 uv : TEXCOORD0;
				 float4 normal : NORMAL;
			};

			vert2frag vert(input IN) {
				vert2frag o;
				o.objectPos = IN.pos;
				o.pos = UnityObjectToClipPos(IN.pos);
				o.texcoord = MultiplyUV(UNITY_MATRIX_TEXTURE0, IN.uv);
				o.viewDir = normalize(mul(unity_WorldToObject, UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, IN.pos))));
				o.normal = IN.normal;

				return o;
			}

			frag2screen main_frag(vert2frag IN) {
				frag2screen OUT;
				
				OUT.color = (1,1,1,1);

				float d = dot(normalize(_WorldSpaceCameraPos - _Angle.xyz),
					          normalize(_Angle.xyz - mul(unity_ObjectToWorld, IN.objectPos)));

				if(acos(d) < _Angle.w)
					discard;

				return OUT;
			} 
			ENDCG
		}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma fragment main_frag
			#pragma vertex main_vert
		
			struct frag2screen {
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			struct input
			{
				float4 pos : POSITION;
			};

			v2f main_vert(input IN)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(IN.pos);
				return o;
			}

			frag2screen main_frag(v2f IN) {
				frag2screen OUT;

				OUT.color = fixed4(0,0,0,0);

				return OUT;
			} 
			ENDCG
		}
	}
}