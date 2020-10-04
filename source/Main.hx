package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 240, PlayState, 1, 60, 60, true, true));
	}

	function requestFullScreen():Void
	{
		untyped js.Syntax.code("if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen(); else if (document.documentElement.mozRequestFullScreen) document.documentElement.mozRequestFullScreen(); else if (document.documentElement.webkitRequestFullscreen) document.documentElement.webkitRequestFullscreen(); else if (document.documentElement.msRequestFullscreen) document.documentElement.msRequestFullscreen();");
	}

	function cancelFullScreen():Void
	{
		untyped js.Syntax.code("if (document.exitFullscreen) document.exitFullscreen(); else if (document.mozCancelFullScreen) document.mozCancelFullScreen(); else if (document.webkitExitFullscreen) document.webkitExitFullscreen(); else if (document.msExitFullscreen) document.msExitFullscreen();");
	}
}
