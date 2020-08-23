module Utils.MoreEvents exposing (onKeyUp, onTransitionEnd)

{-| This file contains functions for handling HTML events.

It functions as an expansion on the Html.Events module.
-}

import Html
import Html.Events as Events
import Json.Decode as Decode

{-| An HTML attribute that listens for keyup events with a specific key. -}
onKeyUp : String -> message -> Html.Attribute message
onKeyUp expectedKey message =
  Events.on
    "keyup"
    (Decode.field "key" Decode.string
      |> Decode.andThen (\key ->
        if key == expectedKey then
          Decode.succeed message
        else
          -- In an event handler like this, a decoder failure means "don't
          -- emit anything".
          Decode.fail ""
      )
    )

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
          Decode.fail ""
      )
    )
