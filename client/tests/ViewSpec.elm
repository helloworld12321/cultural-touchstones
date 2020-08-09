module ViewSpec exposing (suite)

import Html

import Test
import Test.Html.Query as Query

import View


suite : Test.Test
suite =
  Test.describe
    "The HTML generated by View.view" <|
    [ Test.test
        "Contains a text node with the message \"Hello, World!\" somewhere" <|
        \() ->
          let
            html = View.view ()
          in
          html
            |> Query.fromHtml
            |> Query.contains [ Html.text "Hello, World!" ]
    ]
