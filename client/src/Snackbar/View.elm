module Snackbar.View exposing (view)

{-| This file generates HTML for the snackbar. -}

import Html
import Html.Attributes as Attributes

import Snackbar.Types as Types

{- TODO: Right now, the snackbar is always displayed. Instead, it should pop in
and out as necessary.
-}

view : Types.Model -> Html.Html Types.Message
view (Types.Displayed snackbarContents) =
  Html.div [ Attributes.class "snackbar" ] [ Html.text snackbarContents ]

