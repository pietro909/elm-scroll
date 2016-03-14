import Scroll exposing (Move)
import Signal
import Html exposing (..)
import Html.Attributes exposing (..)
import Debug exposing (log)

main =
    Signal.map (view << log "move") Scroll.move

view : Move -> Html
view (from, to) =
    div [style [("height", "10000px")]] [
    div [style [("position","fixed")]] 
        [ p [] [ text <| "Last Y Scroll: " ++ toString from ]
        , p [] [ text <| "Current Y Scroll: " ++ toString to ]
        ]
        ]
