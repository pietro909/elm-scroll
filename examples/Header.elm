import StartApp
import Scroll exposing (events, Move)
import Signal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Animation as UI
import Task exposing (Task)
import Effects exposing (Never)

main =
    app.html


app =
    StartApp.start
        { init = init
        , view = view
        , update = update
        , inputs = [ Signal.map Header scroll ]
        }


port tasks : Signal (Task Never ())
port tasks = app.tasks

type Action
    = Header Move
    | Shrink
    | Grow
    | Animate UI.Action


type alias Model =
    { style : UI.Animation }


init = (Model False, Effects.none)


update action model =
    case action of
        Header move ->
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


port scroll : Signal Move