module Credential exposing (..)


import Api
import Css
import Css.Global
import Generated.Api.Data as Data
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Attributes as A
import Js
import Js.Data
import Styles.Breakpoints as Breakpoints
import Styles.Elements as Elements
import Styles.Fonts as Fonts
import Styles.Theme as Theme


-- MODEL


type alias Model =
    { account : Maybe Js.Data.ArxAccount
    , arxBalance : String
    }


init : (Model, Cmd Msg)
init =
    ( { account = Nothing, arxBalance = "" }, Js.sendCommand (Js.encodeCommand Js.FetchAccount) )


-- UPDATE


type Msg =
    SendJsCommand Js.Command
  | Fetched (Maybe Js.Data.ArxAccount)
  | Account Js.Data.ArxAccount
  | ArxCoin (Data.MoveResource Data.CoinStore)
  | Error String

matchResult f r =
    case r of
        Ok result ->
            f result
        Err err ->
            Error (Debug.toString err)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendJsCommand cmd ->
            ( model, Js.sendCommand (Js.encodeCommand cmd) )
        Fetched maybeAccount ->
            case maybeAccount of
                Just account ->
                    ( { model | account = Just account }
                    , Api.getAccountArxCoinResource (matchResult ArxCoin) account.accountAddress.hexString
                    )
                Nothing ->
                    ( model, Js.sendCommand (Js.encodeCommand Js.GenerateAccount) )
        Account account ->
            ( { model | account = Just account }, Cmd.none )
        ArxCoin coinStore ->
            ( { model | arxBalance = coinStore.data.coin.value }, Cmd.none )
        Error err ->
            let _ = Debug.log err in
            ( model, Cmd.none )


-- VIEW


renderAddress address =
    let start = String.slice 0 2 address in
    let end = String.slice 2 20 (String.toUpper address) in
    start ++ end ++ "..."


view model =
    case model.account of
        Just account ->
            let address = account.accountAddress.hexString in
            div [ A.css [ Css.color Theme.havelockBlue ] ]
                [ Elements.listElement [ A.class "listElement" ]
                      [ a [ A.href "/account" ] [ text (renderAddress address) ]
                      , text ("ARX = " ++ model.arxBalance)
                      ]
--                , Elements.btn [ onClick (SendJsCommand (Js.Faucet address 10)) ]
--                    [ text "FAUCET" ]
                ]
        Nothing ->
            Elements.btn [ onClick (SendJsCommand Js.GenerateAccount) ]
                [ text "GENERATE ACCOUNT" ]


navigation =
    div [ A.css navigationCss ]
        [ ul
          [ A.class "credentialNavigation" ]
          [ li
            [ A.class "credentialNavigation__item" ]
            [ text "1 ARX = 1.000 XUSD" ]
          , li
            [ A.class "credentialNavigation__item" ]
            [ text "EPOCH = 0" ]
          , li
            [ A.class "credentialNavigation__item" ]
            [ text "DELTA = 0" ]
          , li
            [ A.class "credentialNavigation__item" ]
            [ text "CONNECTED" ]
          ]
        ]


-- STYLES


css =
    [ -- Css.color Theme.secondary
          Fonts.barlowCondensed
    ]


navigationCss =
    [ Css.displayFlex
    , Css.alignItems Css.center
    , Css.justifyContent Css.center
    , Css.Global.descendants
        [ Css.Global.selector ".credentialNavigation"
            [ Css.displayFlex
            , Css.alignItems Css.center
            , Css.listStyle Css.none
            , Css.margin Css.zero
            -- , Css.border3 (Css.px 1) Css.solid theme.redAnalogous
            -- , Css.borderRadius <| Css.px 4
            --, Css.width <| Css.pct 100
            , Css.Global.descendants
                [ Css.Global.selector ".credentialNavigation__item"
                    [ Css.padding <| Css.rem 1
                    --, Css.marginLeft <| Css.rem 2
                    , Css.lastOfType
                        [ Css.marginLeft Css.auto
                        -- , Css.backgroundColor Theme.primary
                        -- , Css.borderRadius (Css.px 100)
                        ]
                    , Fonts.barlowCondensed
                    , Css.fontSize (Css.rem 1.2)
                    , Css.color Theme.geyser
                    , Breakpoints.small
                        [ Css.padding <| Css.rem 0.3 ]
                    ]
                ]
            ]
        ]
    ]    
