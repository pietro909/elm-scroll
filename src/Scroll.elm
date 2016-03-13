module Scroll
    ( move, y
    , Direction(Up, Down), direction
    , Event(Update,Trigger)
    , eventsBuilder, Move
    , crossing, up, down, over
    )
    where
{-| This Library is to aid in managing scroll events

# Signals
@docs move, y 

# Types
@docs Event, Direction, Move

# Building event groups
@docs eventsBuilder

# Helpers
@docs direction, crossing, up, down, over
-}

import Native.Scroll
import Signal
import List exposing (foldl)
import Basics exposing (snd, identity)
import Effects exposing (Effects, batch)

{-| Contains the previous and current scroll positions. -}
move : Signal Move
move =
    Native.Scroll.move

{-| The current y scroll position. -}
y : Signal Float
y =
    Signal.map snd move

{-| -}
type Direction
    = Up
    | Down

{-| -}
type Event m a
    = Update (m -> m)
    | Trigger (Effects a)

{-| -}
type alias Move =
    (Float, Float)

{-| -}
direction : Move -> Direction
direction (from, to) =
    if from < to then
        Down
    else
        Up



{-| -}
eventsBuilder : List (Move -> Maybe (Event m a)) -> Move -> (m -> m, Effects a)
eventsBuilder list move =
    let
        events =
            List.filterMap (\a -> a move) list
        
        updates =
            List.filterMap
                updateFilter
                events

        modelUpdate =
            foldl
                (<<)
                identity
                updates

        fx =
            List.filterMap
                triggerFilter
                events
    in
        (modelUpdate, Effects.batch fx)


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

{-|  -}
crossing : Float -> Move -> Maybe Direction
crossing line (from, to) =
    let
        ratio =
            (line - from) / (to - from)

        crossed =
            0 <= ratio && ratio <= 1
    in
        if crossed then
            Just (direction (from, to))
        else
            Nothing

{-| -}
up : Float -> Event m a -> Move -> Maybe (Event m a)
up line event move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just Up ->
                Just event
            _ ->
                Nothing

{-| -}
down : Float -> Event m a -> Move -> Maybe (Event m a)
down line event move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just Down ->
                Just event
            _ ->
                Nothing


{-| -}
over : Float -> Event m a -> Move -> Maybe (Event m a)
over line event move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just x ->
                Just event
            _ ->
                Nothing   