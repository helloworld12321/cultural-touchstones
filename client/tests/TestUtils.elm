module TestUtils exposing (parameterized)

{-| This file contains some helper functions for testing. -}

import Expect
import Test

{- Run a test on every item in a list of inputs -}
parameterized : String -> (a -> Expect.Expectation) -> List a -> Test.Test
parameterized name test inputs =
  Test.describe
    (name ++ "…")
    (inputs |> List.map (\input ->
      Test.test
        ("with input " ++ Debug.toString input)
        (\() -> test input)
    ))
