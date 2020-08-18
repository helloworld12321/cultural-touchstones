module Watchlist.State exposing (init, update)

{-| This file provides functions that manaage the state of the watchlist. -}

import Watchlist.Ajax as Ajax
import Watchlist.Types as Types

init : Types.Flags -> (Types.Model, Cmd Types.Message)
init () =
  (Types.Loading, Ajax.getWatchlist)

update : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
update message _ =
  case message of
    Types.GetWatchlistCompleted (Ok items) ->
      (Types.Watchlist items, Cmd.none)
    Types.GetWatchlistCompleted (Err _) ->
      (Types.Error, Cmd.none)
