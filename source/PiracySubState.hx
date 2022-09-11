package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class PiracySubState extends MusicBeatState
{
	//EVERYTHING HERE IS FOR ANTI PIRACY FOR KBHGAMES OR ANY UNOFFICIAL BROWSER BUILD!!!
	//please do not straight up steal and compile the code from this mod without permission from me or Bluecheese just to steal the mod. 
	//Don't try to remove this code please. Thank you!

	//idk if calling this piracy even makes sense, but kbh sucks anyway

	public static var leftState:Bool = false;
	var bg:FlxSprite;
	var piracy:FlxSprite;
	var piracyPath:String = 'anti_piracy_update'; //im lazy, also so i can change the path easily

	override function create()
	{
		super.create();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		bg.alpha = 0;
		bg.visible = false;

		piracy = new FlxSprite().loadGraphic(Paths.image(piracyPath));
		add(piracy);
	}

	override function update(elapsed:Float)
	{
		//MIGHT BUG THINGS OUT SO JUST IN CASE SINCE THIS IS ALL A LOADING STATE FOR DESKTOP/ANYTHING NOT HTML

		if (controls.ACCEPT)
			FlxG.openURL("https://gamebanana.com/mods/296548");
		if (controls.BACK)
			MusicBeatState.switchState(new MainMenuState());

		super.update(elapsed);
	}
}
