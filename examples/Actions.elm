module Actions exposing (..)

import Animation
import Scroll exposing (Move)

type Action
    = Header Move
    | Shrink
    | Grow
    | Animate Animation.Msg 

type alias Model =
    { style : Animation.State
    , defaultStyle : Animation.State
    , lastHeight : Float
    , info :
      { previousValue : Float
      , currentValue : Float
      , delta : Float
      , direction : String
      }
    }
