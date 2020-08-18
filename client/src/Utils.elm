module Utils exposing (delay, flip)

{-| This file contains some helper functions. -}

import Process
import Task

{-| Wait a variable amount of milliseconds and then send a message. -}
delay : Float -> message -> Cmd message
delay millis message =
  {- Adapted from https://stackoverflow.com/a/44354637 -}
  Process.sleep millis
  |> Task.perform (\() -> message)

flip : (a -> b -> c) -> b -> a -> c
flip function a b =
  function b a
