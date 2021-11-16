package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.media.Video;
import Achievements;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['cry about it', 0.2], //From 0% to 19%
		['AWFUL !', 0.4], //From 20% to 39%
		['AWFUL !', 0.5], //From 40% to 49%
		['AWFUL !', 0.6], //From 50% to 59%
		['BAD !', 0.69], //From 60% to 68%
		['NICE !', 0.7], //69%
		['BAD !', 0.8], //From 70% to 79%
		['GOOD !', 0.9], //From 80% to 89%
		['COOL !', 1], //From 90% to 99%
		['COOL !', 1] //The value on this one isn't used actually, since Perfect is always "1"
	]; 

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var boyfriendGroup:FlxTypedGroup<Boyfriend>;
	public var dadGroup:FlxTypedGroup<Character>;
	public var littleManGroup:FlxTypedGroup<Character>;
	public var gfGroup:FlxTypedGroup<Character>;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var cutsceneShit:Bool = false;

	public var vocals:FlxSound;

	public var dad:Character;
	public var littleMan:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var isDad:Bool = false;
	public var isLittleMan:Bool = false;
	public var isGF:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	private var babyArrow:StrumNote;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var phillyCounter:BGSprite;
	var phillyFade:BGSprite;
	var phillyBlack:BGSprite;
	public static var phillyBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var boppers:BGSprite;
	var counter:BGSprite;
	var frontBoppers:BGSprite;

	var joey:BGSprite;
	var crystal:BGSprite;
	var ralsei:BGSprite;
	var stickmin:BGSprite;
	var dansilot:BGSprite;
	var wallLeft:BGSprite;
	var snow:BGSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var versionShit:FlxText;
	public var blackscreenhud:FlxSprite;
	public var whiteBox:FlxSprite;

	public var freezeFade:FlxSprite;
	public var redFade:FlxSprite;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	var infoTxt:FlxText;
	var shitsTxt:FlxText;
	var badsTxt:FlxText;
	var goodsTxt:FlxText;
	var sicksTxt:FlxText;
	var perfectsTxt:FlxText;
	var shits:Int = 0;
	var bads:Int = 0;
	var goods:Int = 0;
	var sicks:Int = 0;
	var perfects:Int = 0;
	var missesTxt:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;
	public static var isCutscene:Bool = false;
	var noCountdown:Bool = false;
	var hasMP4:Bool = false;

	var songLength:Float = 0;
	public static var displaySongName:String = "";

	public static var dadnoteMovementXoffset:Int = 0;
	public static var dadnoteMovementYoffset:Int = 0;
	public static var bfnoteMovementXoffset:Int = 0;
	public static var bfnoteMovementYoffset:Int = 0;

	private var dadPog:Bool = false;
	private var boyfriendPog:Bool = false;
	private var freezePogging:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var luaArray:Array<FunkinLua> = [];

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public var backgroundGroup:FlxTypedGroup<FlxSprite>;
	public var foregroundGroup:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		shits = 0;
		bads = 0;
		goods = 0;
		sicks = 0;
		perfects = 0;

		noCountdown = false;
		hasMP4 = false;
		practiceMode = false;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		if (cutsceneShit) {
			camHUD.visible = false;
			camGame.visible = false;
		}

		FlxCamera.defaultCameras = [camGame];
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		var songName:String = SONG.song;
		displaySongName = StringTools.replace(songName, '-', ' ');

		dadnoteMovementXoffset = 0;
		dadnoteMovementYoffset = 0;
		bfnoteMovementXoffset = 0;
		bfnoteMovementYoffset = 0;

		// TIMING WINDOWS!!!

		// im pretty sure it works like this:
		// the number is how close it is to the strumline
		// and the number and everything below that is what
		// counts as the timing.

		// this means that 16ms+ is perfect according to this hypothesis.
		// (this might all be wrong because i dont fuckig understand lmao)

		var timingTxt;
		var file:String = (Paths.txt('timingWindows')); // txt for timing windows
		if (OpenFlAssets.exists(file))
		{
			timingTxt = CoolUtil.coolTextFile(file);

			for (i in 0...timingTxt.length)
				{
					CoolUtil.timingWindows.push(Std.parseFloat(timingTxt[i+1]));
				}
			trace('loaded timingTxt file');
		}
		else // crash prevention default
		{
			CoolUtil.timingWindows = [
				[0.85],
				[0.5],
				[0.25],
				[0.15]
			];
			trace('failed to load txt file');
			trace('timing windows set to default');
		}

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			var weekCustomName = 'Week ' + storyWeek;
			if(WeekData.weekResetName[storyWeek] != null)
				weekCustomName = '' + WeekData.weekResetName[storyWeek];
			else if(WeekData.weekNumber[storyWeek] != null)
				weekCustomName = 'Week ' + WeekData.weekNumber[storyWeek];

			detailsText = "Story Mode: " + weekCustomName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				curStage = 'restauranteKitchen';

				defaultCamZoom = 0.60;

				var bg:BGSprite = new BGSprite('cheese/kitchen/background_main', -762.4, -1524.4, 1, 1);
				bg.updateHitbox();

				var sink:BGSprite = new BGSprite('cheese/kitchen/Sink', 916.8, -23.55, 1, 1, ['Sink'], true); //anim
				sink.updateHitbox();

				var stove:BGSprite = new BGSprite('cheese/kitchen/THEE_AWESIOME_STOBEVE', 278.8, 29.05, 1, 1, ['THEE AWESIOME STOBEVE'], true); //anim
				stove.updateHitbox();

				var silly:BGSprite = new BGSprite('cheese/kitchen/SILLY_TRAMSHCANSH', -44.45, 697.95, 1, 1);
				silly.updateHitbox();

				var shelf:BGSprite = new BGSprite('cheese/kitchen/cheeese_nevr_uses_that_frying_pan_on_that_shelf', 251.6, -607.5, 1, 1);
				shelf.updateHitbox();

				counter = new BGSprite('cheese/kitchen/counter_strike_source', 331.8, 709.1, 1, 1);
				counter.updateHitbox();

				if (!ClientPrefs.fuckyouavi) { //fuckyouavi is shitty optimized mode
					add(bg);
					add(sink);
					add(stove);
					add(silly);
					add(shelf);
				}

			case 'restaurante' | 'milkshake' | 'cultured':
				curStage = 'restaurante';

				defaultCamZoom = 0.60;

				var suzuki:BGSprite;
				var exPath:String = '';
				var charPath:String = '';

				if (CoolUtil.difficultyString() == 'EX') {
					exPath = 'ex/';
					charPath = '';
				}
				else {
					exPath = '';
					charPath = 'char/';
				}

				var floor:BGSprite = new BGSprite('cheese/floor', -377.9, -146.4, 1, 1);
				floor.updateHitbox();

				var tableA:BGSprite = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
				tableA.updateHitbox();

				var tableB:BGSprite = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
				tableB.updateHitbox();

				boppers = new BGSprite('cheese/' + exPath + charPath + 'boppers', 1265.6, 127.6, 1, 1, ['boppers']); //add anim
				boppers.updateHitbox();

				suzuki = new BGSprite('cheese/' + exPath + 'wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);

				frontBoppers = new BGSprite('cheese/' + exPath + charPath + 'front_boppers', 67.5, 959.7, 1, 1, ['front boppers']);

				counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']); //add anim
				counter.updateHitbox();

				phillyBlack = new BGSprite(null, -390, -190, 1, 1);
				phillyBlack.makeGraphic(Std.int(FlxG.width * 12), Std.int(FlxG.height * 12), FlxColor.BLACK);
				phillyBlack.alpha = 0.0;

				phillyCounter = new BGSprite('cheese/counter_white', 232.35, 403.25, 1, 1, ['COUNTER WHITE']); //add anim
				phillyCounter.alpha = 0.0;
				phillyCounter.updateHitbox();

				if(!ClientPrefs.fuckyouavi) {
					suzuki.updateHitbox();
					frontBoppers.updateHitbox();
					add(floor);
				    add(tableA);
				    add(tableB);
				    add(boppers);
				    add(suzuki);
					add(phillyBlack);
				}

			case 'wifi':
				curStage = 'restauranteArsen';

				defaultCamZoom = 0.60;

				var floor:BGSprite = new BGSprite('cheese/floor', -377.9, -146.4, 1, 1);
				floor.updateHitbox();

				stickmin = new BGSprite('cheese/char/stickmin', 1855.55, 49.9, 1, 1, ['henry']);
				stickmin.updateHitbox();

				var tSideMod:BGSprite = new BGSprite('cheese/t-side_mod', 1288.35, 279.9, 1, 1);
				tSideMod.updateHitbox();

				var tableA:BGSprite = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
				tableA.updateHitbox();

				var tableB:BGSprite = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
				tableB.updateHitbox();

				joey = new BGSprite('cheese/char/joey_new', 1975.35, 115.35, 1, 1, ['joey']);
				joey.updateHitbox();

				crystal = new BGSprite('cheese/char/crystal_bop', 2199.8, 340.2, 1, 1, ['crystal bop']);
				crystal.updateHitbox();

				ralsei = new BGSprite('cheese/char/ralsei_bop', 2059.45, 469.55, 1, 1, ['ralsei bop']);
				ralsei.updateHitbox();

				var wall:BGSprite = new BGSprite('cheese/wall', -358.25, -180.35, 1, 1);
				wall.updateHitbox();

				counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);
				counter.updateHitbox();

				frontBoppers = new BGSprite('cheese/char/crowdindie', 254.15, 823.45, 1, 1, ['crowdindie']);
				frontBoppers.updateHitbox();

				if(!ClientPrefs.fuckyouavi) {
					add(floor);
					add(stickmin);
					add(tSideMod);
				    add(tableA);
				    add(tableB);
					add(joey);
					add(crystal);
					add(ralsei);
					add(wall);
				}

			case 'casual-duel':
				curStage = 'restauranteDansilot';

				defaultCamZoom = 0.60;

				var floor:BGSprite = new BGSprite('cheese/floor', -377.9, -146.4, 1, 1);
				floor.updateHitbox();

				stickmin = new BGSprite('cheese/char/stickmin', 1855.55, 49.9, 1, 1, ['henry']);
				stickmin.updateHitbox();

				var tSideMod:BGSprite = new BGSprite('cheese/t-side_mod', 1288.35, 279.9, 1, 1);
				tSideMod.updateHitbox();

				var tableA:BGSprite = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
				tableA.updateHitbox();

				var tableB:BGSprite = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
				tableB.updateHitbox();

				joey = new BGSprite('cheese/char/joey_new', 1975.35, 115.35, 1, 1, ['joey']);
				joey.updateHitbox();

				crystal = new BGSprite('cheese/char/crystal_bop', 2199.8, 340.2, 1, 1, ['crystal bop']);
				crystal.updateHitbox();

				ralsei = new BGSprite('cheese/char/ralsei_bop', 2059.45, 469.55, 1, 1, ['ralsei bop']);
				ralsei.updateHitbox();

				var wall:BGSprite = new BGSprite('cheese/wall', -358.25, -180.35, 1, 1);
				wall.updateHitbox();

				counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);
				counter.updateHitbox();

				frontBoppers = new BGSprite('cheese/char/crowdindie', 254.15, 823.45, 1, 1, ['crowdindie']);
				frontBoppers.updateHitbox();

				if(!ClientPrefs.fuckyouavi) {
					add(floor);
					add(stickmin);
					add(tSideMod);
				    add(tableA);
				    add(tableB);
					add(joey);
					add(crystal);
					add(ralsei);
					add(wall);
				}

			case 'manager-strike-back':
				curStage = 'undertale';

				defaultCamZoom = 0.60;

				//added during dark fade event.
				phillyFade = new BGSprite(null, -390, -190, 1, 1);
				phillyFade.makeGraphic(Std.int(FlxG.width * 12), Std.int(FlxG.height * 12), FlxColor.BLACK);
				phillyFade.alpha = 0;

			case 'frosted':
				curStage = 'frostedStage';

				defaultCamZoom = 0.9;

				var outside = new BGSprite('bonus/outside', -438.85, -213.3, 1, 1);
				outside.updateHitbox();

				snow = new BGSprite('bonus/snowstorm', -369.8, -114.8, 1, 1, ['funny snowsto'], true);
				snow.updateHitbox();
				snow.visible = false;

				var wall = new BGSprite('bonus/wall', -486, -352.3, 1, 1);
				wall.updateHitbox();

				dansilot = new BGSprite('bonus/tableRight', 632.95, 17.8, 1, 1, ['tableRight']);
				dansilot.updateHitbox();

				frontBoppers = new BGSprite('bonus/boppers', 855.9, 327.65, 1, 1, ['TABLE BOP FIXED']);
				frontBoppers.updateHitbox();

				wallLeft = new BGSprite('bonus/wallLeft', -949.25, -393.6, 1, 1);
				wallLeft.updateHitbox();

				counter = new BGSprite('bonus/boppers', -348.35, 403, 1, 1, ['cheese bop']);
				counter.updateHitbox();

				if(!ClientPrefs.fuckyouavi) {
					add(outside);
					add(snow);
					add(wall);
					add(dansilot);
				}

			default:
				curStage = 'restauranteDefault';

				defaultCamZoom = 0.58;

				var suzuki:BGSprite;
				var oldPath:String = 'cheese/old/';

				var floor:BGSprite = new BGSprite(oldPath + 'bedrock', -1262.95, -138.7, 0.9, 0.9);
				floor.updateHitbox();

				var tableA:BGSprite = new BGSprite(oldPath + 'sit', 1918.1, 282.15, 0.9, 0.9);
				tableA.updateHitbox();

				var tableB:BGSprite = new BGSprite(oldPath + 'UHM', 1664.95, 581.65, 0.9, 0.9);
				tableB.updateHitbox();

				boppers = new BGSprite(oldPath + 'doot', 1276.65, 154.1, 0.9, 0.9, ['doot']); //add anim
				boppers.updateHitbox();

				suzuki = new BGSprite(oldPath + 'SUSSY_IMPOSER', -358.25, -142.2, 0.9, 0.9, ['wall'], true);

				counter = new BGSprite(oldPath + 'counter', 230.8, 417.45, 1, 1);
				counter.updateHitbox();

				frontBoppers = new BGSprite(oldPath + 'spectator_mode', 256.6, 1069.85, 0.9, 0.9, ['spectator mode']);

				if(!ClientPrefs.fuckyouavi) {
					suzuki.updateHitbox();
					frontBoppers.updateHitbox();
					add(floor);
				    add(tableA);
				    add(tableB);
				    add(boppers);
				    add(suzuki);
				}
		}

		backgroundGroup = new FlxTypedGroup<FlxSprite>();
		add(backgroundGroup);

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		var bfType:String = SONG.player1;
		if(!ClientPrefs.bfreskin) {
			{
				//BFTYPE IS NOW PER CHARACTER AND NOT PER STAGE, WORKS BETTER
				switch (SONG.player1)
				{
					case 'bf':
						bfType = 'bf-alt';
					case 'bf-small':
						bfType = 'bf-small-alt';
					default:
					    bfType = SONG.player1;
			    }
			}
			SONG.player1 = bfType;
		}

		boyfriendGroup = new FlxTypedGroup<Boyfriend>();
		dadGroup = new FlxTypedGroup<Character>();
		littleManGroup = new FlxTypedGroup<Character>();
		gfGroup = new FlxTypedGroup<Character>();

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				BF_Y -= 220;
				BF_X += 260;

			case 'mall':
				BF_X += 200;

			case 'mallEvil':
				BF_X += 320;
				DAD_Y -= 80;
			case 'school':
				BF_X += 200;
				BF_Y += 220;
				GF_X += 180;
				GF_Y += 300;
			case 'schoolEvil':
				BF_X += 200;
				BF_Y += 220;
				GF_X += 180;
				GF_Y += 300;
		}

		gf = new Character(GF_X, GF_Y, gfVersion);
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.scrollFactor.set(1, 1);
		gfGroup.add(gf);

		dad = new Character(DAD_X, DAD_Y, SONG.player2);
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
		dad.scrollFactor.set(1, 1);
		dadGroup.add(dad);

		littleMan = new Character(DAD_X, DAD_Y, 'bluecheese-little-man'); //no json for little man since hes only used in cultured ex
		littleMan.x += 807;
		littleMan.y += 385;
		littleMan.scrollFactor.set(1, 1);
		littleMan.visible = false;
		littleManGroup.add(littleMan);

		boyfriend = new Boyfriend(BF_X, BF_Y, SONG.player1);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.scrollFactor.set(1, 1);
		boyfriendGroup.add(boyfriend);

		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		//suzuki is actually on top of gf and gf is invisible
		if(dad.curCharacter.startsWith('gf')) {
			gf.visible = false;
		}

		//trail issue
		if (dad.curCharacter == 'avinera-frosted') {
			var freezeTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.69);
			add(freezeTrail);
			freezeTrail.alpha = 0;
			if (freezePogging)
				freezeTrail.alpha = 1;
			else
				freezeTrail.alpha = 0;
		}

		//REALLY SHITTY LAYERING STUFF
		//AND CASES BECAUSE IM DUMB
		//foreground and background groups whats that???!?!?!
		switch(curStage)
		{
			case 'restaurante' | 'restauranteArsen' | 'restauranteDansilot' | 'restauranteAvinera':
				gf.visible = true;
			default:
				gf.visible = false;
		}

		if (!ClientPrefs.fuckyouavi) {
			if (!curStage.startsWith('frostedStage'))
			{
				add(gfGroup);

				add(dadGroup);

				//SHITTY BF LAYERING BUT IT WORKS
				if (curStage == 'restauranteKitchen') {
					add(boyfriendGroup);
				}

				if (curStage.startsWith('restaurante')) {
					add(counter);
				}

				if (curStage.startsWith('restaurante') && CoolUtil.difficultyString() == 'EX') {
					add(phillyCounter);
				}

				if (!curStage.endsWith('Kitchen')) {
					add(boyfriendGroup);
				}

				add(littleManGroup); //little man is always invisible

				if (!curStage.endsWith('Kitchen') && !curStage.startsWith('undertale')) {
					add(frontBoppers);
				}

				if (curStage == 'undertale') {
					add(phillyFade);
				}
			}
			else
			{
				//characters
				add(dadGroup);
				add(boyfriendGroup);

				//bg
				add(frontBoppers);
				add(wallLeft);
				add(counter);
			}
		}

		//theres probably a better way to do the shitish mode but this is how i did it lol
		if(!ClientPrefs.shitish) {
			var lowercaseSong:String = SONG.song.toLowerCase();
			var file:String = Paths.txt(lowercaseSong + '/' + lowercaseSong + 'Dialogue');
			if (OpenFlAssets.exists(file)) {
				dialogue = CoolUtil.coolTextFile(file);
			}
	    } else {
			var lowercaseSong:String = SONG.song.toLowerCase();
			var file:String = Paths.txt(lowercaseSong + '/' + lowercaseSong + 'DialogueSHIT');
			if (OpenFlAssets.exists(file)) {
				dialogue = CoolUtil.coolTextFile(file);
			}
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;

		Conductor.songPosition = -5000;

		blackscreenhud = new FlxSprite().loadGraphic(Paths.image('black_screen'));
		add(blackscreenhud);
		blackscreenhud.alpha = ClientPrefs.bgDim;
		if (ClientPrefs.fuckyouavi) {
			blackscreenhud.visible = false;
		} else {
			blackscreenhud.visible = true;
		}

		var boxPath:String = 'cheese/undertale/UT_box_'; //im lazy

		if (!ClientPrefs.downScroll) {
			whiteBox = new FlxSprite().loadGraphic(Paths.image(boxPath + 'upscroll'));
		} else {
			whiteBox = new FlxSprite().loadGraphic(Paths.image(boxPath + 'downscroll'));
		}
		if (curStage == 'undertale' && !ClientPrefs.comboShown && !ClientPrefs.fuckyouavi) //only adds box on undertale stage, fuckyouavi is for optimized mode
			add(whiteBox);

		if (ClientPrefs.specialEffects && curStage == 'frostedStage') {
			freezeFade = new FlxSprite().loadGraphic(Paths.image('effects/FROZEN_BITCH'));
			freezeFade.alpha = 0;
			add(freezeFade);

			redFade = new FlxSprite().loadGraphic(Paths.image('effects/RED_BITCH'));
			redFade.alpha = 0;
			add(redFade);
		}

		if (curSong.toLowerCase() == 'manager-strike-back') {
			strumLine = new FlxSprite(curSong.toLowerCase().startsWith('manager') ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		} else if (curSong.toLowerCase() == 'tutorial') {
			strumLine = new FlxSprite(curSong.toLowerCase().startsWith('tutorial') ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		} else {
			strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		}
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;

		timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(Paths.image('timeBar'));
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);

		/*versionshit = new FlxText(-495, healthBarBG.y + 61, FlxG.width, "", 20);
		versionshit.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionshit.scrollFactor.set();
		versionshit.borderSize = 1.25;
		versionshit.visible = !ClientPrefs.hideHud;
		add(versionshit);*/

		var song:String = curSong.toLowerCase();
		var songArtist:String;

		switch (song)
		{
			case 'manager-strike-back' | 'frosted':
				songArtist = 'Avinera';
			default:
				songArtist = 'Uniimations';
		}

		if (curSong.toLowerCase() == 'manager-strike-back') {
			versionShit = new FlxText(4,healthBarBG.y + 50, 0, songArtist + ' - ' + displaySongName, 16); //no text in manager strike back
			versionShit.setFormat(Paths.font("UNDERTALE.ttf"), 13, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		} else {
			versionShit = new FlxText(4,healthBarBG.y + 60,0, songArtist + ' - ' + displaySongName + ' [' + CoolUtil.difficultyStuff[storyDifficulty][0] + '] | VS Cheese v' + MainMenuState.cheeseVersion, 16);
			versionShit.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		}
		versionShit.scrollFactor.set();
		versionShit.borderSize = 1.25;
		versionShit.visible = !ClientPrefs.hideHud;
		add(versionShit);

		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		if (!curSong.toLowerCase().startsWith('manager')) {
			add(iconP1);
		}

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		if (!curSong.toLowerCase().startsWith('manager')) {
			add(iconP2);
		}
		reloadAllBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		if (curSong.toLowerCase() == 'manager-strike-back') {
			scoreTxt.setFormat(Paths.font("UNDERTALE.ttf"), 17, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		} else {
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		var undertaleString:String = 'vcr.ttf';
		var undertaleSize:Int = 16;

		if (curSong.toLowerCase() == 'manager-strike-back') {
			undertaleString = 'UNDERTALE.ttf';
			undertaleSize = 15;
		}

		infoTxt = new FlxText(0, FlxG.height/2-80, 0, "", 20);
		infoTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		infoTxt.scrollFactor.set();
		infoTxt.borderSize = 1.25;
		infoTxt.visible = !ClientPrefs.hideHud;

		shitsTxt = new FlxText(0, FlxG.height/2+20, 0, "", 20);
		shitsTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shitsTxt.scrollFactor.set();
		shitsTxt.borderSize = 1.25;
		shitsTxt.visible = !ClientPrefs.hideHud;

		badsTxt = new FlxText(0, FlxG.height/2, 0, "", 20);
		badsTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		badsTxt.scrollFactor.set();
		badsTxt.borderSize = 1.25;
		badsTxt.visible = !ClientPrefs.hideHud;

		goodsTxt = new FlxText(0, FlxG.height/2-20, 0, "", 20);
		goodsTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		goodsTxt.scrollFactor.set();
		goodsTxt.borderSize = 1.25;
		goodsTxt.visible = !ClientPrefs.hideHud;

		sicksTxt = new FlxText(0, FlxG.height/2-40, 0, "", 20);
		sicksTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		sicksTxt.scrollFactor.set();
		sicksTxt.borderSize = 1.25;
		sicksTxt.visible = !ClientPrefs.hideHud;

		perfectsTxt = new FlxText(0, FlxG.height/2-60, 0, "", 20);
		perfectsTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		perfectsTxt.scrollFactor.set();
		perfectsTxt.borderSize = 1.25;
		perfectsTxt.visible = !ClientPrefs.hideHud;

		missesTxt = new FlxText(0, FlxG.height/2+40, 0, "", 20);
		missesTxt.setFormat(Paths.font(undertaleString), undertaleSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		missesTxt.scrollFactor.set();
		missesTxt.borderSize = 1.25;
		missesTxt.visible = !ClientPrefs.hideHud;

		add(infoTxt);
		add(shitsTxt);
		add(badsTxt);
		add(goodsTxt);
		add(sicksTxt);
		add(perfectsTxt);
		add(missesTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		blackscreenhud.cameras = [camHUD];
		whiteBox.cameras = [camHUD];
		if (ClientPrefs.specialEffects && curStage == 'frostedStage') {
			freezeFade.cameras = [camHUD];
			redFade.cameras = [camHUD];
		}
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		versionShit.cameras = [camHUD];
		infoTxt.cameras = [camHUD];
		shitsTxt.cameras = [camHUD];
		badsTxt.cameras = [camHUD];
		goodsTxt.cameras = [camHUD];
		sicksTxt.cameras = [camHUD];
		perfectsTxt.cameras = [camHUD];
		missesTxt.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		startingSong = true;
		updateTime = true;

		#if MODS_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'data/' + PlayState.SONG.song.toLowerCase() + '/script.lua';
		if(sys.FileSystem.exists(Paths.mods(luaFile))) {
			luaFile = Paths.mods(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(sys.FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		//STORY CUTSCENE CODE!!!
		var Sng:String = curSong.toLowerCase();
		if (isStoryMode && !seenCutscene)
		{
			switch (Sng)
			{
				case 'tutorial' | 'manager-strike-back':
					startIntro(); // no countdown
				case 'restaurante' | 'milkshake' | 'cultured':
					assEat(doof); // dialogue box
				case 'wifi':
					addwebmIntro('wifi/wifi'); // webm cutscene if mac
				default:
					startCountdown(); // normal countdown
			}
			seenCutscene = true;
		}
		else //FREEPLAY CUTSCENE CODE!!!
		{
			switch (Sng)
			{
				case 'tutorial' | 'manager-strike-back' | 'frosted':
					startIntro();
				default:
					startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
		super.create();
	}

	public function reloadAllBarColors() {
		var percentColor:Int;
		var baseColor:Int = 0xFF2C3149;//FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		var songLC:String = curSong.toLowerCase();
		if (!songLC.startsWith('restaurante') && !songLC.startsWith('milkshake') && !songLC.startsWith('cultured')) {
			percentColor = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
		} else {
			percentColor = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		}

		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		timeBar.createFilledBar(baseColor, percentColor);

		healthBar.updateBar();
		timeBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(BF_X, BF_Y, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(DAD_X, DAD_Y, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(GF_X, GF_Y, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var dialogueCount:Int = 0;

	//dialogueintro doesnt actually work i just put useless stuff here so lua doesnt fuck up
	public function dialogueIntro(dialogue:Array<String>, ?song:String = null):Void
	{
		inCutscene = true;
		CoolUtil.precacheSound('dialogue/clickText');
		CoolUtil.precacheSound('dialogue/bluecheeseText');
		CoolUtil.precacheSound('dialogue/boyfriendText');
		CoolUtil.precacheSound('dialogue/gfText');
		CoolUtil.precacheSound('dialogue/suzukiText');

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			{
				startCountdown();
			}
		});
	}

	//made a new function since schoolIntro's kinda weird bro ngl
	//i also dont like the psych dialogueIntro stuff so BACK TO THE OG'S BOYS

	//no offense to shadowmario i love how it works i just dont like how it looks.
	function assEat(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		//SOUND LOADING CODE
		//this was an attempt to fix the not responding bug but i couldnt fix it :skull:
		CoolUtil.precacheSound('dialogue/clickText');
		CoolUtil.precacheSound('dialogue/bluecheeseText');
		CoolUtil.precacheSound('dialogue/boyfriendText');
		CoolUtil.precacheSound('dialogue/gfText');
		CoolUtil.precacheSound('dialogue/suzukiText');

		//does this FlxTimer even do anything??
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			{
				if (dialogueBox != null)
				{
					add(dialogueBox);
				}
				else
					startCountdown();
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;
	var perfectMode:Bool = false;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			return;
		}

		noCountdown = false;
		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		var rank:Dynamic = callOnLuas('onStartCountdown', []);
		var songLowercase:String = curSong.toLowerCase();
		if(ret != FunkinLua.Function_Stop && rank != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll || songLowercase == 'manager-strike-back' || songLowercase == 'tutorial') opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0)
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (!boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.specialAnim)
					{
						boyfriend.dance();
					}
					if (!dad.animation.curAnim.name.startsWith('sing') && !dad.specialAnim)
					{
						dad.dance();
					}
					if (!littleMan.animation.curAnim.name.startsWith('sing'))
					{
						littleMan.dance();
					}
				}
				else if(dad.danceIdle && !dad.specialAnim && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				switch(curStage) {
					case 'restaurante' | 'restauranteDefault':
						if(!ClientPrefs.fuckyouavi) {
							boppers.dance(true);
							frontBoppers.dance(true);
							if (curStage == 'restaurante') {
								counter.dance(true);
								phillyCounter.dance(true);
							}
						}
					case 'restauranteArsen' | 'restauranteDansilot':
						if(!ClientPrefs.fuckyouavi) {
							stickmin.dance(true);
							joey.dance(true);
							crystal.dance(true);
							ralsei.dance(true);
						    counter.dance(true);
							frontBoppers.dance(true);
						}
					case 'frostedStage':
						if (!ClientPrefs.fuckyouavi) {
							counter.dance(true);
							frontBoppers.dance(true);
							dansilot.dance(true);
						}
				}

				switch (swagCounter)
				{
					case 0:
						introThree();
					case 1:
						introTwo();
					case 2:
						introOne();
					case 3:
						introGo();
					case 4:
				}
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function startIntro():Void
		{
			if(startedCountdown) {
				return;
			}

			noCountdown = true;
			inCutscene = false;
			var ret:Dynamic = callOnLuas('onStartCountdown', []);
			var rank:Dynamic = callOnLuas('onStartCountdown', []);
			var songLowercase:String = curSong.toLowerCase();
			if(ret != FunkinLua.Function_Stop && rank != FunkinLua.Function_Stop) {
				generateStaticArrows(0);
				generateStaticArrows(1);
				for (i in 0...playerStrums.length) {
					setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
					setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				}
				for (i in 0...opponentStrums.length) {
					setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
					if(ClientPrefs.middleScroll || songLowercase == 'manager-strike-back' || songLowercase == 'tutorial') opponentStrums.members[i].visible = false;
				}

				startedCountdown = true;
				Conductor.songPosition = 0;

				startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					if (generatedMusic)
					{
						notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
					}
				}, 5);
			}
		}

	public function addwebmIntro(songPath:String)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			#if !windows
			cutsceneShit = true;
			if (cutsceneShit) {
				var file:String = Paths.json('assets/videos/webm/' + '.webm');
				#if sys
				if (sys.FileSystem.exists(file))
				#else
				if (OpenFlAssets.exists(file))
				#end
				{
					LoadingState.loadAndSwitchState(new VideoState('assets/videos/webm' + songPath + '/' + songPath + '.webm', new PlayState()));
					trace('loaded' + file);
				}
				else
				{
					LoadingState.loadAndSwitchState(new VideoState('assets/videos/webm/ass.webm', new PlayState())); //loads bob and bosip test cutscene if there is no cutscene path
					trace('error: cutscene path not found');
					trace('loaded assets/videos/webm/ass.webm');
				}
				cutsceneShit = false;
			} else {
				camHUD.visible = true;
				camGame.visible = true;
				startCountdown();
			}
			#else
			startCountdown();
			#end
		}

	public function addMP4Outro(songName:String, videoName:String)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			#if windows
			hasMP4 = true;
			var video:VideoMP4State = new VideoMP4State();

			if (curSong.toLowerCase() == songName)
				video.playMP4(Paths.video('mp4/' + videoName + '/' + videoName));
				video.finishCallback = function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
					hasMP4 = false;
				}
			#else
			//do nothing
			#end
		}

	public function videoOutro(songName:String, videoName:String)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			#if windows
			var video:VideoMP4State = new VideoMP4State();

			if (curSong.toLowerCase() == songName) 
				video.playMP4(Paths.video('mp4/' + videoName + '/' + videoName));
				video.finishCallback = function()
				{
					LoadingState.loadAndSwitchState(new StoryMenuState());
				}
			#else
			var file:String = Paths.json('assets/videos/webm' + videoName + '/' + videoName + '.webm');
				#if sys
				if (sys.FileSystem.exists(file))
				#else
				if (OpenFlAssets.exists(file))
				#end
				{
					LoadingState.loadAndSwitchState(new VideoState('assets/videos/webm' + videoName + '/' + videoName + '.webm', new StoryMenuState()));
					trace('loaded' + file);
				}
			#end
		}

	function introThree():Void
		{
			var countdown:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdown3'));
			countdown.scrollFactor.set();
			countdown.updateHitbox();
			countdown.screenCenter();
			countdown.antialiasing = ClientPrefs.globalAntialiasing;
			add(countdown);
			FlxTween.tween(countdown, {y: countdown.y += 100, alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					countdown.destroy();
				}
			});

			if (noCountdown == false) {
				FlxG.sound.play(Paths.sound('intro3'), 0.8);
			}
		}
	function introTwo():Void
		{
			var countdown:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdown2'));
			countdown.scrollFactor.set();
			countdown.updateHitbox();
			countdown.screenCenter();
			countdown.antialiasing = ClientPrefs.globalAntialiasing;
			add(countdown);
			FlxTween.tween(countdown, {y: countdown.y += 100, alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					countdown.destroy();
				}
			});
			if (noCountdown == false) {
				FlxG.sound.play(Paths.sound('intro2'), 0.8);
			}
		}

	function introOne():Void
		{
			var countdown:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdown1'));
			countdown.scrollFactor.set();
			countdown.updateHitbox();
			countdown.screenCenter();
			countdown.antialiasing = ClientPrefs.globalAntialiasing;
			add(countdown);
			FlxTween.tween(countdown, {y: countdown.y += 100, alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					countdown.destroy();
				}
			});
			if (noCountdown == false) {
				FlxG.sound.play(Paths.sound('intro1'), 0.8);
			}
		}

	function introGo():Void
		{
			var countdown:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdownGoTrans'));
			countdown.scrollFactor.set();
			countdown.updateHitbox();
			countdown.screenCenter();
			countdown.antialiasing = ClientPrefs.globalAntialiasing;
			add(countdown);
			FlxTween.tween(countdown, {y: countdown.y += 100, alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					countdown.destroy();
				}
			});
			if (noCountdown == false) {
				FlxG.sound.play(Paths.sound('introGo'), 0.8);
			}
		}

	function doFlash():Void
		{
			var flashValue:Int = 1;
			if (ClientPrefs.flashing)
				FlxG.camera.flash(FlxColor.WHITE, flashValue);
			else
				FlxG.camera.flash(FlxColor.BLACK, flashValue);
		}

	function startNextDialogue()
	{
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (CoolUtil.difficultyString() == 'EX') {
			FlxG.sound.playMusic(Paths.instex(PlayState.SONG.song), 1, false);
		} else {
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		if (!curSong.toLowerCase().startsWith('manager') && !curSong.toLowerCase().startsWith('frosted')) {
			FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices) {
			if (CoolUtil.difficultyString() == 'EX') {
				vocals = new FlxSound().loadEmbedded(Paths.voicesex(PlayState.SONG.song));
			} else {
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			}
		} else {
			vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = SONG.song.toLowerCase();
		var file:String;
		if (CoolUtil.difficultyString() == 'EX') {
			file = Paths.json(songName + '/eventsex');
		} else {
			file = Paths.json(songName + "/events");
		}
		#if sys
		if (sys.FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
		//SEX DIFFICULTY!
			var eventsData:Array<SwagSection>;
			if (CoolUtil.difficultyString() == 'EX') {
				eventsData = Song.loadFromJson('eventsex', songName).notes;
			} else {
				eventsData = Song.loadFromJson('events', songName).notes;
			}
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push(songNotes);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					swagNote.mustPress = gottaHitNote;

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}
				} else { //Event Notes
					eventNotes.push(songNotes);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}

		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = Std.parseInt(event[3]);
				if(Math.isNaN(charType)) charType = 0;

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			if (curSong.toLowerCase() == 'manager-strike-back')
				babyArrow = new StrumNote(curSong.toLowerCase().startsWith('manager') ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i);
			else if (curSong.toLowerCase() == 'tutorial')
				babyArrow = new StrumNote(curSong.toLowerCase().startsWith('tutorial') ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i);
			else 
				babyArrow = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/NOTE_assets'));
					babyArrow.width = babyArrow.width / 4;
					babyArrow.height = babyArrow.height / 5;
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/NOTE_assets'), true, Math.floor(babyArrow.width), Math.floor(babyArrow.height));
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				//IS BF BECAUSE NOTE SKINS DON'T WORK YET!!!
				//if there is a skin that doesn't exist it should default to "NOTES_ALT" or "NOTE_assets"
				default:
					var skin:String = 'NOTE_assets';
					if(SONG.arrowSkin != null && SONG.arrowSkin.length > 1) skin = SONG.arrowSkin;

					babyArrow.frames = Paths.getSparrowAtlas(skin);
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = ClientPrefs.globalAntialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			if(phillyBlackTween != null)
				phillyBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			if(phillyBlackTween != null)
				phillyBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;

			playerStrums.forEach(function(spr:StrumNote)
				{
					spr.playAnim('static');
					spr.resetAnim = 0;
				});

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}
		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			iconP1.sussyTime();
		}

		if (FlxG.keys.justPressed.F9)
		{
			iconP1.sussyTime();
		}

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									}
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed); //TEST

		//ALL DEFAULT HIT TIMING TEXT
		infoTxt.text = 'Note Hits:';
		shitsTxt.text = 'Shit: ' + shits;
		badsTxt.text = 'Bad: ' + bads;
		goodsTxt.text = 'Good: ' + goods;
		sicksTxt.text = 'Sick: ' + sicks;
		perfectsTxt.text = 'Perfect: ' + perfects;
		missesTxt.text = 'Misses: ' + songMisses;

		switch (curSong.toLowerCase())
		{
			case 'manager-strike-back':
				if(ratingString == '?') {
					scoreTxt.text = "BF   LVL 19   Score: " + songScore + "   Accuracy: 0" + "%   Deaths: " + deathCounter;
				} else {
					scoreTxt.text = "BF   LVL 19   Score: " + songScore + "   Accuracy: " + Math.floor(ratingPercent * 100) + "%   Deaths: " + deathCounter;
				}
			case 'frosted':
				if(ratingString == '?') {
					scoreTxt.text = "Score: " + songScore + " | Accuracy: 0" + "% | (N/A) | Deaths: " + deathCounter;
				} else {
					scoreTxt.text = "Score: " + songScore + " | Accuracy: " + Math.floor(ratingPercent * 100) + "% | (" + rankString + ") | Deaths: " + deathCounter;
				}
			default:
				if(ratingString == '?') {
					scoreTxt.text = "Score: " + songScore + " | Accuracy: 0" + "% | U rappin': " + ratingString + " | (N/A)";
				} else {
					scoreTxt.text = "Score: " + songScore + " | Accuracy: " + Math.floor(ratingPercent * 100) + "% | U rappin': " + ratingString + " | (" + rankString + ")";
				}
		}

		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			var rank:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop && rank != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		// BF ICON CODE!!!
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else if (healthBar.percent > 80)
			iconP1.animation.curAnim.curFrame = 2;
		else
			iconP1.animation.curAnim.curFrame = 0;

		// DAD ICON CODE!!!
		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else if (healthBar.percent < 20)
			iconP2.animation.curAnim.curFrame = 2;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;
					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
					timeTxt.text = minutesRemaining + ':' + secondsRemaining;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// GAME OVER STUFF!!!

		// NORMAL GAME OVER
		if (health <= 0)
		{
			gameOver();
		}

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong && ClientPrefs.resetDeath)
		{
			gameOver();
			trace("RESET = True");
		}

		// FROSTED MECHANIC
		if (curSong.toLowerCase() == 'frosted')
		{
			if (songMisses > 9)
			{
				gameOver();
				trace('frosted brittle death');
			}
		}

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			var songLowercase:String = curSong.toLowerCase();
			notes.forEachAlive(function(daNote:Note)
			{
				//THIS TOOK FOREVER FOR ME TO REALIZE HOW TO CODE HOLY SHIT I AM SO SMART!!! (dumb)
				switch songLowercase
				{
					case 'manager-strike-back' | 'tutorial': // middle invis notes scroll lock
						if(!daNote.mustPress)
							{
								daNote.active = true;
								daNote.visible = false;
							}
						else if (daNote.y > FlxG.height)
							{
								daNote.active = false;
								daNote.visible = false;
							}
						else
							{
								daNote.visible = true;
								daNote.active = true;
							}
					case 'cultured':
						if (CoolUtil.difficultyString() == 'EX') { // i feel like yanderedev :(
							if (curBeat < 4) {
								if(!daNote.mustPress)
									{
										daNote.active = true;
										daNote.visible = false;
									}
								else if (daNote.y > FlxG.height)
									{
										daNote.active = false;
										daNote.visible = false;
									}
								else
									{
										daNote.visible = true;
										daNote.active = true;
									}
							}
							if (curBeat > 4) {
								if(!daNote.mustPress && ClientPrefs.middleScroll)
									{
										daNote.active = true;
										daNote.visible = false;
									}
								else if (daNote.y > FlxG.height)
									{
										daNote.active = false;
										daNote.visible = false;
									}
								else
									{
										daNote.visible = true;
										daNote.active = true;
									}
							}
						} else { // IF NOT EX DIFFICULTY USES DEFAULT NOTE CODE
							if(!daNote.mustPress && ClientPrefs.middleScroll)
								{
									daNote.active = true;
									daNote.visible = false;
								}
							else if (daNote.y > FlxG.height)
								{
									daNote.active = false;
									daNote.visible = false;
								}
							else
								{
									daNote.visible = true;
									daNote.active = true;
								}
						}
					default:
						if(!daNote.mustPress && ClientPrefs.middleScroll)
							{
								daNote.active = true;
								daNote.visible = false;
							}
						else if (daNote.y > FlxG.height)
							{
								daNote.active = false;
								daNote.visible = false;
							}
						else
							{
								daNote.visible = true;
								daNote.active = true;
							}
				}

				// i am so fucking sorry for this if condition
				var strumY:Float = 0;
				if(daNote.mustPress) {
					strumY = playerStrums.members[daNote.noteData].y;
				} else {
					strumY = opponentStrums.members[daNote.noteData].y;
				}
				var center:Float = strumY + Note.swagWidth / 2;

				if (ClientPrefs.downScroll) {
					daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
					if (daNote.isSustainNote) {
						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
							if(curStage == 'school' || curStage == 'schoolEvil') {
								daNote.y += 8;
							}
						} 
						daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				camZooming = true;

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.ignoreNote)
				{
					var isAlt:Bool = false;

					if(daNote.noteType == 2 && dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					} else {
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 1) {
								altAnim = '-alt';
								isAlt = true;
							}
						}

						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
								if (dadPog) {
									dadnoteMovementXoffset = -30;
								    dadnoteMovementYoffset = 0;
								}
							case 1:
								animToPlay = 'singDOWN';
								if (dadPog) {
									dadnoteMovementYoffset = 30;
									dadnoteMovementXoffset = 0;
								}
							case 2:
								animToPlay = 'singUP';
								if (dadPog) {
									dadnoteMovementYoffset = -30;
									dadnoteMovementXoffset = 0;
								}
							case 3:
								animToPlay = 'singRIGHT';
								if (dadPog) {
									dadnoteMovementXoffset = 30;
									dadnoteMovementYoffset = 0;
								}
						}
						if (isLittleMan)
						{
							littleMan.playAnim(animToPlay + altAnim, true);
						}
						if (isGF)
							gf.playAnim(animToPlay + altAnim, true);
						else if (isDad)
							dad.playAnim(animToPlay + altAnim, true);
						else
							dad.playAnim(animToPlay + altAnim, true);
							dad.holdTimer = 0;
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					if (!curSong.toLowerCase().startsWith('cultured')) {
						StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					} else {
						if (curBeat > 4) {
							StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
						}
					}
					daNote.ignoreNote = true;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							if(!endingSong) {
								//Dupe note remove
								notes.forEachAlive(function(note:Note) {
									if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
										note.kill();
										notes.remove(note, true);
										note.destroy();
									}
								});

								switch(daNote.noteType) {
									case 3: //DODGE NOTE MECHANIC DEATH
										if (!endingSong)
											{
												//health = -100; //Made it so this kills you no matter what
												gameOver();
												trace("DODGE NOTE MECHANIC DEATH");
												FlxG.log.add('dead');
											}
								    case 4: 
										//nothing
									default:
										health -= 0.0475;
										songMisses++;
										if (ClientPrefs.missSounds) {
											vocals.volume = 0;
										}
										RecalculateRating();

										if (ClientPrefs.ghostTapping) {
											switch (daNote.noteData % 4)
											{
												case 0:
													boyfriend.playAnim('singLEFTmiss', true);
												case 1:
													boyfriend.playAnim('singDOWNmiss', true);
												case 2:
													boyfriend.playAnim('singUPmiss', true);
												case 3:
													boyfriend.playAnim('singRIGHTmiss', true);
											}
										}

										if (ClientPrefs.specialEffects && curStage == 'frostedStage' && songMisses > 7)
										{
											if (freezeFade.alpha != 1)
												freezeFadeTween(redFade, 1, 2);
										}
										callOnLuas('noteMiss', [daNote.noteData, daNote.noteType]);
								}
							}
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}


		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}

		if (TitleState.isDebug)
		{
			if(!endingSong && !startingSong)
			{
				if (FlxG.keys.justPressed.ONE)
					FlxG.sound.music.onComplete();
				if(FlxG.keys.justPressed.TWO)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					Conductor.songPosition += 10000;
					notes.forEachAlive(function(daNote:Note)
					{
						if(daNote.strumTime + 800 < Conductor.songPosition)
						{
							daNote.active = false;
							daNote.visible = false;
	
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
					for (i in 0...unspawnNotes.length){
						var daNote:Note = unspawnNotes[0];
						if(daNote.strumTime + 800 >= Conductor.songPosition) {
							break;
						}
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
						daNote.destroy();
					}
	
					FlxG.sound.music.time = Conductor.songPosition;
					FlxG.sound.music.play();

					vocals.time = Conductor.songPosition;
					vocals.play();
				}
			}

			if (FlxG.keys.justPressed.F7 && !endingSong || FlxG.keys.justPressed.SEVEN && !endingSong)
			{
				persistentUpdate = false;
				paused = true;
				MusicBeatState.switchState(new ChartingState());

				#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
			}

			if (FlxG.keys.justPressed.F8 || FlxG.keys.justPressed.EIGHT)
			{
				persistentUpdate = false;
				paused = true;
				MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
			}
		}
		else
		{
			if (FlxG.keys.justPressed.EIGHT || FlxG.keys.justPressed.SEVEN && !endingSong)
			{
				loadSong(true, 'Anti-Cheat');
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String, ?onLua:Bool = false) {
		if (!ClientPrefs.fuckyouavi)
		{
			switch(eventName)
			{
				case 'Hey!':
					var value:Int = Std.parseInt(value1);
					var time:Float = Std.parseFloat(value2);
					if(Math.isNaN(time) || time <= 0) time = 0.6;
	
					if(value != 0) {
						if (dad.curCharacter.startsWith('gf')) {
							dad.playAnim('cheer', true);
							dad.specialAnim = true;
							dad.heyTimer = time;
						} else {
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = time;
						}

						if(curStage == 'mall') {
							bottomBoppers.animation.play('hey', true);
							heyTimer = time;
						}
					}
					if(value != 1) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					}

				case 'Set GF Speed':
					var value:Int = Std.parseInt(value1);
					if(Math.isNaN(value)) value = 1;
					gfSpeed = value;

				case 'Poggers Lights':
					if(ClientPrefs.specialEffects && curStage == 'restaurante' && CoolUtil.difficultyString() == 'EX') {
						var lightId:Int = Std.parseInt(value1);
						if(Math.isNaN(lightId)) lightId = 0;
	
						if(lightId > 0 && curLightEvent != lightId) {
							if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);
	
							var color:Int = 0xffffffff;
							switch(lightId) {
								case 1: //Blue
									color = 0xff31a2fd;
								case 2: //Green
									color = 0xff31fd8c;
								case 3: //Pink
									color = 0xfff794f7;
								case 4: //Red
									color = 0xfff96d63;
								case 5: //Orange
									color = 0xfffba633;
							}
							curLightEvent = lightId;
	
							if(phillyBlack.alpha != 1) {
								if(phillyBlackTween != null) {
									phillyBlackTween.cancel();
								}
								phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
								phillyBlackTween = FlxTween.tween(phillyCounter, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
								phillyBlackTween = FlxTween.tween(frontBoppers, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
	
								var chars:Array<Character> = [boyfriend, gf, dad];
								for (i in 0...chars.length) {
									if(chars[i].colorTween != null) {
										chars[i].colorTween.cancel();
									}
									chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
										chars[i].colorTween = null;
									}, ease: FlxEase.quadInOut});
								}
							} else {
								dad.color = color;
								boyfriend.color = color;
								gf.color = color;
							}

						} else {
							if(phillyBlack.alpha != 0) {
								if(phillyBlackTween != null) {
									phillyBlackTween.cancel();
								}
								phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
								phillyBlackTween = FlxTween.tween(phillyCounter, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
								phillyBlackTween = FlxTween.tween(frontBoppers, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
							}

							var chars:Array<Character> = [boyfriend, gf, dad];
							for (i in 0...chars.length) {
								if(chars[i].colorTween != null) {
									chars[i].colorTween.cancel();
								}
								chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
									chars[i].colorTween = null;
								}, ease: FlxEase.quadInOut});
							}
	
							curLight = 0;
							curLightEvent = 0;
						}
					}
				case 'Poggers Fade':
					var pogging:Int = Std.parseInt(value1);
					var poggerLength:Float = Std.parseFloat(value2);

					switch (curStage)
					{
						case 'undertale': // black fade
							switch (pogging)
							{
								case 0:
									phillyBlackTween = FlxTween.tween(phillyFade, {alpha: 1}, poggerLength, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
								case 1:
									phillyBlackTween = FlxTween.tween(phillyFade, {alpha: 0}, poggerLength, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
							}

						case 'frostedStage': // freeze fade
							if (ClientPrefs.specialEffects)
							{
								switch (pogging)
								{
									case 0:
										doFlash();
										freezePogging = true;
										snow.visible = true;
		
										freezeFadeTween(scoreTxt, 0, poggerLength);
										freezeFadeTween(healthBar, 0, poggerLength);
										freezeFadeTween(healthBarBG, 0, poggerLength);
										freezeFadeTween(iconP1, 0, poggerLength);
										freezeFadeTween(iconP2, 0, poggerLength);
		
										if (redFade.alpha != 1)
											freezeFadeTween(freezeFade, 1, poggerLength);
									case 1:
										doFlash();
										freezePogging = false;
										snow.visible = false;
		
										freezeFadeTween(scoreTxt, 1, poggerLength);
										freezeFadeTween(healthBar, 1, poggerLength);
										freezeFadeTween(healthBarBG, 1, poggerLength);
										freezeFadeTween(iconP1, 1, poggerLength);
										freezeFadeTween(iconP2, 1, poggerLength);
		
										if (freezeFade.alpha != 0)
											freezeFadeTween(freezeFade, 0, poggerLength);
										if (songMisses > 7)
										{
											if (redFade.alpha != 1)
												freezeFadeTween(redFade, 1, 2);
										}
									case 2:
										if (freezePogging == true)
											freezePogging = false;
										freezeFadeTween(scoreTxt, 0, poggerLength);
										freezeFadeTween(healthBar, 0, poggerLength);
										freezeFadeTween(healthBarBG, 0, poggerLength);
										freezeFadeTween(iconP1, 0, poggerLength);
										freezeFadeTween(iconP2, 0, poggerLength);
		
										if (redFade.alpha != 1)
											freezeFadeTween(freezeFade, 1, poggerLength);
									case 3:
										if (freezePogging == true)
											freezePogging = false;
										freezeFadeTween(scoreTxt, 1, poggerLength);
										freezeFadeTween(healthBar, 1, poggerLength);
										freezeFadeTween(healthBarBG, 1, poggerLength);
										freezeFadeTween(iconP1, 1, poggerLength);
										freezeFadeTween(iconP2, 1, poggerLength);
		
										if (freezeFade.alpha != 0)
											freezeFadeTween(freezeFade, 0, poggerLength);
										if (songMisses > 7)
										{
											if (redFade.alpha != 1)
												freezeFadeTween(redFade, 1, 2);
										}
								}
							}
					}

				case 'Kill Henchmen':
					killHenchmen();

				case 'Add Camera Zoom':
					if(FlxG.camera.zoom < 1.35) {
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = 0.015;
						if(Math.isNaN(hudZoom)) hudZoom = 0.03;
	
						FlxG.camera.zoom += camZoom;
						camHUD.zoom += hudZoom;
					}

				case 'Trigger BG Ghouls':
					if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
						bgGhouls.dance(true);
						bgGhouls.visible = true;
					}

				case 'Play Animation':
					trace('Anim to play: ' + value1);
					var val2:Int = Std.parseInt(value2);
					if(Math.isNaN(val2)) val2 = 0;
	
					var char:Character = dad;
					switch(val2) {
						case 1: char = boyfriend;
						case 2: char = gf;
					}
					char.playAnim(value1, true);
					char.specialAnim = true;

				case 'Camera Follow Pos':
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;
	
					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}

				case 'Set CamPog':
					if (ClientPrefs.cameraShake)
					{
						var pogging:Int = Std.parseInt(value1);

						if(Math.isNaN(pogging))
							pogging = 0;

						switch(pogging) {
							case 0:
								boyfriendPog = false;
								dadPog = false;
							case 1:
								dadPog = true;
							case 2:
								boyfriendPog = true;
						}
					}

				case 'Alt Idle Animation':
					var val:Int = Std.parseInt(value1);
					if(Math.isNaN(val)) val = 0;
	
					var char:Character = dad;
					switch(val) {
						case 1: char = boyfriend;
						case 2: char = gf;
						case 3: char = littleMan; //for cultured ex sit
					}
					char.idleSuffix = value2;
					char.recalculateDanceIdle();

				case 'Screen Shake':
					var valuesArray:Array<String> = [value1, value2];
					var targetsArray:Array<FlxCamera> = [camGame, camHUD];
					for (i in 0...targetsArray.length) {
						var split:Array<String> = valuesArray[i].split(',');
						var duration:Float = Std.parseFloat(split[0].trim());
						var intensity:Float = Std.parseFloat(split[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;
	
						if(duration > 0 && intensity != 0) {
							targetsArray[i].shake(intensity, duration);
						}
					}

				case 'Change CamZoom': //this was the worst way to do this im so sorry
					if (ClientPrefs.camZoomOut)
					{
						var camZoomValue:Int = Std.parseInt(value1);
						if(Math.isNaN(camZoomValue)) camZoomValue = 0;

						switch (camZoomValue)
						{
							case 0: //reset camera zoom
								if (curStage.startsWith('restaurante')) {
									defaultCamZoom = 0.60;
								}
							case 1:
								defaultCamZoom = 0.1;
							case 2:
								defaultCamZoom = 0.2;
							case 3:
								defaultCamZoom = 0.3;
							case 4:
								defaultCamZoom = 0.4;
							case 5:
								defaultCamZoom = 0.5;
							case 6:
								defaultCamZoom = 0.6;
							case 7:
								defaultCamZoom = 0.7;
							case 8:
								defaultCamZoom = 0.8;
							case 9:
								defaultCamZoom = 0.9;
						}
					}

				case 'Flash':
					var flashValue:Int = Std.parseInt(value1);

					// dear past me... IS THAT SUPPOSED TO BE AN IF ELSE STATEMENT????

					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, flashValue);
					else
						if (!curSong.toLowerCase().startsWith('manager'))
							FlxG.camera.flash(FlxColor.BLACK, flashValue);

				case 'Flash Color':
					var flashSprite:FlxSprite;
					var flashColor:Int = Std.parseInt(value1);
	
					switch (flashColor)
					{
						case 0:
							flashColor = 0xFFFF5277;
						case 1:
							flashColor = 0xFF49F792;
						case 2:
							flashColor = 0xFF3F71FF;
						case 3:
							flashColor = 0xFFC45EFF;
						case 4:
							flashColor = FlxColor.WHITE;
					}

					flashSprite = new FlxSprite(-430, -250).makeGraphic(Std.int(FlxG.width * 7), Std.int(FlxG.height * 7), flashColor);
					flashSprite.scrollFactor.set();
					flashSprite.alpha = 0.3;
					add(flashSprite);

					FlxTween.tween(flashSprite, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});

				case 'Change Character':
					var charType:Int = Std.parseInt(value1);
					if(Math.isNaN(charType)) charType = 0;

					switch(charType) {
						case 0:
							if(boyfriend.curCharacter != value2) {
									if(!boyfriendMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
	
									boyfriend.visible = false;
									boyfriend = boyfriendMap.get(value2);
									if(!boyfriend.alreadyLoaded) {
										boyfriend.alpha = 1;
										boyfriend.alreadyLoaded = true;
									}
									boyfriend.visible = true;
									iconP1.changeIcon(boyfriend.healthIcon);
							}

						case 1:
							if(dad.curCharacter != value2) {
									if(!dadMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
	
									var wasGf:Bool = dad.curCharacter.startsWith('gf');
									dad.visible = false;
									dad = dadMap.get(value2);
									if(!dad.curCharacter.startsWith('gf')) {
										if(wasGf) {
											gf.visible = true;
										}
									} else {
										gf.visible = false;
									}
									if(!dad.alreadyLoaded) {
										dad.alpha = 1;
										dad.alreadyLoaded = true;
									}
									dad.visible = true;
									iconP2.changeIcon(dad.healthIcon);
									if (CoolUtil.difficultyString() == 'EX' && curSong.toLowerCase() == 'cultured') {
										doFlash();
									}
							}

						case 2:
							if(gf.curCharacter != value2) {
									if(!gfMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
	
									gf.visible = false;
									gf = gfMap.get(value2);
									if(!gf.alreadyLoaded) {
										gf.alpha = 1;
										gf.alreadyLoaded = true;
									}
							}
					}
					reloadAllBarColors();

				case 'Summon Lil Man':
					var littleBool:Int = Std.parseInt(value1);
					var flashOn:Int = Std.parseInt(value2);
	
					if(Math.isNaN(littleBool))
						littleBool = 0;
					if(Math.isNaN(littleBool))
						littleBool = 0;
	
					switch(littleBool) {
						case 0: //SUMMON!!!
							littleMan.visible = true;
						case 1: //KILL.
							littleMan.visible = false;
					}

					switch(flashOn) {
						case 0:
							//default does nothing
						case 1:
							if (ClientPrefs.flashing)
								FlxG.camera.flash(FlxColor.WHITE, 1);
							else
								FlxG.camera.flash(FlxColor.BLACK, 1);
						case 2:
							if (ClientPrefs.flashing)
								FlxG.camera.flash(FlxColor.WHITE, 2);
							else
								FlxG.camera.flash(FlxColor.BLACK, 2);
					}

				case 'Opponent Anim': //this is really dumb DONT LOOK AT THIS!!!
					var activeChar:Int = Std.parseInt(value1);
					var littleSection:Int = Std.parseInt(value2);
	
					if(Math.isNaN(activeChar))
						activeChar = 0;
					if(Math.isNaN(littleSection))
						littleSection = 0;
	
					switch(activeChar) {
						case 0: //DEFAULT
							isDad = false;
							isLittleMan = false;
							isGF = false;
						case 1: //DAD
							isDad = true;
							isLittleMan = false;
							isGF = false;
							if (littleMan.visible == true)
								littleMan.dance();
						case 2: //LITTLE MAN
							isDad = false;
							isLittleMan = true;
							isGF = false;
							dad.dance();
						case 3: //GF
							isDad = false;
							isLittleMan = false;
							isGF = true;
							dad.dance();
							if (littleMan.visible == true)
								littleMan.dance();
					}
					switch (littleSection) {
						case 0:
							isCameraOnForcedPos = false;
						case 1:
							camFollow.set(littleMan.getMidpoint().x + 150, littleMan.getMidpoint().y - 100);
							camFollow.x += 0;
							camFollow.y += 200;
							isCameraOnForcedPos = true;
					}
			}
			if(!onLua) {
				callOnLuas('onEvent', [eventName, value1, value2]);
			}
		}
	}

	function moveCameraSection(?id:Int = 0):Void {
		if (SONG.notes[id] != null && camFollow.x != dad.getMidpoint().x + 150 && !SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}

		if (SONG.notes[id] != null && SONG.notes[id].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	public function moveCamera(isDad:Bool) {
		if(isDad) {
			if (dad.curCharacter.startsWith('undertale')) {
				camFollow.set(dad.getMidpoint().x + 150 + dadnoteMovementXoffset + bfnoteMovementXoffset, dad.getMidpoint().y - 100 + dadnoteMovementYoffset + bfnoteMovementYoffset);
			} else {
				camFollow.set(dad.getMidpoint().x + 150 + dadnoteMovementXoffset, dad.getMidpoint().y - 100 + dadnoteMovementYoffset);
			}
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
		} else {
			camFollow.set(boyfriend.getMidpoint().x - 100 + bfnoteMovementXoffset, boyfriend.getMidpoint().y - 100 + bfnoteMovementYoffset);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	var transitioning = false;
	function endSong():Void
	{
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		KillNotes();

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:Int = checkForAchievement([1, 2, 3, 4]);
			if(achieve > -1) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		callOnLuas('onEndSong', []);
		if (SONG.validScore)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
		}

		if (isStoryMode) // EXITING TO STORY MODE
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				exitSong();
			}
			else // LOADING NEXT SONG
			{
				loadSong();
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			usedPractice = false;
			changedDifficulty = false;
			cpuControlled = false;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	private function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "perfect";

		if (noteDiff > Conductor.safeZoneOffset * CoolUtil.timingWindows[0])
		{
			daRating = 'shit';
			score = 50;
			shits++;
		}

		else if (noteDiff > Conductor.safeZoneOffset * CoolUtil.timingWindows[1])
		{
			daRating = 'bad';
			score = 100;
			bads++;
		}

		else if (noteDiff > Conductor.safeZoneOffset * CoolUtil.timingWindows[2])
		{
			daRating = 'good';
			score = 200;
			goods++;
		}

		else if (noteDiff > Conductor.safeZoneOffset * CoolUtil.timingWindows[3])
		{
			daRating = 'sick';
			sicks++;
		}

		if(daRating == 'perfect')
		{
			spawnNoteSplashOnNote(note);
			perfects++;
		}

		if(!cpuControlled) {
			songScore += score;
			songHits++;
			RecalculateRating();
			if (!curSong.toLowerCase().startsWith('manager')) {
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.1;
				scoreTxt.scale.y = 1.1;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		if (FlxG.save.data.changedHit)
		{
			rating.x = FlxG.save.data.changedHitX;
			rating.y = FlxG.save.data.changedHitY;
		}

		//slightly smaller rating pop up
		rating.scale.x = 0.9;
		rating.scale.y = 0.9;

		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.comboShown;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.comboShown;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		comboSpr.cameras = [camHUD];
		rating.cameras = [camHUD];

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 78;
			numScore.y = rating.y + 75;
			/*if (FlxG.save.data.changedHit)
			{
				numScore.x = comboSpr.x + (43 * daLoop) - 90 + FlxG.save.data.changedHitX;
				numScore.y += 75 + FlxG.save.data.changedHitY;
			}
			else
			{
				numScore.x = comboSpr.x + (43 * daLoop) - 90;
				numScore.y += 75;
			}*/

			numScore.antialiasing = ClientPrefs.globalAntialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.comboShown;

			numScore.cameras = [camHUD];

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		if (!boyfriend.stunned && generatedMusic)
		{
			// THEW NEW FUCKIN INPUT BABY!!!
			notes.forEachAlive(function(daNote:Note)
				{
					// hold note functions
					if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
					&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
						goodNoteHit(daNote);
					}
				});
	
				if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong) {
					var canMiss:Bool = !ClientPrefs.ghostTapping;
					if (controlArray.contains(true)) {
						for (i in 0...controlArray.length) {
							// heavily based on my own code LOL if it aint broke dont fix it
							var pressNotes:Array<Note> = [];
							var notesDatas:Array<Int> = [];
							var notesStopped:Bool = false;
	
							var sortedNotesList:Array<Note> = [];
							notes.forEachAlive(function(daNote:Note)
							{
								if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
								&& !daNote.wasGoodHit && daNote.noteData == i) {
									sortedNotesList.push(daNote);
									notesDatas.push(daNote.noteData);
									canMiss = true;
								}
							});
							sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

							if (sortedNotesList.length > 0) {
								for (epicNote in sortedNotesList)
								{
									for (doubleNote in pressNotes) {
										if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
											doubleNote.kill();
											notes.remove(doubleNote, true);
											doubleNote.destroy();
										} else
											notesStopped = true;
									}
										
									// eee jack detection before was not super good
									if (controlArray[epicNote.noteData] && !notesStopped) {
										goodNoteHit(epicNote);
										pressNotes.push(epicNote);
									}
	
								}
							}
							else if (canMiss) 
								ghostMiss(controlArray[i], i, true);

							// I dunno what you need this for but here you go
							//									- Shubs

							// Shubs, this is for the "Just the Two of Us" achievement lol
							//									- Shadow Mario

							// I love thorns
							//									- Me

							if (!keysPressed[i] && controlArray[i])
								keysPressed[i] = true;
						}
					}
				} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
			}
	
			playerStrums.forEach(function(spr:StrumNote)
			{
				if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
					spr.playAnim('pressed');
					spr.resetAnim = 0;
				}
				if(controlReleaseArray[spr.ID]) {
					spr.playAnim('static');
					spr.resetAnim = 0;
				}
			});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		health -= daNote.missHealth; //For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		if (ClientPrefs.missSounds) {
			vocals.volume = 0;
		}
		RecalculateRating();

		var animToPlay:String = '';
		switch (Math.abs(daNote.noteData) % 4)
		{
			case 0:
				animToPlay = 'singLEFTmiss';
			case 1:
				animToPlay = 'singDOWNmiss';
			case 2:
				animToPlay = 'singUPmiss';
			case 3:
				animToPlay = 'singRIGHTmiss';
		}

		var daAlt = '';
		if(daNote.noteType == 1) daAlt = '-alt';

		boyfriend.playAnim(animToPlay + daAlt, true);
		if (ClientPrefs.specialEffects && curStage == 'frostedStage' && songMisses > 7)
		{
			if (freezeFade.alpha != 1)
				freezeFadeTween(redFade, 1, 2);
		}
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				if(ghostMiss) ghostMisses++;
				songMisses++;
			}
			RecalculateRating();

			if(ClientPrefs.missSounds){
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			}

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			if (ClientPrefs.missSounds) {
				vocals.volume = 0;
			}

			if (ClientPrefs.specialEffects && curStage == 'frostedStage' && songMisses > 7)
			{
				if (freezeFade.alpha != 1)
					freezeFadeTween(redFade, 1, 2);
			}
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(note.hitCausesMiss) {
				switch(note.noteType) {
					case 3: //DODGE NOTE BF ANIM/MECHANIC
					if(!boyfriend.stunned)
					{
						if(!endingSong)
						{
							health -= 0.0404; //error 404 :scream:
							FlxG.camera.shake(0.02, 0.1);
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true); //bf anim
								boyfriend.specialAnim = true;
							}
						}
					}

					note.wasGoodHit = true; //DODGE NOTE PRESSING ANIM

					if (!note.isSustainNote) //DODGE NOTE MECHANIC WORKING
					{
						note.kill();
						notes.remove(note, true);
						note.destroy();
						//fixed botplay stuff
						if(cpuControlled) {
							var time:Float = 0.15;
							if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
								time += 0.15;
							}
							StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
						} else {
							playerStrums.forEach(function(spr:StrumNote)
							{
								if (Math.abs(note.noteData) == spr.ID)
								{
									spr.playAnim('confirm', true);
								}
							});
						}
						spawnNoteSplashOnNote(note);
					}
					return;
				case 4: //DEATH NOTE MECHANIC
					if(cpuControlled) return;

					if(!boyfriend.stunned)
					{
						if(!endingSong)
						    {
								/*health = -100; //this will fucking kill you
						        if (!note.isSustainNote)
						        {
							        note.kill();
							        notes.remove(note, true);
							        note.destroy();
						        }*/
								gameOver();
					        }
					    return;
					}
				}

				note.wasGoodHit = true;
				return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
				if(combo > 9999) combo = 9999;
			}
			health += note.hitHealth;

			var daAlt = '';
			if(note.noteType == 1) daAlt = '-alt';

			var animToPlay:String = '';
			switch (Std.int(Math.abs(note.noteData)))
			{
				case 0:
					animToPlay = 'singLEFT';
					if (boyfriendPog) {
						bfnoteMovementXoffset = -30;
						bfnoteMovementYoffset = 0;
					}
				case 1:
					animToPlay = 'singDOWN';
					if (boyfriendPog) {
						bfnoteMovementXoffset = 30;
						bfnoteMovementYoffset = 0;
					}
				case 2:
					animToPlay = 'singUP';
					if (boyfriendPog) {
						bfnoteMovementYoffset = -30;
						bfnoteMovementXoffset = 0;
					}
				case 3:
					animToPlay = 'singRIGHT';
					if (boyfriendPog) {
						bfnoteMovementYoffset = 30;
						bfnoteMovementXoffset = 0;
					}
			}

			boyfriend.playAnim(animToPlay + daAlt, true);
			boyfriend.holdTimer = 0;

			if(note.noteType == 2) {
				if(boyfriend.animOffsets.exists('hey')) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = 0.6;
				}

				if(gf.animOffsets.exists('cheer')) {
					gf.playAnim('cheer', true);
					gf.specialAnim = true;
					gf.heyTimer = 0.6;
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:Int = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note.noteType);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, type:Int) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, type);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;

		if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
			FlxTween.tween(camHUD, {zoom: 1}, 0.5);
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.45;
			FlxTween.tween(halloweenWhite, {alpha: 0.6}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	override function destroy() {
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

		//HARDCODED EVENTS!!!
		switch (curSong.toLowerCase())
		{
			case 'tutorial':
				switch (curBeat)
				{
					case 12:
						introThree();
					case 13:
						introTwo();
					case 14:
						introOne();
					case 15:
						introGo();
				}
			case 'cultured':
				if (CoolUtil.difficultyString() == 'EX')
					{
						if (curBeat == 256) //create white bar with little man icon
							{
								iconP2.changeIcon('bluecheese-little-man');
								healthBar.createFilledBar(FlxColor.fromRGB(255, 255, 255),
									FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
								healthBar.updateBar();
							}
						if (curBeat == 288) //change back to ex
							{
								iconP2.changeIcon('bluecheese-ex');
								reloadAllBarColors();
							}
					}
			case 'manager-strike-back': //white box HUD effects
				if (curBeat == 0)
					{
						phillyBlackTween = FlxTween.tween(whiteBox, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								phillyBlackTween = null;
							}
						});
					}
				if (curBeat == 8)
					{
						phillyBlackTween = FlxTween.tween(whiteBox, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								phillyBlackTween = null;
							}
						});
					}
				if (curBeat == 200)
					{
						phillyBlackTween = FlxTween.tween(whiteBox, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								phillyBlackTween = null;
							}
						});
					}
				if (curBeat == 230)
					{
						phillyBlackTween = FlxTween.tween(whiteBox, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								phillyBlackTween = null;
							}
						});
					}
				if (curStep == 1694)
					{
						phillyBlackTween = FlxTween.tween(whiteBox, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								phillyBlackTween = null;
							}
						});
					}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		//THIS IS ANNOYING AF!!!!
		/*if(lastBeatHit >= curBeat) {
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}*/

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		//harsher camera zoom on milkshake
		if (curSong.toLowerCase() == 'milkshake') {
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0) {
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
			}
		} else if (curSong.toLowerCase().startsWith('manager')) {
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
					FlxG.camera.zoom += 0.005;
			}
		} else {
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.01;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned)
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.specialAnim)
			{
				boyfriend.dance();
			}
			if (!dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
			if (!littleMan.animation.curAnim.name.startsWith('sing') && !littleMan.stunned)
			{
				littleMan.dance();
			}
		} else if(dad.danceIdle && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'restaurante' | 'restauranteDefault':
				if(!ClientPrefs.fuckyouavi) {
				    boppers.dance(true);
					frontBoppers.dance(true);
					if (curStage == 'restaurante') {
						counter.dance(true);
						phillyCounter.dance(true);
					}
				}
			case 'restauranteArsen' | 'restauranteDansilot':
				if(!ClientPrefs.fuckyouavi) {
					stickmin.dance(true);
					joey.dance(true);
					crystal.dance(true);
					ralsei.dance(true);
					counter.dance(true);
					frontBoppers.dance(true);
				}
			case 'frostedStage':
				if (!ClientPrefs.fuckyouavi) {
					counter.dance(true);
					frontBoppers.dance(true);
					dansilot.dance(true);
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}
		return returnVal;

		var rankVal:Dynamic = FunkinLua.Function_Continue;
		for (i in 0...luaArray.length) {
			var rank:Dynamic = luaArray[i].call(event, args);
			if(rank != FunkinLua.Function_Continue) {
				rankVal = rank;
			}
		}
		return rankVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		var sng:String = curSong.toLowerCase();
		var curDiff:String = CoolUtil.difficultyString();
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
			if (curDiff == 'EX') //HEALTH DRAIN FOR EX
				{
					switch (sng)
					{
						case 'restaurante':
							health -= 0.0125;
						case 'milkshake':
							health -= 0.0115;
						case 'cultured':
							switch dad.curCharacter
							{
								case 'ex-bluecheese':
									health -= 0.0120;
								case 'bluecheese-spamton' | 'bluecheese-garcello' | 'bluecheese-hex':
									health -= 0.0300;
								case 'bluecheese-whitty' | 'bluecheese-tricky':
									health -= 0.0169; //nice
							}
					}
				}
		}
	}

	public var ratingString:String;
	public var rankString:String = '?';
	public var ratingPercent:Float;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		var rank:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop) {
			ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
			if(!Math.isNaN(ratingPercent) && ratingPercent < 0) ratingPercent = 0;

			if(Math.isNaN(ratingPercent)) {
				ratingString = '?';
			} else if(ratingPercent >= 1) {
				ratingPercent = 1;
				ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
			} else {
				for (i in 0...ratingStuff.length-1) {
					if(ratingPercent < ratingStuff[i][1]) {
						ratingString = ratingStuff[i][0];
						break;
					}
				}
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}

		//PERFECT TIMING WINDOW IS SUPER TIGHT SO ITS NOT JUST MFC NOW

		if(rank != FunkinLua.Function_Stop) {
			if (songMisses == 0 && bads == 0 && shits == 0 && goods == 0) {
				rankString = 'MFC'; //all perfects and sicks, no goods
			} else if (songMisses == 0 && bads == 0 && shits == 0 && goods >= 1) {
				rankString = 'GFC'; //no bads or shits
			} else if (songMisses == 0) {
				rankString = 'FC'; //normal fc
			} else if (songMisses < 10) {
				rankString = 'SDCB'; //under 10 misses
			} else if (songMisses > 11) {
				rankString = 'clear'; //anything else
			}
		}

		//ALL HIT TIMING UPDATED TEXT
		shitsTxt.text = 'Shit: ' + shits;
		badsTxt.text = 'Bad: ' + bads;
		goodsTxt.text = 'Good: ' + goods;
		sicksTxt.text = 'Sick: ' + sicks;
		perfectsTxt.text = 'Perfect: ' + perfects;
		missesTxt.text = 'Misses: ' + songMisses;
	}

	public function loadSong(?customSong:Bool, ?customPath:String):Void
	{
		var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

		trace('LOADING NEXT SONG');
		trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

		if (customSong)
		{
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}

		prevCamFollow = camFollow;
		prevCamFollowPos = camFollowPos;

		if (customSong)
			PlayState.SONG = Song.loadFromJson(customPath);
		else
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

		FlxG.sound.music.stop();

		//MP4 CUTSCENES
		if (TitleState.isDebug)
		{
			addMP4Outro('restaurante', 'dani');
			addMP4Outro('wifi', 'dani');
		}

		if(hasMP4 == false)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	public function exitSong():Void
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		switch (curSong.toLowerCase()) // STORY MODE DATA
		{
			case 'tutorial':
				if (FlxG.save.data.beatTutorial == null || FlxG.save.data.beatTutorial == false) {
					FlxG.save.data.beatTutorial = true;
					trace('beat tutorial');
				}
				MusicBeatState.switchState(new StoryMenuState());
			case 'cultured':
				if (FlxG.save.data.beatCulturedWeek == null || FlxG.save.data.beatCulturedWeek == false) {
					FlxG.save.data.beatCulturedWeek = true;
					trace('beat cultured');
				}
				MusicBeatState.switchState(new StoryMenuState());
			case 'casual-duel': //NOTE: Change to Avinera or Dynamic Duo song later
				if (TitleState.isDebug) videoOutro('casual-duel', 'dani');

				if (FlxG.save.data.beatWeekEnding == null || FlxG.save.data.beatWeekEnding == false) {
					FlxG.save.data.beatWeekEnding = true;
					trace('beat week 2');
				}
			case 'manager-strike-back':
				if (FlxG.save.data.beatBonus == null || FlxG.save.data.beatBonus == false) {
					FlxG.save.data.beatBonus = true;
					trace('beat manager strike back');
				}
				MusicBeatState.switchState(new StoryMenuState());
			default:
				MusicBeatState.switchState(new StoryMenuState());
		}
		trace('exited song, transitioned to story mode');

		if (SONG.validScore)
		{
			Highscore.saveWeekScore(WeekData.getCurrentWeekNumber(), campaignScore, storyDifficulty);
		}

		FlxG.save.flush(); // SAVE DATA
		usedPractice = false;
		changedDifficulty = false;
		cpuControlled = false;
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(arrayIDs:Array<Int>):Int {
		for (i in 0...arrayIDs.length) {
			if(!Achievements.achievementsUnlocked[arrayIDs[i]][1]) {
				switch(arrayIDs[i]) {
					case 1:
						if(curSong.toLowerCase() == 'cultured' && CoolUtil.difficultyString() == 'Hard') {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 2:
						if(curSong.toLowerCase() == 'restaurante' && songMisses < 1 && CoolUtil.difficultyString() == 'EX') {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 3:
						if(curSong.toLowerCase() == 'milkshake' && songMisses < 1 && CoolUtil.difficultyString() == 'EX') {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 4:
						if(curSong.toLowerCase() == 'cultured' && songMisses < 1 && CoolUtil.difficultyString() == 'EX') {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
				}
			}
		}
		return -1;
	}
	#end

	private function freezeFadeTween(asset:FlxSprite, opacity:Float, length:Float)
		{
			if (asset.alpha != opacity) {
				phillyBlackTween = FlxTween.tween(asset, {alpha: opacity}, length, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween) {
						phillyBlackTween = null;
					}
				});
				trace('alpha of object is opposite');
			}
			if (asset == freezeFade)
				trace('frozen snowstorm fade');
			else if (asset == redFade)
				trace('red brittle mechanic fade');
		}

	public function gameOver():Void
		{
			if (!practiceMode) //helps me when im testing lol
			{
				var ret:Dynamic = callOnLuas('onGameOver', []);
				var rank:Dynamic = callOnLuas('onGameOver', []);
				if(ret != FunkinLua.Function_Stop && rank != FunkinLua.Function_Stop) {
					boyfriend.stunned = true;
					deathCounter++;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					vocals.stop();
					FlxG.sound.music.stop();

					if (curSong.toLowerCase() == 'frosted') // new class
					{
						openSubState(new GameOverFrostedSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y));
					}
					else // default class
					{
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y));
					}

					#if desktop
					DiscordClient.changePresence("Game Over - " + detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
					#end
				}
			} else {
				deathCounter++;
			}
		}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
