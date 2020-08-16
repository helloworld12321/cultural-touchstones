module View exposing (view)

{-| This file generates HTML for the top-level of the Elm program. -}

import Html
import Html.Attributes as Attributes

import Types

view : Types.Model -> Html.Html Types.Msg
view model =
  case model of
    Types.Watchlist items ->
      let
        liOfItem item = Html.li [] [ Html.text item ]
      in
      Html.ul [] (items |> List.map liOfItem)
    Types.Loading ->
      Html.p [ Attributes.class "loading" ] [ Html.text "Loading…" ]
    Types.Error ->
      let
        errorMessage = "Something went wrong."
      in
      Html.p [ Attributes.class "error" ] [ Html.text errorMessage ]
