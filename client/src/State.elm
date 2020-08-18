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
  let
    snackbarModel = Nothing
    watchlistModel = Watchlist.Types.Loading
  in
  ( (snackbarModel, watchlistModel)
  , Watchlist.Ajax.getWatchlist
  )

update : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
update message oldModel =
  let
    (oldSnackbarModel, oldWatchlistModel) = oldModel
  in
  case message of
    Types.GetWatchlistCompleted (Ok items) ->
      ( ( oldSnackbarModel
        , Watchlist.Types.List items
        )
      , Cmd.none
      )
    Types.GetWatchlistCompleted (Err _) ->
      ( ( Just
            { transitionState = Snackbar.Types.Hidden
            , text = Watchlist.Types.errorSnackbarText
            }
        , Watchlist.Types.Error)
      {- delay 50 makes sure that the snackbar is added to the view before
      the transition starts. See:
      https://stackoverflow.com/questions/24148403/trigger-css-transition-on-appended-element

      Also, the delay can't be too small, or else Elm may not have have
      rendered the snackbar by the time the message is received.
      -}
      , Utils.delay 50 Types.SnackbarNextTransitionState
      )
    Types.SnackbarNextTransitionState ->
      transitionTheSnackbarToItsNextState oldSnackbarModel oldWatchlistModel

{-| Respond to a SnackbarNextTransitionState event. -}
transitionTheSnackbarToItsNextState
  : Snackbar.Types.Model
  -> Watchlist.Types.Model
  -> (Types.Model, Cmd Types.Message)
transitionTheSnackbarToItsNextState oldSnackbarModel oldWatchlistModel =
  oldSnackbarModel
    |> Maybe.map (\{ transitionState, text } ->
      case transitionState of
        Snackbar.Types.Hidden ->
          ( ( Just
                { transitionState = Snackbar.Types.Waxing
                , text = text
                }
            , oldWatchlistModel)
          {- We'll just wait for the HTML to emit a transitionend event. -}
          , Cmd.none
          )
        Snackbar.Types.Waxing ->
          ( ( Just
                { transitionState = Snackbar.Types.Displayed
                , text = text
                }
            , oldWatchlistModel)
          , Utils.delay
              Snackbar.Types.snackbarDuration
              Types.SnackbarNextTransitionState
          )
        Snackbar.Types.Displayed ->
          ( ( Just
                { transitionState = Snackbar.Types.Waning
                , text = text
                }
            , oldWatchlistModel)
          {- Again, we'll wait for a transitionend event before moving on. -}
          , Cmd.none
          )
        Snackbar.Types.Waning ->
          ( ( Nothing
            , oldWatchlistModel)
          , Cmd.none
          )
    )
    |> Maybe.withDefault
      {- There should always be an existing snackbar when we receive this
      message, but if there isn't, we can just ignore the message, I guess.
      -}
      ( (oldSnackbarModel, oldWatchlistModel)
      , Cmd.none
      )



subscriptions : Types.Model -> Sub Types.Message
subscriptions _ =
    Sub.none
