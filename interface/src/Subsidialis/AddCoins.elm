module Subsidialis.AddCoins exposing (..)


import Html.Styled exposing (..)


-- MODEL


type alias Model = { }


default = { }


init = ( default, Cmd.none )


-- UPDATE


type Msg = 
    AddCoins Int


update msg model =
    ( model, Cmd.none )


-- VIEW


view model =
    div []
        [ input [] [] ]
