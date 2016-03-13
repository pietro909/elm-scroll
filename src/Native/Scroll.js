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

	var node = localRuntime.isFullscreen()
		? window
		: localRuntime.node;

	var getY = function() {
		return node.pageYoffset || node.scrollY || 0;
	};

	var y = getY();
	var transition = NS.input('Scroll.transition', Utils.Tuple2(y, y));


	localRuntime.addListener([transition.id], node, 'onscroll', function onscroll() {
		var y = getY();
		var oldY = transition.value._1;
		localRuntime.notify(transition.id, Utils.Tuple2(oldY, y));
	});

	return localRuntime.Native.Scroll.values = {
		transition: transition
	};
};
