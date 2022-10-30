import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class ChoiceState extends MusicBeatState
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = true;
	var nahText:Alphabet;
	var sureText:Alphabet;

	public var canDoStuff:Bool = false;

	override function create()
	{
		canDoStuff = false; //define false

		bg = new FlxSprite(-84.8, 97.8);
		bg.frames = Paths.getSparrowAtlas('week2_choice');
		bg.animation.addByPrefix('avi', 'cheese pick avi', 24, true);
		bg.animation.addByPrefix('unii', 'cheese pick unii', 24, true);
		bg.scrollFactor.set();
		add(bg);

		var choice:Alphabet = new Alphabet(0, 120, "''What do you think Cheese?''", true, false, 0.05, 0.8);
		choice.screenCenter(X);
		choice.alpha = 1;
		add(choice);

		nahText = new Alphabet(0, choice.y + 150, 'Nah', true);
		nahText.screenCenter(X);
		nahText.x -= 320;
		add(nahText);
		sureText = new Alphabet(0, choice.y + 150, "Sure!", true);
		sureText.screenCenter(X);
		sureText.x += 300;
		add(sureText);
		updateOptions();

		super.create();

		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			canDoStuff = true; //define true
		});
	}

	var zoomTween:FlxTween;

	override function update(elapsed:Float)
	{
		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (canDoStuff)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				FlxG.camera.zoom = 1.1;

				if(zoomTween != null) zoomTween.cancel();
				zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 0.6, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
					{
						zoomTween = null;
					}
				});

				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}

			if (controls.ACCEPT)
			{
				canDoStuff = false;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(FlxG.camera, { zoom: 1.5}, 1.5, { ease: FlxEase.expoIn });

				var difficulty = CoolUtil.difficultyStuff[PlayState.storyDifficulty][1];

				if(onYes)
				{
					PlayState.SONG = Song.loadFromJson('dynamic-duo' + difficulty, 'dynamic-duo');
				}
				else if (!onYes)
				{
					PlayState.SONG = Song.loadFromJson('below-zero' + difficulty, 'below-zero');
				}

				new FlxTimer().start(0.5, function(tmr:FlxTimer) {
					LoadingState.loadAndSwitchState(new PlayState());
				});
			}
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.7, 1.1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 0 : 1;

		nahText.alpha = alphas[confirmInt];
		nahText.scale.set(scales[confirmInt], scales[confirmInt]);
		sureText.alpha = alphas[1 - confirmInt];
		sureText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);

		if (onYes)
			bg.animation.play('unii');
		else
			bg.animation.play('avi');
	}
}