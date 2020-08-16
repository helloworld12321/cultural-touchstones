module View exposing (view)

{-| This file generates HTML for the top-level of the Elm program. -}

import Html
import Html.Attributes as Attributes

import Types

view : Types.Model -> Html.Html Types.Msg
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
viewOfWatchlist : List String -> Html.Html Types.Msg
viewOfWatchlist items =
  let
    liOfItem item = Html.li [] [ Html.text item ]
  in
  Html.ul [ Attributes.class "watchlist" ] (items |> List.map liOfItem)
