module Watchlist.View exposing (view)

{-| This file generates HTML for the watchlist. -}

import Html
import Html.Attributes as Attributes

import Watchlist.Types as Types

view : Types.Model -> Html.Html Types.Message
view model =
  case model of
    Types.Watchlist items ->
      viewOfWatchlist items
    Types.Loading ->
      Html.p [ Attributes.class "loading" ] [ Html.text "Loading…" ]
    Types.Error ->
      let
        errorMessage = "Something went wrong."
      in
      Html.p [ Attributes.class "error" ] [ Html.text errorMessage ]

{-| If we have a watchlist to display, this function will turn it into HTML. -}
viewOfWatchlist : List String -> Html.Html Types.Message
viewOfWatchlist items =
  let
    liOfItem item = Html.li [] [ Html.text item ]
  in
  Html.ul [ Attributes.class "watchlist" ] (items |> List.map liOfItem)
