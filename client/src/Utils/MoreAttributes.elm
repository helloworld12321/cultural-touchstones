module Utils.MoreAttributes exposing (ariaLabel)

{-| This file contains functions for making HTML attributes.

It functions as an expansion on the Html.Attributes module.
-}

import Html
import Html.Attributes as Attributes

ariaLabel : String -> Html.Attribute message
ariaLabel value =
  Attributes.attribute "aria-label" value
