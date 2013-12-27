package ;

import editor.EditorState;
import flash.Lib;
import flixel.FlxGame;
	
class Merlot extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / stageWidth;// * 1.5;
		var ratioY:Float = stageHeight / stageHeight;// * 1.5;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), EditorState, ratio);
	}
}
