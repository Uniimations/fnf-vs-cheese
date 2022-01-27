package;

import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if sys
import sys.io.File;
#end

using StringTools;

class Events extends PlayState
{
	public function triggerEventNote(eventName:String, value1:String, value2:String, ?onLua:Bool = false) {
		if (!ClientPrefs.fuckyouavi)
		{
			switch(eventName)
			{
				case 'Hey!':
					var value:Int = Std.parseInt(value1);
					var time:Float = Std.parseFloat(value2);
					if(Math.isNaN(time) || time <= 0) time = 0.6;
	
					if(value != 0) {
						if (dad.curCharacter.startsWith('gf')) {
							dad.playAnim('cheer', true);
							dad.specialAnim = true;
							dad.heyTimer = time;
						} else {
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = time;
						}

						if(curStage == 'mall') {
							bottomBoppers.animation.play('hey', true);
							heyTimer = time;
						}
					}
					if(value != 1) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					}

				case 'Set GF Speed':
					var value:Int = Std.parseInt(value1);
					if(Math.isNaN(value)) value = 1;
					gfSpeed = value;

				case 'Poggers Lights':
					if(ClientPrefs.specialEffects && curStage == 'restaurante') {
						var lightId:Int = Std.parseInt(value1);
						if(Math.isNaN(lightId)) lightId = 0;
	
						if(lightId > 0 && curLightEvent != lightId) {
							if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);
	
							var color:Int = 0xffffffff;
							switch(lightId) {
								case 1: //Blue
									color = 0xff31a2fd;
								case 2: //Green
									color = 0xff31fd8c;
								case 3: //Pink
									color = 0xfff794f7;
								case 4: //Red
									color = 0xfff96d63;
								case 5: //Orange
									color = 0xfffba633;
							}
							curLightEvent = lightId;
	
							if(phillyBlack.alpha != 1) {
								if(phillyBlackTween != null) {
									phillyBlackTween.cancel();
								}
								phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
								if (CoolUtil.difficultyString() == 'EX') {
									phillyBlackTween = FlxTween.tween(phillyCounter, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
								}
								phillyBlackTween = FlxTween.tween(frontBoppers, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
	
								var chars:Array<Character> = [boyfriend, gf, dad];
								for (i in 0...chars.length) {
									if(chars[i].colorTween != null) {
										chars[i].colorTween.cancel();
									}
									chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
										chars[i].colorTween = null;
									}, ease: FlxEase.quadInOut});
								}
							} else {
								dad.color = color;
								boyfriend.color = color;
								gf.color = color;
							}

						} else {
							if(phillyBlack.alpha != 0) {
								if(phillyBlackTween != null) {
									phillyBlackTween.cancel();
								}
								phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
								if (CoolUtil.difficultyString() == 'EX') {
									phillyBlackTween = FlxTween.tween(phillyCounter, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
								}
								phillyBlackTween = FlxTween.tween(frontBoppers, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween) {
										phillyBlackTween = null;
									}
								});
							}

							var chars:Array<Character> = [boyfriend, gf, dad];
							for (i in 0...chars.length) {
								if(chars[i].colorTween != null) {
									chars[i].colorTween.cancel();
								}
								chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
									chars[i].colorTween = null;
								}, ease: FlxEase.quadInOut});
							}
	
							curLight = 0;
							curLightEvent = 0;
						}
					}
				case 'Poggers Fade':
					var pogging:Int = Std.parseInt(value1);
					var poggerLength:Float = Std.parseFloat(value2);

					switch (curStage)
					{
						case 'undertale': // black fade
							switch (pogging)
							{
								case 0:
									phillyBlackTween = FlxTween.tween(phillyFade, {alpha: 1}, poggerLength, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
								case 1:
									phillyBlackTween = FlxTween.tween(phillyFade, {alpha: 0}, poggerLength, {ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween) {
											phillyBlackTween = null;
										}
									});
							}

						case 'frostedStage': // freeze fade
							if (ClientPrefs.specialEffects)
							{
								switch (pogging)
								{
									case 0:
										doFlash();
										freezePogging = true;
										snow.visible = true;
										dadPog = true;
										boyfriendPog = true;
		
										freezeFadeTween(scoreTxt, 0, poggerLength);
										freezeFadeTween(healthBar, 0, poggerLength);
										freezeFadeTween(healthBarBG, 0, poggerLength);
										freezeFadeTween(iconP1, 0, poggerLength);
										freezeFadeTween(iconP2, 0, poggerLength);
		
										if (redFade.alpha != 1)
											freezeFadeTween(freezeFade, 1, poggerLength);

										defaultCamZoom = 1.05;
									case 1:
										doFlash();
										freezePogging = false;
										snow.visible = false;
										dadPog = false;
										boyfriendPog = false;
		
										freezeFadeTween(scoreTxt, 1, poggerLength);
										freezeFadeTween(healthBar, 1, poggerLength);
										freezeFadeTween(healthBarBG, 1, poggerLength);
										freezeFadeTween(iconP1, 1, poggerLength);
										freezeFadeTween(iconP2, 1, poggerLength);
		
										if (freezeFade.alpha != 0)
											freezeFadeTween(freezeFade, 0, poggerLength);
										if (songMisses > 7)
										{
											if (redFade.alpha != 1)
												freezeFadeTween(redFade, 1, 2);
										}

										defaultCamZoom = staticCamZoom;
									case 2:
										if (freezePogging == true)
											freezePogging = false;

										dadPog = false;
										boyfriendPog = false;

										freezeFadeTween(scoreTxt, 0, poggerLength);
										freezeFadeTween(healthBar, 0, poggerLength);
										freezeFadeTween(healthBarBG, 0, poggerLength);
										freezeFadeTween(iconP1, 0, poggerLength);
										freezeFadeTween(iconP2, 0, poggerLength);
		
										if (redFade.alpha != 1)
											freezeFadeTween(freezeFade, 1, poggerLength);
									case 3:
										if (freezePogging == true)
											freezePogging = false;

										dadPog = false;
										boyfriendPog = false;

										freezeFadeTween(scoreTxt, 1, poggerLength);
										freezeFadeTween(healthBar, 1, poggerLength);
										freezeFadeTween(healthBarBG, 1, poggerLength);
										freezeFadeTween(iconP1, 1, poggerLength);
										freezeFadeTween(iconP2, 1, poggerLength);
		
										if (freezeFade.alpha != 0)
											freezeFadeTween(freezeFade, 0, poggerLength);
										if (songMisses > 7)
										{
											if (redFade.alpha != 1)
												freezeFadeTween(redFade, 1, 2);
										}
								}
							}
						default:
							phillyBlackTween = FlxTween.tween(value1, {alpha: poggerLength}, 1, {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									phillyBlackTween = null;
								}
							});
					}

				case 'Add Camera Zoom':
					if(FlxG.camera.zoom < 1.35) {
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = 0.015;
						if(Math.isNaN(hudZoom)) hudZoom = 0.03;
	
						FlxG.camera.zoom += camZoom;
						camHUD.zoom += hudZoom;
					}

				case 'Trigger BG Ghouls':
					if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
						bgGhouls.dance(true);
						bgGhouls.visible = true;
					}

				case 'Play Animation':
					trace('Anim to play: ' + value1);
					var val2:Int = Std.parseInt(value2);
					if(Math.isNaN(val2)) val2 = 0;
	
					var char:Character = dad;
					switch(val2) {
						case 1: char = boyfriend;
						case 2: char = gf;
					}
					char.playAnim(value1, true);
					char.specialAnim = true;

				case 'Camera Follow Pos':
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;
	
					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}

				case 'Set CamPog':
					if (ClientPrefs.cameraShake)
					{
						var pogging:Int = Std.parseInt(value1);

						if(Math.isNaN(pogging))
							pogging = 0;

						switch(pogging) {
							case 0:
								boyfriendPog = false;
								dadPog = false;
							case 1:
								dadPog = true;
							case 2:
								boyfriendPog = true;
						}
					}

				case 'Alt Idle Animation':
					var val:Int = Std.parseInt(value1);
					if(Math.isNaN(val)) val = 0;
	
					var char:Character = dad;
					switch(val) {
						case 1: char = boyfriend;
						case 2: char = gf;
						case 3: char = littleMan; //for cultured ex sit
					}
					char.idleSuffix = value2;
					char.recalculateDanceIdle();

				case 'Screen Shake':
					var valuesArray:Array<String> = [value1, value2];
					var targetsArray:Array<FlxCamera> = [camGame, camHUD];
					for (i in 0...targetsArray.length) {
						var split:Array<String> = valuesArray[i].split(',');
						var duration:Float = Std.parseFloat(split[0].trim());
						var intensity:Float = Std.parseFloat(split[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;
	
						if(duration > 0 && intensity != 0) {
							targetsArray[i].shake(intensity, duration);
						}
					}

				case 'Change CamZoom': //this was the worst way to do this im so sorry
					if (ClientPrefs.camZoomOut)
					{
						var camZoomValue:Int = Std.parseInt(value1);
						if(Math.isNaN(camZoomValue)) camZoomValue = 0;

						switch (camZoomValue)
						{
							case 0: //reset camera zoom
								defaultCamZoom = staticCamZoom;
							case 1:
								defaultCamZoom = 0.1;
							case 2:
								defaultCamZoom = 0.2;
							case 3:
								defaultCamZoom = 0.3;
							case 4:
								defaultCamZoom = 0.4;
							case 5:
								defaultCamZoom = 0.5;
							case 6:
								defaultCamZoom = 0.6;
							case 7:
								defaultCamZoom = 0.7;
							case 8:
								defaultCamZoom = 0.8;
							case 9:
								defaultCamZoom = 0.9;
						}
					}

				case 'Change NumZoom':
					if (ClientPrefs.camZoomOut)
					{
						var zoom:Float = Std.parseFloat(value1);

						if (value1 == 'reset')
						{
							defaultCamZoom = staticCamZoom;
						}
						else
						{
							defaultCamZoom = zoom;
						}
					}

				case 'Flash':
					var flashValue:Int = Std.parseInt(value1);

					// dear past me... IS THAT SUPPOSED TO BE AN IF ELSE STATEMENT????

					if (ClientPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, flashValue);
					else
						if (!curSong.toLowerCase().startsWith('manager'))
							FlxG.camera.flash(FlxColor.BLACK, flashValue);

				case 'Flash Color':
					var flashSprite:FlxSprite;
					var flashColor:Int = Std.parseInt(value1);
	
					switch (flashColor)
					{
						case 0:
							flashColor = 0xFFFF5277;
						case 1:
							flashColor = 0xFF49F792;
						case 2:
							flashColor = 0xFF3F71FF;
						case 3:
							flashColor = 0xFFC45EFF;
						case 4:
							flashColor = FlxColor.WHITE;
					}

					flashSprite = new FlxSprite(-430, -250).makeGraphic(Std.int(FlxG.width * 7), Std.int(FlxG.height * 7), flashColor);
					flashSprite.scrollFactor.set();
					flashSprite.alpha = 0.3;
					add(flashSprite);

					FlxTween.tween(flashSprite, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});

				case 'Change Character':
					var charType:Int = Std.parseInt(value1);
					if(Math.isNaN(charType)) charType = 0;

					switch(charType) {
						case 0:
							if(boyfriend.curCharacter != value2) {
									if(!boyfriendMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
	
									boyfriend.visible = false;
									boyfriend = boyfriendMap.get(value2);
									if(!boyfriend.alreadyLoaded) {
										boyfriend.alpha = 1;
										boyfriend.alreadyLoaded = true;
									}
									boyfriend.visible = true;
									iconP1.changeIcon(boyfriend.healthIcon);
							}

						case 1:
							if(dad.curCharacter != value2) {
									if(!dadMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
	
									var wasGf:Bool = dad.curCharacter.startsWith('gf');
									dad.visible = false;
									dad = dadMap.get(value2);
									if(!dad.curCharacter.startsWith('gf')) {
										if(wasGf) {
											gf.visible = true;
										}
									} else {
										gf.visible = false;
									}
									if(!dad.alreadyLoaded) {
										dad.alpha = 1;
										dad.alreadyLoaded = true;
									}
									dad.visible = true;
									iconP2.changeIcon(dad.healthIcon);
									if (CoolUtil.difficultyString() == 'EX' && curSong.toLowerCase() == 'cultured') {
										doFlash();
									}
							}

						case 2:
							if(gf.curCharacter != value2) {
									if(!gfMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
	
									gf.visible = false;
									gf = gfMap.get(value2);
									if(!gf.alreadyLoaded) {
										gf.alpha = 1;
										gf.alreadyLoaded = true;
									}
							}
					}
					reloadAllBarColors();

				case 'Summon Lil Man':
					var littleBool:Int = Std.parseInt(value1);
					var flashOn:Int = Std.parseInt(value2);
	
					if(Math.isNaN(littleBool))
						littleBool = 0;
					if(Math.isNaN(littleBool))
						littleBool = 0;
	
					switch(littleBool) {
						case 0: //SUMMON!!!
							littleMan.visible = true;
						case 1: //KILL.
							littleMan.visible = false;
					}

					switch(flashOn) {
						case 0:
							//default does nothing
						case 1:
							if (ClientPrefs.flashing)
								FlxG.camera.flash(FlxColor.WHITE, 1);
							else
								FlxG.camera.flash(FlxColor.BLACK, 1);
						case 2:
							if (ClientPrefs.flashing)
								FlxG.camera.flash(FlxColor.WHITE, 2);
							else
								FlxG.camera.flash(FlxColor.BLACK, 2);
					}

				case 'Opponent Anim': //this is really dumb DONT LOOK AT THIS!!!
					var activeChar:Int = Std.parseInt(value1);
					var littleSection:Int = Std.parseInt(value2);
	
					if(Math.isNaN(activeChar))
						activeChar = 0;
					if(Math.isNaN(littleSection))
						littleSection = 0;
	
					switch(activeChar) {
						case 0: //DEFAULT
							isDad = false;
							isLittleMan = false;
							isGF = false;
						case 1: //DAD
							isDad = true;
							isLittleMan = false;
							isGF = false;
							if (littleMan.visible == true)
								littleMan.dance();
						case 2: //LITTLE MAN
							isDad = false;
							isLittleMan = true;
							isGF = false;
							dad.dance();
						case 3: //GF
							isDad = false;
							isLittleMan = false;
							isGF = true;
							dad.dance();
							if (littleMan.visible == true)
								littleMan.dance();
					}
					switch (littleSection) {
						case 0:
							isCameraOnForcedPos = false;
						case 1:
							camFollow.set(littleMan.getMidpoint().x + 150, littleMan.getMidpoint().y - 100);
							camFollow.x += 0;
							camFollow.y += 200;
							isCameraOnForcedPos = true;
					}
			}
			if(!onLua) {
				callOnLuas('onEvent', [eventName, value1, value2]);
			}
		}
	}
}
