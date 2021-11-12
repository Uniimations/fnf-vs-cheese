package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverFrostedSubstate extends MusicBeatSubstate
{
	var frozenShit:FlxSprite;
	var bf:Boyfriend;

	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	public var camHUD:FlxCamera;

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		Conductor.songPosition = 0;

		// camera shit
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD);

		frozenShit = new FlxSprite(0, 0);
		frozenShit.antialiasing = ClientPrefs.globalAntialiasing;
		frozenShit.alpha = 0;
		add(frozenShit);

		bf = new Boyfriend(x, y, 'frosted-death');
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y + -290);

		new FlxTimer().start(1.3, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound('lose/fnf_loss_sfx'));
		});

		Conductor.changeBPM(105);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		if (FlxG.save.data.diedTwiceFrosted)
			frozenShit.loadGraphic(Paths.image('effects/FROZEN_DEATH' + '_IN_GAME'));
		else
			frozenShit.loadGraphic(Paths.image('effects/FROSTED_DEATH_MESSAGE' + '_IN_GAME'));

		frozenShit.cameras = [camHUD];
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

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
					PlayState.phillyBlackTween = FlxTween.tween(frozenShit, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween) {
							PlayState.phillyBlackTween = null;
						}
					});
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
				FlxG.sound.playMusic(Paths.music('gameOver'));
				PlayState.phillyBlackTween = FlxTween.tween(frozenShit, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween) {
						PlayState.phillyBlackTween = null;
					}
				});
				bf.startedDeath = true;
				trace('frozenShit fade');
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

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (FlxG.save.data.diedTwiceFrosted == null || FlxG.save.data.diedTwiceFrosted == false) {
			FlxG.save.data.diedTwiceFrosted = true;
		}
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				PlayState.phillyBlackTween = FlxTween.tween(frozenShit, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween) {
						PlayState.phillyBlackTween = null;
					}
				});
				FlxG.sound.music.fadeOut(1.5, 0);
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
