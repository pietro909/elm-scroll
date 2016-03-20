module Scroll
    ( Direction(Up, Down), direction
    , handle, Move
    , crossing, onCrossUp, onCrossDown, onCrossOver
    )
    where


{-| This Library is to aid in managing scroll events

# Types
@docs Update, Move, Direction

# Building groups of events
@docs handle

# Helpers
@docs direction, crossing, onCrossUp, onCrossDown, onCrossOver
-}


import Signal
import List exposing (foldl)
import Basics exposing (snd, identity)
import Effects exposing (Effects, batch)


type alias Update m a =
    m -> (m, Effects a)


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
handle : List (Move -> Maybe (Update m a)) -> Move -> m -> (m, Effects a)
handle events move model =
    let
        updates =
            List.filterMap (\event -> event move) events
        
        f update (model, fx) =
            let
                (newModel, effect) =
                    update model
            in
                (newModel, fx ++ [effect])

        (newModel, fx) =
            foldl f (model, []) updates
    in
        (newModel, Effects.batch fx)


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
onCrossUp : Float -> Update m a -> Move -> Maybe (Update m a)
onCrossUp line update move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just Up ->
                Just update

            _ ->
                Nothing


{-| Returns event if move crosses the line down -}
onCrossDown : Float -> Update m a -> Move -> Maybe (Update m a)
onCrossDown line update move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just Down ->
                Just update

            _ ->
                Nothing


{-| Returns event if move crosses the line in either direction-}
onCrossOver : Float -> Update m a -> Move -> Maybe (Update m a)
onCrossOver line update move =
    let
        direction =
            crossing line move
    in
        case direction of
            Just x ->
                Just update
            _ ->
                Nothing