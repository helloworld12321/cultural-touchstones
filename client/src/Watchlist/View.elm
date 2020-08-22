module Watchlist.View exposing (view)

{-| This file generates HTML for the watchlist. -}

import Html
import Html.Attributes as Attributes
import Html.Events as Events

import Types
import Utils.MoreAttributes as MoreAttributes
import Watchlist.Types

view : Watchlist.Types.Model -> Html.Html Types.Message
view model =
  case model of
    Watchlist.Types.Ok { list, newItemText } ->
      Html.div
        []
        [ newItemView newItemText
        , viewOfWatchlist list
        ]
    Watchlist.Types.Loading ->
      Html.p [ Attributes.class "loading" ] [ Html.text "Loading…" ]
    Watchlist.Types.Error ->
      let
        errorText = "Something went wrong."
      in
      Html.p [ Attributes.class "error" ] [ Html.text errorText ]

{-| This little piece of HTML lets you add new watchlist items.

The string parameter `newItemText` is the current contents of the text
field where you can type in a new watchlist item.
-}
newItemView : String -> Html.Html Types.Message
newItemView newItemText =
  Html.div
    [ Attributes.class "add-watchlist-item" ]
    [ Html.input
        [ Attributes.type_ "text"
        , Attributes.value newItemText
        , Events.onInput Types.EditAddWatchlistInput
        ]
        []
    , Html.a
        [ Attributes.href "#"
        , MoreAttributes.role "button"
        , MoreAttributes.tabIndex "0"
        , MoreAttributes.ariaLabel "Add watchlist item"
        , Events.onClick Types.ClickAddWatchlistItem
        ]
        [ Html.text "+" ]
    ]

{-| If we have a watchlist to display, this function will turn it into HTML. -}
viewOfWatchlist : Watchlist.Types.Watchlist -> Html.Html Types.Message
viewOfWatchlist items =
  let
    liOfItem item = Html.li [] [ Html.text item ]
  in
  Html.ul [ Attributes.class "watchlist" ] (items |> List.map liOfItem)
