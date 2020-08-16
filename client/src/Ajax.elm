module Ajax exposing (getWatchlist)

{-| This file contains values for working making requests to the server. -}

import Http
import Json.Decode as Decode

import Types

{-| This decoder parses the response from the GET /api/watchlist endpoint. -}
watchlistDecoder : Decode.Decoder (List String)
watchlistDecoder =
  Decode.list Decode.string

{-| This command requests the watchlist from the server. -}
getWatchlist : Cmd Types.Msg
getWatchlist =
  Http.get
    { url = "/api/watchlist"
    , expect =
        Http.expectJson Types.GetWatchlistCompleted watchlistDecoder
    }
