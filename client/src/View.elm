module View exposing (view)

{-| This file generates HTML for the top-level of the Elm program. -}

import Html

import Types
import Watchlist.View
import Snackbar.View

view : Types.Model -> Html.Html Types.Message
view model =
  let
    (snackbarModel, watchlistModel) = model
  in
  Html.div
    []
    {- We're using  Html.map to mark messages according to what component they
    pertain to.
    -}
    [ Watchlist.View.view watchlistModel |> Html.map Types.WatchlistMessage
    , Snackbar.View.view snackbarModel |> Html.map Types.SnackbarMessage
    ]
