module Utils exposing (delay)

{-| This file contains some helper functions. -}

import Process
import Task

{-| Wait a variable amount of milliseconds and then send a message. -}
delay : Float -> message -> Cmd message
delay millis message =
  {- Adapted from https://stackoverflow.com/a/44354637 -}
  Process.sleep millis
  |> Task.perform (\() -> message)
