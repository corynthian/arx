module Subsidialis.AddCoins exposing (..)


import Css
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick, onInput)
import Js
import Js.Data as Data
import Json.Decode
import Layout.Centered as Centered
import Styles.Elements as Elements
import Styles.Fonts as Fonts
import Styles.Theme as Theme


-- MODEL


type InputStatus =
    Valid
  | InvalidNumber
  | MaximumExceeded


type alias Model = {
      arxAccountObject : Maybe Data.ArxAccountObject
    , amount : String
    }


default =
    { arxAccountObject = Nothing
    , amount = "0"
    }


init = ( default, Cmd.none )


-- UPDATE


type Msg
    = SendJsCommand Js.Command
    | UpdateAmount String
    | AddCoins
    | Error String


update msg model =
    case msg of
        SendJsCommand cmd ->
            ( model, Js.sendCommand (Js.encodeCommand cmd) )
        UpdateAmount amount ->
            ( { model | amount = amount }, Cmd.none )
        AddCoins ->
            case model.arxAccountObject of
                Just arxAccountObject ->
                    let cmd = Js.SubsidialisAddCoins arxAccountObject (parseAmountString model.amount) in
                    ( model, Js.sendCommand (Js.encodeCommand cmd) )
                Nothing ->
                    let _ = Debug.log "add_coins" "arxAccountObject was undefined" in
                    ( model, Cmd.none )
        Error err ->
            let _ = Debug.log "add-coins-error" err in
            ( model, Cmd.none )


updateArxAccountObject arxAccountObject model =
    ( { model | arxAccountObject = Just arxAccountObject }, Cmd.none )


-- VIEW


view model =
    Centered.formView
        [ div [ Attr.css containerHeaderStyle ]
              [ text "ADD COINS" ]
        , div [ Attr.css containerBodyStyle ]
            [ div [ Attr.css Elements.formStyle ]
              [ div [ Attr.css Elements.formLeftStyle ]
                [ text "AMOUNT" ]
              , div [ Attr.css Elements.formRightStyle ]
                [ input [ Attr.css inputStyle, onInput UpdateAmount ] []
                , Elements.btn [] [ text "MAX" ]
                ]
              ]
            , Elements.btn [ onClick AddCoins ] [ text "ADD" ]
            ]
        ]


-- HELPERS


parseAmountString s =
    case Json.Decode.decodeString Json.Decode.int s of
        Ok amount ->
            amount
        Err _ ->
            0


-- STYLES


containerHeaderStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.padding (Css.rem 1)
    , Css.color Theme.geyser
    , Css.backgroundColor Theme.mirage
    , Css.borderRadius4 (Css.px 10) (Css.px 10) (Css.px 0) (Css.px 0)
    , Fonts.barlowCondensed
    ]


containerBodyStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.padding <| Css.rem 1
    , Css.color Theme.mirage
    , Css.backgroundColor Theme.geyser
    , Fonts.barlowCondensed
    ]


inputStyle =
    [ Css.displayFlex
    , Css.padding <| Css.rem 0.5
    , Css.flexGrow <| Css.int 1
--    , Css.width <| Css.px 300
    , Css.border3 (Css.px 1) Css.solid Theme.geyser
        --, Css.borderColor <| Theme.havelockBlue
--    , Css.borderRadius (Css.rem 0.25)
    ]
