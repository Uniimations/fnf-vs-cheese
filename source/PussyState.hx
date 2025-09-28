import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.system.System;

using StringTools;

class PussyState extends MusicBeatState
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	public var opened:Bool = false;

	override function create()
	{
		super.create();

		opened = false; //define false

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

		var text:Alphabet = new Alphabet(0, 165, "Having trouble beating this song?", true, false, 0.05, 0.55);
		text.screenCenter(X);
		text.alpha = 1;
		add(text);

		var text2:Alphabet = new Alphabet(0, text.y + 90, "Turn on pussy mode", true, false, 0.05, 0.45);
		text2.screenCenter(X);
		text2.alpha = 1;
		add(text2);

		yesText = new Alphabet(0, text2.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text2.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		updateOptions();

		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			opened = true; //define true
		});
	}

	override function update(elapsed:Float)
	{
		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (opened)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}

			if (controls.ACCEPT)
			{
				if(onYes)
				{
					ClientPrefs.pussyMode = true;
					FlxG.save.data.diedTwiceMSB = true;

					FlxG.sound.play(Paths.sound('confirmMenu'), 1);
					FlxG.sound.playMusic(Paths.music('freaky_overture'));

					MainMenuState.justExited = true;

					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						MusicBeatState.switchState(new MainMenuState());
					});
				}
				else if (!onYes)
				{
					FlxG.save.data.diedTwiceMSB = true;

					FlxG.sound.play(Paths.sound('cancelMenu'), 1);
					FlxG.sound.playMusic(Paths.music('freaky_overture'));

					MainMenuState.justExited = true;

					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						MusicBeatState.switchState(new MainMenuState());
					});
				}
			}
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.9, 1.3];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}