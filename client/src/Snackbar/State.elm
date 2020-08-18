module Snackbar.State exposing (init, update)

{-| This file provides functions that manaage the state of the snackbar. -}

import Snackbar.Types as Types

{- TODO: Right now, the snackbar is always displayed. Instead, it should pop in
and out as necessary.
-}

init : Types.Flags -> (Types.Model, Cmd Types.Message)
init () =
  (Types.Displayed "Test", Cmd.none)

update : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
update () model =
  (model, Cmd.none)
