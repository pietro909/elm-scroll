module Scroll
    ( move, y
    , Direction(Up, Down), direction
    , Event, trigger, update
    , events, Move
    , crossing, up, down, over
    )
    where
{-| This Library is to aid in managing scroll events

# Signals
@docs move, y 

# Types
@docs Event, Move, Direction

# Events
@docs update, trigger

# Building groups of events
@docs events

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

{-| Helps building your own triggers if direction is important.

    upAfterDown : Direction -> Event m a ->  Maybe (Event m a)
    upAfterDown lastDirection event =
        if lastDirection == Scroll.Down then
            Just event
        else
            Nothing

    scrollEvents : Model -> Move -> (m -> m, Effects a)
    scrollEvents model =
        Scroll.events
            [ upAfterDown model.lastDirection <| Effects.tick TopBarDrop ] 
-}
type Direction
    = Up
    | Down

{-| An event can either update a model or trigger an effect -}
type Event m a
    = Update (m -> m)
    | Trigger (Effects a)

{-| Alias of (Float, Float) meant as (from, to) -}
type alias Move =
    (Float, Float)

{-| Returns the directions of a Move-}
direction : Move -> Direction
direction (from, to) =
    if from < to then
        Down
    else
        Up



{-| -}
events : List (Move -> Maybe (Event m a)) -> Move -> (m -> m, Effects a)
events list move =
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

{-| -}
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

{-| -}
trigger : Effects a -> Event m a
trigger effects =
    Trigger effects

{-| -}
update : (m -> m) -> Event m a
update u =
    Update u