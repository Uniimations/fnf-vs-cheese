package;

import flixel.FlxSprite;

class CreditIcon extends FlxSprite
{
	/**
	 * Icon code from Kade Engine
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'unii')
	{
		super();

		loadGraphic(Paths.image('credits/creditIconGrid'), true, 150, 150);

		antialiasing = ClientPrefs.globalAntialiasing;
		animation.add('unii', [0], 0, false);
		animation.add('potionion', [1], 0, false);
		animation.add('avinera', [2], 0, false);
		animation.add('dude0216', [3], 0, false);
		animation.add('cerbera', [4], 0, false);
		animation.add('joey', [5], 0, false);

		animation.add('bluecheese', [10], 0, false);
		animation.add('oisuzuki', [11], 0, false);
		animation.add('dansilot', [12], 0, false);
		animation.add('arsen', [13], 0, false);
		animation.play(char);

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
