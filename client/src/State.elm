module State exposing (init, update, subscriptions)

{-| This file provides functions that managae the state of the web app. -}

import Types
import Watchlist.State
import Watchlist.Types

init : Types.Flags -> (Types.Model, Cmd Types.Msg)
init () =
  Watchlist.State.init ()

update : Types.Msg -> Types.Model -> (Types.Model, Cmd Types.Msg)
update message model =
  case message of
    Watchlist.Types.GetWatchlistCompleted _ ->
      Watchlist.State.update message model

subscriptions : Types.Model -> Sub Types.Msg
subscriptions _ =
    Sub.none
