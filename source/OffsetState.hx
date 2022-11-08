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

class OffsetState extends MusicBeatState
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
		floor = new BGSprite(('cheese/floor'), -377.9, -146.4, 1, 1, null, false);
		tableA = new BGSprite('cheese/tableA', 1966.5, 283.05, 1, 1, null, false);
		tableB = new BGSprite('cheese/tableB', 1936.15, 568.5, 1, 1, null, false);
		tSideMod = new BGSprite('cheese/t-side_mod', 1288.35, 279.9, 1, 1, null, false);
		suzuki = new BGSprite('cheese/wall_suzuki', -358.25, -180.35, 1, 1, ['wall'], true);
		counter = new BGSprite('cheese/counter', 232.35, 403.25, 1, 1, ['counter bop'], false); //add anim

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

		// Note delay stuff
	
		beatText = new Alphabet(0, 0, 'Beat Hit!', true, false, 0.05, 1);
		beatText.x += 500;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		add(beatText);

		timeTxt = new FlxText(0, 600, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 1.5;
		timeTxt.cameras = [camHUD];

		barPercent = ClientPrefs.noteOffset;
		updateNoteDelay();

		timeBarBG = new FlxSprite(0, timeTxt.y + 8).loadGraphic(Paths.image('timeBar', 'shared'));
		timeBarBG.setGraphicSize(Std.int(timeBarBG.width * 1.2));
		timeBarBG.updateHitbox();
		timeBarBG.cameras = [camHUD];
		timeBarBG.screenCenter(X);

		timeBar = new FlxBar(0, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'barPercent', delayMin, delayMax);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200? - sdhut up shadow Mario/.
		timeBar.cameras = [camHUD];

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		///////////////////////

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 40).makeGraphic(FlxG.width, FlxG.height - 32, 0xFF000000);
		textBG.scrollFactor.set();
		textBG.alpha = 0.6;
		textBG.cameras = [camHUD];
		add(textBG);

		changeModeText = new FlxText(textBG.x + 4, textBG.y + 4, FlxG.width, "NOTE OFFSET, adjust with LEFT and RIGHT keys, RESET to reset", 23);
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

		Conductor.changeBPM(130);
		FlxG.sound.playMusic(Paths.music('oatmeal_offset'), 1, true);

		super.create();

		FlxG.camera.zoom = 0.6;
	}

	var holdTime:Float = 0;

	override public function update(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT) addNum = 10;

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
			FlxG.sound.play(Paths.sound('cancelMenu'));
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
			trace('RESET OFFSET TO: 0');
		}

		if(controls.BACK)
		{
			if(zoomTween != null) zoomTween.cancel();
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new OptionsState());

			if (OptionsState.inPause)
				FlxG.sound.playMusic(Paths.music(PauseSubState.pauseSong), 1, true);
			else
				FlxG.sound.playMusic(Paths.music('freaky_overture'), 1, true);

			FlxG.sound.play(Paths.sound('cancelMenu'));

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
			FlxG.camera.zoom = 0.61;

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

	function updateNoteDelay()
	{
		ClientPrefs.noteOffset = Math.round(barPercent);
		timeTxt.text = Math.floor(barPercent) + ' ms';
	}
}