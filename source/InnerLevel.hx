
package ;

class InnerLevel extends Level {
	public var x : Float = 0;
	public var y : Float = 0;
	public var parentLevel : Level = null;

	var mId : String = null;

	public function new(parent : Level, backgroundFilename : String) : Void {
		super(null);

		parentLevel = parent;

		if(backgroundFilename != null) {
			prepareBackground(backgroundFilename);

			mLevelJson = {
				width: Math.ceil(mBackground.width), 
				height: Math.ceil(mBackground.height), 
				background: backgroundFilename,
				x: this.x,
				y: this.y
			};
		}

		mId = parent.getId() + "/" + parent.getInnerLevels().length;
	}

	override public function getId() : String {
		return mId;
	}

	override public function applyChanges() : Void {
		super.applyChanges();
		mLevelJson.x = this.x; 
		mLevelJson.y = this.y;
		mLevelJson.gates = []; // we don't want to double-save gates
	}

	public function setPosition(x : Float, y : Float) : Void {
		for(p in mPlatformSprites) {
			var xoffset : Float = p.x - this.x;
			var yoffset : Float = p.y - this.y;
			p.move(x + xoffset, y + yoffset);
		}

		for(c in mNutCoins) {
			var xoffset : Float = c.x - this.x;
			var yoffset : Float = c.y - this.y;
			c.move(x + xoffset, y + yoffset);
		}

		this.x = x;
		this.y = y;

		mBackground.x = x;
		mBackground.y = y;
	}

	override public function constructLevel(jsonobj : Dynamic) : Void {
		super.constructLevel(jsonobj);
		setPosition(mLevelJson.x, mLevelJson.y);
	}

	override public function addCrossLevelGate(gate : CrossLevelGate) : Void {
		if(gate.isRelevantTo(this) && gate.isRelevantTo(parentLevel)) {
			mCrossLevelGates.add(gate);
		} else {
			trace("innerLevel: did not add gate b/c it is irrelevant.");
		}
	}

	override public function resolveLevelId(id : String) : Level {
		var result : Level = super.resolveLevelId(id);
		if(result != null) 
			return result;
		else if(result == null && parentLevel.getId() == id) 
			return parentLevel;
		return null;
	}

	override public function setVisible(visible : Bool) : Void {
		for(idx in 0...this.mGraphics.members.length) {
			this.mGraphics.members[idx].visible = visible;
		}
	}
}