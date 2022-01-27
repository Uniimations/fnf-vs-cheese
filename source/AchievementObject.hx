import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;


class AchievementObject extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null, ?type:String = 'achievement')
	{
		super(x, y);

		var id:Int;
		var achievementBG:FlxSprite;
		var achievementIcon:FlxSprite;
		var achievementName:FlxText;
		var achievementText:FlxText;

		switch (type)
		{
			case 'achievement':
				id = Achievements.getAchievementIndex(name);

				achievementBG = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
				achievementBG.scrollFactor.set();

				achievementIcon = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/achievementGrid'), true, 150, 150);
				achievementIcon.animation.add('icon', [id], 0, false, false);
				achievementIcon.animation.play('icon');
				achievementIcon.scrollFactor.set();
				achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
				achievementIcon.updateHitbox();
				achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

				achievementName = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
				achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
				achievementName.scrollFactor.set();

				achievementText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.achievementsStuff[id][1], 16);
				achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
				achievementText.scrollFactor.set();
			case 'notification':
				var NewColor:Int = 0xFF401829;

				id = Achievements.getAchievementIndex(name, "notification");

				achievementBG = new FlxSprite(60, 50).makeGraphic(420, 120, NewColor);
				achievementBG.scrollFactor.set();

				achievementIcon = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/NOTIFICATION'), true, 150, 150);
				achievementIcon.scrollFactor.set();
				achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
				achievementIcon.updateHitbox();
				achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

				achievementName = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.notifStuff[id][0], 16);
				achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
				achievementName.scrollFactor.set();

				achievementText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.notifStuff[id][1], 16);
				achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
				achievementText.scrollFactor.set();

                trace('NOTIFICATION ITEM FOUND!');
			default:
				id = Achievements.getAchievementIndex(name, type);

				achievementBG = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
				achievementBG.scrollFactor.set();

				achievementIcon = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/achievementGrid'), true, 150, 150);
				achievementIcon.animation.add('icon', [id], 0, false, false);
				achievementIcon.animation.play('icon');
				achievementIcon.scrollFactor.set();
				achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
				achievementIcon.updateHitbox();
				achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

				achievementName = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
				achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
				achievementName.scrollFactor.set();

				achievementText = new FlxText(achievementName.x, achievementName.y + 32, 280, 'No achievement type specified.', 16);
				achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
				achievementText.scrollFactor.set();

                trace('ERROR: No achievement type specified');
		}

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});

		// ACHIEVEMENT SAVING DATA (not in 4.2 for some reason)
		if (FlxG.save.data.achievementsMap == null) {
			FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		}
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}
