module WatchlistSpec exposing (suite)

{-| This module tests the watchlist-related functionality.

Note that we aren't testing the AJAX requests, just the app's state management
and view generation. (This is mostly for simplicity's sake--AJAX takes place in
the side-effecty parts of Elm's runtime, so it's hard to test.)
-}

import Html
import Http

import Expect
import Test
import Test.Html.Query as Query
import Test.Html.Selector as Selector

import State
import Types
import Watchlist.Types
import Watchlist.View

{-| This function takes an application in the Loading state, gives it a message
of your discretion, and returns the HTML it generates in response.
-}
viewFromMessage : Types.Message -> Html.Html Types.Message
viewFromMessage message =
  let
    (previousState, _) = State.init ()
    ({ watchlistModel }, _) = State.update message previousState
  in
  Watchlist.View.view watchlistModel


suite : Test.Test
suite =
  Test.describe
    "The HTML generated by Watchlist.View.view"
    [ Test.describe
        "When getting the watchlist completed successfully"
        [ Test.test
            "contains an empty <ul class=\"watchlist\"> when there aren't any watchlist items" <|
            \() ->
              let
                viewHtml =
                  viewFromMessage (Types.GetWatchlistCompleted (Ok []))
              in
              {- elm-explorations/test doesn't have a way to query an element
              and its children, so instead what we're going to do is put the
              view in a div and query the children of that div. This lets us
              query the entire view.
              -}
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                {- At this step, the test will fail unless there's exactly one
                ul with the "watchlist" class.
                -}
                |> Query.find [ Selector.tag "ul", Selector.class "watchlist" ]
                {- This query gets all children, since an empty selector list
                matches everything.
                -}
                |> Query.children []
                |> Query.count (Expect.equal 0)

        , Test.test
            "contains a <ul class=\"watchlist\"> with a <li> for each watchlist item" <|
            \() ->
              let
                movies =
                  [ "The Castle of Cagliostro"
                  , "Nausicaä of the Valley of the Wind"
                  , "Castle in the Sky"
                  , "My Neighbor Totoro"
                  , "Kiki's Delivery Service"
                  , "Porco Rosso"
                  , "Princess Mononoke"
                  , "Spirited Away"
                  , "Howl's Moving Castle"
                  , "Ponyo"
                  , "The Wind Rises"
                  ]

                viewHtml =
                  viewFromMessage (Types.GetWatchlistCompleted (Ok movies))

                {- Given a movie name and some html, expect that the html has
                html has a <ul class="watchlist">, and expect that inside that
                <ul> there's a <li> with the movie name.
                -}
                expectContainsLiFor movieName html =
                  Html.div [] [ html ]
                    |> Query.fromHtml
                    |> Query.find
                      [ Selector.tag "ul"
                      , Selector.class "watchlist"
                      ]
                    |> Query.contains [ Html.li [] [ Html.text movieName ] ]
              in
              viewHtml
                |> Expect.all (List.map expectContainsLiFor movies)
        ]

    , Test.describe
        "When getting the watchlist failed"
        [ Test.test
            {- It isn't worth it to be more specific than this. (We wouldn't
            want the tests to be too brittle!)
            -}
            "contains an element with the \"error\" class" <|
            \() ->
              let
                viewHtml =
                  viewFromMessage
                    (Types.GetWatchlistCompleted (Err (Http.BadStatus 400)))
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "error" ]
                |> Query.count (Expect.greaterThan 0)
        ]

    , Test.describe
        "When the watchlist is still loading"
        [ Test.test
            "contains an element with the \"loading\" class" <|
            \() ->
              let
                viewHtml = Watchlist.View.view Watchlist.Types.Loading
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "loading" ]
                |> Query.count (Expect.greaterThan 0)
        ]
    ]
