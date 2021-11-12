package;

import flixel.FlxSprite;

class CheckboxThingie extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public function new(x:Float = 0, y:Float = 0, ?checked = false) {
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingieCheeseEdition');
		animation.addByPrefix("static", "cheese checkbox", 24, false);
		animation.addByPrefix("checked", "cheese checked box", 24, false);
		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(0.6 * width));
		updateHitbox();
		set_daValue(checked);
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 30);

		super.update(elapsed);
	}

	private function set_daValue(value:Bool):Bool {
		if(value) {
			if(animation.curAnim.name != 'checked') {
				animation.play('checked', true);
			}
		} else {
			animation.play("static");
		}
		return value;
	}
}