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
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var gradientBar:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
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

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		FlxG.mouse.visible = false;
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
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
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
		FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

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

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
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

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
			trace('F11 FULLSCREEN');
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

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

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new MainMenuState());
				closedState = true;
			});
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
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

		if(!closedState) {
			switch (curBeat)
			{
				case 4:
					createCoolText(['Uniimations'], 45);
				case 5:
					addMoreText('Avinera', 45);
				case 6:
					addMoreText('Bluecheese', 45);
				case 7:
					addMoreText('Present', 45);
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
				case 12:
					deleteCoolText();
					FlxTween.tween(FNF_Logo, {y: 120, x: 210}, 0.68, {ease: FlxEase.backOut});
			    case 15:
					FlxTween.tween(FNF_SUBTEXT, {y: 48, x: 403}, 0.68, {ease: FlxEase.backOut});
				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(logoSpr);
			remove(FNF_Logo);
			remove(FNF_SUBTEXT);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			//SOME AWESOME TWEENING I DID WOAAAHH IM PROUD OF MYSELF FOR THIS PRAISE ME NOW.
			//i wasnt being serious sorry
			FlxTween.tween(logoBl, {'scale.x': 0.49, 'scale.y': 0.49, x: -200, y: -200}, 1.3, {ease: FlxEase.expoInOut, startDelay: 1.3});
            FlxTween.tween(cheese, {'scale.x': 1, 'scale.y': 1, x: 720, y: 80}, 2.3, {ease: FlxEase.expoInOut, startDelay: 0.9});
			remove(credGroup);
			remove(gradientBar);
			yellow.visible = true;
			skippedIntro = true;
		}
	}
}
