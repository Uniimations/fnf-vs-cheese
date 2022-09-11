package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxGradient;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var isDebug:Bool = false;
	#if debug
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	#else
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO, FlxKey.F4];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS, FlxKey.F7];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS, FlxKey.F8];
	#end
	static var initialized:Bool = false;

	private var canDoShit:Bool = false;

	var blackScreen:FlxSprite;
	var gradientBar:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;
	var FNF_Logo:FlxSprite;
	var FNF_SUBTEXT:FlxSprite;

	var curWacky:Array<String> = [];
	var Timer:Float = 0;

	//LOL WTF IS WACKY IMAGE/????
	//var wackyImage:FlxSprite;

	override public function create():Void
	{
		#if debug
		isDebug = true;
		#end
		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		//Gonna finish this later, probably
		//WHAT THE FUCK DO YOU MEAN LATER SHADOW MARIO COME BACK :wah:
		//actualy theres a new psych engine version so why am i complaining in an old repository lol
		//to whoever's reading this how is your day??
		//...i have 18 homeworks to do and im working on a friday night funkin mod
		//
		//not having fun :')
		#end
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'vscheese');
		loadData();

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
				canDoShit = true;
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var yellow:FlxSprite;
	var cheese:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			//got rid of old code cause stinky
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		Conductor.changeBPM(120);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		yellow = new FlxSprite().loadGraphic(Paths.image('intro/BG'));
		yellow.antialiasing = ClientPrefs.globalAntialiasing;
		add(yellow);
		yellow.visible = false;

		cheese = new FlxSprite(FlxG.width * 0.35, FlxG.height * 1.2);
		cheese.frames = Paths.getSparrowAtlas('intro/cheese_dance');
		cheese.animation.addByIndices('danceLeft', 'cheese menu pog', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		cheese.animation.addByIndices('danceRight', 'cheese menu pog', [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		cheese.antialiasing = ClientPrefs.globalAntialiasing;
		add(cheese);

		//dont mind this shitty code please
		logoBl = new FlxSprite(-200, -260);
		logoBl.frames = Paths.getSparrowAtlas('intro/logoBumpin');
		logoBl.animation.addByIndices('bump1', 'logo bumpin', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		logoBl.animation.addByIndices('bump2', 'logo bumpin', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
        logoBl.scale.set(0.6, 0.6);
		add(logoBl);

		titleText = new FlxSprite(25, 50);
		titleText.frames = Paths.getSparrowAtlas('intro/trolling');
		titleText.animation.addByPrefix('normal', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('normal');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00060A4D, 0xAAD55E82], 2, true); 
		gradientBar.y = FlxG.height - gradientBar.height;
		gradientBar.scale.y = 0;
		gradientBar.updateHitbox();
		add(gradientBar);
		FlxTween.tween(gradientBar, {'scale.y': 1.3}, 8, {ease: FlxEase.quadInOut}); // long gradient tween

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('intro/oglogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FNF_Logo = new FlxSprite(0, 0).loadGraphic(Paths.image('intro/cock'));
		FNF_SUBTEXT = new FlxSprite(0,0).loadGraphic(Paths.image('intro/ass'));
		add(FNF_Logo);
		add(FNF_SUBTEXT);
		FNF_Logo.scale.set(0.6, 0.6);
		FNF_SUBTEXT.scale.set(0.6,0.6);
		FNF_Logo.updateHitbox();
		FNF_SUBTEXT.updateHitbox();
		FNF_Logo.antialiasing = ClientPrefs.globalAntialiasing;
		FNF_SUBTEXT.antialiasing = ClientPrefs.globalAntialiasing;

		FNF_Logo.x = -1500;
		FNF_Logo.y = 300;
		FNF_SUBTEXT.x = -1500;
		FNF_SUBTEXT.y = 300;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		Timer += 1;
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;

		//SORRY IF THIS GETS ANNOYING I WAS TESTING SHIT!!!
		//i forgor to remove :skull:
		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
			trace('PRESS F TO FULLSCREEN');
		}

		var pressedEnter:Bool;

		if (canDoShit == true) {
			pressedEnter = controls.ACCEPT;
		} else {
			pressedEnter = false;
		}

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if(titleText != null) titleText.animation.play('press');
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			//FlxTween.tween(FlxG.camera, {y:1111}, 2, {ease: FlxEase.expoInOut});
			FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.4});
			trace('wacky shit!');

			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				#if web
				MusicBeatState.switchState(new PiracySubState());
				trace('anti piracy log = true');
				trace('access denied');
				closedState = true;
				#else
				MusicBeatState.switchState(new MainMenuState());
				trace('anti piracy log = false');
				trace('access granted');
				closedState = true;
				#end
			});
			canDoShit = false;
		}

		#if debug
		if (canDoShit) {
			if (FlxG.keys.justPressed.F1)
			{
				MusicBeatState.switchState(new MainMenuState());
			}

			if (FlxG.keys.justPressed.F2)
			{
				MusicBeatState.switchState(new StoryMenuState());
			}

			if (FlxG.keys.justPressed.F3)
			{
				MusicBeatState.switchState(new FreeplayState());
			}

			if (FlxG.keys.justPressed.F4)
			{
				MusicBeatState.switchState(new CreditsState());
			}

			if (FlxG.keys.justPressed.F5)
			{
				MusicBeatState.switchState(new OptionsState());
			}

			if (FlxG.keys.justPressed.F6)
			{
				MusicBeatState.switchState(new RatingPopUpMenuState());
			}
		}
		#end

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?yOffset:Float = 0, ?xOffset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + yOffset;
			money.x += (textGroup.length * 5) + 5 + xOffset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?yOffset:Float = 0, ?xOffset:Float = 0)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + yOffset;
			coolText.x += (textGroup.length * 5) + 5 + xOffset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		danceLeft = !danceLeft;

		//really shit way to force the logo to bump but it works so whatever
		if (danceLeft)
			logoBl.animation.play('bump2');
		else
			logoBl.animation.play('bump1');

		if (danceLeft)
			cheese.animation.play('danceRight');
		else
			cheese.animation.play('danceLeft');

		FlxG.log.add(curBeat);
		FlxTween.tween(FlxG.camera, {zoom:1.02}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		if(!closedState)
		{
			switch (curBeat)
			{
				case 4:
					createCoolText(['Uniimations'], 20);
				case 5:
					addMoreText('Avinera', 20);
					addMoreText('Potionion', 20);
				case 6:
					addMoreText('Bluecheese', 20);
					addMoreText('& Many more', 20);
			}

			createStartText(); // else if type beat im not proud of :(

			switch (curBeat)
			{
				case 12: // you've seen the intro text
					if (FlxG.save.data.seenIntro == null || FlxG.save.data.seenIntro == false) {
						FlxG.save.data.seenIntro = true;
					}
					deleteCoolText();
				case 13:
					createCoolText(['getting'], 45);
				case 15:
					addMoreText('Freaky', 45);
				case 16:
					addMoreText('on a', 45);
				case 17:
					addMoreText('Friday', 45);
				case 18:
					deleteCoolText();
					createCoolText(['Night'], 2, 200);
					FlxTween.tween(FNF_Logo, {y: 120, x: 210}, 0.68, {ease: FlxEase.backOut});
			    case 19:
					addMoreText('Yeah', 20, 100);
					FlxTween.tween(FNF_SUBTEXT, {y: 48, x: 403}, 0.68, {ease: FlxEase.backOut});
				case 20:
					deleteCoolText();
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (FlxG.mouse.visible = true) FlxG.mouse.visible = false;
			/*
			makes sure the mouse is invisible (doesnt really matter since it becomes visible in main menu but... its not used in title screen)
			**/

			remove(logoSpr);
			remove(FNF_Logo);
			remove(FNF_SUBTEXT);

			if (ClientPrefs.flashing) {
				FlxG.camera.flash(FlxColor.WHITE, 2);
			} else {
				FlxG.camera.flash(FlxColor.BLACK, 0.6);
			}

			//SOME AWESOME TWEENING I DID WOAAAHH IM PROUD OF MYSELF FOR THIS PRAISE ME NOW.
			//i wasnt being serious sorry
			//wtf past me??? ^
			//this is uniimation from 7 momnths later unii you were a fuicking asshole lmao you suck 
			FlxTween.tween(logoBl, {'scale.x': 0.49, 'scale.y': 0.49, x: -200, y: -200}, 1.3, {ease: FlxEase.expoInOut, startDelay: 1.3});
            FlxTween.tween(cheese, {'scale.x': 1, 'scale.y': 1, x: 720, y: 120}, 2.3, {ease: FlxEase.expoInOut, startDelay: 0.9});
			remove(credGroup);
			remove(gradientBar);
			yellow.visible = true;
			skippedIntro = true;
		}
	}

	// this function is a bit of a mess... dont mind it
	function createStartText():Void
	{
		#if TRAILER_BUILD
		var isTrailer:Bool = true;
		#else
		var isTrailer:Bool = false;
		#end
		if (isTrailer) {
			switch (curBeat)
			{
				case 7:
				addMoreText('Are Proud', 20);
				addMoreText('To Present', 20);
				case 8:
					deleteCoolText();
					createCoolText(["If you're a"], 45);
				case 9:
					addMoreText('Friday Night Funkin fan', 45);
				case 10:
					deleteCoolText();
					createCoolText(['You definitely want'], 45);
				case 11:
					addMoreText('the full ass', 45);
			}
		} else if (FlxG.save.data.seenIntro == false) {
			switch (curBeat)
			{
				case 7:
				addMoreText('Are Proud', 20);
				addMoreText('To Present', 20);
				case 8:
					deleteCoolText();
					createCoolText(["If you're a"], 45);
				case 9:
					addMoreText('Friday Night Funkin fan', 45);
				case 10:
					deleteCoolText();
					createCoolText(['You definitely want'], 45);
				case 11:
					addMoreText('the full ass', 45);
			}
		} else {
			switch (curBeat)
			{
				case 7:
					addMoreText('Present', 20);
				case 8:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					deleteCoolText();
					createCoolText([curWacky[0]], 45);
				case 9:
					addMoreText(curWacky[1], 45);
				case 10:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					deleteCoolText();
					createCoolText([curWacky[0]], 45);
				case 11:
					addMoreText(curWacky[1], 45);
			}
		}
	}

	private function loadData():Void
	{
		ClientPrefs.loadPrefs();
		Highscore.load();
		ResetTools.resetData();
		FlxG.mouse.visible = false;
	}
}
