module Snackbar.View exposing (view)

{-| This file generates HTML for the snackbar. -}

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Maybe

import Snackbar.Types
import Types

view : Snackbar.Types.Model -> Maybe.Maybe (Html.Html Types.Message)
view model =
  model
    |> Maybe.map (\{ transitionState, text } ->
      let
        classes =
          if
            List.member
              transitionState
              [Snackbar.Types.Hidden, Snackbar.Types.Waning]
          then
            [ Attributes.class "snackbar", Attributes.class "hidden" ]
          else
            [ Attributes.class "snackbar" ]
        listeners =
          [ onTransitionEnd "transform" Types.SnackbarNextTransitionState ]
      in
      Html.div
        (List.concat [ classes, listeners ])
        [ Html.text text ]
    )

{-| An HTML attribute that listens for the end of a transition involving a
specific CSS property.
-}
onTransitionEnd : String -> msg -> Html.Attribute msg
onTransitionEnd expectedPropertyName message =
  {- Only listen for the "transform" property. (Usually, transitionend fires
  once per property involved in the transition. To debounce it, we fiter out) -}
  Events.on
    "transitionend"
    (Decode.field "propertyName" Decode.string
      |> Decode.andThen (\propertyName ->
        if propertyName == expectedPropertyName then
          Decode.succeed message
        else
          Decode.fail ""
      )
    )
