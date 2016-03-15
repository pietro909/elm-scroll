Elm.Native.Scroll = {};
Elm.Native.Scroll.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Scroll = localRuntime.Native.Scroll || {};
	if (localRuntime.Native.Scroll.values)
	{
		return localRuntime.Native.Scroll.values;
	}

	var NS = Elm.Native.Signal.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);

	var node = localRuntime.node;

	var y = node.pageYoffset || node.scrollTop;
	var move = NS.input('Scroll.move', Utils.Tuple2(y, y));

	if (localRuntime.isFullscreen()) {
		window.onscroll = function() {
			var y = window.pageYoffset || document.body.scrollTop;
			var oldY = move.value._1;
			localRuntime.notify(move.id, Utils.Tuple2(oldY, y));
		};
	} else {
		localRuntime.addListener([move.id], node, 'onscroll', function onscroll() {
			var y = node.pageYoffset || node.scrollTop;
			var oldY = move.value._1;
			localRuntime.notify(move.id, Utils.Tuple2(oldY, y));	
		});
	}

	return localRuntime.Native.Scroll.values = {
		move: move
	};
};
