module Types exposing
  ( Flags
  , Model
  , Message(..)
  , PseudoCmd(..)
  , pseudoCmdToRealCmd
  )

{-| These are the types and values used at the top-level of the Elm program -}

import Http
import Json.Encode as Encode

import Snackbar.Types
import Utils exposing (wait)
import Utils.MoreHttp as MoreHttp
import Watchlist.Types

type alias Flags = ()

type alias Model =
  { snackbarModel: Snackbar.Types.Model
  , watchlistModel: Watchlist.Types.Model
  }

type Message
  -- We receive this message when our request to the server to get the
  -- watchlist completed (either successfully or unsuccessfully).
  = GetWatchlistCompleted (Result Http.Error Watchlist.Types.Watchlist)

  -- We receive this message when our request to the server to change the
  -- watchlist completed (either successfully or unsuccessfully).
  | PutWatchlistCompleted (Result Http.Error ())

  -- We receive this message when the edits the "add watchlist item" text
  -- field. The string parameter is the current contents of that field.
  | EditAddWatchlistItemInput String

  -- We receive this message when the user clicks the "add watchlist item"
  -- button.
  | ClickAddWatchlistItem

  -- We receive this message when the user clicks the "delete" button on a
  -- watchlist item. Here, the the int is the position of the watchlist item
  -- to be deleted, where position 0 is the first element in the list.
  | ClickDeleteWatchlistItem Int

  -- We receive this message when a snackbar finishes one state of its
  -- animation, and is ready to transition into the next state.
  -- The TransitionState parameter indicates what the next transition state
  -- should be, or Nothing, if the snackbar should be removed from the DOM.
  -- This allows the transition animation to skip backwards or forwards as
  -- necessary.
  | SnackbarNextTransitionState (Maybe Snackbar.Types.TransitionState)

{-| Each PseudoCmd msg unambiguously represents a `Cmd msg`, except that we
can manipulate a PseudoCmd and do pattern-matching on it. We use this type
internally, but before we send the value to the Elm runtime, we turn it into a
real `Cmd Message`.

This type exists to provide a less-opaque, easier-to-test version of Cmd;
see https://github.com/elm-community/elm-test/issues/220.
-}
type PseudoCmd msg
  -- The representation of `Cmd.none`.
  = NoCmd

  -- Try to make a GET request.
  | GetCmd { url : String, expect : Http.Expect msg }

  -- Try to send a PUT request with a JSON body.
  | PutCmd { url : String, body : Encode.Value, expect : Http.Expect msg }

  -- Wait a certain amount of milliseconds (the Float parameter), and then send
  -- back a Message to Elm (the Message parameter).
  | WaitCmd Float msg

pseudoCmdToRealCmd : PseudoCmd msg -> Cmd msg
pseudoCmdToRealCmd pseudoCmd =
  case pseudoCmd of
    NoCmd ->
      Cmd.none
    GetCmd params ->
      Http.get params
    PutCmd params ->
      MoreHttp.put
        { url = params.url
        , body = Http.jsonBody params.body
        , expect = params.expect
        }
    WaitCmd millis message ->
      wait millis message

