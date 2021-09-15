package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf') {
		if(character == this.character) return;
	
		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;

		switch(character) {
			case 'bf':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_BF');
				animation.addByPrefix('idle', "M BF Idle", 24);
				animation.addByPrefix('confirm', 'M bf HEY', 24, false);

			case 'gf':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_GF');
				animation.addByPrefix('idle', "M GF Idle", 24);

			case 'dad':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Dad');
				animation.addByPrefix('idle', "M Dad Idle", 24);

			case 'bluecheese':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Cheese');
				animation.addByPrefix('idle', "Cheese Idle Menui", 24);

			case 'null-man':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Cheese');
				animation.addByPrefix('idle', "Cheese Idle Menui", 24);
		}
		animation.play('idle');
		updateHitbox();

		switch(character) {
			case 'bf':
				offset.set(15, -40);
				visible = true;

			case 'gf':
				offset.set(0, -25);
				visible = true;

			case 'bluecheese':
				offset.set(0, 10);
				visible = true;

			case 'null-man':
				offset.set(0, 0);
				visible = false;
		}
	}
}
