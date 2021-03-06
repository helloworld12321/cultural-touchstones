module WatchlistSpec exposing (suite)

{-| This module tests the watchlist-related functionality. -}

import Html
import Html.Attributes as Attributes
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

{-| This is a long list of movie names for testing. -}
miyazakiMovies : Watchlist.Types.Watchlist
miyazakiMovies =
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

{-| This is a short list of movie names for testing. -}
twilightMovies : Watchlist.Types.Watchlist
twilightMovies =
  [ "Twilight", "New Moon", "Eclipse" ]

{-| Given an application in a certain state, apply a series of messages to
that application, and return the model updated in response to all of those
messages.
-}
applyMessages : List Types.Message -> Types.Model -> Types.Model
applyMessages remainingMessages currentModel =
  case remainingMessages of
    head :: tail ->
      let (nextModel, _) = currentModel |> State.update head in
      applyMessages tail nextModel
    [] ->
      currentModel

{-| Like `applyMessages`, but starting from the initial application state. -}
modelFromMessages : List Types.Message -> Types.Model
modelFromMessages messages =
  let (initialModel, _) = State.init () in
  initialModel |> applyMessages messages

{-| Like `modelFromMessages`, but it then takes the model, generates the
HTML for the watchlist view, and returns that HTML.
-}
watchlistViewFromMessages : List Types.Message -> Html.Html Types.Message
watchlistViewFromMessages =
  modelFromMessages >> .watchlistModel >> Watchlist.View.view

{-| A sequence of messages that populates the watchlist with the Miyazaki
movies, and then types a new movie name into the watchlist input.
-}
addItem : String -> List Types.Message
addItem newMovieName =
  [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
  , Types.EditAddWatchlistItemInput newMovieName
  ]

{-| Like `watchlistViewFromMessages`, but it generates the HTML for the whole
page, not just the watchlist views.
-}
pageViewFromMessages : List Types.Message -> Html.Html Types.Message
pageViewFromMessages =
  modelFromMessages >> View.view

{-| The longest possible string that you can add to a watchlist. -}
maxLengthWatchlistItem : String
maxLengthWatchlistItem =
  (String.repeat Watchlist.Types.maxWatchlistItemLength ".")

{-| This is a silly string that's useful for checking that we treat
astral-plane unicode code points as single characters, rather than as two
surrogate-pair characters.
-}
santas : String
santas =
  (String.repeat Watchlist.Types.maxWatchlistItemLength "🎅")


{-| Given a movie name and some html, expect that the html has a
<ul class="watchlist">, and expect that inside that <ul> there's a <li> with
the movie name in question.
-}
expectContainsLiFor : String -> Html.Html msg -> Expect.Expectation
expectContainsLiFor movieName html =
  -- elm-explorations/test doesn't have a way to query an element and its
  -- children, so instead what we're going to do is put the view in a div and
  -- query the children of that div. This lets us query the entire view.
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
      , Selector.class "movie"
      , Selector.containing [ Selector.text movieName ]
      ]
    |> Query.count (Expect.equal 0)

suite : Test.Test
suite =
  Test.describe
    "The HTML generated for the watchlist"
    [ Test.describe
        "When loading the watchlist completed successfully"
        [ Test.test
            "Contains an empty <ul class=\"watchlist\"> when there aren't any watchlist items"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok [] ]
              in
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
            "contains a <ul class=\"watchlist\"> with a <li class=\"movie\"> for each watchlist item"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies ]
              in
              viewHtml
                |> Expect.all (List.map expectContainsLiFor miyazakiMovies)
            )
        , Test.test
            "contains <li class=\"movie\">s that have one `delete-button` apiece"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies ]
              in
              Html.div [] [ viewHtml ]
                |> Query.fromHtml
                |> Query.find [ Selector.tag "ul", Selector.class "watchlist" ]
                |> Query.findAll [ Selector.tag "li", Selector.class "movie"]
                |> Query.each (\li ->
                  li
                    |> Query.findAll [ Selector.class "delete-button" ]
                    |> Query.count (Expect.equal 1)
                )
            )
        , Test.test
            "Contains an `add-watchlist-item` section"
            (\() ->
              let
                viewHtml =
                  watchlistViewFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok [] ]
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
                    [ Types.LoadWatchlistCompleted <| Err <| Http.BadStatus 400
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
                    [ Types.LoadWatchlistCompleted <| Err <| Http.BadStatus 400
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
              let viewHtml = Watchlist.View.view Watchlist.Types.Loading in
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
                    [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                    , Types.EditAddWatchlistItemInput "How Do You Live?"
                    , Types.ClickAddWatchlistItem
                    , Types.PutWatchlistCompleted
                        { shouldClearWatchlistInput = True }
                        (Err <| Http.BadStatus 400)
                    ]
              in
              viewHtml
                |> Expect.all
                  (expectDoesNotContainLiFor "How Do You Live?"
                    :: List.map expectContainsLiFor miyazakiMovies
                  )
            )

        , Test.test
            "Contains a snackbar"
            (\() ->
              let
                viewHtml =
                  pageViewFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                    , Types.EditAddWatchlistItemInput "How Do You Live?"
                    , Types.ClickAddWatchlistItem
                    , Types.PutWatchlistCompleted
                        { shouldClearWatchlistInput = True }
                        (Err <| Http.BadStatus 400)
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
                    <| addItem (maxLengthWatchlistItem ++ ".")
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
                  pageViewFromMessages <| addItem maxLengthWatchlistItem
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
                  pageViewFromMessages <| addItem santas
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
                  modelFromMessages <| addItem ""
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
                  modelFromMessages <| addItem (maxLengthWatchlistItem ++ ".")
                (_, cmd) =
                  model |> State.update Types.ClickAddWatchlistItem
              in
              cmd |> Expect.equal Types.NoCmd
            )
        , let
            exampleMovieNames =
              [ "How Do You Live", maxLengthWatchlistItem, santas ]
          in
          exampleMovieNames |> MoreTest.parameterized
            "If the movie name is valid, makes a PUT request that prepends the movie name to the watchlist"
            (\movieName ->
              let
                model =
                  modelFromMessages <| addItem movieName
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
                      , rest |> Expect.equal miyazakiMovies
                      ]
                    _ ->
                      Expect.fail "The PUT request doesn't have a non-empty list of strings as its body"
                _ ->
                  Expect.fail "Does not make a PUT request."
            )
        , let
            movieName = "How Do You Live"
            initialState = modelFromMessages <| addItem movieName
            -- Each test case is a series of messages that will be applied to
            -- the initial state. After the application processes all of those
            -- messages, the movie name should still be present in the input
            -- field.
            testCases =
              [ [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickAddWatchlistItem
                ]
              , [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickAddWatchlistItem
                , Types.PutWatchlistCompleted
                    { shouldClearWatchlistInput = True }
                    (Err Http.NetworkError)
                ]
              ]
          in
          testCases |> MoreTest.parameterized
            ("Leaves your text in the input field in the following situations:\n"
              ++ "\t* While waiting for the PUT request to complete\n"
              ++ "\t* If the PUT request failed\n"
            )
            (\messages ->
              let
                appState = initialState |> applyMessages messages
                viewHtml = appState.watchlistModel |> Watchlist.View.view
              in
              viewHtml
                |> Query.fromHtml
                |> Query.find [ Selector.class "add-watchlist-item" ]
                |> Query.find [ Selector.tag "input" ]
                |> Query.has
                  [ Selector.attribute <| Attributes.value movieName ]
            )

        , Test.test
            "Clears your text from the input if the PUT request completed successfully"
            (\() ->
              let
                newMovie = "How Do You Live"
                allMovies = newMovie :: miyazakiMovies
                initialState = modelFromMessages <| addItem newMovie
                appState = initialState
                  |> applyMessages
                    [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                    , Types.EditAddWatchlistItemInput newMovie
                    , Types.ClickAddWatchlistItem
                    , Types.PutWatchlistCompleted
                        { shouldClearWatchlistInput = True }
                        (Ok ())
                    ]
                viewHtml = appState.watchlistModel |> Watchlist.View.view
              in
              viewHtml
                |> Query.fromHtml
                |> Query.find [ Selector.class "add-watchlist-item" ]
                |> Query.find [ Selector.tag "input" ]
                |> Query.has
                  [ Selector.attribute <| Attributes.value "" ]
            )
        ]

    , Test.describe
        "When you delete a movie"
        [ [-1, 5] |> MoreTest.parameterized
            "If the position given is too high or too low, ignores you"
            (\position ->
              let
                model =
                  modelFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok twilightMovies ]
                (_, cmd) =
                  model
                    |> State.update (Types.ClickDeleteWatchlistItem position)
              in
              cmd |> Expect.equal Types.NoCmd
            )
        , let
            -- Each test case consists of a position to delete, and a list of
            -- what movies should be left over after deleting that position.
            testCases =
              [ (0, [ "New Moon", "Eclipse" ])
              , (1, [ "Twilight", "Eclipse" ])
              , (2, [ "Twilight", "New Moon" ])
              ]
          in
          testCases |> MoreTest.parameterized
            "If the position given is a valid list index, makes a PUT request that elides the corresponding movie from the watchlist."
            (\(position, expectedNewWatchlist) ->
              let
                model =
                  modelFromMessages
                    [ Types.LoadWatchlistCompleted <| Ok twilightMovies ]
                (_, cmd) =
                  model
                    |> State.update (Types.ClickDeleteWatchlistItem position)
              in
              case cmd of
                Types.PutCmd { body } ->
                    body
                      |> Decode.decodeValue (Decode.list Decode.string)
                      |> Expect.equal (Ok expectedNewWatchlist)
                _ ->
                  Expect.fail "Does not make a PUT request."
            )
        ]
        , let
            movieName = "How Do You Live"
            initialState = modelFromMessages <| addItem movieName
            -- Each test case is a series of messages that will be applied to
            -- the initial state. After the application processes all of those
            -- messages, the movie name should still be present in the input
            -- field.
            testCases =
              [ [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickDeleteWatchlistItem 0
                ]
              , [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickDeleteWatchlistItem 0
                , Types.PutWatchlistCompleted
                    { shouldClearWatchlistInput = False }
                    (Ok ())
                ]
              , [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickDeleteWatchlistItem 0
                , Types.PutWatchlistCompleted
                    { shouldClearWatchlistInput = False }
                    (Err Http.NetworkError)
                ]
              , [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickDeleteWatchlistItem 0
                , Types.PutWatchlistCompleted
                    { shouldClearWatchlistInput = False }
                    (Ok ())
                , Types.ReloadWatchlistCompleted <| Err <| Http.BadStatus 404
                ]
              , [ Types.LoadWatchlistCompleted <| Ok miyazakiMovies
                , Types.EditAddWatchlistItemInput movieName
                , Types.ClickDeleteWatchlistItem 0
                , Types.PutWatchlistCompleted
                    { shouldClearWatchlistInput = False }
                    (Ok ())
                , Types.ReloadWatchlistCompleted
                    (Ok (miyazakiMovies |> List.tail |> Maybe.withDefault []))
                ]
              ]
          in
          testCases |> MoreTest.parameterized
            ("Leaves your text in the input field in the following situations:\n"
              ++ "\t* While waiting for the PUT request to complete\n"
              ++ "\t* While waiting for the subsequent GET request to complete\n"
              ++ "\t* If the PUT request failed\n"
              ++ "\t* If the PUT request succeeded but the GET request failed"
              ++ "\t* If both the PUT request and the GET request succeeded"
            )
            (\messages ->
              let
                appState = initialState |> applyMessages messages
                viewHtml = appState.watchlistModel |> Watchlist.View.view
              in
              viewHtml
                |> Query.fromHtml
                |> Query.find [ Selector.class "add-watchlist-item" ]
                |> Query.find [ Selector.tag "input" ]
                |> Query.has
                  [ Selector.attribute <| Attributes.value movieName ]
            )
    ]
