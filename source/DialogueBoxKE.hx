package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitLeft1:FlxSprite;
	var portraitLeft2:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitGF:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'ice-cold':
				FlxG.sound.playMusic(Paths.music('Park'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFF000000);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(0, 0);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			/*case 'tutorial':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('cream/creamUI/19dollarfortnitecard');
				box.animation.addByPrefix('normalOpen', 'OLDopen', 24, false);
				box.animation.addByPrefix('normal', 'text box ANIMATE', 24, true);*/
			case 'ice-cold':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('cream/creamUI/19dollarfortnitecard');
				box.animation.addByPrefix('normalOpen', 'OLDopen', 24, false);
				box.animation.addByPrefix('normal', 'text box ANIMATE', 24, true);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(0, 0);
		portraitLeft.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft.animation.addByPrefix('enter', 'cream normal', 24, false);
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitLeft1 = new FlxSprite(0, 0);
		portraitLeft1.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft1.animation.addByPrefix('enter', 'cream LOL', 24, false);
		portraitLeft1.updateHitbox();
		portraitLeft1.scrollFactor.set();
		add(portraitLeft1);
		portraitLeft1.visible = false;

		portraitLeft2 = new FlxSprite(0, 0);
		portraitLeft2.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft2.animation.addByPrefix('enter', 'cream smug', 24, false);
		portraitLeft2.updateHitbox();
		portraitLeft2.scrollFactor.set();
		add(portraitLeft2);
		portraitLeft2.visible = false;

		portraitRight = new FlxSprite(0, 0);
		portraitRight.frames = Paths.getSparrowAtlas('cream/creamUI/bf');
		portraitRight.animation.addByPrefix('enter', 'bf stuff', 24, false);
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		portraitGF = new FlxSprite(0, 0);
		portraitGF.frames = Paths.getSparrowAtlas('cream/creamUI/gf');
		portraitGF.animation.addByPrefix('enter', 'gf stuff', 24, false);
		portraitGF.updateHitbox();
		portraitGF.scrollFactor.set();
		add(portraitGF);
		portraitGF.visible = false;

		//all stuff for song specific shit because im too lazy to code in more portraits and it also saves space
		//or smth probably idfk ask tom whos tom? idk tom like uhh fuckin uhh u lookin liken uhm n uhh hh like auhh uh uhnm uhhh uuh
		if (PlayState.SONG.song.toLowerCase() == 'tutorial')
		{
		portraitLeft1 = new FlxSprite(0, 0);
		portraitLeft1.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft1.animation.addByPrefix('enter', 'cream sad', 24, false);
		portraitLeft1.updateHitbox();
		portraitLeft1.scrollFactor.set();
		add(portraitLeft1);
		portraitLeft1.visible = false;

		portraitLeft2 = new FlxSprite(0, 0);
		portraitLeft2.frames = Paths.getSparrowAtlas('cream/creamUI/AMIGOS');
		portraitLeft2.animation.addByPrefix('enter', 'THE THREE AMIGOS', 24, true);
		portraitLeft2.updateHitbox();
		portraitLeft2.scrollFactor.set();
		add(portraitLeft2);
		portraitLeft2.visible = false;
		}

		if (PlayState.SONG.song.toLowerCase() == 'ice-cold')
		{
		portraitLeft1 = new FlxSprite(0, 0);
		portraitLeft1.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft1.animation.addByPrefix('enter', 'cream sad', 24, false);
		portraitLeft1.updateHitbox();
		portraitLeft1.scrollFactor.set();
		add(portraitLeft1);
		portraitLeft1.visible = false;
		}

		if (PlayState.SONG.song.toLowerCase() == 'thawed')
		{
		portraitLeft1 = new FlxSprite(0, 0);
		portraitLeft1.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft1.animation.addByPrefix('enter', 'creampie sex', 24, false);
		//dont ask why i called it that
		portraitLeft1.updateHitbox();
		portraitLeft1.scrollFactor.set();
		add(portraitLeft1);
		portraitLeft1.visible = false;

		/*portraitGF = new FlxSprite(0, 0);
		portraitGF.frames = Paths.getSparrowAtlas('cream/creamUI/gf');
		portraitGF.animation.addByPrefix('enter', 'gf2 stuff', 24, false);
		portraitGF.updateHitbox();
		portraitGF.scrollFactor.set();
		add(portraitGF);
		portraitGF.visible = false;*/
		}

		if (PlayState.SONG.song.toLowerCase() == 'vibing')
		{
		portraitLeft = new FlxSprite(0, 0);
		portraitLeft.frames = Paths.getSparrowAtlas('cream/creamUI/cream better');
		portraitLeft.animation.addByPrefix('enter', 'cream dead', 24, false);
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitLeft1 = new FlxSprite(0, 0);
		portraitLeft1.frames = Paths.getSparrowAtlas('cream/creamUI/AMIGOS');
		portraitLeft1.animation.addByPrefix('enter', 'THE THREE AMIGOS', 24, true);
		portraitLeft1.updateHitbox();
		portraitLeft1.scrollFactor.set();
		add(portraitLeft1);
		portraitLeft1.visible = false;

		portraitGF = new FlxSprite(0, 0);
		portraitGF.frames = Paths.getSparrowAtlas('cream/creamUI/gf');
		portraitGF.animation.addByPrefix('enter', 'gf2 stuff', 24, false);
		portraitGF.updateHitbox();
		portraitGF.scrollFactor.set();
		add(portraitGF);
		portraitGF.visible = false;
		}

		box.animation.play('normalOpen');
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		
		if (!talkingRight)
		{
			//DO NOTHING LMAOOOOO
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
						FlxG.sound.music.fadeOut(2.2, 0);
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5;
						portraitLeft.alpha -= 1 / 5;
						portraitLeft1.alpha -= 1 / 5;
						portraitLeft2.alpha -= 1 / 5;
						portraitRight.alpha -= 1 / 5;
						portraitGF.alpha -= 1 / 5;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);
					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'cream':
				portraitRight.visible = false;
				portraitLeft1.visible = false;
				portraitLeft2.visible = false;
				portraitGF.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
					if (PlayState.SONG.song.toLowerCase() == 'vibing')
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/SNAS'), 0.6)];
					else if (PlayState.SONG.song.toLowerCase() == 'ice-cold' || PlayState.SONG.song.toLowerCase() == 'cold-shoulder' || PlayState.SONG.song.toLowerCase() == 'thawed')
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.6)];
					trace('BIG MAN HUGE GUY funny man');
				}
			case 'creamLOL':
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitGF.visible = false;
				if (!portraitLeft1.visible)
				{
					portraitLeft1.visible = true;
					portraitLeft1.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.6)];
					trace('its fucking uhh yknow');
				}
			case 'creamsmug':
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitLeft1.visible = false;
				portraitGF.visible = false;
				if (!portraitLeft2.visible)
				{
					portraitLeft2.visible = true;
					portraitLeft2.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.6)];
					trace('LOOK ITS THE FUNNY MAN!!!');
				}
			case 'bf':
				portraitLeft.visible = false;
				portraitLeft1.visible = false;
				portraitLeft2.visible = false;
				portraitGF.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/boyfriendText'), 0.6)];
					trace('dantdm squiggly looking ass');
				}
			case 'gf':
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitLeft1.visible = false;
				portraitLeft2.visible = false;
				if (!portraitGF.visible)
				{
					portraitGF.visible = true;
					portraitGF.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/gfText'), 0.6)];
					trace('really sexy omfg i wanna fuck her so hard');
					/*
					really sexy omfg i wanna fuck her so hard ara ara my bulgie wolgie is OwOing i
					am gonna COOM im gonna fuck the girlfriend from friday night funkin from funky
					friday friday night funk funkin funky friday friday night funkin!!!
					-avinera
					*/
				}
				if(nextDialogueThing != null) {
					nextDialogueThing();
				}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
