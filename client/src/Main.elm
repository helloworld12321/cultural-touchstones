module Main exposing (main)

{-| This is the entry-point of the Cultural Touchstones website. -}

import Browser

import State
import Types
import View

main : Program Types.Flags Types.Model Types.Msg
main =
  Browser.element
    { init = State.init
    , update = State.update
    , subscriptions = State.subscriptions
    , view = View.view
    }

