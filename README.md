# Elm Scroll

An Elm Library for scrolling through a page and handling events. 
 Meant to be used alongside StartApp.

## Usage

### index.html

```html
<!DOCTYPE html>
<html>
<head>
	<title>Adam Brykajlo</title>
	<link rel="stylesheet" type="text/css" href="css/main.css">
	<script type="text/javascript" src="js/main.js"></script>
</head>
<body>
<div id="main"></div>
<script>
	var scroll = window.pageYOffset || document.body.scrollTop;
	var myApp = Elm.fullscreen(Elm.Main, {scroll: [scroll,scroll]});

	window.onscroll = function() {
		var newScroll = window.pageYOffset || document.body.scrollTop;
		myApp.ports.scroll.send([scroll, newScroll]);
		scroll = newScroll;
	};
</script>
</body>
</html>

```

### Inside Elm file

```elm
port scroll : Signal Scroll.Move

-- app definition
app =
	{ init = init 
	, view = view
	, update = update
	, inputs = [ Signal.map ScrollAction scroll ]
	}

-- inside update
ScrollAction move ->
	let
		(updateModel, fx) =
			Scroll.handle
				[ Scroll.update
					(\m -> { m | isFixed = True })
					|> Scroll.crossDown 400
				, Scroll.update
					(\m -> { m | isFixed = False })
					|> Scroll.crossUp 400
				]
				move
	in
		(updateModel model, fx)
```

## TODO

+ 