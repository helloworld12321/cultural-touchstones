module Main exposing (main)

{-| This is the entry-point of the Cultural Touchstones website. -}

import Browser
import Html

main : Program Flags Model Msg
main =
  Browser.sandbox
    { init = ()
    , update = \() () -> ()
    , view = \() -> Html.text "Hello, World!"
    }

type alias Flags = ()

type alias Model = ()

type alias Msg = ()
