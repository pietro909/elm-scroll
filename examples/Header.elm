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

defaultStyles = Animation.style
  [ Animation.width (percent 100)
  , Animation.backgroundColor Color.lightRed
  ]

initialModel =
  { style = Animation.style [ Animation.height (px 90) ]
  , defaultStyle = defaultStyles
  , lastPostion = 90.0
  , info =
      { previousValue = 0.0
      , currentValue = 0.0
      , delta = 0.0 
      , direction = "" 
      }
  }

init =
  ( initialModel, Cmd.none )

setDirection : String -> Model -> Model
setDirection direction ({info} as model) = { model | info = { info | direction = direction } }

update action model =
    case action of
        Grow ->
            let
              style = 
                  Animation.queue
                      [ Animation.toWith
                          (Animation.easing 
                            { duration = 2*second
                            , ease = (\x -> x^2)
                            }
                          ) 
                          [ Animation.height (px 200) ]
                      ]
                  <|
                      Animation.style
                          [ Animation.height (px 90) ]
              midModel = setDirection "grow" model
              newModel = { midModel | style = style }
            in
              (newModel, Cmd.none)
        Shrink ->
            let
              style = 
                  Animation.queue
                      [ Animation.to
                          [ Animation.height (px 0) ]
                      ]
                  <|
                      Animation.style
                          [ Animation.height (px 90) ]
              midModel = setDirection "shrink" model
              newModel = { midModel | style = style }
            in
              (newModel, Cmd.none)
        Animate animMsg ->
          ({ model
              | style = Animation.update animMsg model.style
          }, Cmd.none)
        Header move ->
            let
              (previous, current) = Debug.log "move" move
              newModel = (
                let infoB = model.info 
                in { model | info = { infoB 
                  | previousValue = previous 
                  , currentValue = current 
                  , delta = previous - current
                  } })
            in
                Scroll.handle
                    [ update Grow
                      |> Scroll.onCrossDown 400
                    , update Shrink
                      |> Scroll.onCrossUp 400
                    ]
                    move newModel


view : Model -> Html a
view model =
    let
      info = model.info
      styles = Animation.render model.style ++ [ style [("position", "fixed")]] ++ (Animation.render defaultStyles)
    in
      div []
        [ div
          styles 
          [ h2 [] [ text ("direction: " ++ (toString info.direction)) ]
          , h3 [] [ text ("previousValue: " ++ (toString info.previousValue)) ]
          , h3 [] [ text ("currentValue: " ++ (toString info.currentValue)) ]
          ]
        , div [ style [("height", "10000px")] ] [] 
        ]

{-- SUBSCRIPTIONS
 -  need to collect all the inbound ports in one subscription flow
--}
subscriptions : Model -> Sub Action
subscriptions model =
    Sub.batch
        [ scroll Header
        , Animation.subscription Animate [ model.style ]
        ]
