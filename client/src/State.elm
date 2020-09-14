module State exposing (init, update, subscriptions)

{-| This file provides functions that manage the state of the web app. -}

import Maybe

import Snackbar.Types
import Types
import Utils exposing (delay, dropIndices)
import Watchlist.Ajax
import Watchlist.Types

init : Types.Flags -> (Types.Model, Cmd Types.Message)
init () =
  ( { snackbarModel = Nothing, watchlistModel = Watchlist.Types.Loading }
  , Watchlist.Ajax.getWatchlist
  )

update : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
update message =
  case message of
    Types.GetWatchlistCompleted (Ok items) ->
      setTheWatchlist items
    Types.GetWatchlistCompleted (Err _) ->
      respondToGetWatchlistError
    Types.PutWatchlistCompleted (Ok ()) ->
      respondToPutWatchlistSuccess
    Types.PutWatchlistCompleted (Err _) ->
      respondToPutWatchlistError
    Types.EditAddWatchlistItemInput newItemText ->
      updateNewItemInput newItemText
    Types.ClickAddWatchlistItem ->
      maybeAddWatchlistItem
    Types.ClickDeleteWatchlistItem position ->
      maybeDeleteWatchlistItem position
    Types.SnackbarNextTransitionState nextState ->
      transitionTheSnackbar nextState

{-| Respond to a successful GetWatchlistCompleted event. -}
setTheWatchlist
  : Watchlist.Types.Watchlist
  -> Types.Model
  -> (Types.Model, Cmd Types.Message)
setTheWatchlist items oldModel =
  let
    maybeOldWatchlist =
      case oldModel.watchlistModel of
        Watchlist.Types.Present oldWatchlist -> Just oldWatchlist
        _ -> Nothing
  in
  ( { oldModel
    | watchlistModel =
      Watchlist.Types.Present
        (maybeOldWatchlist
          |> Maybe.map (\oldWatchlist -> { oldWatchlist | list = items })
          |> Maybe.withDefault
            { list = items
            , newItemText = ""
            , newItemState = Err Watchlist.Types.Empty
            }
        )
    }
  , Cmd.none
  )

{-| Respond to an unsuccessful GetWatchlistCompleted event. -}
respondToGetWatchlistError : Types.Model -> (Types.Model, Cmd Types.Message)
respondToGetWatchlistError oldModel =
  ( { oldModel
    | snackbarModel =
        Just
          { transitionState = Snackbar.Types.Hidden
          , text = Watchlist.Types.getErrorText
          }
    , watchlistModel =
        Watchlist.Types.Error
    }
  , delaySnackbarState Snackbar.Types.Waxing
  )

{-| Respond to a successful PutWatchlistCompleted event. -}
respondToPutWatchlistSuccess : Types.Model -> (Types.Model, Cmd Types.Message)
respondToPutWatchlistSuccess oldModel =
  -- Now that we've written to the server successfully, we need to get the
  -- watchlist again to see the changes.
  -- (We could have just immediately updated the local model and saved
  -- ourselves an extra HTTP request, but that would have made recovering
  -- from an error harder.)
  (oldModel, Watchlist.Ajax.getWatchlist)

{-| Respond to an unsuccessful PutWatchlistCompleted event. -}
respondToPutWatchlistError : Types.Model -> (Types.Model, Cmd Types.Message)
respondToPutWatchlistError oldModel =
  ( { oldModel
    | snackbarModel =
        Just
          { transitionState = Snackbar.Types.Hidden
          , text = Watchlist.Types.putErrorText
          }
    }
  , delaySnackbarState Snackbar.Types.Waxing
  )

{-| Respond to an EditAddWatchlistItemInput event. -}
updateNewItemInput
  : String
  -> Types.Model
  -> (Types.Model, Cmd Types.Message)
updateNewItemInput newItemText oldModel =
  case oldModel.watchlistModel of
    Watchlist.Types.Present { list } ->
      ( { oldModel
        | watchlistModel =
            Watchlist.Types.Present
              { list = list
              , newItemText = newItemText
              , newItemState = Watchlist.Types.validateNewItem newItemText
              }
        }
      , Cmd.none
      )
    _ ->
      -- If there isn't currently a watchlist, just ignore this message.
      (oldModel, Cmd.none)

{-| Respond to a ClickAddWatchlistItem event.

This function checks if there's a new watchlist item ready, and if there is,
it asks the server to prepend that item to the watchlist.
-}
maybeAddWatchlistItem : Types.Model -> (Types.Model, Cmd Types.Message)
maybeAddWatchlistItem oldModel =
  case oldModel.watchlistModel of
    Watchlist.Types.Present { list, newItemText, newItemState } ->
      case newItemState of
        Ok () ->
          ( oldModel
          , Watchlist.Ajax.putWatchlist <| newItemText :: list
          )
        _ ->
          (oldModel, Cmd.none)
    _ ->
      -- If there isn't currently a watchlist, just ignore this message.
      (oldModel, Cmd.none)

{-| Respond to a ClickDeleteWatchlistItem event.

Here, `position` is the index of the item in the watchlist we want to delete,
where 0 is the item at the top of the watchlist. Provided the given position
is actually a valid index, we're going to ask the server to remove the item at
that position from the watchlist.
-}
maybeDeleteWatchlistItem
  : Int
  -> Types.Model
  -> (Types.Model, Cmd Types.Message)
maybeDeleteWatchlistItem position oldModel =
  case oldModel.watchlistModel of
    Watchlist.Types.Present { list } ->
      if 0 <= position && position < List.length list then
        ( oldModel
        , Watchlist.Ajax.putWatchlist <| dropIndices [ position ] list
        )
      else
        -- Don't bother with an AJAX call if it's not going to have any effect.
        (oldModel, Cmd.none)
    _ ->
      -- If there isn't currently a watchlist, just ignore this message.
      (oldModel, Cmd.none)


{-| Respond to a SnackbarNextTransitionState event. -}
transitionTheSnackbar
  : Maybe Snackbar.Types.TransitionState
  -> Types.Model
  -> (Types.Model, Cmd Types.Message)
transitionTheSnackbar nextTransitionState oldModel =
  oldModel.snackbarModel
    |> Maybe.map (\snackbar ->
      case nextTransitionState of
        Just Snackbar.Types.Hidden ->
          ( { oldModel
            | snackbarModel =
                Just
                  { snackbar
                  | transitionState = Snackbar.Types.Hidden
                  }
            }
          , delaySnackbarState Snackbar.Types.Waxing
          )
        Just Snackbar.Types.Waxing ->
          ( { oldModel
            | snackbarModel =
                Just
                  { snackbar
                  | transitionState = Snackbar.Types.Waxing
                  }
            }
          -- We'll just wait for the HTML to emit a transitionend event.
          , Cmd.none
          )
        Just Snackbar.Types.Displayed ->
          ( { oldModel
            | snackbarModel =
                Just
                  { snackbar
                  | transitionState = Snackbar.Types.Displayed
                  }
            }
          -- Wait for the user to click the dismiss button.
          , Cmd.none
          )
        Just Snackbar.Types.Waning ->
          ( { oldModel
            | snackbarModel =
                Just
                  { snackbar
                  | transitionState = Snackbar.Types.Waning
                  }
            }
          -- Again, we'll wait for a transitionend event before moving on.
          , Cmd.none
          )
        Nothing ->
          ( { oldModel
            | snackbarModel = Nothing
            }
          , Cmd.none
          )
    )
    |> Maybe.withDefault
      -- There should always be an existing snackbar when we receive this
      -- message, but if there isn't, we can just ignore the message, I guess.
      ( oldModel
      , Cmd.none
      )

{-| Emit a SnackbarNextTransitionState message in just a few milliseconds. -}
delaySnackbarState
  : Snackbar.Types.TransitionState
  -> Cmd Types.Message
delaySnackbarState nextTransitionState =
  -- A short delay, like 50 milliseconds, makes sure that Elm renders the
  -- previous state before the next state of the transition starts See:
  -- https://stackoverflow.com/questions/24148403/trigger-css-transition-on-appended-element
  -- Also, the delay can't be too small, or else Elm may not have have finished
  -- rendering the previous state by the time the message is received. (The
  -- snackbar should be robust against that sort of sequence-breaking, but it
  -- would be *better* if it didn't skip steps.
  let
    message = Types.SnackbarNextTransitionState <| Just nextTransitionState
  in
  delay 50 message

subscriptions : Types.Model -> Sub Types.Message
subscriptions _ =
    Sub.none
