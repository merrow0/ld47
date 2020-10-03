package;

import PlayState.WurstDirection;
import flixel.FlxSprite;

class Wurst extends FlxSprite
{
	public static inline var WURST_SPEED:Int = 15;

	public var direction:WurstDirection;
	public var possibleDirections:Array<WurstDirection>;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(AssetPaths.wurst__png, false, 16, 16);
		possibleDirections = new Array<WurstDirection>();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		switch (direction)
		{
			case UP:
				velocity.set(0, -WURST_SPEED);
			case DOWN:
				velocity.set(0, WURST_SPEED);
			case LEFT:
				velocity.set(-WURST_SPEED, 0);
			case RIGHT:
				velocity.set(WURST_SPEED, 0);
			default:
				velocity.set(0, 0);
		}
	}

	public function setDirection(newDir:WurstDirection)
	{
		direction = newDir;
	}
}
