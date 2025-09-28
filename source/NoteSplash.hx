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
	public static var skin:String;

	public function new(x:Float = 0, y:Float = 0, note:Int = 0, noteType:Int = 0)
	{
		super(x, y);

		if (useSplashes) {
			skin = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

			setupNoteSplash(x, y, note, noteType);
			antialiasing = ClientPrefs.globalAntialiasing;
		}
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, noteType:Int = 0)
	{
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

		if (useSplashes) {
			setGraphicSize(200);
			setPosition(x - Note.swagWidth * 0.95 + 55, y - Note.swagWidth + 65); // OFFSETS FINAL
			alpha = 0.63; // crying

			animation.play('note' + note + '-' + FlxG.random.int(1, 2), true);
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
			updateHitbox();
		}
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);

		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float)
	{
		if(useSplashes && animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}