var Meditr = {};
Meditr.WEB_PATH = "http://0.0.0.0:8000/";
Meditr.APP_PATH = "http://0.0.0.0:8000/editor";
Meditr.ASSETS_LVLS = Meditr.WEB_PATH + "assets/lvls/";
Meditr.ASSETS_BGS = Meditr.WEB_PATH + "assets/bgs/";

Meditr._pjs = null;
Meditr._lvl = null;
Meditr._imgs = {};

Meditr.init = function(canvas_id) {
	var pjs = new Processing(document.getElementById(canvas_id));

	var drawSprite = function(s) {
		pjs.image(Meditr._imgs[s.f], s.p[0], s.p[1]);
	};

	var drawBoundary = function(b) {
		pjs.stroke(0);
		pjs.line(b.s[0],b.s[1],b.s[2],b.s[3]); /* surface */
		pjs.stroke(255,0,0);
		pjs.line(b.n[0],b.n[1],b.n[2],b.n[3]); /* normal */
	};

	var drawPlatform = function(p) {
		drawSprite(p);
		Mutil.each(p.b, drawBoundary);
	}

	pjs.draw = function() {
		var lvl = Meditr._lvl;
		if(lvl) {
			pjs.image(Meditr._imgs[lvl.background], 0, 0);

			Mutil.each(lvl.nutcoins, drawSprite);
			Mutil.each(lvl.platforms, drawPlatform);

			pjs.noStroke();
			pjs.fill(0,255,0);
			pjs.rect(lvl.startpt[0], lvl.startpt[1], Mutil.PLAYER_WIDTH, Mutil.PLAYER_HEIGHT);
		} else {
			pjs.background(255, 255, 255, 0);
		}
	};

	pjs.loadImageExt = function(path) {
		var parts = Mutil.splitext(path);
		return pjs.loadImage(Meditr.WEB_PATH + parts[0], parts[1]);
	};

	this._pjs = pjs;

	// pjs setup
	/*pjs.noSmooth(); html5 canvas does not support aliasing!!*/
};

Meditr.loadSprites = function(sprites) {
	var s = null; var i = 0;
	for(i = 0; i < sprites.length; i++) {
		s = sprites[i];
		if(!this._imgs[s.f]) {
			this._imgs[s.f] = this._pjs.loadImageExt(s.f);
		}
	}
};

Meditr.play = function(pause) {
	if(pause === true) {
		this._pjs.noloop();
	} else {
		this._pjs.loop();
	}
}

Meditr.load = function(json) {
	var p = this._pjs;

	/* Set canvas size */
	p.size(json.width, json.height);

	/* Load images/sprites */
	this._imgs[json.background] = p.loadImageExt(json.background);

	this.loadSprites(json.nutcoins);
	this.loadSprites(json.platforms);

	/* set level */
	this._lvl = json;
};