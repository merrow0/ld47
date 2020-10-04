package;

import flixel.group.FlxGroup;
import flixel.text.FlxText;

class HUD extends FlxGroup
{
	public var zoomLevel:FlxText;

	public function new()
	{
		super();

		zoomLevel = new FlxText(20, 20, 0, "Scheissbollen: ", 14);
		add(zoomLevel);
	}
}
