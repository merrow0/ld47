package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;

enum WurstDirection
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

	override public function create()
	{
		super.create();

		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;

		spawners = new FlxTypedGroup<WurstSpawner>();
		actors = new FlxTypedGroup<FlowActor>();
		wurstGroup = new FlxGroup();

		level = new TiledLevel(AssetPaths.test_level__tmx, this);

		add(spawners);
		add(level.backgroundLayer);
		add(level.wallLayer);
		add(wurstGroup);
		add(level.foregroundLayer);
		add(actors);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		collisionCheck();
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
		// exit.exists = false;
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
				var possibleDirs:Array<WurstDirection> = new Array<WurstDirection>();
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
}
