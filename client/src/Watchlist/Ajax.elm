module Watchlist.Ajax exposing (getWatchlist, putWatchlist)

{-| This file is in charge of watchlist-related requests to the server. -}

import Http
import Json.Decode as Decode
import Json.Encode as Encode

import Types
import Watchlist.Types

{-| This decoder parses the response from the GET /api/watchlist endpoint. -}
watchlistDecoder : Decode.Decoder (Watchlist.Types.Watchlist)
watchlistDecoder =
  Decode.list Decode.string

{-| This encoder encodes the watchlist for the PUT /api/watchlist endpoint. -}
encodeWatchlist : Watchlist.Types.Watchlist -> Encode.Value
encodeWatchlist =
  Encode.list Encode.string


{-| This command requests the watchlist from the server.

You can customize what message you want it to send when it completes. (You
probably either want it to send Types.LoadWatchlistCompleted or
Types.ReloadWatchlistCompleted.)
-}
getWatchlist : Types.GetWatchlistResponder -> Types.PseudoCmd Types.Message
getWatchlist responder =
  Types.GetCmd
    { url = "/api/watchlist"
    , expect =
        Http.expectJson responder watchlistDecoder
    }

{-| This command sends the watchlist to the server (replacing the existing
watchlist).
-}
putWatchlist
  : { shouldClearWatchlistInput: Bool }
  -> Watchlist.Types.Watchlist
  -> Types.PseudoCmd Types.Message
putWatchlist options watchlist =
  Types.PutCmd
    { url = "/api/watchlist"
    , body = encodeWatchlist watchlist
    , expect = Http.expectWhatever <| Types.PutWatchlistCompleted options
    }
