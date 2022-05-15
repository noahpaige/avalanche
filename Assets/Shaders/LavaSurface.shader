Shader "Unlit/LavaSurface"
{

   Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_DepthFactor("Depth Factor", float) = 1.0
		_WaveSpeed("Wave Speed", float) = 1.0
		_WaveAmp("Wave Amp", float) = 0.2
		_DepthRampTex("Depth Ramp", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_MainTex("Main Texture", 2D) = "white" {}
		_DistortStrength("Distort Strength", float) = 1.0
		_ExtraHeight("Extra Height", float) = 0.0
		_EdgeThreshold("Edge Detect Threshold", Range (0,1)) = 0.95
		_DistortX ("Distortion in X", Range (0,2)) = 1
		_DistortY ("Distortion in Y", Range (0,2)) = 0
	}

	SubShader
	{
        Tags
		{ 
			  "RenderType" = "Transparent" "Queue" = "Transparent" 
		}
		Pass
		{

			CGPROGRAM
            #include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			float4 _Color;
			float4 _EdgeColor;
			float  _DepthFactor;
			float  _WaveSpeed;
			float  _WaveAmp;
			float _ExtraHeight;
			float _EdgeThreshold;

			sampler2D _CameraDepthTexture;
			sampler2D _DepthRampTex;
			sampler2D _NoiseTex;
			sampler2D _MainTex;

			fixed _DistortX;
			fixed _DistortY;

			struct vertexInput
			{
				float4 pos : POSITION;
				float4 texCoord : TEXCOORD1;
				half3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texCoord : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert to world space
				output.pos = UnityObjectToClipPos(input.pos);

				// apply wave animation
				float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));
				output.pos.y += sin(_Time.z*_WaveSpeed*noiseSample)*_WaveAmp + _ExtraHeight;
				output.pos.x += cos(_Time.z*_WaveSpeed*noiseSample)*_WaveAmp;

				// compute depth
				output.screenPos = ComputeScreenPos(output.pos);

				// texture coordinates 
				output.texCoord = input.texCoord;
				
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// apply depth texture
				float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
				float depth = LinearEyeDepth(depthSample).r;

				// create foamline
				float foamLine = 1 - saturate(_DepthFactor * (depth - input.screenPos.w));
				float4 foamRamp = float4(tex2D(_DepthRampTex, float2(foamLine, 0.5)).rgb, 1.0);

				// sample main texture
				//float4 albedo = tex2D(_MainTex, input.texCoord.xy); //use if adding a main lava tex

				//float4 col = _Color  + (foamLine * _EdgeColor); //used for orange to yellow foam effect
				float xCoord = input.texCoord.x;
				float yCoord = input.texCoord.y;
				float edgeFactor = 1 - _EdgeThreshold;
				if(xCoord > _EdgeThreshold) {
					foamLine += (xCoord/edgeFactor) - (_EdgeThreshold/edgeFactor);
				} else if(xCoord < 0.05) {
					foamLine += (xCoord/-edgeFactor) + 1;
				} if(yCoord > 0.95) {
					foamLine += (yCoord/edgeFactor) - (_EdgeThreshold/edgeFactor);
				} else if(yCoord < 0.05) {
					foamLine += (yCoord/-edgeFactor) + 1;
				}
				float4 col = float4(foamLine,0,0, 1);

                return col;
			}

			ENDCG
		}
	}
}
