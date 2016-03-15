import StartApp
import Scroll exposing (events)
import Signal
import Html exposing (..)
import Html.Attributes exposing (..)
import Task exposing (Task)
import Effects exposing (Never)

main =
    app.html


app =
    StartApp.start
        { init = init
        , view = view
        , update = update
        , inputs = [ Signal.map Header Scroll.move ]
        }


port tasks : Signal (Task Never ())
port tasks = app.tasks

type Action
    = Header Scroll.Move


type alias Model =
    { isSmall : Bool }


init = (Model False, Effects.none)


update action model =
    case action of
        Header transition ->
            let
                (updateModel, fx) =
                    events
                        [ Scroll.down 400 <| Scroll.update <| (\m -> { m | isSmall = True })
                        , Scroll.up 400 <| Scroll.update <| (\m -> { m | isSmall = False })
                        ]
                        transition
            in
                (updateModel model, fx)


view address model =
    div [] []