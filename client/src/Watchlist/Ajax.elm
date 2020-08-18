module Watchlist.Ajax exposing (getWatchlist)

{-| This file is in charge of watchlist-related requests to the server. -}

import Http
import Json.Decode as Decode

import Watchlist.Types as Types

{-| This decoder parses the response from the GET /api/watchlist endpoint. -}
watchlistDecoder : Decode.Decoder (List String)
watchlistDecoder =
  Decode.list Decode.string

{-| This command requests the watchlist from the server. -}
getWatchlist : Cmd Types.Message
getWatchlist =
  Http.get
    { url = "/api/watchlist"
    , expect =
        Http.expectJson Types.GetWatchlistCompleted watchlistDecoder
    }
