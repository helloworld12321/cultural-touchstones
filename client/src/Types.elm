module Types exposing
  ( Flags
  , GetWatchlistResponder
  , Message(..)
  , Model
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
  -- We receive this message when our request to the server to load the
  -- watchlist for the first time completes (either successfully or
  -- unsuccessfully).
  = LoadWatchlistCompleted (Result Http.Error Watchlist.Types.Watchlist)

  -- We receive this message if we try to get the watchlist from the server
  -- again to see if anything has changed, and that request completed (either
  -- successfully or unsuccessfully).
  | ReloadWatchlistCompleted (Result Http.Error Watchlist.Types.Watchlist)

  -- We receive this message when our request to the server to change the
  -- watchlist completes (either successfully or unsuccessfully).
  --
  -- Sometimes, after we've changed the watchlist, we should clear the
  -- watchlist <input> tag at the top of the page. (If we just added a movie
  -- name, for example, we should reset the <input>.)
  -- But sometimes, we're changing the watchlist for unrelated reasons, like
  -- deleting a movie. In those cases, there's no need to clear the <input>
  -- tag.
  --
  -- We represent this in the message by the `shouldClearWatchlistInput` field.
  -- If this field is True AND the watchlist was updated successfully, then
  -- we'll clear the watchlist <input>.
  -- But, if the `shouldClearWatchlistInput` is False, or if the request
  -- failed, then we won't touch the <input>.
  | PutWatchlistCompleted
      { shouldClearWatchlistInput: Bool }
      (Result Http.Error ())

  -- We receive this message when the user edits the "add watchlist item" text
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


{-| A message constructor that can be used to respond to a "GET watchlist"
request. (Usually, either LoadWatchlistCompleted and ReloadWatchlistCompleted.)
-}
type alias GetWatchlistResponder =
  Result Http.Error Watchlist.Types.Watchlist -> Message


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

