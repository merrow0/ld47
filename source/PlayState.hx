package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

enum Direction
{
	NONE;
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum ActorType
{
	AUTO;
	SEMI;
	MANUAL;
	ONEWAY;
}

class PlayState extends TiledState
{
	static var actions:FlxActionManager;

	var mapCam:FlxCamera;
	var uiCam:FlxCamera;
	var grabbedPos:FlxPoint = new FlxPoint(-1, -1);
	var initialScroll:FlxPoint = new FlxPoint(0, 0);
	var selectedActor:FlowActor;
	var _left:FlxActionDigital;
	var _right:FlxActionDigital;
	var _up:FlxActionDigital;
	var _down:FlxActionDigital;
	var _hud:HUD;
	var _aboutToRestart:Bool = false;

	override public function create()
	{
		super.create();

		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;

		FlxG.fullscreen = true;
		FlxG.stage.showDefaultContextMenu = false;

		// var mouseSprite = new FlxSprite();
		// mouseSprite.makeGraphic(32, 32, FlxColor.TRANSPARENT);

		// // Load the sprite's graphic to the cursor
		// FlxG.mouse.load(mouseSprite.pixels);

		_left = new FlxActionDigital();
		_right = new FlxActionDigital();
		_up = new FlxActionDigital();
		_down = new FlxActionDigital();
		_initCamPos = new FlxPoint(0, 0);

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([_left, _right, _up, _down]);

		_left.addKey(LEFT, JUST_PRESSED).addKey(A, JUST_PRESSED);
		_right.addKey(RIGHT, JUST_PRESSED).addKey(D, JUST_PRESSED);
		_up.addKey(UP, JUST_PRESSED).addKey(W, JUST_PRESSED);
		_down.addKey(DOWN, JUST_PRESSED).addKey(S, JUST_PRESSED);

		level = new TiledLevel(Reg.levels[Reg.levelIdx], this);

		add(level.backgroundLayer);
		add(level.wallLayer);
		add(wurstGroup);
		add(spawners);
		add(level.foregroundLayer);
		add(actors);
		add(exits);

		FlxG.camera.scroll.set((FlxG.width * -0.5) + (level.tileWidth * level.tileWidth / 2),
			(FlxG.height * -0.5) + (level.tileHeight * level.tileHeight / 2));
		FlxG.camera.setScrollBoundsRect(0, 0, level.fullWidth, level.fullHeight, true);
		FlxG.camera.focusOn(_initCamPos);

		_hud = new HUD();
		_hud.scrollFactor.set(0, 0);
		add(_hud);

		actors.forEach((actor) -> actor.init());

		FlxG.sound.playMusic(AssetPaths.sewer_shuffle_new__ogg, 0.7, true);
		FlxG.sound.music.persist = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		overlapCheck();
		clickActorCheck();
		keyboardCheck();
		mouseCheck();
		checkWin();
		checkLose();

		persistentDraw = Reg.persistentDraw;
	}

	override function overlapCheck():Void
	{
		super.overlapCheck();

		FlxG.overlap(wurstGroup, exits, onWurstHitsExit);
		FlxG.overlap(wurstGroup, spawners, onWurstHitsSpawner);
		FlxG.overlap(wurstGroup, onWurstHitsWurst, pixelPerfectProcess);
	}

	function checkWin():Void
	{
		if (Reg.winCount <= 0)
		{
			Reg.levelIdx++;
			if (Reg.levelIdx < Reg.levels.length)
			{
				FlxG.sound.music.stop();
				FlxG.sound.play(AssetPaths.music_win__ogg, 1, false);
				openSubState(new WinHUD());
			}
			else
			{
				// FlxG.switchState(new MenuState());
			}
		}
	}

	function checkLose():Void
	{
		if (Reg.loseCount <= 0)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(AssetPaths.music_lose__ogg, 1, false);
			openSubState(new EscapeHUD("YOU LOSE", false));
		}
	}

	function clickActorCheck():Void
	{
		if (FlxG.mouse.justPressed)
		{
			var actorSelected:Bool = false;

			actors.forEach((actor) ->
			{
				var mousePos = FlxG.mouse.getWorldPosition(mapCam);
				var mousePosGridX = Std.int(mousePos.x / level.tileWidth);
				var mousePosGridY = Std.int(mousePos.y / level.tileHeight);

				var actorGridX = Std.int(actor.x / level.tileWidth);
				var actorGridY = Std.int(actor.y / level.tileHeight);

				if (actor.type != AUTO && mousePosGridX == actorGridX && mousePosGridY == actorGridY)
				{
					actorSelected = true;

					if (selectedActor != null)
					{
						selectedActor.isSelected = false;
					}
					selectedActor = actor;
					selectedActor.isSelected = true;
				}
			});

			if (!actorSelected && selectedActor != null)
			{
				selectedActor.isSelected = false;
			}
		}
	}

	function mouseCheck():Void
	{
		if (_aboutToRestart)
			return;

		if (FlxG.mouse.justPressedRight)
		{
			grabbedPos = FlxG.mouse.getWorldPosition();
			initialScroll = FlxG.camera.scroll;
		}
		if (FlxG.mouse.pressedRight)
		{
			var mousePosChange:FlxPoint = FlxG.mouse.getWorldPosition().subtractPoint(grabbedPos);
			FlxG.camera.scroll.subtractPoint(mousePosChange);
		}
		// mapCam.zoom += 0.2 * FlxG.mouse.wheel / 100;
		// _hud.zoomLevel.text = Std.string(mapCam.zoom);
	}

	function keyboardCheck():Void
	{
		if (selectedActor != null)
		{
			if (selectedActor.isSelected == true)
			{
				if (_left.triggered)
				{
					if (selectedActor.canChangeToDirection(LEFT))
					{
						selectedActor.setDirection(LEFT);
						selectedActor.isSelected = false;
					}
					else
					{
						FlxG.sound.play(AssetPaths.blocked_valve__ogg, 1, false);
					}
				}
				else if (_right.triggered)
				{
					if (selectedActor.canChangeToDirection(RIGHT))
					{
						selectedActor.setDirection(RIGHT);
						selectedActor.isSelected = false;
					}
					else
					{
						FlxG.sound.play(AssetPaths.blocked_valve__ogg, 1, false);
					}
				}
				else if (_up.triggered)
				{
					if (selectedActor.canChangeToDirection(UP))
					{
						selectedActor.setDirection(UP);
						selectedActor.isSelected = false;
					}
					else
					{
						FlxG.sound.play(AssetPaths.blocked_valve__ogg, 1, false);
					}
				}
				else if (_down.triggered)
				{
					if (selectedActor.canChangeToDirection(DOWN))
					{
						selectedActor.setDirection(DOWN);
						selectedActor.isSelected = false;
					}
					else
					{
						FlxG.sound.play(AssetPaths.blocked_valve__ogg, 1, false);
					}
				}
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			openSubState(new EscapeHUD("PAUSED", true));
		}

		// ***DEBUG ****
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.sound.music.stop();
			FlxG.switchState(new PlayState());
		}
		else if (FlxG.keys.justPressed.L)
		{
			Reg.winCount = 0;
		}
		else if (FlxG.keys.justPressed.O)
		{
			Reg.loseCount = 0;
		}
	}

	function onWurstHitsWurst(wurst1:Wurst, wurst2:Wurst):Void
	{
		Reg.loseCount--;
		_hud.updateHUD();

		FlxG.sound.play(Reg.sounds_fluch[FlxG.random.int(0, Reg.sounds_fluch.length - 1)], 2, false);
		FlxG.camera.flash(FlxColor.BROWN, 0.1);

		wurst1.isImmovable = true;
		wurst2.killWurst(false);
	}

	function onWurstHitsExit(wurst:Wurst, actor:FlxSprite):Void
	{
		if (wurst.active)
		{
			Reg.winCount--;
			_hud.updateHUD();
		}

		wurst.killWurst(true);
	}

	function onWurstHitsSpawner(wurst:Wurst, spawner:WurstSpawner):Void
	{
		wurst.killWurst(false);

		_aboutToRestart = true;

		FlxG.camera.setScrollBounds(null, null, null, null);
		FlxG.camera.focusOn(spawner.getMidpoint());
		FlxG.camera.shake(0.01, 1);

		FlxTween.tween(FlxG.camera, {zoom: 2}, 0.2, {
			onComplete: function(t:FlxTween)
			{
				t.destroy();
				FlxG.sound.music.stop();
				FlxG.sound.play(Reg.sounds_fluch[FlxG.random.int(0, Reg.sounds_fluch.length - 1)], 2, false, function()
				{
					FlxG.switchState(new PlayState());
				});
			},
			ease: FlxEase.quadOut
		});
	}

	private static function pixelPerfectProcess(obj1:FlxBasic, obj2:FlxBasic):Bool
	{
		if (Std.is(obj1, Wurst) && Std.is(obj2, Wurst))
		{
			var spr1:Wurst = cast obj1;
			var spr2:Wurst = cast obj2;
			if (FlxG.pixelPerfectOverlap(spr1, spr2))
				return true;
		}
		return false;
	}
}
