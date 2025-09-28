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
import flixel.input.keyboard.FlxKey;

using StringTools;

/**
 * @author BrightFyre
 */
class LoadingStartup extends MusicBeatState
{
	var screen:LoadingScreen;

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public function new()
	{
		super();
	}

	override function create()
	{
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.sound.muted = false; // bug fix

		PlayerSettings.init();

		super.create();

		FlxG.save.bind('funkin', 'vscheese');
		loadData();

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

		FlxG.bitmap.add(Paths.image('rating-stuffs/perfect', 'shared'));
		FlxG.bitmap.add(Paths.image('rating-stuffs/sick', 'shared'));
		FlxG.bitmap.add(Paths.image('rating-stuffs/good', 'shared'));
		FlxG.bitmap.add(Paths.image('rating-stuffs/bad', 'shared'));
		FlxG.bitmap.add(Paths.image('rating-stuffs/shit', 'shared'));
		FlxG.bitmap.add(Paths.image('rating-stuffs/miss', 'shared'));

		screen.progress = 2; // rating graphix

		FlxG.sound.cache(Paths.sound('confirmMenu', 'preload'));
		FlxG.sound.cache(Paths.sound('cancelMenu', 'preload'));
		FlxG.sound.cache(Paths.sound('scrollMenu', 'preload'));

		screen.progress = 3; // menu sounds

		/**
			NOTE: Other menu sounds are not important enough to be cached. They will not lag the game.
		**/

		FlxGraphic.defaultPersist = false;

		trace("bullshit over lmao");

		//trace("dude YOU'RE GOATED...");

		new FlxTimer().start(2.5, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(new TitleState());
		});
	}

	private function loadData():Void
	{
		ClientPrefs.loadPrefs();
		Highscore.load();
		ResetTools.resetData();
		FlxG.mouse.visible = false;
	}
}
