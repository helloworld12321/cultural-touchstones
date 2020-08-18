module State exposing (init, update, subscriptions)

{-| This file provides functions that managae the state of the web app. -}

import Types
import Snackbar.State
import Watchlist.State

init : Types.Flags -> (Types.Model, Cmd Types.Message)
init () =
  let
    (snackbarModel, snackbarCmd) = Snackbar.State.init ()
    (watchlistModel, watchlistCmd) = Watchlist.State.init ()
  in
  ( (snackbarModel, watchlistModel)
  , Cmd.batch
    {- Use Cmd.map to mark messages according to the component they pertain to.
    -}
    [ Cmd.map Types.SnackbarMessage snackbarCmd
    , Cmd.map Types.WatchlistMessage watchlistCmd
    ]
  )

update : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
update message model =
  let
    (snackbarModel, watchlistModel) = model
  in
  {- Delegate messages according to the component they pertain to. -}
  case message of
    Types.SnackbarMessage m ->
      let
        (newSnackbarModel, cmd) =
          snackbarModel |> Snackbar.State.update m
      in
      ( (newSnackbarModel, watchlistModel)
      , Cmd.map Types.SnackbarMessage cmd
      )
    Types.WatchlistMessage m ->
      let
        (newWatchlistModel, cmd) =
          watchlistModel |> Watchlist.State.update m
      in
      ( (snackbarModel, newWatchlistModel)
      , Cmd.map Types.WatchlistMessage cmd
      )

subscriptions : Types.Model -> Sub Types.Message
subscriptions _ =
    Sub.none
