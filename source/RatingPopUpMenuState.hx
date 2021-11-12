import OptionsState.ControlsSubstate;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class RatingPopUpMenuState extends MusicBeatState
{
    var defaultX:Float = FlxG.width * 0.55 - 135;
    var defaultY:Float = FlxG.height / 2 - 50;

    var background:FlxSprite;
    var curt:FlxSprite;
    var front:FlxSprite;

    var textBG:FlxSprite;
    var text:FlxText;
    var previewSine:Float = 0;
    var previewTxt:FlxText;

    var perfect:FlxSprite;

    var bf:Boyfriend;
    var dad:Character;

    private var arrows:FlxSprite;

    private var camHUD:FlxCamera;

    public override function create()
    {
        perfect = new FlxSprite().loadGraphic(Paths.image('perfect','shared'));
        perfect.scrollFactor.set();
        perfect.antialiasing = ClientPrefs.globalAntialiasing;

        background = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        curt = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        front = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));

        background.antialiasing = ClientPrefs.globalAntialiasing;
        curt.antialiasing = ClientPrefs.globalAntialiasing;
        front.antialiasing = ClientPrefs.globalAntialiasing;

        textBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
        textBG.scrollFactor.set();

		text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "Drag rating pop up, RESET to reset, BACK to go back.", 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
		text.scrollFactor.set();

        previewTxt = new FlxText(400, 75, FlxG.width - 800, "", 32);
		previewTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        previewTxt.text = "v GAMEPLAY PREVIEW v";
		previewTxt.scrollFactor.set();
		previewTxt.borderSize = 1.25;

		Conductor.changeBPM(120);
		persistentUpdate = true;

        super.create();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        background.scrollFactor.set(0.9,0.9);
        curt.scrollFactor.set(0.9,0.9);
        front.scrollFactor.set(0.9,0.9);

        add(background);
        add(front);
        add(curt);

		var camFollow = new FlxObject(0, 0, 1, 1);

		dad = new Character(100, 100, 'dad');

        if (ClientPrefs.bfreskin)
        {
            bf = new Boyfriend(770, 450, 'bf-menu-remaster');
        }
        else
        {
            bf = new Boyfriend(770, 450, 'bf-menu');
        }

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

        add(bf);
        add(dad);

        add(perfect);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

        if (ClientPrefs.downScroll) {
            //strumLine.y = FlxG.height - 165;
        }

        add(textBG);
        add(text);
        add(previewTxt);
        trace('loaded all text?');

        perfect.cameras = [camHUD];
        textBG.cameras = [camHUD];
        text.cameras = [camHUD];
        previewTxt.cameras = [camHUD];

        if (!FlxG.save.data.changedHit)
        {
            FlxG.save.data.changedHitX = defaultX;
            FlxG.save.data.changedHitY = defaultY;
        }

        perfect.x = FlxG.save.data.changedHitX;
        perfect.y = FlxG.save.data.changedHitY;

        FlxG.mouse.visible = true;
    }

    override function update(elapsed:Float)
    {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
        camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

        if (FlxG.mouse.overlaps(perfect) && FlxG.mouse.pressed)
        {
            perfect.x = FlxG.mouse.x - perfect.width / 2;
            perfect.y = FlxG.mouse.y - perfect.height;
        }

        if (FlxG.mouse.overlaps(perfect) && FlxG.mouse.justReleased)
        {
            FlxG.save.data.changedHitX = perfect.x;
            FlxG.save.data.changedHitY = perfect.y;
            FlxG.save.data.changedHit = true;
        }

        if (controls.RESET)
        {
            perfect.x = defaultX;
            perfect.y = defaultY;
            FlxG.save.data.changedHitX = perfect.x;
            FlxG.save.data.changedHitY = perfect.y;
            FlxG.save.data.changedHit = false;
        }

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new OptionsState());
        }
    }

    private function newArrows(scrollPref:String)
    {
        if (arrows != null) {
            remove(arrows);
        }
        arrows = new FlxSprite().loadGraphic(Paths.image('settingsmenu/' + scrollPref + '_notes'));
        arrows.setGraphicSize(Std.int(arrows.width * 1.1));
        arrows.updateHitbox();
        arrows.screenCenter();
        arrows.antialiasing = ClientPrefs.globalAntialiasing;
        add(arrows);
    }

    override function beatHit() 
    {
        super.beatHit();

        bf.playAnim('idle');
        dad.dance();

        FlxG.camera.zoom += 0.015;
        camHUD.zoom += 0.010;

        trace('beat');
    }
}