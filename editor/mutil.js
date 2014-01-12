var Mutil = {};
Mutil.PLAYER_WIDTH = 40;
Mutil.PLAYER_HEIGHT = 75;

Mutil.splitext = function(path) {
	var idx = path.lastIndexOf(".");
	return [path.substring(0, idx), path.substring(idx+1)];
};

Mutil.each = function(list, func) {
	var i;
	for(i = 0; i < list.length; i ++) {
		func(list[i], i);
	}
};