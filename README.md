# Elm Scroll

An Elm Library for scrolling through a page and handling events. 
 Meant to be used alongside StartApp.

## Example

```elm
import StartApp
import Scroll exposing (eventsBuilder)
import Signal

type Action
	= Header Scroll.Move

app =
	{ init = init
	, view = view
	, update = update
	, inputs = [ Signal.map Header Scroll.move ]
	}

update action model =
	case action of
		Header transition ->
			let
				(updateModel, fx) =
					eventsBuilder
						[ Scroll.down 400 (\m -> { m | isFixed = True })
						, Scroll.up 400 (\m -> { m | isFixed = False })
						]
						transition
			in
				(updateModel model, fx)

```