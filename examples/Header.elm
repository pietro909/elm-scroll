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
  , now = 0.0
  }

init =
  ( initialModel, Cmd.none )
  
 
update action model =
    case action of
        -- Grow ->
        --     -- Animation.animate
        --     --     |> Animation.duration (2*second)
        --     --     |> UI.props
        --     --         [ Height (UI.to 200) px ]
        --     --     |> onModel model

        --     (model, Cmd.none)
        -- Shrink ->
        --   -- helper functions are no longer required
        --   (model, Animation.animate
        --     -- styles are specified slightly differently.
        --     |> Animation.to
        --         [ Animation.height (px 90)
        --         ]
        --     |> Animation.on model.style)
        Animate animMsg ->
          ({ model
              | style = Animation.update animMsg model.style
          }, Cmd.none)
        Header move ->
            let
                nums = Debug.log "move" move
            in
                ( { model | now = snd(nums) }, Cmd.none)

            -- Scroll.handle
            --     [ update Grow
            --       |> Scroll.onCrossDown 400
            --     , update Shrink
            --       |> Scroll.onCrossUp 400
            --     ]
            --     move model


view : Model -> Html a
view model =
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
