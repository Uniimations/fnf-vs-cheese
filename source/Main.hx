package;

import flixel.util.FlxColor;
import haxe.display.FsPath;
import openfl.display.Bitmap;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.graphics.FlxGraphic;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var autoPause:Bool = false;

	public static var fpsVar:FPS;
	#if cpp
	public static var MemoryMonitor:MemoryMonitor = new MemoryMonitor(10, 3, 0xffffff);
	#end
	public static var watermarkCheese:Sprite;

	// You can pretty much ignore everything from here on - your code should go in your states.

	// stfu suck my nuts im gonna kill everything!!! -unii

	// i did kill everything and i am happy :]

	// oh.

	// damn this broke the game for a period of time fuck you past unii's

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
		setupDefines();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		initialState = TitleState;

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if web
		var str1:String = "HTML CRAP";
		var vHandler = new VideoHandler();
		vHandler.init1();
		vHandler.video.name = str1;
		addChild(vHandler.video);
		vHandler.init2();
		GlobalVideo.setVid(vHandler);
		vHandler.source(ourSource);
		#elseif desktop
		var str1:String = "WEBM SHIT"; 
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end

		#if html5
		FlxG.mouse.visible = false;
		#end

		autoPause = ClientPrefs.autoP;
	}

	function setupDefines()
	{
		FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;

		var bitmapData = Assets.getBitmapData("assets/images/watermark.png");

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end

		#if cpp
		MemoryMonitor = new MemoryMonitor(10, 3, 0xFFFFFF);
		addChild(MemoryMonitor);
		#end

		watermarkCheese = new Sprite();
        watermarkCheese.addChild(new Bitmap(bitmapData));
		watermarkCheese.alpha = 0.2;
        #if mobile
		watermarkCheese.x =  10;
        watermarkCheese.y = 3;
		#else
		watermarkCheese.x =  fpsVar.x;
        watermarkCheese.y = fpsVar.y + 25;
		#end
        addChild(watermarkCheese);
		if(watermarkCheese != null) {
			watermarkCheese.visible = ClientPrefs.showWatermark;
		}
	}
}
