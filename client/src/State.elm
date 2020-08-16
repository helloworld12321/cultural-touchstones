module State exposing (init, update, subscriptions)

{-| This file provides functions that managae the state of the web app. -}

import Ajax
import Types

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

subscriptions : Types.Model -> Sub Types.Msg
subscriptions _ =
    Sub.none
