package shaders;

import flixel.system.FlxAssets.FlxShader;

class PosterizationShader extends FlxShader
{
	@:glVersion("100")
	@:glFragmentSource('
		/* 
			Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

			https://www.shadertoy.com/view/wtcyzX
		*/ 

		#pragma header

		#define round(a) floor(a + 0.5)
		#define iResolution vec3(openfl_TextureSize, 0.)
		#define iChannel0 bitmap
		#define texture flixel_texture2D

		uniform float dithering = 7.0;

		// third argument fix
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
			vec4 color = texture2D(bitmap, coord, bias);
			if (!hasTransform)
			{
				return color;
			}
			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}
			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}
			color = vec4(color.rgb / color.a, color.a);
			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}

		vec4 Posterize(in vec4 inputColor){
		float gamma = 0.3f;
		float numColors = dithering;
		

		vec3 c = inputColor.rgb;
		c = pow(c, vec3(gamma, gamma, gamma));
		c = c * numColors;
		c = floor(c);
		c = c / numColors;
		c = pow(c, vec3(1.0/gamma));
		
		return vec4(c, inputColor.a);
		}

		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			// Normalized pixel coordinates (from 0 to 1)
			vec2 uv = fragCoord/iResolution.xy;
			fragColor = texture(iChannel0, uv);
			// Time varying pixel color
			vec3 col = 0.5 + 0.5*cos(uv.xyx+vec3(0,2,4));
			// Output to screen
			fragColor = Posterize(fragColor);
		}

		void main() {
			mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
		}'
	)
	public function new()
	{
		super();
	}
}
