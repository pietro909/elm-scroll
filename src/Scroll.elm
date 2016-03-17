module Scroll
    ( Direction(Up, Down), direction
    , Event, trigger, update
    , handle, Move
    , crossing, crossUp, crossDown, crossOver
    )
    where


{-| This Library is to aid in managing scroll events

# Types
@docs Event, Move, Direction

# Events
@docs update, trigger

# Building groups of events
@docs handle

# Helpers
@docs direction, crossing, crossUp, crossDown, crossOver
-}


import Signal
import List exposing (foldl)
import Basics exposing (snd, identity)
import Effects exposing (Effects, batch)


{-| Helps building your own triggers if direction is important.

    upAfterDown : Direction -> Event m a -> Move ->  Maybe (Event m a)
    upAfterDown lastDirection event move =
        if direction move != Up then
            Nothing 
        else if lastDirection == Scroll.Down  then
            Just event
        else
            Nothing 
-}


type Direction
    = Up
    | Down


{-| An event can either update a model or trigger an effect -}
type Event m a
    = Update (m -> m)
    | Trigger (Effects a)


{-| Creates an Event _ a-}
trigger : Effects a -> Event m a
trigger effects =
    Trigger effects


{-| Creates an Event m _-}
update : (m -> m) -> Event m a
update u =
    Update u


{-| Alias of (Float, Float) represents a move from a scroll position
to another scroll position -}
type alias Move =
    (Float, Float)


{-| Returns the direction of a Move-}
direction : Move -> Direction
direction (from, to) =
    if from < to then
        Down
    else
        Up


{-| Used in generating a function to trigger all possible events for a single
move. It returns a tuple containing a Model -> Model function that is a chain of
all the possible updates and a batch of all trigger effects.

    scrollEvents : Model -> Move -> (m -> m, Effects a)
    scrollEvents model =
        Scroll.events
            [ upAfterDown model.lastDirection <| trigger <| Effects.tick TopBarDrop
            , over 400.0 <| update <| toggleProperty
            ]

    update action model =
        case action of
            Transition move ->
                let
                    (updateModel, fx) =
                        scrollEvents model move
                in
                    (updateModel model, fx)
            TopBarDrop clockTime ->
-}


handle : List (Move -> Maybe (Event m a)) -> Move -> (m -> m, Effects a)
handle list move =
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


{-| Returns Nothing if the Move does not cross the line-}
crossing : Float -> Move -> Maybe Direction
crossing line (from, to) =
    let
        ratio =
            (line - from) / (to - from)

        crossed =
            0 <= ratio && ratio < 1
    in
        if crossed then
            Just (direction (from, to))
        else
            Nothing


{-| Returns event if move crosses the line down-}
crossUp : Float -> Event m a -> Move -> Maybe (Event m a)
crossUp line event move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just Up ->
                Just event

            _ ->
                Nothing


{-| Returns event if move crosses the line down -}
crossDown : Float -> Event m a -> Move -> Maybe (Event m a)
crossDown line event move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just Down ->
                Just event

            _ ->
                Nothing


{-| Returns event if move crosses the line in either direction-}
crossOver : Float -> Event m a -> Move -> Maybe (Event m a)
crossOver line event move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just x ->
                Just event
            _ ->
                Nothing
