module SnackbarSpec exposing (suite)

{-| This module tests the Snackbar-related functionality. -}

import Html

import Expect
import Fuzz
import Test
import Test.Html.Query as Query
import Test.Html.Selector as Selector

import State
import Types
import Snackbar.Types
import Snackbar.View
import Utils exposing (flip)

import TestUtils

{-| This function gets the initial state of the application, and then modifies
that state to include a snackbar, hidden, with the given text.
-}
modelWithSnackbar : String -> Types.Model
modelWithSnackbar snackbarText =
  let
    (model, _) = State.init ()
  in
  { model
  | snackbarModel =
    Just
      { transitionState = Snackbar.Types.Hidden
      , text = snackbarText
      }
  }

{-| This function takes an application with a snackbar in the Hidden state,
gives it a message of your discretion, and returns the HTML it generates in
response.
-}
viewFromMessage : String -> Types.Message -> Maybe (Html.Html Types.Message)
viewFromMessage snackbarText =
  flip State.update (modelWithSnackbar snackbarText)
  >> Tuple.first
  >> .snackbarModel
  >> Snackbar.View.view


transitionStateFuzzer : Fuzz.Fuzzer Snackbar.Types.TransitionState
transitionStateFuzzer =
  Fuzz.oneOf
    [ Fuzz.constant Snackbar.Types.Hidden
    , Fuzz.constant Snackbar.Types.Waxing
    , Fuzz.constant Snackbar.Types.Displayed
    , Fuzz.constant Snackbar.Types.Waning
    ]

suite : Test.Test
suite =
  Test.describe
    "The snackbar"
    [ Test.describe
        "Responding to a SnackbarNextTransitionState message"
        [ Test.fuzz
            (Fuzz.maybe transitionStateFuzzer)
            "updates the snackbarModel to the requested state"
            (\maybeTransitionState ->
              let
                message =
                  Types.SnackbarNextTransitionState maybeTransitionState
                (newModel, _) =
                  modelWithSnackbar "Hello!" |> State.update message
              in
              newModel
                |> .snackbarModel
                |> Maybe.map .transitionState
                |> Expect.equal maybeTransitionState
            )
        ]

    , Test.describe
        "Snackbar.View.view"
        [ [ Snackbar.Types.Hidden, Snackbar.Types.Waning ]
            |> TestUtils.parameterized
              "marks the snackbar as hidden during the appropriate transition states"
              (let
                expectedClasses =
                  [ Selector.class "snackbar", Selector.class "hidden" ]
              in
              (Just
                >> Types.SnackbarNextTransitionState
                >> viewFromMessage "Hi!"
                >> Maybe.map (Query.fromHtml >> Query.has expectedClasses)
                >> Maybe.withDefault (Expect.fail "No html generated")
              ))

        , [ Snackbar.Types.Waxing, Snackbar.Types.Displayed ]
            |> TestUtils.parameterized
              "marks the snackbar as visible during the appropriate transition states"
              (let
                expectedClasses =
                  [ Selector.class "snackbar" ]
                notExpectedClasses =
                  [ Selector.class "hidden" ]
              in
              (Just
                >> Types.SnackbarNextTransitionState
                >> viewFromMessage "Hi!"
                >> Maybe.map
                  (Query.fromHtml
                    >> Expect.all
                      [ Query.has expectedClasses
                      , Query.hasNot notExpectedClasses
                      ]
                  )
                >> Maybe.withDefault (Expect.fail "No html generated")
              ))

        , Test.test
            "generates no HTML when there isn't a snackbar"
            (\() ->
              viewFromMessage "Hi!" (Types.SnackbarNextTransitionState Nothing)
                |> Expect.equal Nothing
            )
        ]
    ]
