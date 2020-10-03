package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
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
	MANUAL;
}

class PlayState extends FlxState
{
	public var level:TiledLevel;
	public var wurstGroup:FlxGroup;
	public var spawners:FlxTypedGroup<WurstSpawner>;
	public var actors:FlxTypedGroup<FlowActor>;
	public var exit:FlxSprite;

	var mapCam:FlxCamera;
	var grabbedPos:FlxPoint = new FlxPoint(-1, -1);
	var initialScroll:FlxPoint = new FlxPoint(0, 0);
	var selectedActor:FlowActor;

	override public function create()
	{
		super.create();

		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;

		// Mouse setup
		// var mouseSprite = new FlxSprite();
		// mouseSprite.makeGraphic(32, 32, FlxColor.TRANSPARENT);

		// // Load the sprite's graphic to the cursor
		// FlxG.mouse.load(mouseSprite.pixels);

		spawners = new FlxTypedGroup<WurstSpawner>();
		actors = new FlxTypedGroup<FlowActor>();
		wurstGroup = new FlxGroup();

		level = new TiledLevel(AssetPaths.level__tmx, this);

		add(spawners);
		add(level.backgroundLayer);
		add(level.wallLayer);
		add(wurstGroup);
		add(level.foregroundLayer);
		add(actors);

		mapCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		mapCam.scroll.set((FlxG.width * -0.5) + (level.tileWidth * level.tileWidth / 2), (FlxG.height * -0.5) + (level.tileHeight * level.tileHeight / 2));
		mapCam.setScrollBoundsRect(0, 0, level.fullWidth, level.fullHeight, true);
		FlxG.cameras.add(mapCam);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		collisionCheck();
		clickActorCheck();
		mouseCheck();
	}

	public function handleLoadSpawner(x:Float, y:Float):Void
	{
		var spawner = new WurstSpawner(x, y, this);
		spawners.add(spawner);
	}

	public function handleLoadExit(x:Int, y:Int):Void
	{
		exit = new FlxSprite(x, y);
		exit.loadGraphic(AssetPaths.exit__png, false, 16, 16);
		add(exit);
	}

	public function handleFlowActor(x:Int, y:Int, type:ActorType):Void
	{
		var actor = new FlowActor(x, y, type);
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

				if (possibleDirs.length > 0)
				{
					wurst.setDirection(possibleDirs[FlxG.random.int(0, possibleDirs.length - 1)]);
				}
			}
		});
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

				if (mousePosGridX == actorGridX && mousePosGridY == actorGridY)
				{
					actor.flipY = !actor.flipY;
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
	}
}
