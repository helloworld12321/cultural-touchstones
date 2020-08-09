module Demo exposing (suite)

import Expect
import Test exposing (Test, test)


suite : Test
suite =
    test "Two plus two equals four" <|
      \() ->
         Expect.equal 4 (2 + 2)
