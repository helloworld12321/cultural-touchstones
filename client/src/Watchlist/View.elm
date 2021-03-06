module Watchlist.View exposing (view)

{-| This file generates HTML for the watchlist. -}

import Html
import Html.Attributes as Attributes
import Html.Events as Events

import Types
import Utils.MoreAttributes as MoreAttributes
import Utils.MoreEvents as MoreEvents
import Watchlist.Types

view : Watchlist.Types.Model -> Html.Html Types.Message
view model =
  case model of
    Watchlist.Types.Present { list, newItemText, newItemState } ->
      Html.div
        []
        [ newItemView newItemText newItemState
        , viewOfWatchlist list
        ]
    Watchlist.Types.Loading ->
      Html.p [ Attributes.class "loading" ] [ Html.text "Loading…" ]
    Watchlist.Types.Error ->
      let errorText = "Something went wrong." in
      Html.p [ Attributes.class "error" ] [ Html.text errorText ]

{-| This little piece of HTML lets you add new watchlist items.

The string parameter `newItemText` is the current contents of the text
field where you can type in a new watchlist item.
-}
newItemView
  : String
  -> Result Watchlist.Types.ValidationProblem ()
  -> Html.Html Types.Message
newItemView newItemText newItemState =
  let
    newItemInput =
      let
        baseAttributes =
          [ Attributes.type_ "text"
          , Attributes.value newItemText
          , Events.onInput Types.EditAddWatchlistItemInput
          , MoreEvents.onKeyUp "Enter" Types.ClickAddWatchlistItem
          ]
        attributes =
          case newItemState of
            Err (Watchlist.Types.Invalid _) ->
              Attributes.class "invalid" :: baseAttributes
            _ ->
              baseAttributes
      in
      Html.input attributes []

    addItemButton =
      Html.button
        [ Attributes.class "add-button"
        , MoreAttributes.ariaLabel "Add watchlist item"
        , Events.onClick Types.ClickAddWatchlistItem
        ]
        [ Html.text "+" ]

    maybeValidationMessage =
      case newItemState of
        Err (Watchlist.Types.Invalid reason) ->
          Just <|
            Html.span
              [ Attributes.class "validation-error" ]
              [ Html.text reason ]
        _ ->
          Nothing
  in
  Html.div
    [ Attributes.class "add-watchlist-item" ]
    (maybeValidationMessage
      |> Maybe.map (\validationMessage ->
        [ newItemInput
        , addItemButton
        , validationMessage
        ]
      )
      |> Maybe.withDefault [ newItemInput, addItemButton ]
    )

{-| If we have a watchlist to display, this function will turn it into HTML. -}
viewOfWatchlist : Watchlist.Types.Watchlist -> Html.Html Types.Message
viewOfWatchlist items =
  let
    deleteItemButton index =
      Html.button
        [ Attributes.class "delete-button"
        , MoreAttributes.ariaLabel "Delete watchlist item"
        , Events.onClick <| Types.ClickDeleteWatchlistItem index
        ]
        [ Html.text "×" ]

    liOfItem index item =
      Html.li
        [ Attributes.class "movie" ]
        [ deleteItemButton index
        , Html.span [ Attributes.class "movie-name" ] [ Html.text item ]
        ]
  in
  Html.ul [ Attributes.class "watchlist" ] (items |> List.indexedMap liOfItem)

