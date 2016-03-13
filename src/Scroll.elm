module Scroll
    ( scrollY
    , Direction(Up, Down), (=>)
    , Event(Update,Trigger)
    , eventsTrigger, Transition, Boundary
    )
    where

import Native.Scroll
import Signal
import Basics exposing (snd)
import Effects exposing (Effects, batch)


transition : Signal Transition
transition =
    Native.Scroll.transition


y : Signal Float
y =
    Signal.map snd transition


type Direction
    = Up
    | Down


type alias Boundary =
    Float


type Event m a
    = Update (m -> m)
    | Trigger (Effects a)


type alias Transition =
    (Float, Float)


(=>) : Transition -> Direction
(=>) (from, to) =
    if from < to then
        Down
    else
        Up


crossing : Boundary -> Transition -> Maybe Direction
crossing boundary (from, to) =
    let
        ratio =
            (boundary - from) / (to - from)

        crossed =
            0 <= ratio && ratio <= 1
    in
        if crossed then
            Just (from => to)
        else
            Nothing


eventsTrigger : List (Transition -> Maybe (Event m a)) -> Transition -> (m -> m, Effects a)
eventsTrigger list transition =
    let
        filter =
            scrollEventFilter transition

        events =
            List.filterMap filter list
        
        updates =
            List.filterMap
                triggerUpdateFilter
                events

        newModel =
            foldl
                (\update m -> update m)
                model
                updates

        fx =
            List.filterMap
                triggerEffectFilter
                events
    in
        (newModel, Effects.batch fx)


triggerFilter : Event m a -> Maybe (Effects a)
triggerFilter event =
    case event of
        Trigger effect ->
            Just effect
        _ ->
            Nothing


updateFilter : Event m a -> Maybe (m -> m)
updateFilter event =
    case event of
        Update update ->
            Just update
        _ ->
            Nothing