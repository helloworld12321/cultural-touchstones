module Utils.MoreAttributes exposing (ariaLabel, role, tabIndex)

{-| This file contains functions for making HTML attributes.

It functions as an expansion on the Html.Attributes module.
-}

import Html
import Html.Attributes as Attributes

ariaLabel : String -> Html.Attribute message
ariaLabel value =
  Attributes.attribute "aria-label" value

role : String -> Html.Attribute message
role value =
  Attributes.attribute "role" value

tabIndex : String -> Html.Attribute message
tabIndex value =
  Attributes.attribute "tabindex" value
