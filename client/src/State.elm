module State exposing (init, update, subscriptions)

{-| This file provides functions that manage the state of the web app. -}

import Maybe

import Snackbar.Types
import Types
import Utils
import Watchlist.Ajax
import Watchlist.Types

init : Types.Flags -> (Types.Model, Cmd Types.Message)
init () =
  ( { snackbarModel = Nothing, watchlistModel = Watchlist.Types.Loading }
  , Watchlist.Ajax.getWatchlist
  )

update : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
update message oldModel =
  case message of
    Types.GetWatchlistCompleted (Ok items) ->
      ( { oldModel
        | watchlistModel = Watchlist.Types.List items
        }
      , Cmd.none
      )
    Types.GetWatchlistCompleted (Err _) ->
      ( { oldModel
        | snackbarModel =
            Just
              { transitionState = Snackbar.Types.Hidden
              , text = Watchlist.Types.errorSnackbarText
              }
        , watchlistModel =
            Watchlist.Types.Error
        }
      , delaySnackbarState Snackbar.Types.Waxing
      )
    Types.SnackbarNextTransitionState nextState ->
      transitionTheSnackbar oldModel nextState

{-| Respond to a SnackbarNextTransitionState event. -}
transitionTheSnackbar
  : Types.Model
  -> Maybe Snackbar.Types.TransitionState
  -> (Types.Model, Cmd Types.Message)
transitionTheSnackbar oldModel nextTransitionState =
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
          {- We'll just wait for the HTML to emit a transitionend event. -}
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
          {- Wait for the user to click the dismiss button-}
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
          {- Again, we'll wait for a transitionend event before moving on. -}
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
      {- There should always be an existing snackbar when we receive this
      message, but if there isn't, we can just ignore the message, I guess.
      -}
      ( oldModel
      , Cmd.none
      )

{-| Emit a SnackbarNextTransitionState message in just a few milliseconds -}
delaySnackbarState
  : Snackbar.Types.TransitionState
  -> Cmd Types.Message
delaySnackbarState nextTransitionState =
  {- A short delay, like 50 milliseconds, makes sure that Elm renders the
  previous state before the next state of the transition starts See:
  https://stackoverflow.com/questions/24148403/trigger-css-transition-on-appended-element

  Also, the delay can't be too small, or else Elm may not have have finished
  rendering the previous state by the time the message is received. (The
  snackbar should be robust against that sort of sequence-breaking, but it
  would be *better* if it didn't skip steps.)
  -}
  Utils.delay
    50
    (Types.SnackbarNextTransitionState (Just nextTransitionState))



subscriptions : Types.Model -> Sub Types.Message
subscriptions _ =
    Sub.none
