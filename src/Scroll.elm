module Scroll
    ( scroll
    , Direction(Up, Down), (=>)
    , Event(Update,Trigger)
    , triggerEvents, ScrollEvent, Transition, Boundary
    )
    where

import Native.Scroll
import Effects exposing (Effects, batch)


scroll : Signal Transition
scroll =
    scroll


type Direction
    = Up
    | Down


type alias Boundary =
    Float


type Event m a
    = Update (m -> m)
    | Trigger (Effects a)


type alias ScrollEvent m a =
    (Boundary, Direction, Event m a)


type alias Transition =
    (Float, Float)


(=>) : Transition -> Direction
(=>) (from, to) =
    if from < to then
        Down
    else
        Up


cross : Boundary -> Transition -> Maybe Direction
cross line (from, to) =
    let
        ratio =
            (line - from) / (to - from)

        crossed =
            0 <= ratio && ratio <= 1
    in
        if crossed then
            Just (from => to)
        else
            Nothing


triggerEvents : m -> List (ScrollEvent m a) -> Transition -> (m, Effects a)
triggerEvents model list transition =
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


triggerEventFilter : Transition -> ScrollEvent m a -> Maybe (Event m a)
triggerEventFilter (from, to) (line, direction, event) =
    let
        crossed =
            cross line from to
    in
        if crossed && dir == direction then
            Just event
        else
            Nothing


triggerEffectFilter : Event m a -> Maybe (Effects a)
triggerEffectFilter event =
    case event of
        Trigger effect ->
            Just effect
        _ ->
            Nothing


triggerUpdateFilter : Event m a -> Maybe (m -> m)
triggerUpdateFilter event =
    case event of
        Update update ->
            Just update
        _ ->
            Nothing