module Watchlist.Types exposing
  ( Model(..)
  , Watchlist
  , ValidationProblem(..)
  , getErrorText
  , maxWatchlistItemLength
  , putErrorText
  , validateNewItem
  )

{-| These are the types and values used by the watchlist. -}

import Utils exposing (stringLengthUtf8)

type Model
  -- This is the state when we have a watchlist. `list` is  `newItemText` is
  = Present
    -- The current items in the watchlist.
    { list : Watchlist
    -- The current contents of the text input where you can add new watchlist
    -- items.
    , newItemText : String
    -- Whether newItemText passes the validator.
    , newItemState : Result ValidationProblem ()
    }
  -- This is the state When we don't have a watchlist, but we're waiting for
  -- one.
  | Loading
  -- This is the state when we tried to get a watchlist, but it didn't work.
  | Error

{-| These are the complaints the validator could have with the contents of the
new item input.
-}
type ValidationProblem
  -- The validator doesn't like the text. (The string parameter is a
  -- human-readable error message for display to the user.)
  = Invalid String
  -- The text field is empty. (This case is handled specially.)
  | Empty

{-| The list of movies you want to watch. Position 0 is at the top of the list.
-}
type alias Watchlist = List String

{-| This text should be displayed when getting the watchlist failed. -}
getErrorText : String
getErrorText = "Error: Couldn't get your watchlist from the server"

{-| This text should be displayed when putting the watchlist failed. -}
putErrorText : String
putErrorText = "Error: Couldn't write your watchlist to the server"

{-| Make sure that the contents of the new item text box are okay to send to
the server.
-}
validateNewItem : String -> Result ValidationProblem ()
validateNewItem newItemText =
  if String.isEmpty newItemText then
    Err Empty
  else if stringLengthUtf8 newItemText > maxWatchlistItemLength then
    let
      reason =
        "Movie names be at most "
          ++ String.fromInt maxWatchlistItemLength
          ++ " characters long."
    in
    Err <| Invalid reason
  else
    Ok ()

{-| This is the maximum allowed length of a watchlist item, in UTF-8 code
points.
-}
maxWatchlistItemLength : Int
maxWatchlistItemLength = 300
