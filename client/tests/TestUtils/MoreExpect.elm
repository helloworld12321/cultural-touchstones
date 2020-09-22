module TestUtils.MoreExpect exposing (and)

{-| This file contains some helper functions for writing expectations. -}

import Expect

{-| Expect that all of the given expectations pass. -}
and : List Expect.Expectation -> Expect.Expectation
and expectations =
  -- Expect.all wants an input to run the expectations against, so we're just
  -- going to give it unit as a dummy input.
  () |> Expect.all (expectations |> List.map always)
