module WatchlistSpec exposing (suite)

{-| This module tests the watchlist-related functionality.

Note that we aren't testing the AJAX requests, just the app's state management
and view generation. (This is mostly for simplicity's sake--AJAX takes place in
the side-effecty parts of Elm's runtime, so it's hard to test.)
-}

import Html
import Http
import Json.Decode as Decode

import Expect
import Test
import Test.Html.Query as Query
import Test.Html.Selector as Selector

import State
import Types
import View
import Watchlist.Types
import Watchlist.View

import TestUtils.MoreExpect as MoreExpect
import TestUtils.MoreTest as MoreTest

{-| This function takes an application in the initial state, gives it a
series of messages of your discretion, and returns the model updated in
response to all of those messages.
-}
modelFromMessages : List Types.Message -> Types.Model
modelFromMessages messages =
  let
    applyMessages remainingMessages currentModel =
      case remainingMessages of
        head :: tail ->
          currentModel
            |> State.update head
            |> Tuple.first
            |> applyMessages tail
        [] ->
          currentModel
    (initialModel, _) = State.init ()
  in
  initialModel
    |> applyMessages messages

{-| Like `modelFromMessages`, but it then takes the model, generates the
HTML for the watchlist view, and returns that HTML.
-}
watchlistViewFromMessages : List Types.Message -> Html.Html Types.Message
watchlistViewFromMessages =
  modelFromMessages
    >> .watchlistModel
    >> Watchlist.View.view


{-| Like `watchlistViewFromMessages`, but it generates the HTML for the whole
page, not just the watchlist views.
-}
pageViewFromMessages : List Types.Message -> Html.Html Types.Message
pageViewFromMessages =
  modelFromMessages >> View.view


{-| This is a list of movie names for testing. -}
movies : Watchlist.Types.Watchlist
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


{-| Given a movie name and some html, expect that the html has a
<ul class="watchlist">, and expect that inside that <ul> there's a <li> with
the movie name in question.
-}
expectContainsLiFor : String -> Html.Html msg -> Expect.Expectation
expectContainsLiFor movieName html =
  Html.div [] [ html ]
    |> Query.fromHtml
    |> Query.find [ Selector.tag "ul" , Selector.class "watchlist" ]
    |> Query.findAll
      [ Selector.tag "li"
      , Selector.containing
        [ Selector.class "movie-name"
        , Selector.containing [ Selector.text movieName ]
        ]
      ]
    |> Query.count (Expect.greaterThan 0)

{-| Given a movie name and some html, expect that the html has a
<ul class="watchlist">, but expect that <ul> *NOT* to contain a <li> with
the movie name in question.
-}
expectDoesNotContainLiFor : String -> Html.Html msg -> Expect.Expectation
expectDoesNotContainLiFor movieName html =
  Html.div [] [ html ]
    |> Query.fromHtml
    |> Query.find [ Selector.tag "ul" , Selector.class "watchlist" ]
    |> Query.findAll
      [ Selector.tag "li"
      , Selector.containing [ Selector.text movieName ]
      ]
    |> Query.count (Expect.equal 0)

suite : Test.Test
suite =
  Test.describe
    "The HTML generated for the watchlist"
    [ Test.describe
        "When getting the watchlist completed successfully"
        [ Test.test
            "Contains an empty <ul class=\"watchlist\"> when there aren't any watchlist items"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok [] ]
              in
              -- elm-explorations/test doesn't have a way to query an element
              -- and its children, so instead what we're going to do is put the
              -- view in a div and query the children of that div. This lets us
              -- query the entire view.
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                -- At this step, the test will fail unless there's exactly one
                -- ul with the "watchlist" class.
                |> Query.find [ Selector.tag "ul", Selector.class "watchlist" ]
                -- This query gets all children, since an empty selector list
                -- matches everything.
                |> Query.children []
                |> Query.count (Expect.equal 0)
            )

        , Test.test
            "contains a <ul class=\"watchlist\"> with a <li> for each watchlist item"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies ]
              in
              viewHtml
                |> Expect.all (List.map expectContainsLiFor movies)
            )
        , Test.test
            "Contains an `add-watchlist-item` section"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok [] ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "add-watchlist-item" ]
                |> Query.count (Expect.equal 1)
            )
        ]

    , Test.describe
        "When getting the watchlist failed"
        [ Test.test
            -- It isn't worth it to be more specific than this. (We wouldn't
            -- want the tests to be too brittle!)
            "Contains an element with the \"error\" class"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.GetWatchlistCompleted <| Err <| Http.BadStatus 400
                    ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "error" ]
                |> Query.count (Expect.greaterThan 0)
            )

        , Test.test
            "The page contains a snackbar"
            (\() ->
              let
                viewHtml =
                  pageViewFromMessages
                    [ Types.GetWatchlistCompleted <| Err <| Http.BadStatus 400
                    ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "snackbar" ]
                |> Query.count (Expect.equal 1)
            )
        ]

    , Test.describe
        "When the watchlist is still loading"
        [ Test.test
            "Contains an element with the \"loading\" class"
            (\() ->
              let
                viewHtml = Watchlist.View.view Watchlist.Types.Loading
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "loading" ]
                |> Query.count (Expect.greaterThan 0)
            )
        ]

    , Test.describe
        "When putting the watchlist fails"
        [ Test.test
            "Should display the same watchlist that it did before the request completed"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput "How Do You Live?"
                    , Types.ClickAddWatchlistItem
                    , Types.PutWatchlistCompleted <| Err <| Http.BadStatus 400
                    ]
              in
              viewHtml
                |> Expect.all
                  (expectDoesNotContainLiFor "How Do You Live?"
                    :: List.map expectContainsLiFor movies
                  )
            )

        , Test.test
            "Contains a snackbar"
            (\() ->
              let
                viewHtml =
                  pageViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput "How Do You Live?"
                    , Types.ClickAddWatchlistItem
                    , Types.PutWatchlistCompleted <| Err <| Http.BadStatus 400
                    ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "snackbar" ]
                |> Query.count (Expect.equal 1)
            )
        ]

    , Test.describe
        "When you type a movie name into the new-watchlist-item text box"
        [ Test.test
            "Displays a validation error if the movie name is too long"
            (\() ->
              let
                viewHtml =
                  pageViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput
                        (String.repeat
                          (Watchlist.Types.maxWatchlistItemLength + 1)
                          "."
                        )
                    ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "validation-error" ]
                |> Query.count (Expect.equal 1)
            )
        , Test.test
            "Doesn't display a validation error if the movie name exactly the maximum allowed length"
            (\() ->
              let
                viewHtml =
                  pageViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput
                        (String.repeat
                          Watchlist.Types.maxWatchlistItemLength
                          "."
                        )
                    ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "validation-error" ]
                |> Query.count (Expect.equal 0)
            )
        , Test.test
            "Treats astral-plane characters as 1 character for validation purposes"
            (\() ->
              let
                viewHtml =
                  pageViewFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput
                        (String.repeat
                          Watchlist.Types.maxWatchlistItemLength
                          -- Santa is an astral-plane character.
                          "🎅"
                        )
                    ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.findAll [ Selector.class "validation-error" ]
                |> Query.count (Expect.equal 0)
            )
        ]
    , Test.describe
        "When you submit a new movie name"
        [ Test.test
            "If the movie name is the empty string, ignores you."
            (\() ->
              let
                model =
                  modelFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput ""
                    ]
                (_, cmd) =
                  model |> State.update Types.ClickAddWatchlistItem
              in
              cmd |> Expect.equal Types.NoCmd
            )
        , Test.test
            "If the movie name is too long string, ignores you"
            (\() ->
              let
                model =
                  modelFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput
                        (String.repeat
                          (Watchlist.Types.maxWatchlistItemLength + 1)
                          "."
                        )
                    ]
                (_, cmd) =
                  model |> State.update Types.ClickAddWatchlistItem
              in
              cmd |> Expect.equal Types.NoCmd
            )
        , let
            exampleMovieNames =
              [ "How Do You Live"
              , String.repeat Watchlist.Types.maxWatchlistItemLength "."
              , String.repeat Watchlist.Types.maxWatchlistItemLength "🎅"
              ]
          in
          exampleMovieNames |> MoreTest.parameterized
            "if the movie name is valid, makes a PUT request that prepends the movie name to the watchlist"
            (\movieName ->
              let
                model =
                  modelFromMessages
                    [ Types.GetWatchlistCompleted <| Ok movies
                    , Types.EditAddWatchlistItemInput movieName
                    ]
                (_, cmd) =
                  model |> State.update Types.ClickAddWatchlistItem
              in
              case cmd of
                Types.PutCmd { body } ->
                  let
                    maybeNewWatchlist =
                      body |> Decode.decodeValue (Decode.list Decode.string)
                  in
                  case maybeNewWatchlist of
                    Ok (first :: rest) ->
                      MoreExpect.and
                      [ first |> Expect.equal movieName
                      , rest |> Expect.equal movies
                      ]
                    _ ->
                      Expect.fail "The PUT request doesn't have a non-empty list of strings as its body"
                _ ->
                  Expect.fail "Does not make a PUT request."
            )
        ]
    ]
