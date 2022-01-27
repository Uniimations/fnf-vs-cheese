package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/**

 * MY NUTS HANG.

 */

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;
	var bg:FlxSprite;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('distant', 'shared'));
		}

		Conductor.changeBPM(105);
		persistentUpdate = true;

		/*
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		*/

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(Paths.image('startupWarning'));
		bg.scrollFactor.set();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var bgBlackShit:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgBlackShit.alpha = 0.8;
		add(bgBlackShit);

		warnText = new FlxText(459, 0, FlxG.width,
			"OI, watch out!\n
			This Mod contains some flashing lights!\n
			Press your ESCAPE key to disable them or\n
			head to the options menu. You may also just\n
			press ENTER to ignore this if you're not\n
			sensitive to flashing lights.\n
			Remember! You've been warned. :]",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if(!leftState)
		{
			if (controls.ACCEPT)
			{
				FlxG.sound.music.fadeOut(1, 0);

				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				ClientPrefs.flashing = true;
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1);

				/*
				FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
					new FlxTimer().start(0.5, function (tmr:FlxTimer) {
						
					});
				});

				FlxG.camera.flash(FlxColor.WHITE, 0.5);

				*/

				FlxTween.tween(bg, {alpha: 0}, 1.5, {
					onComplete: function (twn:FlxTween) {
						if (FlxG.sound.music != null) {
							FlxG.sound.music.stop();
							FlxG.sound.music.destroy();
							FlxG.sound.music == null;
						}
					}
				});

				FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.3});
				trace('wacky shit!');

				new FlxTimer().start(1.8, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new TitleState());
				});

				FlxG.log.add('warning ignored/flash enabled');
			}

			if (controls.BACK)
			{
				FlxG.sound.music.fadeOut(1, 0);

				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				ClientPrefs.flashing = false;
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1);

				FlxTween.tween(bg, {alpha: 0}, 1.5, {
					onComplete: function (twn:FlxTween) {
						if (FlxG.sound.music != null) {
							FlxG.sound.music.stop();
							FlxG.sound.music.destroy();
							FlxG.sound.music == null;
						}
					}
				});

				FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.2});
				trace('wacky shit!');

				new FlxTimer().start(1.8, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new TitleState());
				});

				FlxG.log.add('flash disabled');
			}
		}
		super.update(elapsed);

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
	}

	//BEAT HIT SHIT!
	override function beatHit()
    {
        super.beatHit();

		FlxTween.tween(FlxG.camera, {zoom:1.02}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

        //FlxG.log.add('ayO its me beaT boy!');
    }
}
