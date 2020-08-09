module View exposing (view)

{-| This file generates HTML for the top-level of the Elm program. -}

import Html

import Types

view : Types.Model -> Html.Html Types.Msg
view =
  \() ->
    Html.text "Hello, World!"
