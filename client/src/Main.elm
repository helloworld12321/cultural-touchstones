module Main exposing (main)

{-| This is the entry-point of the Cultural Touchstones website. -}

import Browser

import Types
import View

main : Program Types.Flags Types.Model Types.Msg
main =
  Browser.sandbox
    { init = ()
    , update = \() () -> ()
    , view = View.view
    }

