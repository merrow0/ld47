package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class EscapeHUD extends FlxSubState
{
	var _screen:FlxSprite;
	var _background:FlxSprite;
	var _canClose:Bool;

	public function new(titleText:String, canClose:Bool)
	{
		super();

		_canClose = canClose;
		var title:FlxText = new FlxText(0, 0, 0, titleText, 23);
		title.screenCenter(FlxAxes.X);
		title.y = 40;
		title.scrollFactor.set();
		title.setBorderStyle(OUTLINE, FlxColor.BROWN, 5);
		title.alpha = 0;
		FlxTween.tween(title, {alpha: 1}, 1);
		add(title);

		add(new FlxButton(FlxG.camera.width / 2 - 45, FlxG.camera.height / 2 - 15, "Restart", click_restart));
		add(new FlxButton(FlxG.camera.width / 2 - 45, FlxG.camera.height / 2 + 15, "Menu", click_quit));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE && _canClose)
		{
			close();
		}
	}

	function click_restart():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.2, false, restart);
	}

	function restart():Void
	{
		FlxG.sound.music.stop();
		FlxG.switchState(new PlayState());
	}

	function click_quit():Void
	{
		FlxG.camera.fade(FlxColor.TRANSPARENT, 0.2, false, actuallyQuit);
	}

	function actuallyQuit():Void
	{
		FlxG.switchState(new MenuState());
	}
}
