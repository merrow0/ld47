package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxPoint;
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

class PlayState extends FlxState
{
	static var actions:FlxActionManager;

	public var level:TiledLevel;
	public var wurstGroup:FlxGroup;
	public var spawners:FlxTypedGroup<WurstSpawner>;
	public var exits:FlxGroup;
	public var actors:FlxTypedGroup<FlowActor>;
	public var exit:FlxSprite;

	var mapCam:FlxCamera;
	var uiCam:FlxCamera;
	var grabbedPos:FlxPoint = new FlxPoint(-1, -1);
	var initialScroll:FlxPoint = new FlxPoint(0, 0);
	var selectedActor:FlowActor;
	var _initCamPos:FlxPoint;
	var _left:FlxActionDigital;
	var _right:FlxActionDigital;
	var _up:FlxActionDigital;
	var _down:FlxActionDigital;
	var _hud:HUD;

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

		spawners = new FlxTypedGroup<WurstSpawner>();
		actors = new FlxTypedGroup<FlowActor>();
		wurstGroup = new FlxGroup();
		exits = new FlxGroup();

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

		collisionCheck();
		clickActorCheck();
		keyboardCheck();
		mouseCheck();
		checkWin();
	}

	public function handleLoadSpawner(x:Float, y:Float, minInitTime:Int, maxInitTime:Int, minTime:Int, maxTime:Int, initDir:String):Void
	{
		var initalDirection = Direction.DOWN;
		if (initDir != null)
		{
			initalDirection = strToDirection(initDir);
		}
		var spawner = new WurstSpawner(x, y, minInitTime, maxInitTime, minTime, maxTime, initalDirection, this);
		spawners.add(spawner);
	}

	public function handleLoadExit(x:Int, y:Int):Void
	{
		var exit = new FlxSprite(x, y);
		exit.makeGraphic(16, 16, FlxColor.TRANSPARENT);
		exits.add(exit);
	}

	public function handleFlowActor(x:Int, y:Int, type:ActorType, initDir:String, avoidDir:String):Void
	{
		var initalDirection = Direction.NONE;
		if (initDir != null)
		{
			initalDirection = strToDirection(initDir);
		}
		var avoidDirection = Direction.NONE;
		if (avoidDir != null)
		{
			avoidDirection = strToDirection(avoidDir);
		}

		var actor = new FlowActor(x, y, type, initalDirection, avoidDirection, this);
		actors.add(actor);
	}

	public function handleCameraStart(x:Int, y:Int, winCount:Int)
	{
		Reg.winCount = winCount;
		_initCamPos = new FlxPoint(x, y);
	}

	function collisionCheck():Void
	{
		wurstGroup.forEachAlive((it) ->
		{
			var wurst:Wurst = cast(it, Wurst);
			if (level.collideWithLevel(wurst))
			{
				var possibleDirs:Array<Direction> = new Array<Direction>();
				var tileX = Std.int(wurst.x / level.tileWidth);
				var tileY = Std.int(wurst.y / level.tileHeight);

				if (level.collidableTileLayers[0].getTile(tileX, tileY - 1) == 0 && wurst.direction != DOWN)
					possibleDirs.push(UP);
				if (level.collidableTileLayers[0].getTile(tileX, tileY + 1) == 0 && wurst.direction != UP)
					possibleDirs.push(DOWN);
				if (level.collidableTileLayers[0].getTile(tileX - 1, tileY) == 0 && wurst.direction != RIGHT)
					possibleDirs.push(LEFT);
				if (level.collidableTileLayers[0].getTile(tileX + 1, tileY) == 0 && wurst.direction != LEFT)
					possibleDirs.push(RIGHT);

				if (possibleDirs.length == 1)
				{
					wurst.direction = possibleDirs[0];
				}
			}
		});

		FlxG.overlap(wurstGroup, actors, onWurstHitsActor);
		FlxG.overlap(wurstGroup, exits, onWurstHitsExit);
		FlxG.overlap(wurstGroup, spawners, onWurstHitsSpawner);
		FlxG.overlap(wurstGroup, onWurstHitsWurst, pixelPerfectProcess);
	}

	function checkWin():Void
	{
		if (Reg.winCount <= 0)
		{
			FlxG.switchState(new PlayState());
		}
	}

	function clickActorCheck():Void
	{
		if (FlxG.mouse.justPressed)
		{
			actors.forEach((actor) ->
			{
				var mousePos = FlxG.mouse.getWorldPosition(mapCam);
				var mousePosGridX = Std.int(mousePos.x / level.tileWidth);
				var mousePosGridY = Std.int(mousePos.y / level.tileHeight);

				var actorGridX = Std.int(actor.x / level.tileWidth);
				var actorGridY = Std.int(actor.y / level.tileHeight);

				if (actor.type != AUTO && mousePosGridX == actorGridX && mousePosGridY == actorGridY)
				{
					if (selectedActor != null)
					{
						selectedActor.isSelected = false;
					}
					selectedActor = actor;
					selectedActor.isSelected = true;
				}
			});
		}
	}

	function mouseCheck():Void
	{
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
				if (_left.triggered && selectedActor.canChangeToDirection(LEFT))
				{
					selectedActor.setDirection(LEFT);
					selectedActor.isSelected = false;
				}
				else if (_right.triggered && selectedActor.canChangeToDirection(RIGHT))
				{
					selectedActor.setDirection(RIGHT);
					selectedActor.isSelected = false;
				}
				else if (_up.triggered && selectedActor.canChangeToDirection(UP))
				{
					selectedActor.setDirection(UP);
					selectedActor.isSelected = false;
				}
				else if (_down.triggered && selectedActor.canChangeToDirection(DOWN))
				{
					selectedActor.setDirection(DOWN);
					selectedActor.isSelected = false;
				}
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			openSubState(new EscapeHUD());
		}

		// ***DEBUG ****
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.sound.music.stop();
			FlxG.switchState(new PlayState());
		}
	}

	function onWurstHitsActor(wurst:Wurst, actor:FlowActor):Void
	{
		if (wurst.direction != actor.direction)
		{
			wurst.setNextDirection(actor.x, actor.y, actor.direction);
		}

		if (actor.type == AUTO && actor.type == SEMI)
		{
			actor.setNextDirection(wurst.direction);
		}
	}

	function onWurstHitsWurst(wurst1:Wurst, wurst2:Wurst):Void
	{
		wurst1.isImmovable = true;
		wurst2.kill();
	}

	function onWurstHitsExit(wurst:Wurst, actor:FlxSprite):Void
	{
		wurst.kill();

		Reg.winCount--;
		_hud.updateHUD();
	}

	function onWurstHitsSpawner(wurst:Wurst, spawner:WurstSpawner):Void
	{
		wurst.kill();
		// FlxG.switchState(new PlayState());
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

	function strToDirection(str:String):Direction
	{
		var ret:Direction = NONE;
		switch (str.toLowerCase())
		{
			case "up":
				ret = UP;
			case "down":
				ret = DOWN;
			case "left":
				ret = LEFT;
			case "right":
				ret = RIGHT;
		}
		return ret;
	}
}
