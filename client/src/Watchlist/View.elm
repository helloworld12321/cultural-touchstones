module Watchlist.View exposing (view)

{-| This file generates HTML for the watchlist. -}

import Html
import Html.Attributes as Attributes

import Watchlist.Types
import Types

view : Watchlist.Types.Model -> Html.Html Types.Message
view model =
  case model of
    Watchlist.Types.List items ->
      viewOfWatchlist items
    Watchlist.Types.Loading ->
      Html.p [ Attributes.class "loading" ] [ Html.text "Loading…" ]
    Watchlist.Types.Error ->
      let
        errorText = "Something went wrong."
      in
      Html.p [ Attributes.class "error" ] [ Html.text errorText ]

{-| If we have a watchlist to display, this function will turn it into HTML. -}
viewOfWatchlist : List String -> Html.Html Types.Message
viewOfWatchlist items =
  let
    liOfItem item = Html.li [] [ Html.text item ]
  in
  Html.ul [ Attributes.class "watchlist" ] (items |> List.map liOfItem)
