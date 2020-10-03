package;

import PlayState.Direction;
import flixel.FlxSprite;

class Wurst extends FlxSprite
{
	public static inline var WURST_SPEED:Int = 15;

	public var direction:Direction;
	public var possibleDirections:Array<Direction>;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(AssetPaths.wurst__png, false, 16, 16);
		possibleDirections = new Array<Direction>();
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

	public function setDirection(newDir:Direction)
	{
		direction = newDir;
	}
}
