package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class EscapeHUD extends FlxSubState
{
	var _screen:FlxSprite;
	var _background:FlxSprite;

	public function new()
	{
		super();

		persistentDraw = false;

		var title:FlxText = new FlxText(0, 0, 0, "PAUSED", 28);
		title.screenCenter(FlxAxes.X);
		title.y = 40;
		title.scrollFactor.set();
		title.setBorderStyle(OUTLINE, FlxColor.RED, 5);
		title.alpha = 0;
		FlxTween.tween(title, {alpha: 1}, 2);
		add(title);

		add(new FlxButton(FlxG.camera.width / 2 - 45, FlxG.camera.height / 2 - 15, "Restart", click_restart));

		add(new FlxButton(FlxG.camera.width / 2 - 45, FlxG.camera.height / 2 + 15, "Quit", click_quit));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
	}

	function click_restart():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, restart);
	}

	function restart():Void
	{
		FlxG.switchState(new PlayState());
	}

	function click_quit():Void
	{
		FlxG.camera.fade(FlxColor.TRANSPARENT, 0.5, false, actuallyQuit);
	}

	function actuallyQuit():Void
	{
		// FlxG.switchState(new MenuState());
	}
}
