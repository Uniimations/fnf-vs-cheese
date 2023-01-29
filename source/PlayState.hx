package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
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
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;

import openfl.display.StageQuality;
import openfl.media.Video;
import Achievements;
import UniiStringTools.LuaStage;

#if !flash 
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var HARDER_THAN_HARD:String = 'VIP';

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public var littleMan:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var cutsceneShit:Bool = false;
	public static var skippedDialogue:Bool = false;

	public var vocals:FlxSound;

	public var dad:Character;
	public var dad2:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public var boyfriend2:Boyfriend;

	var arsenTriangle:Character;
	var daniTriangle:Boyfriend;

	public var isBoyfriend:Bool = true;
	public var isDad:Bool = true;
	public var isDad2:Bool = false;
	public var isUnii:Bool = false;
	public var isDuo:Bool = false;
	public var isGF:Bool = false;

	public var isArsen:Bool = false;
	public var isDani:Bool = false;

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

	//here is my even sexier cam code fuck you
	var camPercentFloat:Float;
	var camGameZoom:Float;
	var camHudZoom:Float;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	private var babyArrow:StrumNote;

	public var FIRE_HITS:Int = 0;
	public var FIRE_DRAIN:Float = 0;

	public var camZooming:Bool = false;
	private var songLowercase:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarOV:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:FlxSprite;
	public var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;

	var frostedMisses:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueDefault:DialogueBox;

	public static var phillyBlackTween:FlxTween;
	var phillyCounter:BGSprite;
	var phillyFade:FlxSprite;
	var phillyBlack:FlxSprite;
	var grpBlackBars:FlxTypedGroup<FlxSprite>;

	var subTxt:FlxText;
	var blackBarTop:FlxSprite;
	var blackBarBottom:FlxSprite;

	var heyTimer:Float;

	var boppers:BGSprite;
	var counter:BGSprite;
	var frontBoppers:BGSprite;

	var grpCustomTableBoppers:FlxTypedGroup<BGSprite>;

	var bagelSinging:Bool = false;
	var bagel:BGSprite;
	var dansilot:BGSprite;
	var avineraCasualDuel:BGSprite;
	var wallLeft:BGSprite;
	var snow:BGSprite;
	var songInfo:BGSprite;
	var dirtyChair:BGSprite;

	var nightBack:BGSprite;
	var angryBack:BGSprite;
	var sadBack:BGSprite;
	var sunnyBack:BGSprite;

	var click:BGSprite;
	var soundWave:BGSprite;
	var uniiEye:BGSprite;
	var gotcha:BGSprite;

	public var blackscreenhud:FlxSprite;
	public var whiteBox:FlxSprite;
	public var freezeFade:FlxSprite;
	public var redFade:FlxSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var accText:FlxText;

	public var versionShit:FlxText;
	public var songShit:FlxText;

	var timeTxt:FlxText;

	public var shits:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;
	public var perfects:Int = 0;

	public var rpcIcon:String = '';

	var shitsTxt:FlxText;
	var badsTxt:FlxText;
	var goodsTxt:FlxText;
	var sicksTxt:FlxText;
	var perfectsTxt:FlxText;
	var missesTxt:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var staticCamZoom:Float = 1.05; // used whenever the camera needs to be put back in place

	// how big to stretch the pixel art assets
	// shut up ninjamuffin99.
	public static var daPixelZoom:Float = 6;

	public static var isCutscene:Bool = false;
	public static var hasDialogue:Bool = false;

	public var inCutscene:Bool = false;
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

	private var comboOffset:Array<Int> = [];

	public static var safeZoneOffset:Float = 0; // is calculated in create(), is safeFrames in milliseconds

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	// Lua shit
	public var backgroundGroup:FlxTypedGroup<FlxSprite>;
	public var foregroundGroup:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		FlxGraphic.defaultPersist = false; // set graphics to not persist to clear everything from last create call

		// for lua
		instance = this;

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

		// they look fancy c:
		MainMenuState.cursed = false;
		PlayState.isCutscene = false;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);

		safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		if (cutsceneShit) {
			camHUD.visible = false;
			camGame.visible = false;
		}

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null) SONG = Song.loadFromJson('restaurante');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		songLowercase = SONG.song.toLowerCase(); // ACTUALLY MADE A VARIABLE FOR IT GOD DAMN THATS ALWAYS SO ANNOYING LMFAO

		displaySongName = StringTools.replace(SONG.song, '-', ' ');

		dadnoteMovementXoffset = 0;
		dadnoteMovementYoffset = 0;
		bfnoteMovementXoffset = 0;
		bfnoteMovementYoffset = 0;

		comboOffset = [0, 0];

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

			detailsText = "Story Mode: " + displaySongName + " (" + storyDifficultyText + ")";
		}
		else
		{
			detailsText = "Freeplay - " + displaySongName + " (" + storyDifficultyText + ")";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + "Freeplay";
		#end

		grpCustomTableBoppers = new FlxTypedGroup<BGSprite>();

		if (!ClientPrefs.fuckyouavi) {
			switch (songLowercase)
			{
				case 'tutorial':
					curStage = 'kitchen';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					var bg:BGSprite = new BGSprite('cheese/kitchen/background_main', -762.4, -1524.4, 1, 1);
					var sink:BGSprite = new BGSprite('cheese/kitchen/Sink', 916.8, -23.55, 1, 1, ['Sink'], true);
					var stove:BGSprite = new BGSprite('cheese/kitchen/THEE_AWESIOME_STOBEVE', 278.8, 29.05, 1, 1, ['THEE AWESIOME STOBEVE'], true);
					var silly:BGSprite = new BGSprite('cheese/kitchen/SILLY_TRAMSHCANSH', -44.45, 697.95, 1, 1);
					var shelf:BGSprite = new BGSprite('cheese/kitchen/cheeese_nevr_uses_that_frying_pan_on_that_shelf', 251.6, -607.5, 1, 1);

					counter = new BGSprite('cheese/kitchen/counter_strike_source', 331.8, 709.1, 1, 1);

					add(bg);
					add(sink);
					add(stove);
					add(silly);
					add(shelf);

				// kinda sorry for this code but also kinda not... it works.
				case 'restaurante' | 'milkshake' | 'cultured':
					curStage = 'restaurante';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					// local variables stated here
					var floor:BGSprite;
					var tableA:BGSprite;
					var tableB:BGSprite;
					var suzuki:BGSprite;

					if (CoolUtil.difficultyString() == HARDER_THAN_HARD)
					{
						switch (songLowercase)
						{
							case 'restaurante':
								floor = new BGSprite('cheese/floor', -377.9, -146.4, 1, 1);
								tableA = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
								tableB = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
								boppers = new BGSprite('cheese/ex/boppers', 1278.2, 128.8, 1, 1, ['boppers']);
								suzuki = new BGSprite('cheese/ex/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);
								frontBoppers = new BGSprite('cheese/ex/front_boppers', 67.5, 959.7, 1, 1, ['front boppers']);

							case 'milkshake':
								floor = new BGSprite('cheese/sunset_floor', -377.9, -146.4, 1, 1);
								tableA = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
								tableB = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
								boppers = new BGSprite('cheese/ex/boppers', 1278.2, 128.8, 1, 1, ['boppers']);
								suzuki = new BGSprite('cheese/ex/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);
								frontBoppers = new BGSprite('cheese/ex/front_boppers', 67.5, 959.7, 1, 1, ['front boppers']);

							case 'cultured':
								floor = new BGSprite('cheese/night/floor', -377.9, -146.4, 1, 1);
								tableA = new BGSprite('cheese/night/tableA', 1966.5, 283.05, 1, 1);
								tableB = new BGSprite('cheese/night/tableB', 1936.15, 568.5, 1, 1);
								boppers = new BGSprite('cheese/night/boppers', 1287.3, 206.05, 1, 1, ['boppers']);
								suzuki = new BGSprite('cheese/night/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);
								frontBoppers = new BGSprite('cheese/night/front_boppers', 67.5, 959.7, 1, 1, ['front boppers']);

							default:
								floor = new BGSprite('cheese/floor', -377.9, -146.4, 1, 1);
								tableA = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
								tableB = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
								boppers = new BGSprite('cheese/ex/boppers', 1278.2, 128.8, 1, 1, ['boppers']);
								suzuki = new BGSprite('cheese/ex/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);
								frontBoppers = new BGSprite('cheese/ex/front_boppers', 67.5, 959.7, 1, 1, ['front boppers']);
						}
						phillyCounter = new BGSprite('cheese/counter_effect', 232.35, 403.25, 1, 1, ['COUNTER WHITE']);
						phillyCounter.alpha = 0.0;
					}
					else
					{
						floor = new BGSprite('cheese/floor', -377.9, -146.4, 1, 1);
						tableA = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
						tableB = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);
						boppers = new BGSprite('cheese/char/boppers', 1265.6, 127.6, 1, 1, ['boppers']);
						suzuki = new BGSprite('cheese/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);
						frontBoppers = new BGSprite('cheese/char/front_boppers', 67.5, 959.7, 1, 1, ['front boppers']);
					}
					counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);

					phillyBlack = new FlxSprite(-220, -100).makeGraphic(Std.int(FlxG.width * 2.2), Std.int(FlxG.height * 2.2), FlxColor.BLACK);
					phillyBlack.scrollFactor.set(1, 1);
					phillyBlack.alpha = 0.0;

					add(floor);
					add(tableA);
					add(tableB);
					add(boppers);
					add(suzuki);
					add(phillyBlack);

					comboOffset = [430, -550];

				case 'cream-cheese':
					curStage = 'restauranteCream';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					var floor:BGSprite = new BGSprite('bonus/cream/floor', -377.9, -146.4, 1, 1);
					var tables:BGSprite = new BGSprite('bonus/cream/tables', 1287.4, 278.65, 1, 1);
					var suzuki:BGSprite = new BGSprite('bonus/cream/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);

					bagel = new BGSprite('bonus/cream/ice_cream', 1962, 74, 1, 1, ['ice creamed bageled', 'ice cream change'], false);

					counter = new BGSprite('bonus/cream/counter', 232.35, 403.25, 1, 1, ['counter bop'], false, 12);

					phillyBlack = new FlxSprite(-250, -180).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					phillyBlack.scrollFactor.set(1, 1);
					phillyBlack.alpha = 1;

					add(floor);
					add(bagel);
					add(tables);
					add(suzuki);
					add(phillyBlack);

					comboOffset = [430, -550];

				case 'wifi':
					curStage = 'restauranteArsen';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					var floor:BGSprite = new BGSprite('cheese/floor_week2', -377.9, -146.4, 1, 1);

					var tSideMod:BGSprite = new BGSprite('cheese/t-side_mod', 1288.35, 279.9, 1, 1);
					var tableA:BGSprite = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1);
					var tableB:BGSprite = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);

					var stickmin = new BGSprite('cheese/char/stickmin', 1855.55, 49.9, 1, 1, ['henry']);
					grpCustomTableBoppers.add(stickmin);

					var joey = new BGSprite('cheese/char/joey_new', 1474.3, 222.25, 1, 1, ['joey']);
					grpCustomTableBoppers.add(joey);

					var ralsei = new BGSprite('cheese/char/ralsei_bop', 2045, 469, 1, 1, ['ralsei bop']);
					grpCustomTableBoppers.add(ralsei);

					var wall:BGSprite = new BGSprite('cheese/wall', -358.25, -180.35, 1, 1);

					counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);

					add(floor);
					add(tSideMod);
					add(tableA);
					add(tableB);
					add(grpCustomTableBoppers);
					add(wall);

					comboOffset = [430, -550];

				case 'casual-duel':
					curStage = 'restauranteDansilot';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					var floor:BGSprite = new BGSprite('cheese/floor_week2', -377.9, -146.4, 1, 1);
					var tableForDeltarune:BGSprite = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1);

					var funGang:BGSprite = new BGSprite('cheese/char/fun_gang_latest', 1307.25, 79.25, 1, 1, ['fungang boppy']);
					grpCustomTableBoppers.add(funGang);

					var sussyArgument:BGSprite = new BGSprite('cheese/char/sussy_table', 1967.65, 48.05, 1, 1, ['SUSSY TABLE']);
					grpCustomTableBoppers.add(sussyArgument);

					var deltaBop = new BGSprite('cheese/char/DELTARUNE', 1851.35, 468.8, 1, 1, ['kris bop']);
					grpCustomTableBoppers.add(deltaBop);

					var wall:BGSprite = new BGSprite('cheese/wall', -358.25, -180.35, 1, 1);

					counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);
					avineraCasualDuel = new BGSprite('cheese/char/avinera_counter', 357.65, 257.4, 1, 1, ['avinera counter']);
					frontBoppers = new BGSprite('cheese/char/crowdindie_big', -29.25, 744.45, 1, 1, ['crowdindie']);

					add(floor);
					add(tableForDeltarune);
					add(grpCustomTableBoppers);
					add(wall);

					comboOffset = [430, -550];

				case 'below-zero':
					curStage = 'restauranteAvi';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					var floor:BGSprite = new BGSprite('cheese/floor_zero', -377.9, -146.4, 1, 1);

					var belowBop = new BGSprite('cheese/char/BELOW_BOPPER', 1333, 102, 1, 1, ['beloppers']);
					grpCustomTableBoppers.add(belowBop);

					var wall:BGSprite = new BGSprite('cheese/wall', -358.25, -180.35, 1, 1);

					counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);

					freezeFade = new FlxSprite().loadGraphic(Paths.image('effects/BZ_FROZEN')); //bz means below zero lololololl
					freezeFade.cameras = [camHUD];
					freezeFade.alpha = 0.0;
					freezeFade.blend = UniiStringTools.getBlend('add');

					freezeFade.antialiasing = ClientPrefs.globalAntialiasing;

					add(floor);
					add(grpCustomTableBoppers);
					add(wall);
					add(freezeFade);

					comboOffset = [430, -550];

				case 'dynamic-duo':
					curStage = 'restauranteDynamic';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60 ;

					// local variables stated here
					var floor:BGSprite;
					var wall:BGSprite;
					var dynamicBop:BGSprite;

					floor = new BGSprite('cheese/floor_week2', -377.9, -146.4, 1, 1);

					dynamicBop = new BGSprite('cheese/char/DYANMIC_BOPPER', 1340.3, 9.75, 1, 1, ['dynamic bop']);
					grpCustomTableBoppers.add(dynamicBop);

					wall = new BGSprite('cheese/wall', -358.25, -180.35, 1, 1);

					counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop']);

					phillyFade = new FlxSprite(-220, -60).makeGraphic(Std.int(FlxG.width * 2.2), Std.int(FlxG.height * 2.2), FlxColor.BLACK);
					phillyFade.scrollFactor.set(1, 1);
					phillyFade.alpha = 0.0;

					add(floor);
					add(grpCustomTableBoppers);
					add(wall);

					comboOffset = [430, -550];

				case 'manager-strike-back':
					curStage = 'undertale';

					defaultCamZoom = 0.60;
					staticCamZoom = 0.60;

					//added during dark fade event.
					phillyFade = new FlxSprite(-390, -190).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					phillyFade.scrollFactor.set(1, 1);
					phillyFade.alpha = 0.0;

					comboOffset = [1300, -150];

				case 'frosted':
					curStage = 'frostedStage';

					defaultCamZoom = 0.92;
					staticCamZoom = 1;

					var outside = new BGSprite('bonus/outside', -438.85, -213.3, 0.9, 0.9);

					snow = new BGSprite('bonus/snowstorm', -369.8, -114.8, 1, 1, ['funny snowsto'], true);
					snow.visible = false;

					var wall = new BGSprite('bonus/wall', -486, -352.3, 1, 1);
					dansilot = new BGSprite('bonus/tableRight', 632.95, 17.8, 1, 1, ['tableRight']);
					frontBoppers = new BGSprite('bonus/boppers', 855.9, 327.65, 1.2, 1.2, ['TABLE BOP FIXED']);
					wallLeft = new BGSprite('bonus/wallLeft', -949.25, -393.6, 1.1, 1.1);

					counter = new BGSprite('bonus/boppers', -348.35, 403, 1.2, 1.2, ['cheese bop']);

					add(outside);
					add(snow);
					add(wall);
					add(dansilot);

				case 'alter-ego':
					curStage = 'theBack';

					defaultCamZoom = 0.7;
					staticCamZoom = 0.8;

					nightBack = new BGSprite('bonus/ALTER_NORMAL', -322.55, -248.1, 0.95, 0.95, ['NORMAL']);
					nightBack.updateHitbox();

					angryBack = new BGSprite('bonus/ALTER_ANGRY', -322.55, -248.1, 0.95, 0.95, ['ANGRY']);
					angryBack.updateHitbox();

					sadBack = new BGSprite('bonus/ALTER_SADGE', -322.55, -248.1, 0.95, 0.95, ['SADGE']);
					sadBack.updateHitbox();

					sunnyBack = new BGSprite('bonus/ALTER_SUNNY', -322.55, -248.1, 0.95, 0.95, ['SUNNY']);
					sunnyBack.updateHitbox();

					var repositionX = -300;
					var repositionY = -150;

					click = new BGSprite('bonus/ALTER_click', 0 + repositionX, 0 + repositionY, 0, 0, ['click fadew']);
					click.screenCenter();
					click.updateHitbox();

					soundWave = new BGSprite('bonus/ALTER_sound_wave', -212 + repositionX, -252 + repositionY, 0, 0, ['the thing']);
					soundWave.updateHitbox();

					uniiEye = new BGSprite('bonus/ALTER_eye', 300 + repositionX, 132 + repositionY, 0, 0, ['unii eye open']);
					uniiEye.updateHitbox();

					gotcha = new BGSprite('bonus/ALTER_gotcha', 600 + repositionX, 335 + repositionY, 0, 0, ['gotcha'], true);
					gotcha.updateHitbox();

					// bigger bg
					nightBack.scale.set(1.5, 1.5);
					angryBack.scale.set(1.5, 1.5);
					sadBack.scale.set(1.5, 1.5);
					sunnyBack.scale.set(1.5, 1.5);

					// hide other stages
					angryBack.alpha = 0;
					sadBack.alpha = 0;
					sunnyBack.alpha = 0;

					// hide mid song stuff
					click.alpha = 0;
					soundWave.alpha = 0;
					uniiEye.alpha = 0;
					gotcha.alpha = 0;

					phillyFade = new FlxSprite(-390, -190).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					phillyFade.scrollFactor.set(1, 1);
					phillyFade.alpha = 0.0;

					add(nightBack);
					add(angryBack);
					add(sadBack);
					add(sunnyBack);

				case 'dirty-cheater':
					curStage = 'chartEditor';

					defaultCamZoom = 0.67;
					staticCamZoom = 0.67;

					var leftChart:BGSprite = new BGSprite('bonus/dirt/left_chart', -42.6, -173.4, 1, 1);

					var rightChart:BGSprite = new BGSprite('bonus/dirt/right_chart', 1107.1, 57.15, 1, 1);

					var editorMenu:BGSprite = new BGSprite('bonus/dirt/THIS_ONE', 804.95, -1.40, 1, 1);

					songInfo = new BGSprite('bonus/dirt/song_info', 729.6, -41.85, 1, 1, [for(i in 1...10) Std.string(i)]);
					// that function makes an array of numbers but as a string! thanks yoshi

					dirtyChair = new BGSprite('bonus/dirt/CHAIR', 209.25, 738.3, 1, 1);
					dirtyChair.alpha = 0;

					add(leftChart);
					add(rightChart);
					add(editorMenu);
					add(songInfo);
					add(dirtyChair);

					comboOffset = [-245, -80];

				default:
					var stageJson:LuaStage = UniiStringTools.getLuaStage(songLowercase);
					if(stageJson == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
						stageJson = {
							stage: "placeholder",
							defaultZoom: 0.9,
							staticZoom: 0.9,
							combo: [0, 0],

							boyfriend: [770, 100],
							girlfriend: [400, 130],
							opponent: [100, 100]
						};
						trace('SONG HAS NO STAGE FILE');
					}

					curStage = stageJson.stage;
					defaultCamZoom = stageJson.defaultZoom;
					staticCamZoom = stageJson.staticZoom;
					comboOffset = [0, 0];
					BF_X = stageJson.boyfriend[0];
					BF_Y = stageJson.boyfriend[1];
					GF_X = stageJson.girlfriend[0];
					GF_Y = stageJson.girlfriend[1];
					DAD_X = stageJson.opponent[0];
					DAD_Y = stageJson.opponent[1];
			}
			blackBarTop = new FlxSprite(0, -750);
			blackBarTop.cameras = [camHUD];

			blackBarBottom = new FlxSprite(0, 750);
			blackBarBottom.cameras = [camHUD];

			subTxt = new FlxText(50, 0, 1180, "", 32);
			subTxt.cameras = [camHUD];

			if(ClientPrefs.downScroll)
				subTxt.y = 35;
			else
				subTxt.y = 620;

			add(blackBarTop);
			add(blackBarBottom);
			add(subTxt);
		}
		backgroundGroup = new FlxTypedGroup<FlxSprite>();
		add(backgroundGroup);

		var bfType:String = '';
		if(!ClientPrefs.bfreskin) {
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
			SONG.player1 = bfType;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'theBack':
				DAD_X -= 700;
				DAD_Y -= 269; //nice.
				BF_X -= 540;
				BF_Y -= 360;
			case 'chartEditor':
				DAD_Y -= 100;
				BF_Y -= 100;
		}

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		littleMan = new FlxSpriteGroup(DAD_X, DAD_Y);

		gf = new Character(0, 0, SONG.player3);
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.scrollFactor.set(1, 1);
		gfGroup.add(gf);
		startCharacterLua(gf.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
		dad.scrollFactor.set(1, 1);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.scrollFactor.set(1, 1);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		// second opponent and second player are hardcoded to the character or song its 5am im so tire d .

		switch (SONG.player2)
		{
			case 'potionion':
				dad2 = new Character(0, 0, 'diples-cubed');
				dad2.x += 160;
				dad2.y += 400;
				dad2.scrollFactor.set(1, 1);
				dad2.visible = false;
				dadGroup.add(dad2);

				trace('DIOPLSE AND THE PTOTOION! !!!');
			case 'vip-bluecheese': // cultured vip fix
				dad2 = new Character(0, 0, 'bluecheese-little-man');
				dad2.x += 807;
				dad2.y += 385;
				dad2.scrollFactor.set(1, 1);
				dad2.visible = false;
				littleMan.add(dad2);

				trace('my VIP wife left me .');
			default:
				FlxG.log.add('NO DAD2');
		}

		switch (SONG.player1)
		{
			case 'dd-avinera-and-unii':
				boyfriend2 = new Boyfriend(0, 0, 'dd-unii');
				boyfriend2.x += 800;
				boyfriend2.y += 200;
				boyfriend2.scrollFactor.set(1, 1);
				boyfriendGroup.add(boyfriend2);

				trace('AVINERA + UNIIMATIONS');
			default:
				switch (songLowercase)
				{
					case 'alter-ego':
						boyfriend2 = new Boyfriend(0, 0, 'bf');
						boyfriend2.x += boyfriend.positionArray[0];
						boyfriend2.y += boyfriend.positionArray[1];
						boyfriend2.scrollFactor.set(1, 1);
						boyfriendGroup.add(boyfriend2);

						trace('death bf for alter ego mid song event');
					default:
						FlxG.log.add('NO BOYFRIEND2');
				}
		}

		if (curStage == 'restauranteDynamic')
		{
			arsenTriangle = new Character(DAD_X, DAD_Y, 'comic-arsen');
			arsenTriangle.x += -210;
			arsenTriangle.y += 80;
			arsenTriangle.scrollFactor.set(0, 0);
			arsenTriangle.alpha = 0;

			daniTriangle = new Boyfriend(BF_X, BF_Y, 'comic-dansilot');
			daniTriangle.x += -80;
			daniTriangle.y += 100;
			daniTriangle.scrollFactor.set(0, 0);
			daniTriangle.alpha = 0;

			arsenTriangle.cameras = [camHUD];
			daniTriangle.cameras = [camHUD];

			add(arsenTriangle);
			add(daniTriangle);
		}

		var camPos:FlxPoint;

		switch (curStage)
		{
			case 'frostedStage' | 'theBack':
				camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
				camPos.x += dad.cameraPosition[0];
				camPos.y += dad.cameraPosition[1];
			default:
				camPos = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
				camPos.x += gf.cameraPosition[0];
				camPos.y += gf.cameraPosition[1];
		}

		// ALL CHARACTER add(character); THINGIES
		setCharLayering(curStage);

		if (hasDialogue && isStoryMode)
		{
			var file:String = Paths.txt('dialogue/' + SONG.song.toLowerCase() + 'Dialogue');
			dialogue = CoolUtil.coolTextFile(file);

			dialogueDefault = new DialogueBox(false, dialogue);
			dialogueDefault.scrollFactor.set();
			dialogueDefault.finishThing = startCountdown;
			dialogueDefault.nextDialogueThing = startNextDialogue;
		}

		Conductor.songPosition = -5000;

		if (curStage == 'undertale' && !ClientPrefs.fuckyouavi) //only LOADS box on undertale stage, fuckyouavi is for optimized mode
		{
			var boxPath:String = 'bonus/UT_box_';

			if (!ClientPrefs.downScroll) {
				whiteBox = new FlxSprite().loadGraphic(Paths.image(boxPath + 'upscroll'));
			} else {
				whiteBox = new FlxSprite().loadGraphic(Paths.image(boxPath + 'downscroll'));
			}
			add(whiteBox);

			whiteBox.cameras = [camHUD];
		}

		if (ClientPrefs.specialEffects && curStage == 'frostedStage' && !ClientPrefs.pussyMode) {
			freezeFade = new FlxSprite().loadGraphic(Paths.image('effects/FROZEN_BITCH'));
			freezeFade.alpha = 0;
			add(freezeFade);

			redFade = new FlxSprite().loadGraphic(Paths.image('effects/RED_BITCH'));
			redFade.alpha = 0;
			add(redFade);

			freezeFade.cameras = [camHUD];
			redFade.cameras = [camHUD];
		}

		if (!ClientPrefs.fuckyouavi) {
			blackscreenhud = new FlxSprite().loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));
			blackscreenhud.alpha = ClientPrefs.bgDim;
			add(blackscreenhud);

			blackscreenhud.cameras = [camHUD];
		}

		strumLine = new FlxSprite((ClientPrefs.middleScroll || songLowercase == 'tutorial' || songLowercase.startsWith('manager')) ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var hudFont:String = 'fnf.otf';
		var ratingBarSize:Int = 16;

		timeTxt = new FlxText(STRUM_X + 75, 10, 400, "", 32);
		timeTxt.setFormat(Paths.font(hudFont), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideHud;
		timeTxt.antialiasing = ClientPrefs.globalAntialiasing;

		timeBarBG = new FlxSprite(timeTxt.x + 70, timeTxt.y + (timeTxt.height / 4)).loadGraphic(Paths.image('timeBar'));
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideHud;

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.createFilledBar(0x00000000, 0xFFFFFFFF);
		timeBar.scrollFactor.set();
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideHud;

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if (ClientPrefs.noteSplashes)
		{
			var splash:NoteSplash = new NoteSplash(100, 100, 0);
			grpNoteSplashes.add(splash);
			splash.alpha = 0.0;
		}

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

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

		healthBarOV = new AttachedSprite('healthBar');
		healthBarOV.y = FlxG.height * 0.89;
		healthBarOV.screenCenter(X);
		healthBarOV.scrollFactor.set();
		healthBarOV.visible = !ClientPrefs.hideHud && songLowercase != 'manager-strike-back';
		healthBarOV.xAdd = -4;
		healthBarOV.yAdd = -4;

		if(ClientPrefs.downScroll) healthBarOV.y = 0.12 * FlxG.height;

		if (songLowercase == 'manager-strike-back') {
			hudFont = 'UNDERTALE.otf';
			ratingBarSize = 15;
		}

		healthBar = new FlxBar(healthBarOV.x + 4, healthBarOV.y + 4, RIGHT_TO_LEFT, Std.int(healthBarOV.width - 8), Std.int(healthBarOV.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBarOV.sprTracker = healthBar;

		add(healthBar);
		add(healthBarOV);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud && songLowercase != 'manager-strike-back';

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud && songLowercase != 'manager-strike-back';

		add(iconP1);
		add(iconP2);

		reloadAllBarColors();

		// NO MORE.

		/*
		//what ocd does to a mf
		//what ocd does to a mf pt 2 (i cleaned it for u :3 )

		var versionHeight:Float = healthBarBG.y;

		if (ClientPrefs.downScroll)
		{
			if (ClientPrefs.showFPS)
				versionHeight -= 120;
			else
				versionHeight -= 135;
		}
		*/

		var songArtist:String;

		switch (songLowercase)
		{
			case 'cream-cheese':
				songArtist = 'Ghostoru';
			case 'i-still-have-to-think-about-it':
				songArtist = 'breadiboyo';
			case 'below-zero' | 'dirty-cheater' | 'manager-strike-back' | 'frosted':
				songArtist = 'Avinera';
			case 'fat-blunt':
				songArtist = 'Toby Fox (ft. Avinera)';
			default:
				songArtist = 'uniimations';
		}

		// what ocd does to a mf pt 3 (fuck you diples)

		versionShit = new FlxText(20, FlxG.height * 1 - 28, 0, "", 18); //versionHeight used to be healthBarBG.y fyi
		versionShit.setFormat(Paths.font(hudFont), 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		versionShit.scrollFactor.set();
		versionShit.borderSize = 2;
		versionShit.visible = !ClientPrefs.hideHud;
		versionShit.antialiasing = ClientPrefs.globalAntialiasing;

		songShit = new FlxText(versionShit.x, versionShit.y - 15, 0, "", 18);
		songShit.setFormat(Paths.font(hudFont), 13, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		songShit.scrollFactor.set(0, 0);
		songShit.borderSize = 2;
		songShit.visible = !ClientPrefs.hideHud;
		songShit.antialiasing = ClientPrefs.globalAntialiasing;

		versionShit.text = 'VS Cheese v' + MainMenuState.cheeseVersion;
		songShit.text = songArtist + '  -  ' + displaySongName;

		add(versionShit);
		add(songShit);

		scoreTxt = new FlxText(healthBarOV.x + healthBarOV.width - 150, healthBarOV.y + 25, 0, "", 20);
		scoreTxt.setFormat(Paths.font(hudFont), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 2;
		scoreTxt.visible = !ClientPrefs.hideHud;
		scoreTxt.antialiasing = ClientPrefs.globalAntialiasing;

		scoreTxt.text = "Score: 0";

		accText = new FlxText(scoreTxt.x, scoreTxt.y + 20, 0, "", 20);
		accText.setFormat(Paths.font(hudFont), 14, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accText.scrollFactor.set();
		accText.borderSize = 2;
		accText.visible = !ClientPrefs.hideHud;
		accText.antialiasing = ClientPrefs.globalAntialiasing;

		accText.text = "0%";

		add(scoreTxt);
		add(accText);

		shitsTxt = new FlxText(20, FlxG.height/2+20, 0, "", 20);
		shitsTxt.setFormat(Paths.font(hudFont), ratingBarSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shitsTxt.scrollFactor.set();
		shitsTxt.borderSize = 2;
		shitsTxt.visible = !ClientPrefs.hideHud;
		shitsTxt.antialiasing = ClientPrefs.globalAntialiasing;

		badsTxt = new FlxText(20, FlxG.height/2, 0, "", 20);
		badsTxt.setFormat(Paths.font(hudFont), ratingBarSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		badsTxt.scrollFactor.set();
		badsTxt.borderSize = 2;
		badsTxt.visible = !ClientPrefs.hideHud;
		badsTxt.antialiasing = ClientPrefs.globalAntialiasing;

		goodsTxt = new FlxText(20, FlxG.height/2-20, 0, "", 20);
		goodsTxt.setFormat(Paths.font(hudFont), ratingBarSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		goodsTxt.scrollFactor.set();
		goodsTxt.borderSize = 2;
		goodsTxt.visible = !ClientPrefs.hideHud;
		goodsTxt.antialiasing = ClientPrefs.globalAntialiasing;

		sicksTxt = new FlxText(20, FlxG.height/2-40, 0, "", 20);
		sicksTxt.setFormat(Paths.font(hudFont), ratingBarSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		sicksTxt.scrollFactor.set();
		sicksTxt.borderSize = 2;
		sicksTxt.visible = !ClientPrefs.hideHud;
		sicksTxt.antialiasing = ClientPrefs.globalAntialiasing;

		perfectsTxt = new FlxText(20, FlxG.height/2-60, 0, "", 20);
		perfectsTxt.setFormat(Paths.font(hudFont), ratingBarSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		perfectsTxt.scrollFactor.set();
		perfectsTxt.borderSize = 2;
		perfectsTxt.visible = !ClientPrefs.hideHud;
		perfectsTxt.antialiasing = ClientPrefs.globalAntialiasing;

		missesTxt = new FlxText(20, FlxG.height/2+40, 0, "", 20);
		missesTxt.setFormat(Paths.font(hudFont), ratingBarSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		missesTxt.scrollFactor.set();
		missesTxt.borderSize = 2;
		missesTxt.visible = !ClientPrefs.hideHud;
		missesTxt.antialiasing = ClientPrefs.globalAntialiasing;

		add(shitsTxt);
		add(badsTxt);
		add(goodsTxt);
		add(sicksTxt);
		add(perfectsTxt);
		add(missesTxt);

		shitsTxt.cameras = [camHUD];
		badsTxt.cameras = [camHUD];
		goodsTxt.cameras = [camHUD];
		sicksTxt.cameras = [camHUD];
		perfectsTxt.cameras = [camHUD];
		missesTxt.cameras = [camHUD];

		//ALL DEFAULT HIT TIMING TEXT
		shitsTxt.text = 'Shit: ' + shits;
		badsTxt.text = 'Bad: ' + bads;
		goodsTxt.text = 'Good: ' + goods;
		sicksTxt.text = 'Sick: ' + sicks;
		perfectsTxt.text = 'Perfect: ' + perfects;
		missesTxt.text = 'Miss: ' + songMisses;

		if (curStage == 'frostedStage') {
			frostedMisses = new FlxText(400, 20, FlxG.width - 800, "" + deathCounter, 32);
			frostedMisses.setFormat(Paths.font("fnf.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			frostedMisses.scrollFactor.set();
			frostedMisses.borderSize = 3;
			frostedMisses.antialiasing = ClientPrefs.globalAntialiasing;

			if (ClientPrefs.downScroll) {
				frostedMisses.y += 550;
			}

			if (ClientPrefs.middleScroll) {
				frostedMisses.x += 340;
			}

			if (ClientPrefs.pussyMode)
				frostedMisses.text = "MISSES: " + songMisses + "\nDEATHS: " + deathCounter + "\nYOU'RE A PUSSY!";
			else
				frostedMisses.text = "MISSES: " + songMisses + "/10\nDEATHS: " + deathCounter;

			add(frostedMisses);
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarOV.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		accText.cameras = [camHUD];
		versionShit.cameras = [camHUD];
		songShit.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		if (curStage == 'frostedStage') frostedMisses.cameras = [camHUD];

		if (hasDialogue && isStoryMode) dialogueDefault.cameras = [camHUD];

		// LOAD SONG DATA //
		preloadSongs(); // preloads music
		generateSong(); // generates chart

		// EVENT SCRIPTS

		#if LUA_ALLOWED
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.mods('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		#end
		eventPushedMap.clear();
		eventPushedMap = null;

		startingSong = true;
		updateTime = true;

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.mods('charts/' + songLowercase + '/')];

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.mods('scripts/')];

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';

		if (FileSystem.exists(Paths.mods(luaFile))) {
			luaFile = Paths.mods(luaFile);
			doPush = true;
		}

		if (doPush) luaArray.push(new FunkinLua(luaFile));
		#end

		//STORY CUTSCENE CODE!!!

		if (isStoryMode && !seenCutscene)
		{
			switch (songLowercase)
			{
				case 'tutorial' | 'manager-strike-back':
					startIntro(); // no countdown
				case 'restaurante' | 'milkshake' | 'cultured':
					assEat(dialogueDefault); // dialogue box
				case 'wifi':
					addwebmIntro('wifi'); // webm cutscene if mac
				default:
					startCountdown(); // normal countdown
			}
			seenCutscene = true;
		}
		else //FREEPLAY CUTSCENE CODE!!!
		{
			switch (songLowercase)
			{
				case 'tutorial' | 'cream-cheese' | 'manager-strike-back' | 'frosted' | 'dirty-cheater':
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

		// SONG SPECIFIC VALUE SETTING
		switch (songLowercase)
		{
			case 'restaurante' | 'cultured':
				camPercentFloat = 4;
				camGameZoom = 0.015;
				camHudZoom = 0.01;

				camZooming = true;

			case 'milkshake':
				camPercentFloat = 2;
				camGameZoom = 0.02;
				camHudZoom = 0.015;

			case 'manager':
				camPercentFloat = 4;
				camGameZoom = 0.005;
				camHudZoom = 0;

			case 'dirty-cheater':
				camPercentFloat = 1;
				camGameZoom = 0.005;
				camHudZoom = 0.005;

				camZooming = true;

				boyfriend.idleSuffix = '-straight'; // HE IS NOT HOMOSEXUAL !!

			default:
				camPercentFloat = 4;
				camGameZoom = 0.015;
				camHudZoom = 0.01;
		}

        switch (songLowercase) //ARE YOU PROUD OF ME UNII - yes i am dops ill always be proud of you <3
        {
            case 'wifi' | 'casual-duel' | 'dynamic-duo' | 'below-zero':
                rpcIcon = iconP1.getCharacter();
            default:
                rpcIcon = dad.healthIcon;
        }

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, "Combo: " + combo + " - " + "Misses: " + songMisses, rpcIcon);
		#end

		callOnLuas('onCreatePost', []);

		super.create();

		Paths.clearOpenflAssets(); // call Paths to remove local assets.
		FlxGraphic.defaultPersist = true;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadAllBarColors()
	{
		var dad = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		var bf = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);

		healthBar.createFilledBar(dad, bf);
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(1, 1);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';

		if (FileSystem.exists(Paths.mods(luaFile))) {
			luaFile = Paths.mods(luaFile);
			doPush = true;
		}

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var dialogueCount:Int = 0;

	function assEat(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;

		//SOUND LOADING CODE
		CoolUtil.precacheSound('dialogue/clickText');
		CoolUtil.precacheSound('dialogue/bluecheeseText');
		CoolUtil.precacheSound('dialogue/boyfriendText');
		CoolUtil.precacheSound('dialogue/gfText');
		CoolUtil.precacheSound('dialogue/suzukiText');

		//fixed this messy shit lol
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				add(dialogueBox);
			}
			else
			{
				startCountdown();
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		noCountdown = false;
		inCutscene = false;
		isCutscene = false;

		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);

			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0)
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0)
				{
					if (!boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.specialAnim)
					{
						boyfriend.dance();
					}
					if (!dad.animation.curAnim.name.startsWith('sing') && !dad.specialAnim)
					{
						dad.dance();
					}
					if (dad2 != null && !dad2.animation.curAnim.name.startsWith('sing'))
					{
						dad2.dance();
					}
					if (boyfriend2 != null && !boyfriend2.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend2.dance();
					}

					if (curStage == 'restauranteDynamic')
					{
						if (!arsenTriangle.animation.curAnim.name.startsWith('sing'))
						{
							arsenTriangle.dance();
						}
						if (!daniTriangle.animation.curAnim.name.startsWith('sing'))
						{
							daniTriangle.dance();
						}
					}
				}
				else if(dad.danceIdle && !dad.specialAnim && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				// fixed
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

				notes.forEachAlive(function(note:Note) {
					if (note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
			}, 5);
		}
	}

	public function startIntro():Void
		{
			noCountdown = true;
			inCutscene = false;
			isCutscene = false;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = 0;

			startTimer = new FlxTimer().start(0);
		}

	public function addwebmIntro(videoName:String)
		{
			#if !WINDOWS_BUILD
			cutsceneShit = true;

			if (cutsceneShit) {
				var file:String = 'assets/videos/webm/' + videoName + '/' + videoName + '.webm';
				if (OpenFlAssets.exists(file))
				{
					LoadingState.loadAndSwitchState(new VideoState('assets/videos/webm/' + videoName + '/' + videoName + '.webm', new PlayState()));
					trace('loaded' + file);
				}
				else
				{
					LoadingState.loadAndSwitchState(new VideoState('assets/videos/webm/ass.webm', new PlayState()));
					trace('error: cutscene path:' + file + 'not found');
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
			#if WINDOWS_BUILD
			if (songLowercase == songName)
			{
				var video:VideoMP4State = new VideoMP4State();

				hasMP4 = true;
				video.playMP4(Paths.video('mp4/' + videoName + '/' + videoName));
				video.finishCallback = function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
					hasMP4 = false;
				}
			}
			#end
		}

	public function videoOutro(songName:String, videoName:String)
		{
			if (songLowercase == songName)
			{
				#if WINDOWS_BUILD
				var video:VideoMP4State = new VideoMP4State();

				video.playMP4(Paths.video('mp4/' + videoName + '/' + videoName));
				video.finishCallback = function()
				{
					MusicBeatState.switchState(new StoryMenuState());
				}
				#else
				MusicBeatState.switchState(new VideoState('assets/videos/webm/' + videoName + '/' + videoName + '.webm', new StoryMenuState()));
				trace('loaded' + file);
				#end
			}
		}

	function introThree(?countdownSkin:String = 'default', ?onlySprite:Bool = false)
		{
			var countdown = new FlxSprite().loadGraphic(Paths.image('countdown3'));

			switch (countdownSkin)
			{
				case 'default' | 'normal':
					countdown = new FlxSprite().loadGraphic(Paths.image('countdown3'));
				case 'BNB' | 'bnb':
					countdown = new FlxSprite().loadGraphic(Paths.image('bnb/3'));
			}

			countdown.scrollFactor.set();
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

			if (noCountdown == false && !onlySprite) {
				FlxG.sound.play(Paths.sound('intro3'), 0.8);
			}
		}

	function introTwo(?countdownSkin:String = 'default', ?onlySprite:Bool = false)
		{
			var countdown = new FlxSprite().loadGraphic(Paths.image('countdown2'));

			switch (countdownSkin)
			{
				case 'default' | 'normal':
					countdown = new FlxSprite().loadGraphic(Paths.image('countdown2'));
				case 'BNB' | 'bnb':
					countdown = new FlxSprite().loadGraphic(Paths.image('bnb/2'));
			}

			countdown.scrollFactor.set();
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
			if (noCountdown == false && !onlySprite) {
				FlxG.sound.play(Paths.sound('intro2'), 0.8);
			}
		}

	function introOne(?countdownSkin:String = 'default', ?onlySprite:Bool = false)
		{
			var countdown = new FlxSprite().loadGraphic(Paths.image('countdown1'));

			switch (countdownSkin)
			{
				case 'default' | 'normal':
					countdown = new FlxSprite().loadGraphic(Paths.image('countdown1'));
				case 'BNB' | 'bnb':
					countdown = new FlxSprite().loadGraphic(Paths.image('bnb/1'));
			}

			countdown.scrollFactor.set();
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
			if (noCountdown == false && !onlySprite) {
				FlxG.sound.play(Paths.sound('intro1'), 0.8);
			}
		}

	function introGo(?countdownSkin:String = 'default', ?onlySprite:Bool = false)
		{
			var countdown = new FlxSprite().loadGraphic(Paths.image('countdownGo'));

			switch (countdownSkin)
			{
				case 'default' | 'normal':
					countdown = new FlxSprite().loadGraphic(Paths.image('countdownGo'));
				case 'BNB' | 'bnb':
					countdown = new FlxSprite().loadGraphic(Paths.image('bnb/go'));
			}

			countdown.scrollFactor.set();
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

			if (noCountdown == false && !onlySprite) {
				FlxG.sound.play(Paths.sound('introGo'), 0.8);
			}
		}

	function doFlash(?newVal:Float = 1):Void
		{
			var flashValue:Float = newVal;

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

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song, soundSuffix), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// SET SHORT TIME
		if (SONG.song.toLowerCase() == 'casual-duel')
			trueLength = casualTime[0];
		else
			trueLength = songLength;

		FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, "Combo: " + combo + " - " + "Misses: " + songMisses, rpcIcon, true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var dataPath:String;
	var songData:SwagSong;
	var noteData:Array<SwagSection>;

	function generateSong():Void
	{
		dataPath = SONG.song.toLowerCase();
		songData = SONG;

		noteData = songData.notes;

		Conductor.changeBPM(songData.bpm);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		notes.cameras = [camHUD];

		var file:String = Paths.chart(dataPath + "/events");

		if (CoolUtil.difficultyString() == HARDER_THAN_HARD)
		{
			file = Paths.chart(dataPath + '/events-vip');
		}

		if (OpenFlAssets.exists(file)) {
			var eventsData:Array<SwagSection>;

			if (CoolUtil.difficultyString() == HARDER_THAN_HARD)
				eventsData = Song.loadFromJson('events-vip', dataPath).notes;
			else
				eventsData = Song.loadFromJson('events', dataPath).notes;

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

		var bfArrowSkin:String;
		var dadArrowSkin:String;

		bfArrowSkin = 'noteskins/NOTE_assets';
		dadArrowSkin = 'noteskins/NOTE_assets' + UniiStringTools.noteSkinSuffix(SONG.player2);

		if (SONG.arrowSkin != null && SONG.arrowSkin.length > 1) {
			bfArrowSkin = SONG.arrowSkin;
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{
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

					var swagNote:Note;
					
					if (gottaHitNote)
						swagNote = new Note(bfArrowSkin, daStrumTime, daNoteData, oldNote);
					else
						swagNote = new Note(dadArrowSkin, daStrumTime, daNoteData, oldNote);

					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					swagNote.scrollFactor.set();

					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(swagNote.sustainLength / Conductor.stepCrochet);

					if (floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note;

							if (gottaHitNote)
								sustainNote = new Note(bfArrowSkin , daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							else
								sustainNote = new Note(dadArrowSkin , daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);

							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();

							unspawnNotes.push(sustainNote);

							// NOTE: REMEMBER THIS FOR WHEN U NEED TO DO ALTER EGO NOTE OFFSETS!! ! !  ! ! ! !  ! !!! !  ! !  cheesebone remind me to do this when its time.
							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2;
							}
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2;
					}
				}
				else
				{
					eventNotes.push(songNotes);
					eventPushed(songNotes);
				}
			}
		}

		unspawnNotes.sort(sortByShit);

		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}

		generatedMusic = true;

		//trace('checking music gen: ' + generatedMusic);
		//trace('GENERATED MUSIC !! :3');
	}

	var soundSuffix:String = '';

	function preloadSongs()
	{
		if (CoolUtil.difficultyString() == HARDER_THAN_HARD) soundSuffix = 'VIP';

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, soundSuffix));
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(vocals);

		// CACHE SOUNDS !!
		FlxG.sound.cache(Paths.voices(PlayState.SONG.song, soundSuffix));
		FlxG.sound.cache(Paths.inst(PlayState.SONG.song, soundSuffix));

		//trace('cached inst and voices'); // lowercase B) // shut up
	}

	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	function eventPushed(event:Array<Dynamic>) {
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = Std.parseInt(event[3]);
				if(Math.isNaN(charType)) charType = 0;

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
			case 'Cinematics':
				blackBarTop.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarBottom.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

			case 'Subtitles':
				subTxt.setFormat(Paths.font("fnf.otf"), 40, FlxColor.WHITE, CENTER);
				subTxt.scrollFactor.set();
				subTxt.antialiasing = ClientPrefs.globalAntialiasing;
		}

		if(!eventPushedMap.exists(event[2])) {
			eventPushedMap.set(event[2], true);
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function generateStaticArrows(playerArrow:Int):Void
	{
		for (i in 0...4)
		{
			babyArrow = new StrumNote((ClientPrefs.middleScroll || songLowercase == 'tutorial' || songLowercase.startsWith('manager')) ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i);
			babyArrow.downScroll = ClientPrefs.downScroll;

			// NOTE SKINS WORK NOW!!! LOOK INSIDE OF UniiStringTools.hx TO CHANGE
			var skin:String = 'noteskins/NOTE_assets';

			switch (playerArrow)
			{
				case 0:
					skin = 'noteskins/NOTE_assets' + UniiStringTools.noteSkinSuffix(SONG.player2);
				case 1:
					if (SONG.arrowSkin != null && SONG.arrowSkin.length > 1)
						skin = SONG.arrowSkin;
					else
						skin = 'noteskins/NOTE_assets';
			}

			babyArrow.frames = Paths.getSparrowAtlas(skin, null, true);
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

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			babyArrow.ID = i;

			var targetAlpha:Float = 1;

			switch (playerArrow)
			{
				case 0:
					if(ClientPrefs.middleScroll || songLowercase == 'tutorial' || songLowercase.startsWith('manager'))
						targetAlpha = 0;

					opponentStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * playerArrow);

			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
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

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
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

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, "Combo: " + combo + " - " + "Misses: " + songMisses, rpcIcon, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, "Combo: " + combo + " - " + "Misses: " + songMisses, rpcIcon);
			}
			#end
		}
		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused && !ClientPrefs.gamePause)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, "Combo: " + combo + " - " + "Misses: " + songMisses, rpcIcon, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, "Combo: " + combo + " - " + "Misses: " + songMisses, rpcIcon);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (ClientPrefs.gamePause && !paused)
		{
			pressPause();
		}
		#if desktop
		else if (health > 0 && paused)
		{
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", rpcIcon);
		}
		#end

		super.onFocusLost();
	}

	// COOL FREESTYLE ENGINE STUFF ???? THANKS RAPPER ?? ?

	// Remove refrences that can interfere with GC on switch state //
    override function switchTo(nextState:FlxState):Bool
	{
		clearDefines();
		return super.switchTo(nextState);
	}

	function clearDefines()
	{
		// Reset Defines //
		flixel.graphics.FlxGraphic.defaultPersist = false;
		FlxG.keys.preventDefaultKeys = []; // Prevents Arrow key input drops;

		// Handle Refrences //
		unspawnNotes = [];
		notes.clear();
		strumLineNotes.clear();
		playerStrums.clear();

		GPUFunctions.disposeAllTextures();

		openfl.Assets.cache.clear();
		openfl.system.System.gc();

		camHUD.visible = false; // this wasnt rapper this just looks nice lmao
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		vocals.time = FlxG.sound.music.time;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;

	var casualTime:Array<Float> = [73350, 93350, FlxG.sound.music.length];
	var trueLength:Float = 0;

	override public function update(elapsed:Float)
	{
		callOnLuas('onUpdate', [elapsed]);

		if(!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1);

			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			// DONT BLINK ACHIEVEMENT UPDATED
			if(!startingSong && !endingSong && (boyfriend.animation.curAnim.name.startsWith('idle') || boyfriend.animation.curAnim.name.startsWith('danceLeft') || boyfriend.animation.curAnim.name.startsWith('danceRight')))
			{
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) boyfriendIdled = true;
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		// YOU CAN NOW PAUSE WITH THE PAUSE KEYBIND!!! (idk why this wasnt added sooner)
		if (controls.PAUSE && !paused)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				pressPause();
			}
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (health <= 0.8)
		{
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 2;
		}
		else if (health >= 1.2)
		{
			iconP1.animation.curAnim.curFrame = 2;
			iconP2.animation.curAnim.curFrame = 1;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
		}

		// THANKS FOR THE DELTA TIME CODE RAPPER :3
		// (fixed music syncing problems WOO)

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (Conductor.songPosition >= 0) {
					Conductor.interpTime = 0;
					startSong();
				}
			}
		}
		else
		{
			//Conductor.songPosition += FlxG.elapsed * 1000;

			/* Freestyle Music Resync Ported to hell engine */ // im watching you uni
            // Fixes Desync caused by inconsistent FPS also resyncs faster than onStep// 
            if (FlxG.sound.music != null && FlxG.sound.music.playing) {
                var currentTime = FlxG.sound.music.time/1000; // get currentTime
                Conductor.interpTime += elapsed; // increment Elasped

                var delta = Conductor.interpTime - currentTime; // subtract elapsed from current.
                if (Math.abs(delta) >= 0.05) { // avg desync 10Ms. 1/60 = 16ms/2
                    Conductor.interpTime = currentTime; // resync the Itime.
                }
                Conductor.songPosition = Conductor.interpTime * 1000; // increment Conductor.
            }

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if (updateTime)
				{
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					var secondsTotal:Int = Math.floor((trueLength - curTime) / 1000);
					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;

					songPercent = (curTime / trueLength);

					if(curTime < 0)
						curTime = 0;

					if (secondsTotal < 0)
						secondsTotal = 0;

					if (secondsRemaining.length < 2)
						secondsRemaining = '0' + secondsRemaining;

					timeTxt.text = displaySongName + "  [" + minutesRemaining + ':' + secondsRemaining + "]";
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong)
		{
			switch (songLowercase)
			{
				case 'dirty-cheater':
					if (SONG.notes[Std.int(curStep / 16)] != null && !SONG.notes[Std.int(curStep / 16)].mustHitSection)
						timeBar.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
					if (SONG.notes[Std.int(curStep / 16)] != null && SONG.notes[Std.int(curStep / 16)].mustHitSection)
						timeBar.color = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
				default:
					if (!isCameraOnForcedPos)
						moveCameraSection(Std.int(curStep / 16));
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		FlxG.watch.addQuick("MY NUTS ARE FUCKING HANGING DUDE LOLOOLL HI SOURCE CODE GUY!", "");
		FlxG.watch.addQuick("hi guys", "");
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
		if (curStage == 'frostedStage' && !ClientPrefs.pussyMode)
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
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;

			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed * daNote.multSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * SONG.speed * daNote.multSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				// NOTE TOUCHES STRUM LINE
				if (daNote.mustPress)
				{
					if (ClientPrefs.botplay)
					{
						if(daNote.isSustainNote)
						{
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						}
						else if (daNote.strumTime <= Conductor.songPosition)
						{
							goodNoteHit(daNote);
						}
					}
				}

				switch (daNote.noteType) // swapping notes
				{
					case 14:
						if (daNote.canBeHit && daNote.mustPress) {
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					case 15:
						if (daNote.canBeHit && !daNote.mustPress) {
							daNote.visible = true;
						}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
				(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !ClientPrefs.botplay)
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

								// MECHANIC NOTES
								switch(daNote.noteType) 
								{
									case 3: //DODGE NOTE MECHANIC DEATH
										gameOver();
										trace("DODGE NOTE MECHANIC DEATH");
										FlxG.log.add('dead');
								    case 4:
										//do nothing
									default:
										noteMiss(daNote); // NOTE MISS FUNCTION !!
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
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime) {
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

		// input system and some animation functions
		if (!inCutscene && !ClientPrefs.botplay)
		{
			// if statements for managing all input systems in one convenient function to update it.
			globalKeyStatement();
		}

		if (!endingSong && !startingSong)
		{
			// for making testing easier
			#if PLAYTEST_BUILD
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
			#end
			if (FlxG.keys.justPressed.SEVEN && !endingSong)
			{
				persistentUpdate = false;
				paused = true;
				PauseSubState.psChartingMode = true;
				MusicBeatState.switchState(new ChartingState());

				#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
			}

			if (FlxG.keys.justPressed.EIGHT && !endingSong)
			{
				persistentUpdate = false;
				paused = true;
				FlxG.sound.music.stop();

				// if you hold ctrl + 8 it will switch to the boyfriend instead of the dad.
				// i added shift and alt too :3
				if (FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.ALT)
					MusicBeatState.switchState(new CharacterEditorState(SONG.player1));
				else
					MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
			}

			if (FlxG.keys.justPressed.SIX && !endingSong)
			{
				persistentUpdate = false;
				paused = true;
				FlxG.sound.music.onComplete = FUCKING_CHEATER;

				FlxG.sound.music.onComplete();
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', ClientPrefs.botplay);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
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
					if(ClientPrefs.specialEffects && curStage == 'restaurante') {
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
								if (CoolUtil.difficultyString() == HARDER_THAN_HARD) {
									phillyBlackTween = FlxTween.tween(phillyCounter, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
								}
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
								if (CoolUtil.difficultyString() == HARDER_THAN_HARD) {
									phillyBlackTween = FlxTween.tween(phillyCounter, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
								}
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
					var pogging:Float = Std.parseFloat(value1);
					var poggerLength:Float = Std.parseFloat(value2);

					switch (curStage)
					{
						case 'restauranteCream':
							switch (pogging)
							{
								case 0:
									FlxTween.tween(phillyBlack, {alpha: 1}, 0.001, {ease: FlxEase.quadInOut});
									FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
									gf.visible = false;
									boyfriend.visible = false;
									counter.visible = false;
								case 1:
									FlxTween.tween(phillyBlack, {alpha: 0}, 0.001, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											remove(phillyBlack);
										}
									});
									FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
									gf.visible = true;
									boyfriend.visible = true;
									counter.visible = true;
							}

						case 'restauranteAvi':
							phillyBlackTween = FlxTween.tween(freezeFade, {alpha: pogging}, poggerLength, {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									phillyBlackTween = null;
								}
							});

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
							if (ClientPrefs.specialEffects && !ClientPrefs.pussyMode)
							{
								switch (pogging)
								{
									case 0:
										doFlash();
										freezePogging = true;
										snow.visible = true;

										if (ClientPrefs.cameraShake) {
											dadPog = true;
											boyfriendPog = true;
										}
		
										freezeFadeTween(scoreTxt, 0, poggerLength);
										freezeFadeTween(healthBar, 0, poggerLength);
										freezeFadeTween(healthBarOV, 0, poggerLength);
										freezeFadeTween(iconP1, 0, poggerLength);
										freezeFadeTween(iconP2, 0, poggerLength);
		
										if (redFade.alpha != 1)
											freezeFadeTween(freezeFade, 1, poggerLength);

										defaultCamZoom = 1.1;
									case 1:
										doFlash();
										freezePogging = false;
										snow.visible = false;
										dadPog = false;
										boyfriendPog = false;
		
										freezeFadeTween(scoreTxt, 1, poggerLength);
										freezeFadeTween(healthBar, 1, poggerLength);
										freezeFadeTween(healthBarOV, 1, poggerLength);
										freezeFadeTween(iconP1, 1, poggerLength);
										freezeFadeTween(iconP2, 1, poggerLength);
		
										if (freezeFade.alpha != 0)
											freezeFadeTween(freezeFade, 0, poggerLength);
										if (songMisses > 7)
										{
											if (redFade.alpha != 1)
												freezeFadeTween(redFade, 1, 2);
										}

										defaultCamZoom = staticCamZoom;
									case 2:
										if (freezePogging == true)
											freezePogging = false;

										dadPog = false;
										boyfriendPog = false;

										freezeFadeTween(scoreTxt, 0, poggerLength);
										freezeFadeTween(healthBar, 0, poggerLength);
										freezeFadeTween(healthBarOV, 0, poggerLength);
										freezeFadeTween(iconP1, 0, poggerLength);
										freezeFadeTween(iconP2, 0, poggerLength);
		
										if (redFade.alpha != 1)
											freezeFadeTween(freezeFade, 1, poggerLength);
									case 3:
										if (freezePogging == true)
											freezePogging = false;

										dadPog = false;
										boyfriendPog = false;

										freezeFadeTween(scoreTxt, 1, poggerLength);
										freezeFadeTween(healthBar, 1, poggerLength);
										freezeFadeTween(healthBarOV, 1, poggerLength);
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
							else if (ClientPrefs.pussyMode)
							{
								switch (pogging)
								{
									case 0:
										doFlash();
										freezePogging = true;
										snow.visible = true;

										if (ClientPrefs.cameraShake) {
											dadPog = true;
											boyfriendPog = true;
										}

										defaultCamZoom = 1.1;
									case 1:
										doFlash();
										freezePogging = false;
										snow.visible = false;
										dadPog = false;
										boyfriendPog = false;

										defaultCamZoom = staticCamZoom;
									case 2:
										if (freezePogging == true)
											freezePogging = false;

										dadPog = false;
										boyfriendPog = false;

									case 3:
										if (freezePogging == true)
											freezePogging = false;

										dadPog = false;
										boyfriendPog = false;
								}
							}
						default:
							if (phillyBlack != null) {
								phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: pogging}, poggerLength, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
							}
					}

				case 'Add Camera Zoom':
					if(FlxG.camera.zoom < 1.35 && ClientPrefs.camZoomOut) {
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = camGameZoom;
						if(Math.isNaN(hudZoom)) hudZoom = camHudZoom;
	
						FlxG.camera.zoom += camZoom;
						camHUD.zoom += hudZoom;
					}

				case 'Edit Camera Settings':
					if (ClientPrefs.camZoomOut)
					{
						camPercentFloat = Std.parseInt(value1);

						var split:Array<String> = value2.split(',');
						var newGameZoom:Float = Std.parseFloat(split[0].trim());
						var newHUDzoom:Float = Std.parseFloat(split[1].trim());

						if (Math.isNaN(newGameZoom))
						{
							// do literally nothing
						}
						else
						{
							camGameZoom = newGameZoom;
							camHudZoom = newHUDzoom;
						}

						trace(camPercentFloat);
						trace(camGameZoom);
						trace(camHudZoom);
					}

				case 'Play Animation':
					trace('Anim to play: ' + value1);

					var val2:Int = Std.parseInt(value2);
					if(Math.isNaN(val2)) val2 = 0;
	
					var char:Character = dad;
					switch(val2) {
						case 1:
							char = boyfriend;
						case 2:
							char = gf;
						case 3:
							if (dad2 != null) char = dad2;
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
							case 3:
								dadPog = true;
								boyfriendPog = true;
						}
					}

				case 'Alt Idle Animation':
					var val:Int = Std.parseInt(value1);
					if(Math.isNaN(val)) val = 0;
	
					var char:Character = dad;
					switch(val) {
						case 1:
							char = boyfriend;
						case 2:
							char = gf;
						case 3:
							if (dad2 != null) char = dad2;
					}
					char.idleSuffix = value2;
					char.recalculateDanceIdle();

				case 'Screen Shake':
					if (ClientPrefs.cameraShake) {
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
					}

				// this is my old code but its still here to use staticCamZoom variable and to not change the old charts. It may sound confusing but uhh... I'm weird :P
				case 'Change CamZoom':
					if (ClientPrefs.camZoomOut)
					{
						var camZoomValue:Int = Std.parseInt(value1);
						if(Math.isNaN(camZoomValue)) camZoomValue = 0;

						switch (camZoomValue)
						{
							case 0: //reset camera zoom
								defaultCamZoom = staticCamZoom;
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

				// actually changes defaultCamZoom variable number.
				case 'Change NumZoom':
					if (ClientPrefs.camZoomOut)
					{
						var zoom:Float = Std.parseFloat(value1);

						if (value1 == 'reset')
						{
							defaultCamZoom = staticCamZoom;
						}
						else
						{
							defaultCamZoom = zoom;
						}
					}

				case 'Flash':
					var flashValue:Float = Std.parseFloat(value1);

					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, flashValue);
					else if (!songLowercase.startsWith('manager'))
						FlxG.camera.flash(FlxColor.BLACK, flashValue);

				/*
				case 'Load Flash': // same as flash but invisible
					var coolFolder:String = 'effects/'; //change folder easily
					var intenseBool:Int = Std.parseInt(value2); //intensity

					var flashSprite = new FlxSprite().loadGraphic(Paths.image('effects/flashNormalBlue'));
					var flashMirror = new FlxSprite().loadGraphic(Paths.image('effects/flashIntenseBlue'));

					if (Math.isNaN(intenseBool))
						intenseBool = 1;

					if (ClientPrefs.flashing)
					{
						if (intenseBool >= 1) {
							switch (value1)
							{
								case 'blue' | 'Blue' | 'BLUE':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));

								case 'green' | 'Green' | 'GREEN':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseGreen'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseGreen'));

								case 'pink' | 'Pink' | 'PINK':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntensePink'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntensePink'));

								case 'red' | 'Red' | 'RED':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseRed'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseRed'));

								default:
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
							}
							trace('loaded flash sprites succesfully');
						} else {
							switch (value1)
							{
								case 'blue' | 'Blue' | 'BLUE':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalBlue'));
	
								case 'green' | 'Green' | 'GREEN':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalGreen'));
	
								case 'pink' | 'Pink' | 'PINK':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalPink'));
	
								case 'red' | 'Red' | 'RED':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalRed'));
	
								default:
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalBlue'));
							}
							trace('loaded flash sprites succesfully');
						}

						flashSprite.scrollFactor.set(0, 0);
						flashSprite.updateHitbox();
						flashSprite.visible = false;
						add(flashSprite);

						if (intenseBool >= 1) {
							flashMirror.scrollFactor.set(0, 0);
							flashMirror.updateHitbox();
							flashMirror.visible = false;
							add(flashMirror);
						}

						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							if (intenseBool >= 1)
								flashMirror.destroy();

							flashSprite.destroy();

							trace('destroyed flash sprites, cached in memory');
						});
					}

				case 'Flash Color': // I KNOW THIS IS REALLY BAD... BUT SHUT UP
					var coolFolder:String = 'effects/'; //change folder easily
					var intenseBool:Int = Std.parseInt(value2); //intensity

					var flashSprite = new FlxSprite().loadGraphic(Paths.image('effects/flashNormalBlue'));
					var flashMirror = new FlxSprite().loadGraphic(Paths.image('effects/flashIntenseBlue'));

					var randomChance:Int = FlxG.random.int(1, 4);

					if (Math.isNaN(intenseBool))
						intenseBool = 1;

					if (ClientPrefs.flashing)
					{
						if (intenseBool >= 1) {
							switch (value1)
							{
								case 'blue' | 'Blue' | 'BLUE':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
									FlxG.log.add('INTENSE blue flash sprite');

								case 'green' | 'Green' | 'GREEN':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseGreen'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseGreen'));
									FlxG.log.add('INTENSE green flash sprite');

								case 'pink' | 'Pink' | 'PINK':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntensePink'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntensePink'));
									FlxG.log.add('INTENSE pink flash sprite');

								case 'red' | 'Red' | 'RED':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseRed'));
									flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseRed'));
									FlxG.log.add('INTENSE red flash sprite');

								default:
									switch (randomChance)
									{
										case 1: // blue
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
											flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseBlue'));
										case 2: // green
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseGreen'));
											flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseGreen'));
										case 3: // pink
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntensePink'));
											flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntensePink'));
										case 4: // red
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseRed'));
											flashMirror = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashIntenseRed'));
									}

								FlxG.log.add('RANDOM INTENSE FLASH SPRITE');
							}
						} else {
							switch (value1)
							{
								case 'blue' | 'Blue' | 'BLUE':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalBlue'));
									FlxG.log.add('blue flash sprite');
	
								case 'green' | 'Green' | 'GREEN':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalGreen'));
									FlxG.log.add('green flash sprite');
	
								case 'pink' | 'Pink' | 'PINK':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalPink'));
									FlxG.log.add('pink flash sprite');
	
								case 'red' | 'Red' | 'RED':
									flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalRed'));
									FlxG.log.add('red flash sprite');
	
								default:
									switch (randomChance)
									{
										case 1: // blue
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalBlue'));
										case 2: // green
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalGreen'));
										case 3: // pink
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalPink'));
										case 4: // red
											flashSprite = new FlxSprite().loadGraphic(Paths.image(coolFolder + 'flashNormalRed'));
									}

								FlxG.log.add('random flash sprite');
							}
						}

						flashSprite.scrollFactor.set(0, 0);
						flashSprite.updateHitbox();
						flashSprite.screenCenter();
						flashSprite.flipX = false;
						add(flashSprite);

						if (intenseBool >= 1) {
							if (intenseBool == 1) {
								flashMirror.scrollFactor.set(0, 0);
								flashMirror.updateHitbox();
								flashMirror.screenCenter();
								flashMirror.flipX = false;
								add(flashMirror);
							} else if (intenseBool >= 2) {
								flashMirror.scrollFactor.set(0, 0);
								flashMirror.updateHitbox();
								flashMirror.screenCenter();
								flashMirror.flipX = true;
								add(flashMirror);
							}

							// hurts yo eyes less ew
							flashSprite.alpha = 0.8;
							flashMirror.alpha = 0.8;

							// big camera
							flashSprite.cameras = [camHUD];
							flashMirror.cameras = [camHUD];
						}

						FlxTween.tween(flashSprite, {alpha: 0}, 0.3, {
							onComplete: function(twn:FlxTween)
							{
								flashSprite.destroy();
							}
						});

						if (intenseBool >= 1) {
							FlxTween.tween(flashMirror, {alpha: 0}, 0.3, {
								onComplete: function(twn:FlxTween)
								{
									flashMirror.destroy();
								}
							});
						}
					}
				*/

				case 'Change Character':
					var charType:Int = Std.parseInt(value1);
					if(Math.isNaN(charType)) charType = 0;

					switch (charType)
					{
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
							setOnLuas('boyfriendName', boyfriend.curCharacter);

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
							}
							setOnLuas('dadName', dad.curCharacter);

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
							setOnLuas('gfName', gf.curCharacter);
					}
					if (CoolUtil.difficultyString() == HARDER_THAN_HARD && songLowercase == 'cultured') {
						doFlash();
					}
					reloadAllBarColors();

				case 'Summon Lil Man' | 'Spawn Diples':
					if (dad2 != null) {
						var littleBool:Int = Std.parseInt(value1);
						var flashOn:Int = Std.parseInt(value2);
	
						if(Math.isNaN(littleBool))
							littleBool = 0;
						if(Math.isNaN(littleBool))
							littleBool = 0;

						switch(littleBool) {
							case 0: //SUMMON!!!
								dad2.visible = true;
							case 1: //KILL.
								dad2.visible = false;
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
					}

				case 'Opponent Anim': //this is really dumb DONT LOOK AT THIS!!!
					var activeChar:Int = Std.parseInt(value1);
					var customSection:Int = Std.parseInt(value2);

					if(Math.isNaN(activeChar))
						activeChar = 0;
					if(Math.isNaN(customSection))
						customSection = 0;

					if (dad2 != null)
					{
						switch(activeChar) {
							case 0: //DEFAULT
								isDad = false;
								isDad2 = false;
								isGF = false;

							case 1: //DAD
								isDad = true;
								isDad2 = false;
								isGF = false;
								if (dad2.visible == true) dad2.dance();

								iconP2.changeIcon(dad.healthIcon);
								healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
									FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
								healthBar.updateBar();

							case 2: //DAD2
								isDad = false;
								isDad2 = true;
								isGF = false;
								dad.dance();

								iconP2.changeIcon(dad2.healthIcon);
								healthBar.createFilledBar(FlxColor.fromRGB(dad2.healthColorArray[0], dad2.healthColorArray[1], dad2.healthColorArray[2]),
									FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
								healthBar.updateBar();

							case 3: //GF
								isDad = false;
								isDad2 = false;
								isGF = true;
								dad.dance();
								if (dad2.visible == true) dad2.dance();
						}
						switch (customSection) {
							case 0:
								isCameraOnForcedPos = false;
							case 1:
								camFollow.set(dad2.getMidpoint().x + 150, dad2.getMidpoint().y - 100);
								camFollow.x += 0;
								camFollow.y += 200;
								isCameraOnForcedPos = true;
							default:
								return;
						}
					}

				case 'Set Singer':
					var activeBoyfriend:String = value1; // for bf tag
					var activeDad:String = value2; // for dad tag

					switch(activeBoyfriend)
					{
						case 'avinera':
							isBoyfriend = true;
							isUnii = false;

							boyfriend2.dance();
						case 'unii':
							isUnii = true;
							isBoyfriend = false;

							boyfriend.dance();
						case 'dynamic duo':
							isDuo = true;
							isBoyfriend = false;
							isUnii = false;
						case 'reset':
							isBoyfriend = false;
							isUnii = false;
							isDuo = false;

							boyfriend.dance();
							boyfriend2.dance();
					}

					switch(activeDad)
					{
						case 'cheese':
							isDad = true;
							isGF = false;

							gf.dance();
						case 'suzuki':
							isGF = true;
							isDad = false;

							dad.dance();
						case 'fan favorites':
							isDad = true;
							isGF = true;
						case 'reset':
							isDad = false;
							isGF = false;

							dad.dance();
							gf.dance();
					}

				case 'Comic Toggle':
					var arsenToggle:String = value1;
					var daniToggle:String = value2;

					if (arsenToggle == 'true') {
						isArsen = true;
					} else {
						isArsen = false;
					}

					if (daniToggle == 'true') {
						isDani = true;
					} else {
						isDani = false;
					}

				case 'Comic Spawn':
					var arsenAlpha:Int = Std.parseInt(value1);
					var daniAlpha:Int = Std.parseInt(value2);

					FlxG.camera.flash();

					arsenTriangle.alpha = arsenAlpha;
					daniTriangle.alpha = daniAlpha;

				case 'Cream Cheese Pan':
					switch (Std.parseInt(value1))
					{
						case 0:
							isCameraOnForcedPos = false;
						case 1:
							camFollow.set(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
							camFollow.x += gf.cameraPosition[0];
							camFollow.y += gf.cameraPosition[1];
							isCameraOnForcedPos = true;
						case 2:
							camFollow.set(bagel.getGraphicMidpoint().x, bagel.getGraphicMidpoint().y);
							isCameraOnForcedPos = true;
					}

				case 'KEY CHANGE':
					switch (Std.parseInt(value1))
					{
						case 0:
							bagelSinging = false;
						case 1:
							bagelSinging = true;
							bagel.animation.play('ice cream change');
					}

				case 'Cheater Event':
					if (value2 == 'on')
						dirtyChair.alpha = 1;
					else if (value2 == 'off')
						dirtyChair.alpha = 0;
					else
						songInfo.animation.play(value1);

				case 'Set Freeze Fade':
					freezeFade.alpha = Std.parseFloat(value1);

				case 'Cinematics':
					switch (Std.parseInt(value1))
					{
						case 0:
							FlxTween.tween(blackBarTop, {y: -750}, 1, {ease: FlxEase.quadOut});
							FlxTween.tween(blackBarBottom, {y: 750}, 1, {ease: FlxEase.quadOut});
						case 1:
							FlxTween.tween(blackBarTop, {y: -610}, 1, {ease: FlxEase.quadOut});
							FlxTween.tween(blackBarBottom, {y: 610}, 1, {ease: FlxEase.quadOut});
					}

					var newOpacity:Int = 0;
					switch (Std.parseInt(value2))
					{
						case 1:
							newOpacity = 0;
						default:
							newOpacity = 1;
					}

					FlxTween.tween(scoreTxt, {alpha: newOpacity}, 1, {ease: FlxEase.quadOut});
					FlxTween.tween(accText, {alpha: newOpacity}, 1, {ease: FlxEase.quadOut});
					FlxTween.tween(healthBar, {alpha: newOpacity}, 1, {ease: FlxEase.quadOut});
					FlxTween.tween(healthBarOV, {alpha: newOpacity}, 1, {ease: FlxEase.quadOut});
					FlxTween.tween(iconP1, {alpha: newOpacity}, 1, {ease: FlxEase.quadOut});
					FlxTween.tween(iconP2, {alpha: newOpacity}, 1, {ease: FlxEase.quadOut});

				case 'Subtitles':
					if (value1 == 'null')
						subTxt.text = "";
					else
						subTxt.text = value1;
			}
			callOnLuas('onEvent', [eventName, value1, value2]);
		}
		//trace('triggered event note: ' + eventName + ' | ' + value1 + ' | ' + value2);
	}

	function moveCameraSection(?id:Int = 0):Void
	{
		if (songLowercase == 'manager-strike-back')
		{
			camFollow.set(dad.getMidpoint().x + 150 + dadnoteMovementXoffset + bfnoteMovementXoffset, dad.getMidpoint().y - 100 + dadnoteMovementYoffset + bfnoteMovementYoffset);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			timeBar.color = 0xFFFF0000;
		}
		else
		{
			if (SONG.notes[id] != null && !SONG.notes[id].mustHitSection)
			{
				moveCamera(true);
				callOnLuas('onMoveCamera', ['dad']);
			}
	
			if (SONG.notes[id] != null && SONG.notes[id].mustHitSection)
			{
				moveCamera(false);
				callOnLuas('onMoveCamera', ['boyfriend']);
			}
		}
	}

	public function moveCamera(isDad:Bool) {
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150 + dadnoteMovementXoffset, dad.getMidpoint().y - 100 + dadnoteMovementYoffset);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			timeBar.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100 + bfnoteMovementXoffset, boyfriend.getMidpoint().y - 100 + bfnoteMovementYoffset);
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];
			timeBar.color = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong():Void
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

	public function endSong():Void
	{
		endingSong = true;

		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		KillNotes();

		FlxTween.tween(camHUD, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});

		if(achievementObj != null)
		{
			return;
		}
		else
		{
			// this is probably not how u structure these but i dont give a shit i like how it looks
			var achieve:String = checkForAchievement([
				'tutorial_beat',
				'week1_beat',
				'week2_beat',
				'dynamic_duo',
				'below_zero',

				'restaurante_ex',
				'milkshake_ex',
				'cultured_ex',

				'beat_bonus',
				'beat_chara',
				'beat_sans',
				'beat_onion',

				'ur_bad',
				'ur_good',
				'oversinging',
				'hype',
				'two_keys',
				'toastie'
			]);

			if(achieve != null) {
				startAchievement(achieve, 'achievement');
				return;
			}
		}

		callOnLuas('onEndSong', []);
		if (SONG.validScore)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
		}

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if (PauseSubState.psChartingMode)
			{
				MusicBeatState.switchState(new ChartingState());

				trace('chartered char.t.  . CERBERA !!	yup');
			}
			else
			{
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
					MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freaky_overture'));
					skippedDialogue = false;

					trace('WENT BACK TO FREEPLAY??');

					MainMenuState.cursed = false; // makes you not cursed
				}

				switch (songLowercase)
				{
					case 'cream-cheese':
						if (FlxG.save.data.beatCream == null || FlxG.save.data.beatCream == false) {
							FlxG.save.data.beatCream = true;
							trace('beat cream');
						}
					case 'dirty-cheater':
						if (FlxG.save.data.beatOnion == null || FlxG.save.data.beatOnion == false) {
							FlxG.save.data.beatOnion = true;
							trace('YOU FUCKING CHEATER !!! u beat it btw');
						}
				}
			}
		});
	}

	var achievementObj:AchievementObject = null;

	function startAchievement(achieve:String, ?Type:String = 'achievement')
	{
		var TypeString:String = Type;

		achievementObj = new AchievementObject(achieve, camOther, TypeString);
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

	public function KillNotes() {
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

	private function popUpScore(note:Note = null, ?missSpr:Bool = false):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "perfect";

		// weird code to check every time if its a miss lmao idk if this is good or not x)
		if (missSpr) 
		{
			daRating = 'miss';
			combo = 0;
			songScore -= 50; // BIG
		}
		else
		{
			if (noteDiff > safeZoneOffset * 0.8)
			{
				daRating = 'shit';
				score = 0;
				shits++;
			}
			else if (noteDiff > safeZoneOffset * 0.6)
			{
				daRating = 'bad';
				score = 50;
				bads++;
			}
			else if (noteDiff > safeZoneOffset * 0.4)
			{
				daRating = 'good';
				score = 100;
				goods++;
			}
			else if (noteDiff > safeZoneOffset * 0.2)
			{
				daRating = 'sick';
				score = 330;
				sicks++;
			}
			else
			{
				daRating = 'perfect';
				score = 350;
				perfects++;
				spawnNoteSplashOnNote(note);
			}

			songScore += score;
			songHits++;
		}
		RecalculateRating();

		rating.loadGraphic(Paths.image('rating-stuffs/' + daRating));
		rating.screenCenter();
		rating.x = FlxG.width * 0.35 - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.comboShown;
		rating.x += comboOffset[0];
		rating.y -= comboOffset[1];
		add(rating);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = ClientPrefs.globalAntialiasing;

		rating.updateHitbox();

		if (!missSpr)
		{
			var daLoop:Int = 0;
			var xThing:Float = 0;
			var seperatedScore:Array<Int> = [];

			if (combo >= 1000) {
				seperatedScore.push(Math.floor(combo / 1000) % 10);
			}
			seperatedScore.push(Math.floor(combo / 100) % 10);
			seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);

			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = FlxG.width * 0.35 + (43 * daLoop) + 25;
				numScore.y += 80;

				numScore.x += comboOffset[0];
				numScore.y -= comboOffset[1];

				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				numScore.visible = !ClientPrefs.comboShown;

				if (combo >= 10 || combo == 0) add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
				if (numScore.x > xThing) xThing = numScore.x;
			}
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function globalKeyStatement():Void
	{
		switch (ClientPrefs.inputSystem)
		{
			case "Kade Engine":
				kadeKeyShit(); // kade + shubs + me
			case "Psych Engine":
				psychKeyShit(); // shubs
			case "Vanilla":
				vanillaKeyShit(); // ninjamuffin
			case "Controller":
				controllerKeyShit(); // cheedbone real
		}
	}

	// kade engine 1.5 input system (but with psych stuff and also kinda my own stuff so i kinda made by own input B)
	private function kadeKeyShit():Void
	{
		// CONTROLS AND SHIT
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

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP]; // pressing keys
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR]; // releasing keys
		var controlHoldArray:Array<Bool> = [left, down, up, right]; // holding keys

		// HUGE IF STATEMENT WITH ALL THE INPUT SYSTEM STUFF!
		if (!boyfriend.stunned && generatedMusic)
		{
			if (controlHoldArray.contains(true) && !endingSong) // HOLDING
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
					&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
						goodNoteHit(daNote);
					}
				});
			}

			if ((controlArray.contains(true) || controlReleaseArray.contains(true) || controlHoldArray.contains(true)) && !endingSong) // PRESSING
			{
				var sortedNotesList:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var noteToKill:Array<Note> = []; // notes to kill

				notes.forEachAlive(function(daNote:Note) // deleting some weird notes
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (directionList.contains(daNote.noteData))
						{
							for (coolNote in sortedNotesList)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{
									// if it's the same note twice, below 10ms distance, it will kill it
									noteToKill.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{
									// if daNote is earlier than existing note (coolNote), replace
									sortedNotesList.remove(coolNote);
									sortedNotesList.push(daNote);
									break;
								}
							}
						}
						else
						{
							sortedNotesList.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in noteToKill)
				{
					trace("killed noteToKill at: " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sorting

				var dontCheck = false;

				for (x in 0...controlArray.length) // for anti mash
				{
					if (controlArray[x] && !directionList.contains(x))
						dontCheck = true;
				}

				if (sortedNotesList.length > 0 && !dontCheck)
				{
					if (!ClientPrefs.ghostTapping) // hitting a note that ur not supposed to hit
					{
						for (x in 0...controlArray.length)
						{
							if (controlArray[x] && !directionList.contains(x))
								ghostMiss(controlArray[x], x, true);
						}
					}

					for (coolNote in sortedNotesList) // hitting a note normally
					{
						if (controlArray[coolNote.noteData])
							goodNoteHit(coolNote);
					}
				}
				else if (!ClientPrefs.ghostTapping)
				{
					for (x in 0...controlArray.length)
					{
						ghostMiss(controlArray[x], x, true);
					}
				}

				for (i in 0...controlArray.length)
				{
					if (!keysPressed[i] && controlArray[i])
						keysPressed[i] = true;
				}

				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
			else if (boyfriend2 != null && boyfriend2.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend2.singDuration && boyfriend2.animation.curAnim.name.startsWith('sing')
			&& !boyfriend2.animation.curAnim.name.endsWith('miss'))
				boyfriend2.dance();
			else if (daniTriangle != null && daniTriangle.holdTimer > Conductor.stepCrochet * 0.001 * daniTriangle.singDuration && daniTriangle.animation.curAnim.name.startsWith('sing')
			&& !daniTriangle.animation.curAnim.name.endsWith('miss'))
				daniTriangle.dance();
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if (controlReleaseArray[spr.ID]) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	// psych engine 4.2 input system
	private function psychKeyShit():Void
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
							} else if (canMiss)
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

					var achieve:String = checkForAchievement(['oversinging']);
					if (achieve != null) {
						startAchievement(achieve);
					}
				}
				else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
				else if (boyfriend2 != null && boyfriend2.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend2.singDuration && boyfriend2.animation.curAnim.name.startsWith('sing')
				&& !boyfriend2.animation.curAnim.name.endsWith('miss'))
					boyfriend2.dance();
				else if (daniTriangle != null && daniTriangle.holdTimer > Conductor.stepCrochet * 0.001 * daniTriangle.singDuration && daniTriangle.animation.curAnim.name.startsWith('sing')
				&& !daniTriangle.animation.curAnim.name.endsWith('miss'))
					daniTriangle.dance();
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

	// friday night funkin vanilla 0.2.7.1 input system (why is that version so long lmfao)
	private function vanillaKeyShit():Void
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

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		// oops forgot to add
		for (i in 0...controlArray.length)
		{
			if (!keysPressed[i] && controlArray[i])
				keysPressed[i] = true;
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && !up && !down && !right && !left && boyfriend.animation.curAnim.name.startsWith('sing')
		&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			boyfriend.dance();

		if (boyfriend2 != null && boyfriend2.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend2.singDuration && !up && !down && !right && !left && boyfriend2.animation.curAnim.name.startsWith('sing')
		&& !boyfriend2.animation.curAnim.name.endsWith('miss'))
			boyfriend2.dance();

		if (daniTriangle != null && daniTriangle.holdTimer > Conductor.stepCrochet * 0.001 * daniTriangle.singDuration && !up && !down && !right && !left && daniTriangle.animation.curAnim.name.startsWith('sing')
		&& !daniTriangle.animation.curAnim.name.endsWith('miss'))
			daniTriangle.dance();

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function controllerKeyShit()
	{
		// i forgor
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void //You didn't hit the key and let it go offscreen, also used by Hurt Notes
	{
		health -= 0.05;
		songMisses++;

		if (ClientPrefs.missSounds) {
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.2);
			vocals.volume = 0;
		}
		RecalculateRating();

		if (curStage == 'restauranteDynamic')
		{
			if (isBoyfriend)
				boyfriend.playAnim('singGLOBALmiss', true);
			if (isUnii)
				boyfriend2.playAnim('singGLOBALmiss', true);
			if (isDuo) {
				boyfriend.playAnim('singGLOBALmiss', true);
				boyfriend2.playAnim('singGLOBALmiss', true);
			}
		}
		else
		{
			switch (SONG.player1) // global misses
			{
				case 'arsen' | 'dansilot' | 'avinera':
					boyfriend.playAnim('singGLOBALmiss', true);

				default:
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
		}

		if (ClientPrefs.specialEffects && curStage == 'frostedStage' && songMisses > 7 && !ClientPrefs.pussyMode)
		{
			if (freezeFade.alpha != 1)
				freezeFadeTween(redFade, 1, 2);
		}

		popUpScore(daNote, true); // NOTE MISS POPUP!!

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05;
			combo = 0;

			if(!endingSong) {
				if(ghostMiss) ghostMisses++;
				songMisses++;
			}
			RecalculateRating();

			if(ClientPrefs.missSounds){
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.2);
				vocals.volume = 0;
			}

			if (curStage == 'restauranteDynamic')
			{
				if (isBoyfriend)
					boyfriend.playAnim('singGLOBALmiss', true);
				if (isUnii)
					boyfriend2.playAnim('singGLOBALmiss', true);
				if (isDuo) {
					boyfriend.playAnim('singGLOBALmiss', true);
					boyfriend2.playAnim('singGLOBALmiss', true);
				}
			}
			else
			{
				switch (SONG.player1) // global misses
				{
					case 'arsen' | 'dansilot' | 'avinera':
						boyfriend.playAnim('singGLOBALmiss', true);

					default:
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
				}
			}

			if (ClientPrefs.specialEffects && curStage == 'frostedStage' && songMisses > 7 && !ClientPrefs.pussyMode)
			{
				if (freezeFade.alpha != 1)
					freezeFadeTween(redFade, 1, 2);
			}
		}
	}

	function vanillaNoteMiss(direction:Int = 1):Void {
		if (!boyfriend.stunned)
		{
			health -= 0.05;
			combo = 0;
			songScore -= 10;
			songMisses++;

			if (ClientPrefs.missSounds) {
				vocals.volume = 0;
			}
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.2);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			if (curStage == 'restauranteDynamic')
			{
				if (isBoyfriend)
					boyfriend.playAnim('singGLOBALmiss', true);
				if (isUnii)
					boyfriend2.playAnim('singGLOBALmiss', true);
				if (isDuo) {
					boyfriend.playAnim('singGLOBALmiss', true);
					boyfriend2.playAnim('singGLOBALmiss', true);
				}
			}
			else
			{
				switch (SONG.player1) // global misses
				{
					case 'arsen' | 'dansilot' | 'avinera':
						boyfriend.playAnim('singGLOBALmiss', true);
	
					default:
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
				}
			}

			if (ClientPrefs.specialEffects && curStage == 'frostedStage' && songMisses > 7 && !ClientPrefs.pussyMode)
			{
				if (freezeFade.alpha != 1)
					freezeFadeTween(redFade, 1, 2);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		if (leftP)
			vanillaNoteMiss(0);
		if (downP)
			vanillaNoteMiss(1);
		if (upP)
			vanillaNoteMiss(2);
		if (rightP)
			vanillaNoteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		var altAnim:String = "";

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].altAnim || note.noteType == 1) {
				altAnim = '-alt';
			}
		}

		var animToPlay:String = '';
		switch (Math.abs(note.noteData))
		{
			case 0:
				animToPlay = 'singLEFT';
			case 1:
				animToPlay = 'singDOWN';
			case 2:
				animToPlay = 'singUP';
			case 3:
				animToPlay = 'singRIGHT';
		}

		if (dadPog && !note.isSustainNote) {
			switch (Math.abs(note.noteData))
			{
				case 0:
					dadnoteMovementXoffset = -30;
					dadnoteMovementYoffset = 0;
				case 1:
					dadnoteMovementYoffset = 30;
					dadnoteMovementXoffset = 0;
				case 2:
					dadnoteMovementYoffset = -30;
					dadnoteMovementXoffset = 0;
				case 3:
					dadnoteMovementXoffset = 30;
					dadnoteMovementYoffset = 0;
			}
		}

		//THIOS OPNE IS FOR DADDY DEAREST
		switch (note.noteType)
		{
			case 2: //hey
				if (dad.animOffsets.exists('hey')) {
					dad.playAnim('hey', true);
					dad.specialAnim = true;
					dad.heyTimer = 0.6;
				}
			case 6: //gf
				gf.playAnim(animToPlay + altAnim, true);

				gf.holdTimer = 0;
			case 7: //bf2
				boyfriend2.playAnim(animToPlay + altAnim, true);

				boyfriend2.holdTimer = 0;
			case 8: //dad
				dad.playAnim(animToPlay + altAnim, true);

				dad.holdTimer = 0;
			case 9: //bf
				boyfriend.playAnim(animToPlay + altAnim, true);

				boyfriend.holdTimer = 0;
			case 10: //comic arsen
				arsenTriangle.playAnim(animToPlay + altAnim, true);

				arsenTriangle.holdTimer = 0;
			case 11: //comic dani
				daniTriangle.playAnim(animToPlay + altAnim, true);

				daniTriangle.holdTimer = 0;
			case 12: //everyone sings at the same time except avi cause he plays guitar
				dad.playAnim(animToPlay + altAnim, true);
				boyfriend2.playAnim(animToPlay + altAnim, true);
				gf.playAnim(animToPlay + altAnim, true);

				arsenTriangle.playAnim(animToPlay + altAnim, true);
				daniTriangle.playAnim(animToPlay + altAnim, true);

				dad.holdTimer = 0;
				boyfriend2.holdTimer = 0;
				gf.holdTimer = 0;

				arsenTriangle.holdTimer = 0;
				daniTriangle.holdTimer = 0;
			case 13: //none
				// do nothing lolz
			default:
				if (!note.isSustainNote)
				{
					if (isDad2) {
						dad2.playAnim(animToPlay + altAnim, true);
					}

					if (isGF) {
						gf.playAnim(animToPlay + altAnim, true);
					}

					if (isDad) {
						dad.playAnim(animToPlay + altAnim, true);
					}

					if (isArsen && curStage == 'restauranteDynamic') {
						arsenTriangle.playAnim(animToPlay + altAnim, true);
					}
				}

				// its probably bad that it checks for this all the time but uhh 
				if (ClientPrefs.cameraShake) {
					if (dad.curCharacter.startsWith('toxic') && note.isSustainNote == false) FlxG.camera.shake(0.003, 0.15);
				}

				gf.holdTimer = 0;
				dad.holdTimer = 0;

				if (dad2 != null) dad2.holdTimer = 0;
				if (curStage == 'restauranteDynamic') arsenTriangle.holdTimer = 0;
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		switch (note.noteType)
		{
			case 10 | 11 | 12 | 16:
				camZooming = true;

			default:
				StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4);

				camZooming = true;
		}
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(note.customFunctions == true)
			{
				switch(note.noteType)
				{
					case 3: //DODGE NOTE BF ANIM/MECHANIC
						if(!boyfriend.stunned)
						{
							if(!endingSong)
							{
								health -= 0.05;
								FlxG.camera.shake(0.02, 0.1);
								if(boyfriend.animation.getByName('hurt') != null) {
									boyfriend.playAnim('hurt', true); //bf anim
									boyfriend.specialAnim = true;
								}
							}
						}

						note.wasGoodHit = true;

						if (!note.isSustainNote) //DODGE NOTE PRESSING ANIM
						{
							note.kill();
							notes.remove(note, true);
							note.destroy();

							//fixed botplay stuff
							if(ClientPrefs.botplay)
							{
								StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4);
							}
							else
							{
								playerStrums.forEach(function(spr:StrumNote)
								{
									if (Math.abs(note.noteData) == spr.ID)
									{
										spr.playAnim('confirm', true);
									}
								});
							}
							spawnNoteSplashOnNote(note); //purple note splash since we cant do purple confirm
						}
						return;
				case 4: //DEATH NOTE MECHANIC
					if (ClientPrefs.botplay) return;

					if (!boyfriend.stunned)
					{
						if (!endingSong)
						    {
								note.kill();
								notes.remove(note, true);
								note.destroy();

								// plays confirm animation, and then sends you to game over
								playerStrums.forEach(function(spr:StrumNote)
								{
									if (Math.abs(note.noteData) == spr.ID)
									{
										spr.playAnim('confirm', true);
									}
								});
								gameOver();
					        }
					    return;
					}
				case 14: // MISS NOTE !!
					return;
				/*
				case 14: //WIP FIRE DRAIN
					if (cpuControlled) return;

					FIRE_HITS += 1;

					if (!boyfriend.stunned)
					{
						if (!endingSong)
						{
							note.kill();
							notes.remove(note, true);
							note.destroy();

							playerStrums.forEach(function(spr:StrumNote)
							{
								if (Math.abs(note.noteData) == spr.ID)
								{
									spr.playAnim('confirm', true);
								}
							});
							spawnNoteSplashOnNote(note);

							switch (FIRE_HITS)
							{
								case 0:
									//do nothing, u safe homie
								case 1:
									FIRE_DRAIN = 0.02;
								case 2:
									FIRE_DRAIN = 0.03;
								case 3:
									FIRE_DRAIN = 0.04;
								default:
									FIRE_DRAIN = 0.05;
							}
						}
					}
				*/
				}

				note.wasGoodHit = true;
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if (combo > 9999) combo = 9999;
				popUpScore(note);

				health += 0.04;
			}
			else
			{
				health += 0.02;
			}

			var daAlt = '';
			if(note.noteType == 1) daAlt = '-alt';

			var animToPlay:String = '';
			switch (Math.abs(note.noteData))
			{
				case 0:
					animToPlay = 'singLEFT';
				case 1:
					animToPlay = 'singDOWN';
				case 2:
					animToPlay = 'singUP';
				case 3:
					animToPlay = 'singRIGHT';
			}

			if (boyfriendPog && !note.isSustainNote) {
				switch (Math.abs(note.noteData))
				{
					case 0:
						bfnoteMovementXoffset = -30;
						bfnoteMovementYoffset = 0;
					case 1:
						bfnoteMovementYoffset = 30;
						bfnoteMovementXoffset = 0;
					case 2:
						bfnoteMovementYoffset = -30;
						bfnoteMovementXoffset = 0;
					case 3:
						bfnoteMovementXoffset = 30;
						bfnoteMovementYoffset = 0;
				}
			}



			//THIS ONE IS FOR BOYFRIEND
			//FORCE ANIMATION NOTES - FORCE THE ANIMATION NO MATTER WHAT SINGER IS SET
			switch (note.noteType)
			{
				case 6: //gf
					gf.playAnim(animToPlay + daAlt, true);

					gf.holdTimer = 0;
				case 7: //bf2
					boyfriend2.playAnim(animToPlay + daAlt, true);

					boyfriend2.holdTimer = 0;
				case 8: //dad
					dad.playAnim(animToPlay + daAlt, true);

					dad.holdTimer = 0;
				case 9: //bf
					boyfriend.playAnim(animToPlay + daAlt, true);

					boyfriend.holdTimer = 0;
				case 10: //comic arsen
					arsenTriangle.playAnim(animToPlay + daAlt, true);

					arsenTriangle.holdTimer = 0;
				case 11: //comic dani
					daniTriangle.playAnim(animToPlay + daAlt, true);

					daniTriangle.holdTimer = 0;
				case 12: //everyone sings at the same time except avi cause he plays guitar
					dad.playAnim(animToPlay + daAlt, true);
					boyfriend2.playAnim(animToPlay + daAlt, true);
					gf.playAnim(animToPlay + daAlt, true);

					arsenTriangle.playAnim(animToPlay + daAlt, true);
					daniTriangle.playAnim(animToPlay + daAlt, true);

					dad.holdTimer = 0;
					boyfriend2.holdTimer = 0;
					gf.holdTimer = 0;

					arsenTriangle.holdTimer = 0;
					daniTriangle.holdTimer = 0;
				case 13: //none
					// do nothing lolz
				default:
					if (SONG.player1.startsWith('bf')) // start characters name with bf if you want it to have old sing code.
					{
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
					}
					else
					{
						if (!note.isSustainNote)
						{
							if (isBoyfriend) {
								boyfriend.playAnim(animToPlay + daAlt, true);
								boyfriend.holdTimer = 0;
							}
		
							if (isUnii) {
								boyfriend2.playAnim(animToPlay + daAlt, true);
								boyfriend2.holdTimer = 0;
							}
		
							if (isDuo) {
								boyfriend.playAnim(animToPlay + daAlt, true);
								boyfriend2.playAnim(animToPlay + daAlt, true);
		
								boyfriend.holdTimer = 0;
								boyfriend2.holdTimer = 0;
							}
		
							if (isDani) {
								daniTriangle.playAnim(animToPlay + daAlt, true);
		
								daniTriangle.holdTimer = 0;
							}
						}
					}
			}

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

			if (ClientPrefs.botplay)
			{
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4);
			}
			else
			{
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

	override function destroy() {
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		super.destroy();
	}

	override function stepHit()
	{
		super.stepHit();

		// RESYNC VOCALS
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			//resyncVocals();
			FlxG.sound.music.play();
			vocals.time = FlxG.sound.music.time;
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText,"(" + rankString + ") Misses: " + songMisses + " - " + "Combo: " + combo, rpcIcon, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
		#end

		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

		//HARDCODED EVENTS!!!
		//IDK HOW BAD IT IS THAT I EMBEDED THESE IN SWITCHES BUUUUUT ITS PROBABLY FINE

		switch (songLowercase)
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

			case 'casual-duel':
				// OH MY GOSH IM A GENIUS
				switch (curBeat)
				{
					case 176:
						FlxTween.num(trueLength, casualTime[1], 2, {ease: FlxEase.circOut}, function (x:Float) {
							trueLength = x;
						});
					case 224:
						FlxTween.num(trueLength, casualTime[2], 2, {ease: FlxEase.circOut}, function (x:Float) {
							trueLength = x;
						});
				}

			case 'dynamic-duo':
				switch (curBeat)
				{
					case 32:
						defaultCamZoom = 0.80;
					case 48:
						defaultCamZoom = 0.70;
					case 54:
						defaultCamZoom = 0.9;
					case 56:
						defaultCamZoom = 0.80;
					case 64:
						defaultCamZoom = 0.85;
					case 96:
						defaultCamZoom = 0.60;
						camPercentFloat = 1;
					case 160:
						defaultCamZoom = 0.85;
						camPercentFloat = 4;
					case 192:
						defaultCamZoom = 0.60;
					case 194:
						defaultCamZoom = 0.82;
					case 220:
						defaultCamZoom = 0.9;
					case 224:
						defaultCamZoom = 0.60;
						camPercentFloat = 4;
						camGameZoom = 0.020;
						camHudZoom = 0.03;
					case 286:
						defaultCamZoom = 0.8;
						camPercentFloat = 2;
						camGameZoom = 0.020;
						camHudZoom = 0;
					case 320:
						defaultCamZoom = 0.9;
					case 336:
						camGameZoom = 0.022;
						camHudZoom = 0.03;
					case 420:
						camHUD.alpha = 0; //camhud hide
						phillyFade.alpha = 1;
						camPercentFloat = 4;
						camGameZoom = 0.020;
						camHudZoom = 0.10;
						introThree('default', true);
					case 421:
						introTwo('default', true);
					case 422:
						introOne('default', true);
					case 423:
						defaultCamZoom = 0.65;
						introGo('default', true);
					case 424:
						camHUD.alpha = 1; //camhud show
						phillyFade.alpha = 0;
						camPercentFloat = 1;
						camGameZoom = 0.020;
						camHudZoom = 0.03;
						defaultCamZoom = 0.60;
					case 436 | 452:
						introThree('default', true);
					case 437 | 453:
						introTwo('default', true);
					case 438 | 454:
						introOne('default', true);
					case 439 | 455:
						introGo('default', true);
					case 456:
						camPercentFloat = 1;
						camGameZoom = 0.020;
						camHudZoom = 0.03;
						defaultCamZoom = 0.60;
					case 512:
						defaultCamZoom = 0.66;
					case 516:
						defaultCamZoom = 0.70;
					case 519:
						camPercentFloat = 4;
						camGameZoom = 0;
						camHudZoom = 0;
					case 520:
						defaultCamZoom = 0.59;

						//big zoom for avi final strum
						FlxG.camera.zoom += 0.40;
						camHUD.zoom += 0.20;
					case 524:
						boyfriend2.dance();
						daniTriangle.dance();
				}

				switch (curBeat) //unii camera function
				{
					case 80 | 120 | 152 | 192 | 220 | 226 | 248 | 280 | 336 | 376 | 440 | 452 | 472:
						setUniiCam(true); //focus on unii
					case 96 | 128 | 160 | 194 | 224 | 232 | 256 | 288 | 352 | 388 | 448 | 456 | 480:
						setUniiCam(false); //focus on must hit sectionz
				}
			case 'manager-strike-back': //rewritten box hud effects. //unii from a year later why tf u so serious bro ?? ToT
				switch (curBeat)
				{
					case 0 | 200 | 1694:
						if (whiteBox != null) FlxTween.tween(whiteBox, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
					case 8 | 230:
						if (whiteBox != null) FlxTween.tween(whiteBox, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
				}
			case 'alter-ego':
				var boyfriendZoom:Float = 0.82;
				var followCamPos:Bool = false;

				switch (curBeat)
				{
					case 16:
						followCamPos = true;
					case 32: // ANGRY
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
						boyfriendZoom = 0.9;
						nightBack.alpha = 0;
						angryBack.alpha = 1;

						boyfriend.color = 0x9c707b;
						dad.color = 0xab848d;
					case 36:
						camPercentFloat = 1;
						camGameZoom = 0.015;
						camHudZoom = 0.03;
					case 84:
						camPercentFloat = 8;
					case 88:
						camPercentFloat = 1;
						camGameZoom = 0.020;
						camHudZoom = 0.03;
					case 96:
						staticCamZoom = 0.9;
						phillyFade.alpha = 1;
						camPercentFloat = 4;
						camGameZoom = 0.015;
						camHudZoom = 0.01;
					case 100: // NIGHT
						FlxG.camera.flash(FlxColor.WHITE, 1);
						staticCamZoom = 0.8;
						phillyFade.alpha = 0;
						angryBack.alpha = 0;
						nightBack.alpha = 1;

						camPercentFloat = 4;
						camGameZoom = 0.010;
						camHudZoom = 0.02;

						boyfriend.color = 0xffffff;
						dad.color = 0xffffff;
					case 112:
						boyfriendZoom = 1.1;
					case 114:
						boyfriendZoom = 0.9;
					case 126:
						camPercentFloat = 1;
						camGameZoom = 0.015;
						camHudZoom = 0.01;
					case 128: // SAD
						FlxG.camera.flash(FlxColor.WHITE, 1);
						phillyFade.alpha = 0;
						nightBack.alpha = 0;
						sadBack.alpha = 1;

						boyfriend.color = 0x9086b0;
						dad.color = 0xaca5c4;
					case 192: // HAPPY
						FlxG.camera.flash(FlxColor.WHITE, 1);
						sadBack.alpha = 0;
						sunnyBack.alpha = 1;

						boyfriend.color = 0xffffff;
						dad.color = 0xffffff;
					case 224:
						camPercentFloat = 4;
					case 232:
						boyfriendZoom = staticCamZoom;
					case 248:
						camGameZoom = 0.020;
						camHudZoom = 0.02;
					case 256: // NORMAL AGAIN BUT COOLER
						FlxG.camera.flash(FlxColor.WHITE, 2);
						sunnyBack.alpha = 0;
						nightBack.alpha = 1;

						camGameZoom = 0.020;
						camHudZoom = 0.02;
					case 288:
						followCamPos = false;
						defaultCamZoom = 0.7;

						camPercentFloat = 1;
						camGameZoom = 0.010;
						camHudZoom = 0.05;
					case 319:
						defaultCamZoom = 0.6;
						phillyFade.alpha = 1;
						click.alpha = 1;
						click.dance();
					case 320:
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
						defaultCamZoom = 0.8;
						phillyFade.alpha = 0;
						click.alpha = 0;

						camPercentFloat = 4;
						camGameZoom = 0.010;
						camHudZoom = 0.05;
					case 328:
						defaultCamZoom = 0.7;
						camHUD.alpha = 0;
						phillyFade.alpha = 1;
						soundWave.alpha = 1;
						soundWave.dance();
					case 330:
						defaultCamZoom = 0.82;
						camHUD.alpha = 1;
						phillyFade.alpha = 0;
						soundWave.alpha = 0;
					case 345:
						defaultCamZoom = 0.75;
						phillyFade.alpha = 1;
						uniiEye.alpha = 1;
						uniiEye.dance();
					case 347:
						defaultCamZoom = 0.7;
						phillyFade.alpha = 0;
						uniiEye.alpha = 0;
					case 351:
						defaultCamZoom = 0.92;
						phillyFade.alpha = 1;
						gotcha.alpha = 1;
					case 352:
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
						defaultCamZoom = 0.7;
						phillyFade.alpha = 0;
						gotcha.alpha = 0;

						camPercentFloat = 1;
						camGameZoom = 0.015;
						camHudZoom = 0.06;
					case 414:
						FlxG.camera.flash(FlxColor.RED, 1);
					case 416:
						FlxG.camera.flash(FlxColor.WHITE, 1);
						followCamPos = true;

						camPercentFloat = 1;
						camGameZoom = 0.010;
						camHudZoom = 0.025;
					case 444:
						camPercentFloat = 4;
						camGameZoom = 0;
						camHudZoom = 0;
					case 446:
						followCamPos = false;
						defaultCamZoom = 1;
					case 448:
						FlxG.camera.flash(FlxColor.WHITE, 2);
						defaultCamZoom = 0.7;
				}

				//specifically curstep for all this stuff so it doesnt spam it on every step of every beat
				switch (curStep)
				{
					case 504: // sad cam fade
						phillyBlackTween = FlxTween.tween(phillyFade, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								phillyBlackTween = null;
							}
						});
					case 1536: // DIE BF DIE IN THE MIDDLE OF SONG :scream:
						camHUD.alpha = 0;
						phillyFade.alpha = 1;
						boyfriend2.alpha = 1;
						boyfriend2.playAnim('firstDeath', true);
					case 1537: // fade out death
						FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut});
						FlxTween.tween(phillyFade, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
						FlxTween.tween(boyfriend2, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
				}

				if (ClientPrefs.camZoomOut)
				{
					if (followCamPos)
						{
							// this "function" handles the switching zoom stuff between sections!
							var bf_focus:Bool = SONG.notes[Math.floor(curStep / 16)].mustHitSection;

							if (bf_focus) {
								defaultCamZoom = boyfriendZoom;
							} else {
								defaultCamZoom = staticCamZoom;
							}
						}
				}

				if (curStep % 4 == 0)
				{
					health -= FIRE_DRAIN;
				}
		}
	}

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

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
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);

			setOnLuas('curSection', curSection);
			callOnLuas('onSectionHit', []);
		}

		if (!ClientPrefs.fuckyouavi)
		{
			// sorry for all these variables its iffy but it works
			if (ClientPrefs.camZoomOut && camZooming && FlxG.camera.zoom < 1.35 && curBeat % camPercentFloat == 0) {
				FlxG.camera.zoom += camGameZoom;
				camHUD.zoom += camHudZoom;
			}

			var dancePercent:Int = 2;
			var forceBeat:Bool = false;

			switch (songLowercase)
			{
				case 'tutorial':
					dancePercent = 1;
					forceBeat = false;
				case 'dynamic-duo':
					dancePercent = 2;
					forceBeat = true;
				case 'below-zero':
					dancePercent = 1;
					forceBeat = false;
				case 'alter-ego':
					dancePercent = 2;
					forceBeat = true; //this makes it bug out a bit but i dont like them not dancing on beat so i force it
				default:
					dancePercent = 2;
					forceBeat = false;
			}

			if (curBeat % gfSpeed == 0 && !gf.stunned)
			{
				if (!gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
					gf.dance();
				}
			}

			if(curBeat % dancePercent == 0) {
				if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.specialAnim)
				{
					boyfriend.dance(forceBeat);
				}
				if (!dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
				{
					dad.dance(forceBeat);
				}
				if (dad2 != null && !dad2.animation.curAnim.name.startsWith('sing') && !dad2.stunned)
				{
					dad2.dance(forceBeat);
				}
				if (boyfriend2 != null && !boyfriend2.animation.curAnim.name.startsWith('sing') && !boyfriend2.stunned)
				{
					boyfriend2.dance(forceBeat);
				}

				if (curStage == 'restauranteDynamic')
				{
					if (!arsenTriangle.animation.curAnim.name.startsWith('sing') && !arsenTriangle.stunned)
					{
						arsenTriangle.dance(forceBeat);
					}
					if (!daniTriangle.animation.curAnim.name.startsWith('sing') && !daniTriangle.stunned)
					{
						daniTriangle.dance(forceBeat);
					}
				}
			} else if(dad.danceIdle && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
				dad.dance(forceBeat);
			}

			setStageBops();
		}
		iconP1.scale.set(1.1, 1.1);
		iconP2.scale.set(1.1, 1.1);

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int) {
		var spr:StrumNote = null;

		if(isDad)
			spr = strumLineNotes.members[id];
		else
			spr = playerStrums.members[id];

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = 0.1;
		}
	}

	public var rankString:String = '?';
	public var ratingPercent:Float;
	public function RecalculateRating()
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		callOnLuas('onRecalculateRating', []);

		ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
		if (!Math.isNaN(ratingPercent) && ratingPercent < 0) {
			ratingPercent = 0;
		}
		if (ratingPercent >= 1) {
			ratingPercent = 1;
		}

		setOnLuas('rating', ratingPercent);

		var accuracyDisplay:Float = FlxMath.roundDecimal(Math.floor(ratingPercent * 10000) / 100, 2);

		rankString = UniiStringTools.makePlayRanks(songMisses, shits, bads, goods, sicks, perfects);

		scoreTxt.text = "Score: " + songScore;

		if (!Math.isNaN(ratingPercent))
		{
			accText.text = accuracyDisplay + "%   [" + rankString + "]";
		}

		//ALL HIT TIMING UPDATED TEXT
		shitsTxt.text = 'Shit:  ' + shits;
		badsTxt.text = 'Bad:  ' + bads;
		goodsTxt.text = 'Good:  ' + goods;
		sicksTxt.text = 'Sick:  ' + sicks;
		perfectsTxt.text = 'Perfect:  ' + perfects;
		missesTxt.text = 'Miss:  ' + songMisses;

		if (curStage == 'frostedStage') {
			if (ClientPrefs.pussyMode)
				frostedMisses.text = "MISSES: " + songMisses + "\nDEATHS: " + deathCounter + "\nYOU'RE A PUSSY!";
			else
				frostedMisses.text = "MISSES: " + songMisses + "/10\nDEATHS: " + deathCounter;
		}

		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingFC', rankString);
	}

	public function loadSong(?customSong:Bool = false, ?customPath:String = '', ?followStorySettings:Bool = true):Void
	{
		var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

		if (!isStoryMode)
			trace('TRYING TO LOAD NEW SONG...');
		else
			trace('LOADING THE NEXT SONG...');

		if (customSong)
		{
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}

		prevCamFollow = camFollow;
		prevCamFollowPos = camFollowPos;

		if (customSong)
		{
			var realDifficulty:String = '';

			if (followStorySettings)
				realDifficulty = difficulty;
			else
				realDifficulty = '-hard';

			PlayState.SONG = Song.loadFromJson(customPath.toLowerCase() + realDifficulty, customPath);

			trace('loaded custom song: "' + customPath + '" suffix: "' + realDifficulty + '"');
		}
		else
		{
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		}

		FlxG.sound.music.stop();

		if (followStorySettings)
		{
			// v   this function checks if the song is the first argument, then the cutscene folder and video name
			addMP4Outro('wifi', 'casual-duel');
		}

		if(!hasMP4)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	public function exitSong():Void
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		switch (songLowercase) // STORY MODE DATA
		{
			case 'tutorial':
				if (FlxG.save.data.beatTutorial == null || FlxG.save.data.beatTutorial == false) {
					FlxG.save.data.beatTutorial = true;
					trace('beat tutorial');
				}
			case 'cultured':
				if (FlxG.save.data.beatCulturedWeek == null || FlxG.save.data.beatCulturedWeek == false) {
					FlxG.save.data.beatCulturedWeek = true;
					trace('beat cultured');
				}
			case 'dynamic-duo' | 'below-zero':
				if (FlxG.save.data.beatWeekEnding == null || FlxG.save.data.beatWeekEnding == false) {
					FlxG.save.data.beatWeekEnding = true;
					trace('beat week 2');
				}
				FlxG.save.data.beatNormalEnd = true; //TAKE THNIS OUT AFTER ENDINGS HAVE BEEN PUT IN!!!
				//SURE THING BUDDY!!! (my future self)
			case 'manager-strike-back':
				if (FlxG.save.data.beatBonus == null || FlxG.save.data.beatBonus == false) {
					FlxG.save.data.beatBonus = true;
					trace('beat manager strike back');
				}
		}

		if (songLowercase == 'casual-duel')
		{
			MusicBeatState.switchState(new ChoiceState());
		}
		else
		{
			backToMenu();
			trace('exited song, transitioned to story mode');
		}

		if (SONG.validScore)
		{
			Highscore.saveWeekScore(WeekData.getCurrentWeekNumber(), campaignScore, storyDifficulty);
		}

		FlxG.save.flush(); // SAVE DATA
		skippedDialogue = false;

		MainMenuState.cursed = false; // makes you not cursed
	}

	public function FUCKING_CHEATER():Void
	{
		loadSong(true, 'DIRTY-CHEATER', false);
	}

	private function backToMenu():Void {
		FlxG.sound.playMusic(Paths.music('freaky_overture'));

		MainMenuState.justExited = true;

		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			MusicBeatState.switchState(new MainMenuState());
		});
	}

	private function checkForAchievement(achievesToCheck:Array<String>):String {
		for (stuff in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[stuff];

			if(!Achievements.isAchievementUnlocked(achievementName))
			{
				var unlock:Bool = false;

				switch (achievementName)
				{
					// CUSTOM ACHIEVEMENTS
					case 'tutorial_beat':
						if (isStoryMode && songLowercase == 'tutorial') {
							unlock = true;
						}

					case 'week1_beat':
						if (isStoryMode && WeekData.getCurrentWeekNumber() == 1 && PlayState.storyPlaylist.length <= 1 && CoolUtil.difficultyString() == 'HARD') {
							unlock = true;
						}

					case 'week2_beat': // this looks rly weird sorry ToT
						if (isStoryMode && WeekData.getCurrentWeekNumber() == 2 && CoolUtil.difficultyString() == 'HARD') {
							if (songLowercase == 'dynamic-duo' || songLowercase == 'below-zero') unlock = true;
						}

					case 'dynamic_duo':
						if (isStoryMode && songLowercase == 'dynamic-duo') {
							unlock = true;
						}

					case 'below_zero':
						if (isStoryMode && songLowercase == 'below-zero') {
							unlock = true;
						}

					case 'restaurante_ex':
						if (songLowercase == 'restaurante' && CoolUtil.difficultyString() == HARDER_THAN_HARD) {
							unlock = true;
						}

					case 'milkshake_ex':
						if (songLowercase == 'milkshake' && CoolUtil.difficultyString() == HARDER_THAN_HARD) {
							unlock = true;
						}

					case 'cultured_ex':
						if (songLowercase == 'cultured' && CoolUtil.difficultyString() == HARDER_THAN_HARD) {
							unlock = true;
						}

					case 'beat_chara':
						if (songLowercase == 'manager-strike-back' && !ClientPrefs.pussyMode) {
							unlock = true;
						}

					case 'beat_sans':
						if (songLowercase == 'frosted' && !ClientPrefs.pussyMode) {
							unlock = true;
						}

					case 'beat_onion':
						if (songLowercase == 'dirty-cheater' && !ClientPrefs.pussyMode) {
							unlock = true;
						}

					// EXTRA ACHIEVEMENTS
					case 'ur_bad':
						if(ratingPercent < 0.2) {
							unlock = true;
						}

					case 'ur_good':
						if(ratingPercent >= 1) {
							unlock = true;
						}

					case 'oversinging':
						if(boyfriend.holdTimer >= 5) {
							unlock = true;
						}

					case 'hype':
						if(!boyfriendIdled) {
							unlock = true;
						}

					case 'two_keys':
						var howManyPresses:Int = 0;

						for (x in 0...keysPressed.length) {
							if(keysPressed[x]) howManyPresses++;
						}

						if (howManyPresses <= 2) {
							unlock = true;
						}

					case 'toastie':
						// run the game with shit settings basically LOL
						if (!ClientPrefs.globalAntialiasing && !ClientPrefs.specialEffects && ClientPrefs.fuckyouavi) {
							unlock = true;
						}
				}

				if (isStoryMode)
					{
						switch (achievementName)
						{
							case 'unlock_week1':
								if (isStoryMode && songLowercase == 'tutorial') {
									unlock = true;
								}

							case 'unlock_ex' | 'unlock_week2':
								if (isStoryMode && WeekData.getCurrentWeekNumber() == 1 && PlayState.storyPlaylist.length <= 1) {
									unlock = true;
								}

							case 'unlock_bonus':
								if (isStoryMode && WeekData.getCurrentWeekNumber() == 2 && PlayState.storyPlaylist.length <= 1) {
									unlock = true;
								}

							case 'unlock_endgame':
								if (isStoryMode && songLowercase == 'manager-strike-back') {
									unlock = true;
								}
						}
					}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}

	// REWROTE MY SHITTY LAYERING CODE WITH SOMEWHAT BETTER LAYERING CODE! (all in this function)
	private function setCharLayering(stage:String, ?startingPos:FlxPoint):Void
		{
			if (!ClientPrefs.fuckyouavi) {
				switch (stage)
				{
					case 'kitchen':
						gf.visible = false;
						add(dadGroup);
						add(boyfriendGroup);
						add(counter);

					case 'restaurante':
						if (CoolUtil.difficultyString() != HARDER_THAN_HARD) {
							gf.visible = true;
							add(gfGroup);
						}
						add(dadGroup);
						add(counter);
						add(littleMan);
						add(phillyCounter);
						add(boyfriendGroup);
						add(frontBoppers);

					case 'restauranteCream':
						gf.visible = false;
						boyfriend.visible = false;
						counter.visible = false;
						camHUD.alpha = 0;
						add(gfGroup);
						add(dadGroup);
						add(counter);
						add(boyfriendGroup);

					case 'restauranteArsen':
						gf.visible = true;
						add(gfGroup);
						add(dadGroup);
						add(counter);
						add(boyfriendGroup);

					case 'restauranteDansilot':
						gf.visible = true;
						add(gfGroup);
						add(dadGroup);
						add(counter);
						add(avineraCasualDuel);
						add(boyfriendGroup);
						add(frontBoppers);

					case 'restauranteAvi':
						gf.visible = true;
						add(gfGroup);
						add(dadGroup);
						add(counter);
						add(boyfriendGroup);

					case 'restauranteDynamic':
						gf.visible = true;
						add(gfGroup);
						add(dadGroup);
						add(counter);
						add(boyfriendGroup);

						add(arsenTriangle);
						add(daniTriangle);

						add(phillyFade); //for black screen

					case 'undertale':
						gf.visible = false;
						add(dadGroup);
						add(boyfriendGroup);
						add(phillyFade);

					case 'frostedStage':
						gf.visible = false;
						add(dadGroup);
						add(boyfriendGroup);
						add(frontBoppers);
						add(wallLeft);
						add(counter);

					case 'theBack':
						gf.visible = false;
						add(gfGroup);
						add(dadGroup);
						add(boyfriendGroup);

						add(phillyFade); //for black screen

						// MID SONG EVENT SPRITES!!! all preloaded bitch
						add(click);
						add(soundWave);
						add(uniiEye);
						add(gotcha);

						boyfriend2.alpha = 0;

					default:
						gf.visible = true;
						add(gfGroup);
						add(dadGroup);
						add(boyfriendGroup);
				}
			}
		}

	private function setStageBops():Void
		{
			switch (curStage)
			{
				case 'restaurante':
					counter.dance();
					boppers.dance();
					frontBoppers.dance();
					if (CoolUtil.difficultyString() == HARDER_THAN_HARD) {
						phillyCounter.dance();
					}

				case 'restauranteCream':
					counter.dance(true);
					if (bagelSinging == false) bagel.dance();

				case 'restauranteArsen':
					counter.dance();
					grpCustomTableBoppers.forEach(function(boppers:BGSprite)
					{
						boppers.dance();
					});

				case 'restauranteDansilot':
					counter.dance();
					frontBoppers.dance();
					avineraCasualDuel.dance();
					grpCustomTableBoppers.forEach(function(boppers:BGSprite)
					{
						boppers.dance();
					});

				case 'restauranteAvi':
					counter.dance();
					grpCustomTableBoppers.forEach(function(boppers:BGSprite)
					{
						boppers.dance();
					});

				case 'restauranteDynamic':
					if (curBeat % 2 == 0)
					{
						counter.dance(true);
						grpCustomTableBoppers.forEach(function(boppers:BGSprite)
						{
							boppers.dance(true);
						});
					}

				case 'frostedStage':
					counter.dance();
					frontBoppers.dance();

					// dani goes sicko mode when pog (wtf am i doing)
					if (dadPog)
						dansilot.dance(true);
					else
						dansilot.dance();

				case 'theBack':
					if (ClientPrefs.flashing) {
						nightBack.dance(true);
						angryBack.dance(true);
						sadBack.dance(true);
						sunnyBack.dance(true);
					}
			}
		}

	private function setUniiCam(forcePos:Bool = true)
		{
			camFollow.set(boyfriend2.getMidpoint().x + 150, boyfriend2.getMidpoint().y - 100);
			camFollow.x += -262;
			camFollow.y += -100;
			isCameraOnForcedPos = forcePos;
		}

	private function freezeFadeTween(asset:FlxSprite, opacity:Float, length:Float)
		{
			if (asset.alpha != opacity) {
				FlxTween.tween(asset, {alpha: opacity}, length, {ease: FlxEase.quadInOut});
			}
		}

	public function pressPause():Void
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			if(!startingSong) {
				FlxG.sound.music.pause();
				vocals.pause();
			}
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", rpcIcon);
			#end
		}

	public function gameOver():Void
		{
			if (!practiceMode)
				gameOverReal(); // IT DOESNT KMILL YOU!!! AND THIS WONT LAG THE GAME !!! NMUAUHHAHAHA
		}

	public function gameOverReal():Void
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop)
			{
				camHUD.visible = false;

				var blackShit:FlxSprite = new FlxSprite(-300, -120);

				blackShit.makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.BLACK);
				blackShit.scrollFactor.set(1, 1);
				blackShit.alpha = 0.8;
				add(blackShit);

				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = true;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}

				if (curStage == 'frostedStage') // new class
				{
					openSubState(new GameOverFrostedSubstate(boyfriend.x, boyfriend.y, camFollowPos.x, camFollowPos.y));
				}
				else // default class
				{
					openSubState(new GameOverSubstate(boyfriend.x, boyfriend.y, camFollowPos.x, camFollowPos.y));
				}

				if (boyfriend2 != null)
				{
					boyfriendGroup.remove(boyfriend);
					trace('found bf 2');
				}
				boyfriendGroup.remove(boyfriend);

				#if desktop
					#if debug
						DiscordClient.changePresence('I FUCKING DIED', null, null, true);
					#else
						DiscordClient.changePresence("Game Over", displaySongName + " (" + storyDifficultyText + ")", rpcIcon);
					#end
				#end
			}
			deathCounter++;
		}

	// do NOT even ask
	public function poggerModeSound(path:String, ?randomSound:Bool = false, ?randomMin:Int, ?randomMax:Int)
		{
			if (!randomSound)
				FlxG.sound.play(Paths.sound('poggers-mode/' + path));
			else
				FlxG.sound.play(Paths.soundRandom('poggers-mode/' + path, randomMin, randomMax));
		}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
// woa. mod again. 7/27/2022 2:29 PM
//hi unii