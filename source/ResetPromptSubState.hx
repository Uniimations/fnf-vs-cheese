import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.system.System;

using StringTools;

class ResetPromptSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	public var opened:Bool = false;

	public function new()
	{
		super();

		opened = false; //define false

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:Alphabet = new Alphabet(0, 165, "Are you sure you want to erase all your save data?", true, false, 0.05, 0.55);
		text.screenCenter(X);
		text.alpha = 1;
		add(text);

		var text2:Alphabet = new Alphabet(0, text.y + 90, "You will lose all your progress and this will close the game", true, false, 0.05, 0.45);
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
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.85) bg.alpha = 0.85;

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

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 1);
				close();
			}

			if (controls.ACCEPT)
			{
				if(onYes)
				{
					ResetTools.resetData();
					FlxG.save.erase();
					System.exit(0);
				}
				else if (!onYes)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'), 1);
					close();
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