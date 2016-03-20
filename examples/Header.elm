import StartApp
import Scroll exposing (Move)
import Signal exposing (Address)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Animation as UI
import Html.Animation.Properties exposing (..)
import Task exposing (Task)
import Effects exposing (Never)
import Time exposing (second)

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


init = 
    ( Model 
    <| UI.init 
        [ Width 100 Percent
        , Height 90 Px
        , BackgroundColor 75 75 75 1
        ]
    , Effects.none
    )


update action model =
    case action of
        Animate action ->
            onModel model action
        Grow ->
            UI.animate
                |> UI.duration (2*second)
                |> UI.props
                    [ Height (UI.to 200) Px ]
                |> onModel model
        Shrink ->
            UI.animate
                |> UI.props
                    [ Height (UI.to 90) Px ]
                |> onModel model
        Header move ->
            Scroll.handle
                [ update Grow
                  |> Scroll.onCrossDown 400
                , update Shrink
                  |> Scroll.onCrossUp 400
                ]
                move model
    


onModel =
    UI.forwardTo
        Animate
        .style
        (\w style -> {w | style = style})


view : Address Action -> Model -> Html
view address model =
    div [] 
        [ div [ style <| ("position", "fixed") :: UI.render model.style ]
            []
        , div [ style [("height", "10000px")] ] [] ]


port scroll : Signal Move