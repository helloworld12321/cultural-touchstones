module Main exposing (main)

{-| This is the entry-point of the Cultural Touchstones website. -}

import Browser

import State
import Types
import View

realInit : () -> (Types.Model, Cmd Types.Message)
realInit () =
  State.init () |> Tuple.mapSecond Types.pseudoCmdToRealCmd

realUpdate : Types.Message -> Types.Model -> (Types.Model, Cmd Types.Message)
realUpdate message model =
  State.update message model |> Tuple.mapSecond Types.pseudoCmdToRealCmd

main : Program Types.Flags Types.Model Types.Message
main =
  Browser.element
    { init = realInit
    , update = realUpdate
    , subscriptions = State.subscriptions
    , view = View.view
    }

