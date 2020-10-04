package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxPoint;

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
	MANUAL;
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
	var grabbedPos:FlxPoint = new FlxPoint(-1, -1);
	var initialScroll:FlxPoint = new FlxPoint(0, 0);
	var selectedActor:FlowActor;
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

		// Mouse setup
		// var mouseSprite = new FlxSprite();
		// mouseSprite.makeGraphic(32, 32, FlxColor.TRANSPARENT);

		// // Load the sprite's graphic to the cursor
		// FlxG.mouse.load(mouseSprite.pixels);

		spawners = new FlxTypedGroup<WurstSpawner>();
		actors = new FlxTypedGroup<FlowActor>();
		wurstGroup = new FlxGroup();
		exits = new FlxGroup();

		_hud = new HUD();

		_left = new FlxActionDigital();
		_right = new FlxActionDigital();
		_up = new FlxActionDigital();
		_down = new FlxActionDigital();

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([_left, _right, _up, _down]);

		_left.addKey(LEFT, JUST_PRESSED).addKey(A, JUST_PRESSED);
		_right.addKey(RIGHT, JUST_PRESSED).addKey(D, JUST_PRESSED);
		_up.addKey(UP, JUST_PRESSED).addKey(W, JUST_PRESSED);
		_down.addKey(DOWN, JUST_PRESSED).addKey(S, JUST_PRESSED);

		level = new TiledLevel(AssetPaths.level__tmx, this);

		add(level.backgroundLayer);
		add(spawners);
		add(level.wallLayer);
		add(wurstGroup);
		add(level.foregroundLayer);
		add(actors);
		add(exits);
		add(_hud);

		// var scanlines = new FlxSprite(0, 0);
		// scanlines.loadGraphic(AssetPaths.scanlines__png, false, FlxG.width, FlxG.height);
		// scanlines.scrollFactor.set(0, 0);
		// scanlines.alpha = 0.1;
		// add(scanlines);

		mapCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		mapCam.scroll.set((FlxG.width * -0.5) + (level.tileWidth * level.tileWidth / 2), (FlxG.height * -0.5) + (level.tileHeight * level.tileHeight / 2));
		mapCam.setScrollBoundsRect(0, 0, level.fullWidth, level.fullHeight, true);
		mapCam.antialiasing = true;
		FlxG.cameras.add(mapCam);

		// Init objects
		actors.forEach((actor) -> actor.init());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		collisionCheck();
		clickActorCheck();
		keyboardCheck();
		mouseCheck();
	}

	public function handleLoadSpawner(x:Float, y:Float):Void
	{
		var spawner = new WurstSpawner(x, y, this);
		spawners.add(spawner);
	}

	public function handleLoadExit(x:Int, y:Int):Void
	{
		var exit = new FlxSprite(x, y);
		exit.loadGraphic(AssetPaths.exit__png, false, 16, 16);
		exits.add(exit);
	}

	public function handleFlowActor(x:Int, y:Int, type:ActorType):Void
	{
		var actor = new FlowActor(x, y, type, this);
		actors.add(actor);
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

				if (actor.type == MANUAL && mousePosGridX == actorGridX && mousePosGridY == actorGridY)
				{
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
			grabbedPos = FlxG.mouse.getWorldPosition(mapCam);
			initialScroll = mapCam.scroll;
		}
		if (FlxG.mouse.pressedRight)
		{
			var mousePosChange:FlxPoint = FlxG.mouse.getWorldPosition(mapCam).subtractPoint(grabbedPos);
			mapCam.scroll.subtractPoint(mousePosChange);
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
					selectedActor.direction = LEFT;
					selectedActor.isSelected = false;
				}
				else if (_right.triggered)
				{
					selectedActor.direction = RIGHT;
					selectedActor.isSelected = false;
				}
				else if (_up.triggered)
				{
					selectedActor.direction = UP;
					selectedActor.isSelected = false;
				}
				else if (_down.triggered)
				{
					selectedActor.direction = DOWN;
					selectedActor.isSelected = false;
				}
			}
		}
	}

	function onWurstHitsActor(wurst:Wurst, actor:FlowActor):Void
	{
		if (wurst.direction != actor.direction)
		{
			wurst.setNextDirection(actor.x, actor.y, actor.direction);
		}

		if (actor.type == AUTO)
		{
			actor.setNextDirection(wurst.direction);
		}
	}

	function onWurstHitsExit(wurst:Wurst, actor:FlxSprite):Void
	{
		if (!wurst.active)
			return;

		wurst.kill();
	}

	function onWurstHitsSpawner(wurst:Wurst, spawner:WurstSpawner):Void
	{
		// FlxG.switchState(new PlayState());
	}
}
