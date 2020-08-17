module View exposing (view)

{-| This file generates HTML for the top-level of the Elm program. -}

import Html

import Types
import Watchlist.View

view : Types.Model -> Html.Html Types.Msg
view model =
  Watchlist.View.view model
