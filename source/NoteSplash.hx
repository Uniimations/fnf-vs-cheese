package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;

class NoteSplash extends FlxSprite
{
	private var idleAnim:String;
	private var lastNoteType:Int = -1;
	public static var useSplashes:Bool = true;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		if (useSplashes) {
			var skin:String = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

			loadAnims(skin);

			setupNoteSplash(x, y, note);
			antialiasing = ClientPrefs.globalAntialiasing;
		}
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, noteType:Int = 0)
	{
		/*
		if(lastNoteType != noteType)
		{
			switch(noteType)
			{
				case 3:
					loadAnims('note-splash-skins/DODGEnoteSplashesUT'); //all expect dodge note splashes arent actually used, this is just in case the game tries to load them
				default:
					if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
						loadAnims(PlayState.SONG.splashSkin);
					else
						loadAnims('note-splash-skins/noteSplashes');
			}
			lastNoteType = noteType;
		}
		*/

		if (useSplashes) {
			loadAnims('note-splash-skins/NOTE_splashes'); // temporary fix to test note splashess!

			setGraphicSize(200);
			setPosition(x - Note.swagWidth * 0.95 + 55, y - Note.swagWidth + 65); // OFFSETS FINAL
			alpha = 0.63; // crying

			animation.play('note' + note + '-' + FlxG.random.int(1, 2), true);
			//animation.curAnim.frameRate += FlxG.random.int(-2, 2);
			updateHitbox();
		}
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);

		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "BLUE splash " + i, 14, false);
			animation.addByPrefix("note2-" + i, "GREEN splash " + i, 14, false);
			animation.addByPrefix("note0-" + i, "PURPLE splash " + i, 14, false);
			animation.addByPrefix("note3-" + i, "RED splash " + i, 14, false);
		}
	}

	override function update(elapsed:Float)
	{
		if(useSplashes && animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}