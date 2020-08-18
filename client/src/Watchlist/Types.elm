module Watchlist.Types exposing (Flags, Model(..), Message(..))

{-| These are the types and values used by the watchlist. -}

import Http

type alias Flags = ()

type Model
  {- This is the state when we have a watchlist. The list of strings represents
  the watchlist items.
  -}
  = Watchlist (List String)
  {- This is the state When we don't have a watchlist, but we're waiting for
  one.
  -}
  | Loading
  {- This is the state when we tried to get a watchlist, but it didn't work. -}
  | Error

type Message
  {- We receive this message hen our request to the server to get the watchlist
  completed (either successfully or unsuccessfully).
  -}
  = GetWatchlistCompleted (Result Http.Error (List String))
