module Watchlist.Ajax exposing (getWatchlist, putWatchlist)

{-| This file is in charge of watchlist-related requests to the server. -}

import Http
import Json.Decode as Decode
import Json.Encode as Encode

import Types
import Utils.MoreHttp as MoreHttp
import Watchlist.Types

{-| This decoder parses the response from the GET /api/watchlist endpoint. -}
watchlistDecoder : Decode.Decoder (Watchlist.Types.Watchlist)
watchlistDecoder =
  Decode.list Decode.string

{-| This encoder encodes the watchlist for the PUT /api/watchlist endpoint. -}
encodeWatchlist : Watchlist.Types.Watchlist -> Encode.Value
encodeWatchlist =
  Encode.list Encode.string


{-| This command requests the watchlist from the server. -}
getWatchlist : Cmd Types.Message
getWatchlist =
  Http.get
    { url = "/api/watchlist"
    , expect =
        Http.expectJson Types.GetWatchlistCompleted watchlistDecoder
    }

{-| This command sends the watchlist to the server (replacing the existing
watchlist).
-}
putWatchlist : Watchlist.Types.Watchlist -> Cmd Types.Message
putWatchlist watchlist =
  MoreHttp.put
    { url = "/api/watchlist"
    , body = Http.jsonBody (encodeWatchlist watchlist)
    , expect = Http.expectWhatever Types.PutWatchlistCompleted
    }
