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
		screen.max = 10;

		trace("Caching images...");

		FlxGraphic.defaultPersist = true;

		FlxG.bitmap.add(Paths.image("noteskins/NOTE_assets_CHEESE", "preload"));

		screen.progress = 1;

		FlxG.sound.cache(Paths.sound('intro3', 'shared'));
		FlxG.sound.cache(Paths.sound('intro2', 'shared'));
		FlxG.sound.cache(Paths.sound('intro1', 'shared'));
		FlxG.sound.cache(Paths.sound('introGo', 'shared'));

		screen.progress = 3;

		FlxG.sound.cache(Paths.sound('confirmMenu', 'preload'));
		FlxG.sound.cache(Paths.sound('cancelMenu', 'preload'));
		FlxG.sound.cache(Paths.sound('scrollMenu', 'preload'));

		screen.progress = 7;

		FlxG.bitmap.add(Paths.image("dialogue/Bluecheese_Dialogue", "shared"));
		FlxG.bitmap.add(Paths.image("dialogue/BOYFRIEND_Dialogue", "shared"));
		FlxG.bitmap.add(Paths.image("dialogue/gf_cheer", "shared"));
		FlxG.bitmap.add(Paths.image("dialogue/gf_Dialogue", "shared"));
		FlxG.bitmap.add(Paths.image("dialogue/OiSuzuki", "shared"));
		FlxG.bitmap.add(Paths.image("dialogue/cooltextboxes", "shared"));

		screen.progress = 10;

		FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;

		trace("bullshit over lmao");

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(new TitleState());
		});
	}
}
