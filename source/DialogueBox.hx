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
import flixel.effects.FlxFlicker;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;

	//cheese
	var portraitLeft:FlxSprite;
	var portraitLeft2:FlxSprite;
	var portraitLeft3:FlxSprite;
	var portraitLeft4:FlxSprite;
	var portraitLeft5:FlxSprite;
	var portraitLeft6:FlxSprite;

	//bf
	var portraitRight:FlxSprite;
	var portraitRight2:FlxSprite;

	//gf
	var portraitGF:FlxSprite;
	var portraitGF2:FlxSprite;
	var portraitGF3:FlxSprite;

	var suzuki:FlxSprite;

	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'restaurante':
				FlxG.sound.playMusic(Paths.music('dialogue/is_that_french'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			case 'milkshake':
				FlxG.sound.playMusic(Paths.music('dialogue/the_tea'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			case 'cultured':
				FlxG.sound.playMusic(Paths.music('dialogue/objection'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFF000000);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(0, 0);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'restaurante' | 'milkshake' | 'cultured':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogue/cooltextboxes');
				box.animation.addByPrefix('normalOpen', 'cooltextSUMMON', 24, false);
				box.animation.addByIndices('normal', 'cooltextanim', [1], "", 24);
				box.antialiasing = ClientPrefs.globalAntialiasing;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(0, 0);
		portraitLeft.frames = Paths.getSparrowAtlas('dialogue/Bluecheese_Dialogue');
		portraitLeft.animation.addByPrefix('enter', 'cheeseportrait1', 24, false);
		portraitLeft.antialiasing = ClientPrefs.globalAntialiasing;
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitLeft2 = new FlxSprite(0, 0);
		portraitLeft2.frames = Paths.getSparrowAtlas('dialogue/Bluecheese_Dialogue');
		portraitLeft2.animation.addByPrefix('enter', 'cheeseportrait2', 24, false);
		portraitLeft2.antialiasing = ClientPrefs.globalAntialiasing;
		portraitLeft2.updateHitbox();
		portraitLeft2.scrollFactor.set();
		add(portraitLeft2);
		portraitLeft2.visible = false;

		portraitLeft3 = new FlxSprite(0, 0);
		portraitLeft3.frames = Paths.getSparrowAtlas('dialogue/Bluecheese_Dialogue');
		portraitLeft3.animation.addByPrefix('enter', 'cheeseportrait3', 24, false);
		portraitLeft3.antialiasing = ClientPrefs.globalAntialiasing;
		portraitLeft3.updateHitbox();
		portraitLeft3.scrollFactor.set();
		add(portraitLeft3);
		portraitLeft3.visible = false;

		portraitLeft4 = new FlxSprite(0, 0);
		portraitLeft4.frames = Paths.getSparrowAtlas('dialogue/Bluecheese_Dialogue');
		portraitLeft4.animation.addByPrefix('enter', 'cheeseportrait4', 24, false);
		portraitLeft4.antialiasing = ClientPrefs.globalAntialiasing;
		portraitLeft4.updateHitbox();
		portraitLeft4.scrollFactor.set();
		add(portraitLeft4);
		portraitLeft4.visible = false;

		portraitLeft5 = new FlxSprite(0, 0);
		portraitLeft5.frames = Paths.getSparrowAtlas('dialogue/Bluecheese_Dialogue');
		portraitLeft5.animation.addByPrefix('enter', 'cheeseportrait5', 24, false);
		portraitLeft5.antialiasing = ClientPrefs.globalAntialiasing;
		portraitLeft5.updateHitbox();
		portraitLeft5.scrollFactor.set();
		add(portraitLeft5);
		portraitLeft5.visible = false;

		portraitLeft6 = new FlxSprite(0, 0);
		portraitLeft6.frames = Paths.getSparrowAtlas('dialogue/Bluecheese_Dialogue');
		portraitLeft6.animation.addByPrefix('enter', 'cheeseportrait6', 24, false);
		portraitLeft6.antialiasing = ClientPrefs.globalAntialiasing;
		portraitLeft6.updateHitbox();
		portraitLeft6.scrollFactor.set();
		add(portraitLeft6);
		portraitLeft6.visible = false;

		portraitRight = new FlxSprite(0, 0);
		portraitRight.frames = Paths.getSparrowAtlas('dialogue/BOYFRIEND_Dialogue');
		portraitRight.animation.addByPrefix('enter', 'bfportrait1', 24, false);
		portraitRight.antialiasing = ClientPrefs.globalAntialiasing;
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		portraitRight2 = new FlxSprite(0, 0);
		portraitRight2.frames = Paths.getSparrowAtlas('dialogue/BOYFRIEND_Dialogue');
		portraitRight2.animation.addByPrefix('enter', 'bfportrait2', 24, false);
		portraitRight2.antialiasing = ClientPrefs.globalAntialiasing;
		portraitRight2.updateHitbox();
		portraitRight2.scrollFactor.set();
		add(portraitRight2);
		portraitRight2.visible = false;

		portraitGF = new FlxSprite(0, 0);
		portraitGF.frames = Paths.getSparrowAtlas('dialogue/gf_Dialogue');
		portraitGF.animation.addByPrefix('enter', 'gfportrait1', 24, false);
		portraitGF.antialiasing = ClientPrefs.globalAntialiasing;
		portraitGF.updateHitbox();
		portraitGF.scrollFactor.set();
		add(portraitGF);
		portraitGF.visible = false;

		if (PlayState.SONG.song.toLowerCase() == 'cultured'){
			portraitGF = new FlxSprite(0, 0);
		    portraitGF.frames = Paths.getSparrowAtlas('dialogue/gf_cheer');
		    portraitGF.animation.addByPrefix('enter', 'gfportrait4', 24, false);
		    portraitGF.antialiasing = ClientPrefs.globalAntialiasing;
		    portraitGF.updateHitbox();
		    portraitGF.scrollFactor.set();
		    add(portraitGF);
		    portraitGF.visible = false;
		}

		portraitGF2 = new FlxSprite(0, 0);
		portraitGF2.frames = Paths.getSparrowAtlas('dialogue/gf_Dialogue');
		portraitGF2.animation.addByPrefix('enter', 'gfportrait2', 24, false);
		portraitGF2.antialiasing = ClientPrefs.globalAntialiasing;
		portraitGF2.updateHitbox();
		portraitGF2.scrollFactor.set();
		add(portraitGF2);
		portraitGF2.visible = false;

		portraitGF3 = new FlxSprite(0, 0);
		portraitGF3.frames = Paths.getSparrowAtlas('dialogue/gf_Dialogue');
		portraitGF3.animation.addByPrefix('enter', 'gfportrait3', 24, false);
		portraitGF3.antialiasing = ClientPrefs.globalAntialiasing;
		portraitGF3.updateHitbox();
		portraitGF3.scrollFactor.set();
		add(portraitGF3);
		portraitGF3.visible = false;

		suzuki = new FlxSprite(0, 0);
		suzuki.frames = Paths.getSparrowAtlas('dialogue/OiSuzuki');
		suzuki.animation.addByPrefix('enter', 'suzukiportrait', 24, false);
		suzuki.antialiasing = ClientPrefs.globalAntialiasing;
		suzuki.updateHitbox();
		suzuki.scrollFactor.set();
		add(suzuki);
		suzuki.visible = false;

		box.animation.play('normalOpen');
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		if (!talkingRight)
		{
			//do NOTHING AHHAH
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.visible = false;
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

		if(PlayerSettings.player1.controls.ACCEPT)
		{
			if (dialogueEnded)
			{
				remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						FlxG.sound.play(Paths.sound('dialogue/clickText'), 0.8);	

						if (PlayState.SONG.song.toLowerCase() == 'restaurante' || PlayState.SONG.song.toLowerCase() == 'milkshake' || PlayState.SONG.song.toLowerCase() == 'cultured')
							FlxG.sound.music.fadeOut(1.5, 0);

						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitLeft2.visible = false;
							portraitLeft3.visible = false;
							portraitLeft4.visible = false;
							portraitLeft5.visible = false;
							portraitLeft6.visible = false;
							portraitRight.alpha -= 1 / 5;
							portraitRight2.alpha -= 1 / 5;
							portraitGF.alpha -= 1 / 5;
							portraitGF2.alpha -= 1 / 5;
							portraitGF3.alpha -= 1 / 5;
							suzuki.visible = false;
							swagDialogue.alpha -= 1 / 5;
							dropText.alpha = swagDialogue.alpha;
						}, 5);

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
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
					FlxG.sound.play(Paths.sound('dialogue/clickText'), 0.8);	
				}
			}
			else if (dialogueStarted)
			{
				FlxG.sound.play(Paths.sound('dialogue/clickText'), 0.8);	
				swagDialogue.skip();
			}
		}

		if (PlayerSettings.player1.controls.BACK)
		{
			isEnding = true;
			FlxG.sound.play(Paths.sound('dialogue/clickText'), 0.8);	

			if (PlayState.SONG.song.toLowerCase() == 'restaurante' || PlayState.SONG.song.toLowerCase() == 'milkshake' || PlayState.SONG.song.toLowerCase() == 'cultured')
			FlxG.sound.music.fadeOut(1.5, 0);

			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.alpha -= 1 / 5;
				portraitRight2.alpha -= 1 / 5;
				portraitGF.alpha -= 1 / 5;
				portraitGF2.alpha -= 1 / 5;
				portraitGF3.alpha -= 1 / 5;
				suzuki.visible = false;
				swagDialogue.alpha -= 1 / 5;
				dropText.alpha = swagDialogue.alpha;
			}, 5);

			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
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
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};

		dialogueEnded = false;
		switch (curCharacter)
		{
			case 'cheese':
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					//if (PlayState.SONG.song.toLowerCase() == 'senpai') portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
				}
			case 'cheese2':
				portraitLeft.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitLeft2.visible)
				{
					portraitLeft2.visible = true;
					portraitLeft2.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
				}
			case 'cheese3':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitLeft3.visible)
				{
					portraitLeft3.visible = true;
					portraitLeft3.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
				}
			case 'cheese4':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitLeft4.visible)
				{
					portraitLeft4.visible = true;
					portraitLeft4.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
				}
			case 'cheese5':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitLeft5.visible)
				{
					if(ClientPrefs.flashing) {
						FlxG.camera.flash(FlxColor.WHITE, 1);
					}
					portraitLeft5.visible = true;
					portraitLeft5.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
					FlxG.sound.play(Paths.sound('dialogue/objection'));
				}
			case 'cheese6':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitLeft6.visible)
				{
					portraitLeft6.visible = true;
					portraitLeft6.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0.6)];
				}
			case 'bf':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/boyfriendText'), 0.6)];
				}
			case 'bfhey':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitRight2.visible)
				{
					portraitRight2.visible = true;
					portraitRight2.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/boyfriendText'), 0.6)];
				}
			case 'gf':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitGF.visible)
				{
					portraitGF.visible = true;
					portraitGF.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/gfText'), 0.6)];
				}
			case 'gf2':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				if (!portraitGF2.visible)
				{
					portraitGF2.visible = true;
					portraitGF2.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/gfText'), 0.6)];
				}
			case 'gf3':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitLeft6.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				suzuki.visible = false;
				if (!portraitGF3.visible)
				{
					portraitGF3.visible = true;
					portraitGF3.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/gfText'), 0.6)];
				}
			case 'suzuki':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				if (!suzuki.visible)
				{
					suzuki.visible = true;
					//if (PlayState.SONG.song.toLowerCase() == 'senpai') portraitLeft.visible = true;
					suzuki.animation.play('enter');
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/suzukiText'), 0.6)];
				}
			case 'blank':
				portraitLeft.visible = false;
				portraitLeft2.visible = false;
				portraitLeft3.visible = false;
				portraitLeft4.visible = false;
				portraitLeft5.visible = false;
				portraitRight.visible = false;
				portraitRight2.visible = false;
				portraitGF.visible = false;
				portraitGF2.visible = false;
				portraitGF3.visible = false;
				suzuki.visible = false;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bluecheeseText'), 0)];
		}
		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}