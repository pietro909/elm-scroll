import Html
import Html.App as App
import Scroll exposing (Move)
import Html exposing (..)
import Html.Attributes exposing (..)
import Animation exposing (px, percent, color)
import Color exposing (Color)

import Task exposing (Task)
import Time exposing (second)

import Ports exposing (..)
import Actions exposing (..)

main =
    app.html


app =
    App.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

initialModel =
  { style =
    Animation.style
      [ Animation.width (percent 100)
      , Animation.height (px 90)
      , Animation.backgroundColor Color.lightRed
      ]
  }
-- port tasks : Signal (Task Never ())
-- port tasks = app.tasks
init =
  ( initialModel, Cmd.none )
  
 
update action model =
    case action of
        -- Grow ->
        --     UI.animate
        --         |> UI.duration (2*second)
        --         |> UI.props
        --             [ Height (UI.to 200) px ]
        --         |> onModel model
        -- Shrink ->
        --   -- helper functions are no longer required
        --   Animation.Style.animate
        --     -- styles are specified slightly differently.
        --     |> Style.to
        --         [ Height 90 px
        --         ]
        --     |> Style.on model.style
        Animate animMsg ->
          { model
              | style = Animation.update animMsg model.style
          }
        Header move ->
            Scroll.handle
                [ update Grow
                  |> Scroll.onCrossDown 400
                , update Shrink
                  |> Scroll.onCrossUp 400
                ]
                move model
    

view : Model -> Html a
view address model =
    div [] 
        [ div 
            (Animation.render model.style ++ [ style [("position", "fixed")]])
            []
        , div [ style [("height", "10000px")] ] [] ]

{-- SUBSCRIPTIONS
 -  need to collect all the inbound ports in one subscription flow
--}
subscriptions : Model -> Sub Action
subscriptions model =
    Sub.batch
        [ scroll Header
        , Animation.subscription Animate [ model.style ]
        ]