package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;

class NoteSplash extends FlxSprite
{
	private var idleAnim:String;
	private var lastNoteType:Int = -1;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, noteType:Int = 0)
	{
		setGraphicSize(200);
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);

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

		var animNum:Int = FlxG.random.int(1, 2);

		// they have different offsets.. ugh
		// OFFSETS !! FIXED
		switch (animNum)
		{
			case 1:
				offset.set(-10, -20);
				alpha = 0.6;
			case 2:
				offset.set(0, -8);
				alpha = 0.8;
		}

		animation.play('note' + note + '-' + animNum, true);
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);

		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 18, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 18, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 18, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 18, false);
		}
	}

	override function update(elapsed:Float)
	{
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}