package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import sys.thread.Thread;

using StringTools;

/**
 * @author BrightFyre
 */
class LoadingStartup extends MusicBeatState
{
	var screen:LoadingScreen;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();

		screen = new LoadingScreen();
		add(screen);

		trace("Starting caching...");

		FlxG.mouse.visible = false;

		Thread.create(() ->
		{
			cache();
		});
	}

	function cache()
	{
		screen.max = 3;

		trace("Caching images...");

		FlxGraphic.defaultPersist = true;

		FlxG.bitmap.add(Paths.image('countdown3', 'shared'));
		FlxG.bitmap.add(Paths.image('countdown2', 'shared'));
		FlxG.bitmap.add(Paths.image('countdown1', 'shared'));
		FlxG.bitmap.add(Paths.image('countdownGo', 'shared'));

		screen.progress = 1; // countdown graphix

		FlxG.bitmap.add(Paths.image('perfect', 'shared'));
		FlxG.bitmap.add(Paths.image('sick', 'shared'));
		FlxG.bitmap.add(Paths.image('good', 'shared'));
		FlxG.bitmap.add(Paths.image('bad', 'shared'));
		FlxG.bitmap.add(Paths.image('shit', 'shared'));
		FlxG.bitmap.add(Paths.image('miss', 'shared'));

		screen.progress = 2; // rating graphix

		FlxG.sound.cache(Paths.sound('confirmMenu', 'preload'));
		FlxG.sound.cache(Paths.sound('cancelMenu', 'preload'));
		FlxG.sound.cache(Paths.sound('scrollMenu', 'preload'));

		screen.progress = 3; // menu sounds

		FlxGraphic.defaultPersist = false;

		trace("bullshit over lmao");

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(new TitleState());
		});
	}
}
