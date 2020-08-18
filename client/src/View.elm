module View exposing (view)

{-| This file generates HTML for the top-level of the Elm program. -}

import Html
import Maybe

import Snackbar.View
import Types
import Watchlist.View

view : Types.Model -> Html.Html Types.Message
view model =
  let
    (snackbarModel, watchlistModel) = model
    maybeSnackbarView = Snackbar.View.view snackbarModel
    watchlistView = Watchlist.View.view watchlistModel
  in
  Html.div
    []
    (maybeSnackbarView
      |> Maybe.map (\snackbarView -> [ watchlistView, snackbarView ])
      |> Maybe.withDefault [ watchlistView ]
    )

