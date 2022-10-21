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
		// TRUE POSITION
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);

		var randomChance = FlxG.random.int(1, 3);

		switch (randomChance)
		{
			case 1:
				alpha = 0.4;
			case 2:
				alpha = 0.6;
			case 3:
				alpha = 0.8;
		}
		//alpha = OPACITY;

		if(lastNoteType != noteType) {
			var skin:String = 'note-splash-skins/noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

			switch(noteType) {
				case 3 | 4 | 5: //CUSTOM NOTE SPLASH
					loadAnims('DODGE' + 'note-splash-skins/noteSplashesUT'); //all expect dodge note splashes arent actually used, this is just in case the game tries to load them
				default:
					loadAnims(skin);
			}
			lastNoteType = noteType;
		}

		// SPLASH SIZE
		setGraphicSize(Std.int(width * 0.7));

		var animNum:Int = FlxG.random.int(1, 2);

		// they have different offsets.. ugh
		// OFFSETS !! FIXED
		switch (animNum)
		{
			case 1:
				offset.set(-10, -20);
			case 2:
				offset.set(0, -8);
		}
		//trace(offset);

		animation.play('note' + note + '-' + animNum, true);
		animation.curAnim.frameRate = 15;
	}

	function loadAnims(skin:String)
	{
		if (!FlxG.bitmap.checkCache("splashasset")) {
			FlxG.bitmap.add(BitmapData.fromFile(Paths.image(skin, null)), false, "splashasset");
		}

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
		if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}