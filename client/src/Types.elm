module Types exposing (Flags, Model(..), Msg(..))

{-| These are the types and values used at the top-level of the Elm program -}

import Http

type alias Flags = ()

type Model
  = Watchlist (List String)
  | Loading
  | Error

type Msg
  = GetWatchlistCompleted (Result Http.Error (List String))
