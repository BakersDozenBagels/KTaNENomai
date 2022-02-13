Shader "KT/Mobile/DiffuseTintHideable" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_Angle ("ObjectToCover", Vector) = (1, 0, 0)
	}
	SubShader {
		Tags { "RenderType"="Geometry"
		"RenderType"="NomaiRender" }
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
				
				float4 tex = tex2D(_MainTex, IN.texcoord); 

				OUT.color = tex * _Color;

				float d = dot(normalize(_WorldSpaceCameraPos - _Angle.xyz),
					          normalize(_Angle.xyz - mul(unity_ObjectToWorld, IN.objectPos)));

				if(acos(d) < _Angle.w)
					discard;

				return OUT;
			} 
			ENDCG
		}
	}
}