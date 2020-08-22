module Watchlist.Types exposing
  ( Model(..)
  , Watchlist
  , getErrorText
  , putErrorText
  )

{-| These are the types and values used by the watchlist. -}

type Model
  -- This is the state when we have a watchlist. `list` is the current items
  -- in the watchlist. `newItemText` is the current contents of the text input
  -- where you can add new watchlist items.
  = Ok
    { list : Watchlist
    , newItemText : String
    }
  -- This is the state When we don't have a watchlist, but we're waiting for
  -- one.
  | Loading
  -- This is the state when we tried to get a watchlist, but it didn't work.
  | Error

type alias Watchlist = List String

{-| This text should be displayed when getting the watchlist failed. -}
getErrorText : String
getErrorText = "Error: Couldn't get your watchlist from the server"

{-| This text should be displayed when putting the watchlist failed. -}
putErrorText : String
putErrorText = "Error: Couldn't write your watchlist to the server"
