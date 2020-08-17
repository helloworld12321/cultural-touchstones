module Watchlist.Types exposing (Flags, Model(..), Msg(..))

{-| These are the types and values used by the watchlist. -}

import Http

type alias Flags = ()

type Model
  = Watchlist (List String)
  | Loading
  | Error

type Msg
  = GetWatchlistCompleted (Result Http.Error (List String))
