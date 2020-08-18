module Types exposing (Flags, Model, Message(..))

{-| These are the types and values used at the top-level of the Elm program -}

import Snackbar.Types
import Watchlist.Types

type alias Flags = ()

type alias Model =
  (Snackbar.Types.Model, Watchlist.Types.Model)

type Message
  = SnackbarMessage Snackbar.Types.Message
  | WatchlistMessage Watchlist.Types.Message
