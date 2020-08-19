module Types exposing (Flags, Model, Message(..))

{-| These are the types and values used at the top-level of the Elm program -}

import Http

import Snackbar.Types
import Watchlist.Types

type alias Flags = ()

type alias Model =
  { snackbarModel: Snackbar.Types.Model
  , watchlistModel: Watchlist.Types.Model
  }

type Message
  -- We receive this message when our request to the server to get the
  -- watchlist completed (either successfully or unsuccessfully).
  = GetWatchlistCompleted (Result Http.Error (List String))

  -- We receive this message when a snackbar finishes one state of its
  -- animation, and is ready to transition into the next state.
  -- The TransitionState parameter indicates what the next transition state
  -- should be, or Nothing, if the snackbar should be removed from the DOM.
  -- This allows the transition animation to skip backwards or forwards as
  -- necessary.
  | SnackbarNextTransitionState (Maybe Snackbar.Types.TransitionState)
