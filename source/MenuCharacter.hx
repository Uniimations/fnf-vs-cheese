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

		//SPRITE CODE
		switch(character) {
			//there's new code in Paths.hx to get the Menu Sparrow Atlas
			case 'bf':
				frames = Paths.getMenuSA('BF');
				animation.addByPrefix('idle', "M BF Idle", 24);
				animation.addByPrefix('confirm', 'M bf HEY', 24, false);

			case 'bf-dark':
				frames = Paths.getMenuSA('BF_Dark');
				animation.addByPrefix('idle', "BF IDLE DARK", 24);
				animation.addByPrefix('confirm', 'BF HEYD ARK', 24, false);

			case 'gf':
				frames = Paths.getMenuSA('GF');
				animation.addByPrefix('idle', "M GF Idle", 24);

			case 'dad':
				frames = Paths.getMenuSA('Dad');
				animation.addByPrefix('idle', "M Dad Idle", 24);

			case 'bluecheese':
				frames = Paths.getMenuSA('Cheese');
				animation.addByPrefix('idle', "Cheese Idle Menui", 24);

			case 'null-boy':
				frames = Paths.getMenuSA('Dad');
				animation.addByPrefix('idle', "M Dad Idle", 24);
		}
		animation.play('idle');
		updateHitbox();

		//OFFSETS
		switch(character) {
			case 'bf':
				offset.set(15, -40);
				visible = true;

			case 'bf-dark':
				offset.set(15, -40);
				visible = true;

			case 'gf':
				offset.set(0, -25);
				visible = true;

			case 'dad':
				visible = true;

			case 'bluecheese':
				offset.set(0, 10);
				visible = true;

			case 'null-boy':
				offset.set(0, 0);
				visible = false;
		}
	}
}
