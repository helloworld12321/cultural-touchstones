module Watchlist.State exposing (init, update)

{-| This file provides functions that managae the state of the watchlist. -}

import Watchlist.Ajax as Ajax
import Watchlist.Types as Types

init : Types.Flags -> (Types.Model, Cmd Types.Msg)
init () =
  (Types.Loading, Ajax.getWatchlist)

update : Types.Msg -> Types.Model -> (Types.Model, Cmd Types.Msg)
update msg _ =
  case msg of
    Types.GetWatchlistCompleted (Ok items) ->
      (Types.Watchlist items, Cmd.none)
    Types.GetWatchlistCompleted (Err _) ->
      (Types.Error, Cmd.none)
