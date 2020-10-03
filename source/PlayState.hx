package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;

class PlayState extends FlxState
{
	public var level:TiledLevel;
	public var wurstGroup:FlxTypedGroup<Wurst>;
	public var spawners:FlxTypedGroup<WurstSpawner>;
	public var exit:FlxSprite;

	override public function create()
	{
		super.create();

		spawners = new FlxTypedGroup<WurstSpawner>();
		wurstGroup = new FlxTypedGroup<Wurst>();

		level = new TiledLevel(AssetPaths.test_level__tmx, this);

		add(spawners);
		add(level.backgroundLayer);
		add(level.wallLayer);
		add(wurstGroup);
		add(level.foregroundLayer);
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

	public function handleFlowActor(x:Int, y:Int, type:String):Void {}

	function collisionCheck():Void
	{
		FlxG.collide(level.wallLayer, wurstGroup, onWurstCollidesWithWall);
	}

	function onWurstCollidesWithWall(wall:FlxGroup, wurst:Wurst)
	{
		if (wurst.alive)
		{
			wurst.velocity.set(0, 0);
			wurst.velocity.x = 15;
		}
	}
}
