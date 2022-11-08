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
import flixel.system.FlxSound;
import flixel.FlxSprite;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var deathSound:String = 'loss_sfx';
	var deathSong:String = 'dinner';

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

		if (PlayState.SONG.player1 == 'undertale-bf') {
			deathSound = 'UT_loss_sfx';
			deathSong = 'determination';
		}

		super();

		Conductor.songPosition = 0;

		if (ClientPrefs.flashing) {
			FlxG.camera.flash(FlxColor.WHITE, 0.5);
		}

		var menuBG = new FlxSprite(0, 0).loadGraphic(Paths.image('game_over'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		menuBG.scrollFactor.set(0, 0);
		menuBG.screenCenter();
		add(menuBG);

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound('lose/' + deathSound));
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

	var canSkip:Bool = false;
	var skipping:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT && canSkip)
		{
			skipping = true;
		}

		if (controls.BACK)
		{
			FlxG.sound.music.fadeOut(1.5, 0);
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
					{
						if (PlayState.isStoryMode)
							MusicBeatState.switchState(new StoryMenuState());
						else
							MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freaky_overture'));
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

	override function beatHit()
	{
		super.beatHit();

		if (skipping) endBullshit();
	}

	var isEnding:Bool = false;

	function coolStartDeath():Void
	{
		var volume:Float = 1;

		if (PlayState.SONG.song.toLowerCase() == 'manager-strike-back')
		{
			volume = 0.3;
			FlxG.sound.play(Paths.soundRandom('suzuki/suzuki', 1, 17), 1, false, null, true, function() {
				if (!isEnding) FlxG.sound.music.fadeIn(1, 0.3, 1);
			});
		}

		FlxG.sound.playMusic(Paths.music(deathSong), volume);
		canSkip = true;
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(deathSong + 'Outro'));
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.switchState(new PlayState());
				});
			});
		}
	}
}
