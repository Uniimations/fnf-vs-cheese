package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BGSprite extends FlxSprite
{
	private var idleAnim:String;
	public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false, ?forceShared:Bool = false)
	{
		super(x, y);

		if (animArray != null)
		{
			if (forceShared) {
				frames = Paths.getSparrowAtlas(image, 'shared', false);
			} else {
				frames = Paths.getSparrowAtlas(image, null, false);
			}

			for (i in 0...animArray.length) {
				var anim:String = animArray[i];
				animation.addByPrefix(anim, anim, 24, loop);
				if(idleAnim == null) {
					idleAnim = anim;
					animation.play(anim);
				}
			}
		}
		else
		{
			if(image != null) {
				if (forceShared) {
					loadGraphic(Paths.image(image, 'shared', false));
				} else {
					loadGraphic(Paths.image(image, null, false));
				}
			}
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = ClientPrefs.globalAntialiasing;

		openfl.system.System.gc();
	}

	public function dance(?forceplay:Bool = false) {
		if(idleAnim != null) {
			animation.play(idleAnim, forceplay);
		}
	}
}