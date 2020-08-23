module Utils exposing
  ( delay
  , flip
  , isLowSurrogate
  , isHighSurrogate
  , stringLengthUtf8
 )

{-| This file contains some helper functions. -}

import Process
import Task

import Hex

{-| Wait a variable amount of milliseconds and then send a message. -}
delay : Float -> message -> Cmd message
delay millis message =
  -- Adapted from https://stackoverflow.com/a/44354637
  Process.sleep millis
  |> Task.perform (\() -> message)

{-| Given a two-argument function, reverse the order of its arguments. -}
flip : (a -> b -> c) -> b -> a -> c
flip function a b =
  function b a

{-| Given an ordered pair, each of whose elements has the same type, apply a
given function to each element.
-}
mapOrderedPair : (a -> b) -> (a, a) -> (b, b)
mapOrderedPair function =
  Tuple.mapBoth function function


{-| Return the number of Unicode code points in a string, treating surrogate
pairs as a single character.

(String.length treats surrogate pairs as two characters.)
-}
stringLengthUtf8 : String -> Int
stringLengthUtf8 =
  let
    aux currentLength previousCharWasALowSurrogate string =
      case String.uncons string of
        Just (currentChar, tail) ->
          if previousCharWasALowSurrogate && isHighSurrogate currentChar then
            aux currentLength False tail
          else if isLowSurrogate currentChar then
            aux (currentLength + 1) True tail
          else
            aux (currentLength + 1) False tail
        Nothing ->
          currentLength
  in
  aux 0 False

{-| Return whether a character point falls in the low surrogate range.

(In UTF-16, a "low surrogate" encodes the first half of a
non-Basic-Multilingual-Plane character.)
-}
isLowSurrogate : Char -> Bool
isLowSurrogate char =
  let
    codePoint = Char.toCode char
    maybeRange =
      ("d800", "dbff")
        |> mapOrderedPair Hex.fromString
        |> \(maybeA, maybeB) -> Result.map2 Tuple.pair maybeA maybeB
  in
  maybeRange
    -- in practice, maybeRange will always be Ok, not Err. (But we've got to
    -- make the compiler happy ¯\_(ツ)_/¯)
    |> Result.map (\(firstLowSurrogate, lastLowSurrogate) ->
      firstLowSurrogate <= codePoint && codePoint <= lastLowSurrogate
    )
    |> Result.withDefault False

{-| Return whether a character falls in the high surrogate range.

(In UTF-16, a "high surrogate" encodes the second half of a
non-Basic-Multilingual-Plane character.)
-}
isHighSurrogate : Char -> Bool
isHighSurrogate char =
  let
    codePoint = Char.toCode char
    maybeRange =
      ("dc00", "dfff")
        |> mapOrderedPair Hex.fromString
        |> \(maybeA, maybeB) -> Result.map2 Tuple.pair maybeA maybeB
  in
  maybeRange
    |> Result.map (\(firstHighSurrogate, lastHighSurrogate) ->
      firstHighSurrogate <= codePoint && codePoint <= lastHighSurrogate
    )
    |> Result.withDefault False
