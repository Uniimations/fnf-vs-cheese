package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var prevNote:Note;

	public var spawned:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):Int = 0;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var multSpeed(default, set):Float = 1;

	public var customFunctions:Bool = false;
	public var noteSkin(default, set):String = 'noteskins/NOTE_assets';

	public var xAdd:Float = 50;
	public var yAdd:Float = 0; // doooont use this lol

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
		if(isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_noteType(value:Int):Int
	{
		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 3: // DODGE NOTE
					reloadNote('dodgeNOTES_UNDERTALE');
					customFunctions = true;

				case 4: // DEATH NOTE
					reloadNote('deathNOTES_UNDERTALE');
					customFunctions = true;

				case 5 | 6 | 8: // DAD NOTE
					reloadNote('noteskins/NOTE_assets' + UniiStringTools.noteSkinSuffix(PlayState.SONG.player2));

				case 10 | 11 | 12 | 15: // INVISIBLE
					reloadNote('noteskins/NOTE_comic');

				case 14:
					customFunctions = true;
			}
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

			noteType = value;
		}
		return value;
	}

	private function set_noteSkin(image:String):String
	{
		reloadNote(image);

		return image;
	}

	var daSong:String = PlayState.SONG.song.toLowerCase();
	public function new(noteSkin:String, strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.inEditor = inEditor;
		isSustainNote = sustainNote;
		this.noteSkin = noteSkin;

		switch (daSong) {
			case 'tutorial' | 'manager-strike-back':
				x += PlayState.STRUM_X_MIDDLESCROLL + xAdd;
			default:
				x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + xAdd;
		}

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000 + yAdd;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		frames = Paths.getSparrowAtlas(noteSkin, null, true);
		loadNoteAnims();

		if(noteData > -1) {
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
			
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

			x += swagWidth * (noteData % 4);

			var animToPlay:String = '';
			switch (noteData % 4)
			{
				case 0:
					animToPlay = 'purple';
				case 1:
					animToPlay = 'blue';
				case 2:
					animToPlay = 'green';
				case 3:
					animToPlay = 'red';
			}
			animation.play(animToPlay + 'Scroll');
		}

		if (isSustainNote && prevNote != null)
		{
			alpha = 1;
			if(ClientPrefs.downScroll) flipY = true;

			x += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				//prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05 * PlayState.instance.songSpeed;
				// CHANGE THIS LATER!!

				prevNote.updateHitbox();
			}
		}
		reloadNote(noteSkin);
	}

	function reloadNote(?newSkin:String = 'noteskins/NOTE_assets')
	{
		var animName:String = null;

		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		if (!FlxG.bitmap.checkCache("noteasset")) {
			FlxG.bitmap.add(BitmapData.fromFile(Paths.image(newSkin, null)), false, "noteasset");
		}

		frames = Paths.getSparrowAtlas(newSkin, null);

		loadNoteAnims();
		animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims()
	{
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (ClientPrefs.inputSystem)
		{
			case "Kade Engine":
				if (mustPress)
				{
					if (isSustainNote)
					{
						if (strumTime > Conductor.songPosition - (PlayState.safeZoneOffset * 1.5)
							&& strumTime < Conductor.songPosition + (PlayState.safeZoneOffset * 0.5))
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strumTime > Conductor.songPosition - PlayState.safeZoneOffset
							&& strumTime < Conductor.songPosition + PlayState.safeZoneOffset)
							canBeHit = true;
						else
							canBeHit = false;
					}

					if (strumTime < Conductor.songPosition - PlayState.safeZoneOffset * PlayState.safeZoneOffset / 166 && !wasGoodHit)
						tooLate = true;
				}
				else
				{
					canBeHit = false;

					if (strumTime < Conductor.songPosition + (PlayState.safeZoneOffset * 0.5))
					{
						// fixes botplay going above strumline // worth noting that above the strumline represents music desync. 
						if ((isSustainNote && prevNote.wasGoodHit) || strumTime - Conductor.songPosition < 4) // mean 1/60 /4 = 4.
							wasGoodHit = true;
					}
				}

				if (tooLate)
				{
					if (alpha > 0.3)
						alpha = 0.3;
				}
			case "Psych Engine" | "Vanilla":
				if (mustPress)
				{
					// The * 0.5 is so that it's easier to hit them too late, instead of too early
					if (strumTime > Conductor.songPosition - PlayState.safeZoneOffset
						&& strumTime < Conductor.songPosition + (PlayState.safeZoneOffset * 0.5))
						canBeHit = true;
					else
						canBeHit = false;

					if (strumTime < Conductor.songPosition - PlayState.safeZoneOffset && !wasGoodHit)
						tooLate = true;
				}
				else
				{
					canBeHit = false;

					if (strumTime < Conductor.songPosition + (PlayState.safeZoneOffset * 0.5))
					{
						// fixes botplay going above strumline // worth noting that above the strumline represents music desync. 
						if ((isSustainNote && prevNote.wasGoodHit) || strumTime - Conductor.songPosition < 4) // mean 1/60 /4 = 4.
							wasGoodHit = true;
					}
				}

				if (tooLate)
				{
					if (alpha > 0.3)
						alpha = 0.3;
				}
		}
	}
}
