module Snackbar.Types exposing (Model, TransitionState(..), snackbarDuration)

{-| These are the types and values used by the snackbar.

A snackbar, also called a toast, is little temporary UI element that pops up
from the bottom of the screen to display a notification or message.
-}

{-| The number of milliseconds for which the snackbar is displayed.

The transitions onto and off of the page aren't included in this duration.
-}
snackbarDuration : Float
snackbarDuration = 4000

{-| This is the state of the snackbar.

Either there's no snackbar (Nothing) or there is a snackbar (Just {...}) in
which case we also have some information about it.
-}
type alias Model = Maybe Snackbar

type alias Snackbar =
  { transitionState : TransitionState
  , text : String
  }


{-| These are the different stages of the snackbar's animation. -}
type TransitionState
  {- This is the state when the snackbar hasn't started popping up yet. -}
  = Hidden
  {- This is the state when the snackbar is in the process of popping up. -}
  | Waxing
  {- This is the state when the snackbar has finished transitioning onto the
  page.
  -}
  | Displayed
  {- This is the state when the snackbar is transitioning down off of the page.
  -}
  | Waning
