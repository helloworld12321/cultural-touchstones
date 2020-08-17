module Types exposing (Flags, Model, Msg)

{-| These are the types and values used at the top-level of the Elm program -}

import Watchlist.Types

type alias Flags = ()

type alias Model = Watchlist.Types.Model

type alias Msg = Watchlist.Types.Msg
