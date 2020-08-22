module Snackbar.View exposing (view)

{-| This file generates HTML for the snackbar. -}

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Maybe

import Snackbar.Types
import Types
import Utils.MoreAttributes as MoreAttributes
import Utils.MoreEvents as MoreEvents

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
          [ MoreEvents.onTransitionEnd
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
