port module Ports exposing (..)

-- import AnimationFrame
import Scroll exposing (Move)
import Actions exposing (..)

port scroll : (Move -> msg) -> Sub msg

