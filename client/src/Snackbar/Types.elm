module Snackbar.Types exposing (Flags, Model(..), Message)

{-| These are the types and values used by the snackbar.

A snackbar, also called a toast, is little temporary UI element that pops up
from the bottom of the screen to display a notification or message.
-}

{- TODO: Right now, the snackbar is always displayed. Instead, it should pop in
and out as necessary.
-}

type alias Flags = ()

type Model
  {- This is the state when the snackbar is displayed. The string represents
  the snackbar's text.
  -}
  = Displayed (String)

type alias Message = ()
