package states;

/*
	Script written by Heavy Bruh!!!!!! :3
*/

import flixel.addons.text.FlxTypeText;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxSpriteUtil;

#if !flash
import openfl.filters.ShaderFilter;
import flash.filters.GlowFilter;
import shaders.PosterizationShader;
#end

class EyeState extends MusicBeatState
{
	var posterization_shader:PosterizationShader; 
	public static var initialized:Bool = false;

	/*
		You can add any amount of text into this without the dialogue messing up
	*/
	var dialogue_text:Array<String> = [
		"It feels cold in here...",
		"Where am I?",
		"Am I dead?",
		"Where is my body?",
		"This can't be the Afterlife...",
	];

	var dialogue:FlxTypeText;
	var eye:FlxSprite;
	var pupil:FlxSprite;

	override function create()
	{
		#if DISCORD_ALLOWED DiscordClient.changePresence("ICU", null); #end

		/* 
			Da cool shader that SHOULD BE USED IN HORROR MODS MORE OFTEN RAAAAAAAAAAGH I LOVE THIS SHADER‼️‼️‼️‼️‼️‼️‼️‼️ 
		*/
		posterization_shader = new PosterizationShader();
		posterization_shader.dithering.value = [7.0];

		// looping background
		var bg:FlxBackdrop = new FlxBackdrop(Paths.image('misc_texture'));
		bg.velocity.set(10, 20);
		bg.scale.set(1.5, 1.5);
		bg.alpha = 0.8;
		bg.antialiasing = false;
		bg.screenCenter();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, (Conductor.crochet / 500), {type: PINGPONG}); // Gives the background that pulsating affect

		eye = createSprite('eye', 1);
		pupil = createSprite('pupil', 1);

		dialogue = new FlxTypeText(0, (FlxG.height - 100), FlxG.width, "", 35);
		dialogue.antialiasing = false;
		dialogue.font = Paths.font("times new roman.ttf");
		dialogue.color = FlxColor.WHITE;
		dialogue.alignment = CENTER;
		dialogue.sounds = [
			// loads through the dialogue sfx files
			for (i in 1 ... 3) FlxG.sound.load(Paths.sound('dialogue/dialogue_$i'))
		];
		add(dialogue);

		super.create();

		// Little intro
		if (!initialized) {
			FlxG.sound.playMusic(Paths.music('menu'));
			FlxG.sound.music.fadeIn(3, 0, 1);
			FlxG.camera.alpha = 0;
			FlxTween.tween(FlxG.camera, {alpha: 1}, 3, {
				onComplete: function(twn:FlxTween) {
					FlxG.mouse.visible = true;
					initialized = true;
					dialogueStart(dialogue_text[1], 0.08, true);
				}
			});
		}

		FlxG.camera.filters = [new ShaderFilter(posterization_shader)];
	}

	function createSprite(spr:String, scale:Float = 1) {
		var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(spr));
		sprite.antialiasing = false;
		sprite.scale.set(scale,scale);
		sprite.screenCenter();
		sprite.updateHitbox();
		add(sprite);
		return sprite;
	}

	function dialogueStart(text:String = "Poo poo!!!", duration:Float = 0.05, forced:Bool = true):Void {
		dialogue.resetText(text);
		dialogue.start(duration, forced, controls.ACCEPT);
	}

	override function beatHit()
	{
		/*
			If the random int == 10 and if the mouse is visible, randomize the dialogue text
		*/
		if (FlxG.random.int(1, 10) == 10 && FlxG.mouse.visible) {
			var randomInt:Int = FlxG.random.int(1, (dialogue_text.length-1));
			dialogueStart(dialogue_text[randomInt], 0.08, true);
		}
		super.beatHit();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.mouse.visible) 
		{
			if (pupil != null) {
				// The math for the eye following the cursor
				var x:Float = FlxMath.lerp((FlxG.mouse.x - (pupil.width/2)), pupil.x, Math.exp(-elapsed * 4));
				var y:Float = FlxMath.lerp((FlxG.mouse.y - (pupil.height/2)), pupil.y, Math.exp(-elapsed * 4));
				pupil.setPosition(
					Math.max(Math.min(x, (FlxG.width-eye.x-pupil.width)-pupil.width), eye.x+pupil.width),
					Math.max(Math.min(y, (FlxG.height-eye.y-pupil.height)-pupil.height), eye.y+pupil.height)
				);
			}
			if (controls.BACK) {
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}
}