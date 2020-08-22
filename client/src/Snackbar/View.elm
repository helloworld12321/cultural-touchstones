module Snackbar.View exposing (view)

{-| This file generates HTML for the snackbar. -}

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Maybe

import Snackbar.Types
import Types
import Utils.MoreAttributes as MoreAttributes

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
          [ onTransitionEnd
              "transform"
              (Types.SnackbarNextTransitionState
                (Snackbar.Types.next transitionState)
              )
          ]
      in
      Html.div
        (List.concat [ classes, listeners ])
        [ Html.text text, dismissButton ]
    )

dismissButton : Html.Html Types.Message
dismissButton =
  let
    message = Types.SnackbarNextTransitionState (Just Snackbar.Types.Waning)
  in
  Html.a
  [ Attributes.class "dismiss"
  , Attributes.href "#"
  , MoreAttributes.role "button"
  , MoreAttributes.tabIndex "0"
  , MoreAttributes.ariaLabel "Dismiss"
  , Events.onClick message
  ]
  [ Html.text "×" ]

{-| An HTML attribute that listens for the end of a transition involving a
specific CSS property.

Note that we never listen for all transitionend events, because that would be
quite noisy--if a transition involves multiple properties, then every one of
those properties emits its own transitionend event.
-}
onTransitionEnd : String -> message -> Html.Attribute message
onTransitionEnd expectedPropertyName message =
  Events.on
    "transitionend"
    (Decode.field "propertyName" Decode.string
      |> Decode.andThen (\propertyName ->
        if propertyName == expectedPropertyName then
          Decode.succeed message
        else
          -- In an event handler like this, a decoder failure means "don't
          -- emit anything".
          Decode.fail ""
      )
    )
