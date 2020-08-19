module Watchlist.Types exposing (Model(..), errorSnackbarText)

{-| These are the types and values used by the watchlist. -}

type Model
  -- This is the state when we have a watchlist. The list of strings represents
  -- the watchlist items.
  = List (List String)
  -- This is the state When we don't have a watchlist, but we're waiting for
  -- one.
  | Loading
  -- This is the state when we tried to get a watchlist, but it didn't work.
  | Error

{-| This text should be displayed in a snackbar when getting the watchlist
failed.
-}
errorSnackbarText : String
errorSnackbarText = "Error: Couldn't get your watchlist from the server"
