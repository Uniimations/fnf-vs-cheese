package;

import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.math.FlxPoint;

using StringTools;

class RatingPopUpMenuState extends MusicBeatState
{
	var floor:BGSprite;
	var tableA:BGSprite;
	var tableB:BGSprite;
	var tSideMod:BGSprite;
	var suzuki:BGSprite;
	var counter:BGSprite;

	var bf:Boyfriend;
	var cheese:Character;
	var gf:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	private var camFollow:FlxPoint;
	private var arrows:FlxSprite;

	var previewSine:Float = 0;
    var previewTxt:FlxText;
	var coolText:FlxText;
	var rating:FlxSprite;
	var comboNums:FlxSpriteGroup;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var barPercent:Float = 0;
	var delayMin:Int = 0;
	var delayMax:Int = 500;
	var timeBarBG:FlxSprite;
	var timeBar:FlxBar;
	var timeTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var changeModeText:FlxText;

	override public function create()
	{
		// Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;
		FlxG.sound.pause();

		// Stage
		floor = new BGSprite(('cheese/floor'), -377.9, -146.4, 1, 1, null, false, true);
		floor.updateHitbox();

		tableA = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1, null, false, true);
		tableA.updateHitbox();

		tableB = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1, null, false, true);
		tableB.updateHitbox();

		tSideMod = new BGSprite('cheese/t-side_mod', 1288.35, 279.9, 1, 1, null, false, true);
		tSideMod.updateHitbox();

		suzuki = new BGSprite('cheese/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true, true);
		suzuki.updateHitbox();

		counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop'], false, true); //add anim
		counter.updateHitbox();

		// Characters
		gf = new Character(400, 130, 'gf');
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];

		cheese = new Character(100, 100, 'bluecheese');
		cheese.x += cheese.positionArray[0];
		cheese.y += cheese.positionArray[1];

		if (ClientPrefs.bfreskin)
			bf = new Boyfriend(770, 100, 'bf');
		else
			bf = new Boyfriend(770, 100, 'bf-alt');

		bf.x += bf.positionArray[0];
		bf.y += bf.positionArray[1];

		if (!ClientPrefs.fuckyouavi)
		{
			add(floor);
			add(tableA);
			add(tableB);
			add(tSideMod);
			add(suzuki);

			add(gf);
			add(cheese);
			add(counter);
			add(bf);
		}

		camFollow = new FlxPoint();
		FlxG.camera.focusOn(camFollow);
		camFollow.set(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camFollow.x += gf.cameraPosition[0];
		camFollow.y += gf.cameraPosition[1];
		FlxG.camera.focusOn(camFollow);

		//SCROLL STUFFFFFF

        if (ClientPrefs.downScroll) {
			newArrows('downscroll');
            arrows.y += 122;
		} else {
			newArrows('upscroll');
		}

        if (ClientPrefs.middleScroll) {
            arrows.x -= 402;
        } else {
            arrows.x -= 69; //nice
            FlxG.log.add('nice');
        }

		arrows.cameras = [camHUD];

		// Combo stuff

		coolText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		rating = new FlxSprite().loadGraphic(Paths.image('perfect', 'shared'));
		rating.cameras = [camHUD];
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		rating.antialiasing = ClientPrefs.globalAntialiasing;
	
		add(rating);

		comboNums = new FlxSpriteGroup();
		comboNums.cameras = [camHUD];
		add(comboNums);

		var seperatedScore:Array<Int> = [];
		for (i in 0...3)
		{
			seperatedScore.push(FlxG.random.int(0, 9));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite(43 * daLoop).loadGraphic(Paths.image('num' + i));
			numScore.cameras = [camHUD];
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.antialiasing = ClientPrefs.globalAntialiasing;
			comboNums.add(numScore);
			daLoop++;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);
		createTexts();

		repositionCombo();

		// Note delay stuff
	
		beatText = new Alphabet(0, 0, 'Beat Hit!', true, false, 0.05, 1);
		beatText.x += 500;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		beatText.visible = false;
		add(beatText);

		timeTxt = new FlxText(0, 600, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 1.5;
		timeTxt.visible = false;
		timeTxt.cameras = [camHUD];

		barPercent = ClientPrefs.noteOffset;
		updateNoteDelay();

		timeBarBG = new FlxSprite(0, timeTxt.y + 8).loadGraphic(Paths.image('timeBar', 'shared'));
		timeBarBG.setGraphicSize(Std.int(timeBarBG.width * 1.2));
		timeBarBG.updateHitbox();
		timeBarBG.cameras = [camHUD];
		timeBarBG.screenCenter(X);
		timeBarBG.visible = false;

		timeBar = new FlxBar(0, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'barPercent', delayMin, delayMax);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200? - sdhut up shadow Mario/.
		timeBar.visible = false;
		timeBar.cameras = [camHUD];

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		///////////////////////

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 32).makeGraphic(FlxG.width, FlxG.height - 32, 0xFF000000);
		textBG.scrollFactor.set();
		textBG.alpha = 0.6;
		textBG.cameras = [camHUD];
		add(textBG);

		changeModeText = new FlxText(textBG.x + 4, textBG.y + 4, FlxG.width, "", 23);
		changeModeText.setFormat(Paths.font("vcr.ttf"), 23, FlxColor.WHITE, LEFT);
		changeModeText.scrollFactor.set();
		changeModeText.cameras = [camHUD];
		add(changeModeText);

		previewTxt = new FlxText(10, 20, FlxG.width - 800, "GAMEPLAY PREVIEW v", 32);
		previewTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		previewTxt.scrollFactor.set();
		previewTxt.borderSize = 1.5;
		previewTxt.cameras = [camHUD];
		add(previewTxt);

		updateMode();

		Conductor.changeBPM(130);
		FlxG.sound.playMusic(Paths.music('oatmeal_offset'), 1, true);

		super.create();

		FlxG.camera.zoom = 0.6;
	}

	var holdTime:Float = 0;
	var onComboMenu:Bool = true;
	var holdingObjectType:Null<Bool> = null;

	var startMousePos:FlxPoint = new FlxPoint();
	var startComboOffset:FlxPoint = new FlxPoint();

	override public function update(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT) addNum = 10;

		if(onComboMenu)
		{
			var controlArray:Array<Bool> = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN,
			
				FlxG.keys.justPressed.A,
				FlxG.keys.justPressed.D,
				FlxG.keys.justPressed.W,
				FlxG.keys.justPressed.S
			];

			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
					{
						switch(i)
						{
							case 0:
								ClientPrefs.comboOffset[0] -= addNum;
							case 1:
								ClientPrefs.comboOffset[0] += addNum;
							case 2:
								ClientPrefs.comboOffset[1] += addNum;
							case 3:
								ClientPrefs.comboOffset[1] -= addNum;
							case 4:
								ClientPrefs.comboOffset[2] -= addNum;
							case 5:
								ClientPrefs.comboOffset[2] += addNum;
							case 6:
								ClientPrefs.comboOffset[3] += addNum;
							case 7:
								ClientPrefs.comboOffset[3] -= addNum;
						}
					}
				}
				repositionCombo();
			}

			// probably there's a better way to do this but, oh well.
			if (FlxG.mouse.justPressed)
			{
				holdingObjectType = null;
				FlxG.mouse.getScreenPosition(camHUD, startMousePos);
				if (startMousePos.x - comboNums.x >= 0 && startMousePos.x - comboNums.x <= comboNums.width &&
					startMousePos.y - comboNums.y >= 0 && startMousePos.y - comboNums.y <= comboNums.height)
				{
					holdingObjectType = true;
					startComboOffset.x = ClientPrefs.comboOffset[2];
					startComboOffset.y = ClientPrefs.comboOffset[3];
					//trace('yo bro');
				}
				else if (startMousePos.x - rating.x >= 0 && startMousePos.x - rating.x <= rating.width &&
						 startMousePos.y - rating.y >= 0 && startMousePos.y - rating.y <= rating.height)
				{
					holdingObjectType = false;
					startComboOffset.x = ClientPrefs.comboOffset[0];
					startComboOffset.y = ClientPrefs.comboOffset[1];
					//trace('heya');
				}
			}
			if(FlxG.mouse.justReleased) {
				holdingObjectType = null;
				//trace('dead');
			}

			if(holdingObjectType != null)
			{
				if(FlxG.mouse.justMoved)
				{
					var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(camHUD);
					var addNum:Int = holdingObjectType ? 2 : 0;
					ClientPrefs.comboOffset[addNum + 0] = Math.round((mousePos.x - startMousePos.x) + startComboOffset.x);
					ClientPrefs.comboOffset[addNum + 1] = -Math.round((mousePos.y - startMousePos.y) - startComboOffset.y);
					repositionCombo();
				}
			}

			if(controls.RESET)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				for (i in 0...ClientPrefs.comboOffset.length)
				{
					ClientPrefs.comboOffset[i] = 0;
				}
				repositionCombo();
				trace('RESET RATING POP UP POSITION');
			}
		}
		else
		{
			if(controls.UI_LEFT_P)
			{
				barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset - 1, delayMax));
				updateNoteDelay();
			}
			else if(controls.UI_RIGHT_P)
			{
				barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset + 1, delayMax));
				updateNoteDelay();
			}

			var mult:Int = 1;
			if(controls.UI_LEFT || controls.UI_RIGHT)
			{
				holdTime += elapsed;
				if(controls.UI_LEFT) mult = -1;
			}

			if(controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

			if(holdTime > 0.5)
			{
				barPercent += 100 * elapsed * mult;
				barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
				updateNoteDelay();
			}

			if(controls.RESET)
			{
				holdTime = 0;
				barPercent = 0;
				updateNoteDelay();
			}
		}

		if(controls.ACCEPT)
		{
			onComboMenu = !onComboMenu;
			updateMode();
		}

		if(controls.BACK)
		{
			if(zoomTween != null) zoomTween.cancel();
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new OptionsState());

			if (OptionsState.inPause)
				FlxG.sound.playMusic(Paths.music('gameOver'), 1, true);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);

			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.mouse.visible = false;

			trace('WENT BACK TO OPTIONS!!!');
		}

		Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		previewSine += 180 * elapsed;
        previewTxt.alpha = 1 - Math.sin((Math.PI * previewSine) / 180);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			cheese.dance();
			bf.dance();
			gf.dance();
			counter.dance();
		}

		if(curBeat % 4 == 2)
		{
			FlxG.camera.zoom = 0.7;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
				{
					zoomTween = null;
				}
			});

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	private function newArrows(scrollPref:String)
	{
		if (arrows != null) {
			remove(arrows);
		}
		arrows = new FlxSprite().loadGraphic(Paths.image('settingsmenu/' + scrollPref + '_notes'));
		arrows.setGraphicSize(Std.int(arrows.width * 1.1));
		arrows.updateHitbox();
		arrows.screenCenter();
		arrows.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrows);
	}

	function repositionCombo()
	{
		rating.screenCenter();
		rating.x = coolText.x - 40 + ClientPrefs.comboOffset[0];
		rating.y -= 60 + ClientPrefs.comboOffset[1];

		comboNums.screenCenter();
		comboNums.x = coolText.x - 90 + ClientPrefs.comboOffset[2];
		comboNums.y += 80 - ClientPrefs.comboOffset[3];
		reloadTexts();
	}

	function createTexts()
	{
		for (i in 0...4)
		{
			var text:FlxText = new FlxText(10, 100 + (i * 30), 0, '', 24);
			text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 1.5;
			dumbTexts.add(text);
			text.cameras = [camHUD];

			if(i > 1)
			{
				text.y += 24;
			}
		}
	}

	function reloadTexts()
	{
		for (i in 0...dumbTexts.length)
		{
			switch(i)
			{
				case 0: dumbTexts.members[i].text = 'Rating Offset:';
				case 1: dumbTexts.members[i].text = '[' + ClientPrefs.comboOffset[0] + ', ' + ClientPrefs.comboOffset[1] + ']';
				case 2: dumbTexts.members[i].text = 'Numbers Offset:';
				case 3: dumbTexts.members[i].text = '[' + ClientPrefs.comboOffset[2] + ', ' + ClientPrefs.comboOffset[3] + ']';
			}
		}
	}

	function updateNoteDelay()
	{
		ClientPrefs.noteOffset = Math.round(barPercent);
		timeTxt.text = 'Current offset: ' + Math.floor(barPercent) + ' ms';
	}

	function updateMode()
	{
		rating.visible = onComboMenu;
		comboNums.visible = onComboMenu;
		dumbTexts.visible = onComboMenu;
		
		timeBarBG.visible = !onComboMenu;
		timeBar.visible = !onComboMenu;
		timeTxt.visible = !onComboMenu;
		beatText.visible = !onComboMenu;

		if(onComboMenu)
			changeModeText.text = 'Drag rating pop up, RESET to reset (Press ACCEPT to Switch)';
		else
			changeModeText.text = 'Note Offset, adjust with LEFT and RIGHT keys, RESET to reset (Press ACCEPT to Switch)';

		FlxG.mouse.visible = onComboMenu;
	}
}