package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var charPrefix:String = '';
	var songSuffix:String = '';

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		//BF DEATH SKIN, TYPE CHARACTER NAME
		var daBf:String = '';
		switch (PlayState.SONG.player1) {
			case 'ex-bf':
				daBf = 'ex-death';
			case 'arsen':
				daBf = 'arsen-death';
			case 'dansilot':
				daBf = 'dansilot-death';
			case 'dd-avinera-and-unii' | 'dd-avinera-guitar':
				daBf = 'dd-death';
			case 'undertale-bf':
				daBf = 'undertale-death';
			default:
				daBf = 'bf';
		}

		//BF DEATH SOUND REPLACEMENT, TYPE SOUND PREFIX OR SONG SUFFIX
		switch (PlayState.SONG.player1) {
			case 'arsen':
				charPrefix = 'arsen';
			case 'undertale-bf':
				songSuffix = 'UT';
				charPrefix = 'UT';
			default:
				charPrefix = 'fnf';
		}

		super();

		Conductor.songPosition = 0;

		if (ClientPrefs.flashing) {
			FlxG.camera.flash(FlxColor.WHITE, 0.5);
		}

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		//charPrefix is for the custom character death sfx
		FlxG.sound.play(Paths.sound('lose/' + charPrefix + '_loss_sfx'));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	override function update(elapsed:Float)
	{
		//

		super.update(elapsed);

		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.fadeOut(1.5, 0);
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, 1.5, false, function()
					{
						if (PlayState.isStoryMode)
							MusicBeatState.switchState(new StoryMenuState());
						else
							MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					});
				});
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	//what the fuck?
	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('hhello i ma  bea t');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (PlayState.SONG.song.toLowerCase() == 'manager-strike-back') {
			FlxG.sound.playMusic(Paths.music('gameOver' + songSuffix), 0);
			FlxG.sound.music.fadeIn(7, 0, 0.8);
			//sound file key/path, minimum int, maximum int
			//this is just a reminder for myself cuz im dumb
			FlxG.sound.play(Paths.soundRandom('suzuki/suzuki', 1, 17));
		} else {
			FlxG.sound.playMusic(Paths.music('gameOver' + songSuffix), volume);
		}
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + songSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.sound.music.fadeOut(1.5, 0);
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.target = new PlayState();
					MusicBeatState.switchState(new LoadingState());
				});
			});
		}
	}
}
