package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isSus:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	// The following icons have antialiasing forced to be disabled
	var noAntialiasing:Array<String> = ['bf-pixel', 'senpai', 'spirit'];

	public function new(char:String = 'bf', isPlayer:Bool = false, doFlip:Bool = false)
	{
		super();
		isSus = (char == 'sus');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x - 120, sprTracker.y - 45);
	}

	//sussy function!!!
	public function sussyTime():Void
	{
		changeIcon('sus');
	}

	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/icon-' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);
			var idleSpr:Int = 0; //idle icon sprite
			var losingSpr:Int = 1; //losing icon sprite
			var winningSpr:Int = 0; //winnning icon sprite

			// ALL ANIMATION ICON SORTING CODE!!!
			switch (char) // NOTE: CHAR IS NOT FOR curCharacter IT IS FOR THE ICON NAME!!!
			{
				case 'bluecheese-ex' | 'bf-ex' | 'bidu':  //ex winning icons
					idleSpr = 0;
					losingSpr = 1;
					winningSpr = 2;
				case 'bluecheese-spamton' | 'bluecheese-hex' | 'bluecheese-whitty' | 'bluecheese-tricky' | 'bluecheese-little-man': //reskin icons are out of order because I'm dumb
					idleSpr = 1;
					losingSpr = 0;
					winningSpr = 1;
				case 'dad' | 'bluecheese-garcello': //static icons
					idleSpr = 0;
					losingSpr = 0;
					winningSpr = 0;
				default:
					idleSpr = 0;
					losingSpr = 1;
					winningSpr = 0;
			}

			loadGraphic(file, true, 150, 150);
			animation.add(char, [idleSpr, losingSpr, winningSpr], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			/**
				TRHIS CODE IS REALLY DUMB DON'T DO THIS. vvv
			**/
			// flipped player icons code here, for freeplay menu to work properly with flipX

			/*
			switch (PlayState.SONG.player1) {
				case 'arsen' | 'dansilot' | 'uniinera':
					flipX = true;
			}
			*/
			// IT DOESN'T WORK

			antialiasing = ClientPrefs.globalAntialiasing;
			for (i in 0...noAntialiasing.length) {
				if(char == noAntialiasing[i]) {
					antialiasing = false;
					break;
				}
			}
		}
	}

	public function getCharacter():String {
		return char;
	}
}
