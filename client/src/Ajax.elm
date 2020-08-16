module Ajax exposing (watchlistDecoder)

{-| This file contains values for working making requests to the server. -}

import Json.Decode as Decode

{-| This decoder parses the response from the GET /api/watchlist endpoint. -}
watchlistDecoder : Decode.Decoder (List String)
watchlistDecoder =
  Decode.list Decode.string
