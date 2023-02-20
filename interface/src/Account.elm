module Account exposing (..)

import Api
import Css
import Css.Global
import Generated.Api.Data as Data
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick)
import Js
import Js.Data
import Json.Decode
import Layout.Centered as Centered
import Styles.Elements as Elements
import Styles.Fonts as Fonts
import Styles.Theme as Theme


-- INIT    


type alias Model =
    { arxAccountObject : Maybe Js.Data.ArxAccountObject
    , arxBalance : Int
    , luxBalance : Int
    , noxBalance : Int
    , address : String
    }


default arxAccountObject =
    { arxAccountObject = arxAccountObject
    , arxBalance = 0
    , luxBalance = 0
    , noxBalance = 0
    , address = ""
    }


init arxAccountObject =
    ( default arxAccountObject, Cmd.none )


-- UPDATE


type Msg
    = SendJsCommand Js.Command
    | Hashes (List String)
    | ArxCoin (Data.MoveResource Data.CoinStore)
    | LuxCoin (Data.MoveResource Data.CoinStore)
    | NoxCoin (Data.MoveResource Data.CoinStore)
    | Error String


matchResult f r =
    case r of
        Ok result ->
            f result
        Err err ->
            Error (Debug.toString err)


updateCredential credential model =
    case credential.arxAccountObject of
        Nothing ->
            ( model, Cmd.none )
        Just arxAccountObject ->
            let address = arxAccountObject.address in
            ( { model | arxAccountObject = Just arxAccountObject, address = address }
            , Cmd.batch [
                 Api.getAccountArxCoinResource (matchResult ArxCoin) address
--               , Api.getAccountLuxCoinResource (matchResult LuxCoin) address
--               , Api.getAccountNoxCoinResource (matchResult NoxCoin) address
              ]
            )


update msg model =
    case msg of 
        SendJsCommand cmd ->
            ( model, Js.sendCommand (Js.encodeCommand cmd) )
        Hashes _ ->
            ( model, Api.getAccountArxCoinResource (matchResult ArxCoin) model.address )
        ArxCoin coinStore ->
            let _ = Debug.log "account-arx" coinStore.data.coin.value in
            ( { model | arxBalance = parseBalanceString coinStore.data.coin.value }, Cmd.none )
        LuxCoin coinStore ->
            let _ = Debug.log "account-lux" coinStore.data.coin.value in
            ( { model | luxBalance = parseBalanceString coinStore.data.coin.value }, Cmd.none )
        NoxCoin coinStore ->
            let _ = Debug.log "account-nox" coinStore.data.coin.value in
            ( { model | noxBalance = parseBalanceString coinStore.data.coin.value }, Cmd.none )
        Error err ->
            let _ = Debug.log "account-error" err in
            ( model, Cmd.none )

-- VIEW


view model =
    Centered.view
        [ div [ Attr.css containerHeaderStyle ]
              [ text "ACCOUNT" ]
        , div [ Attr.css containerBodyStyle ]
            [ div [ Attr.css listStyle ]
                  [ div [ Attr.css listLeftStyle ]
                        [ text "COINS" ]
                  , div [ Attr.css listRightStyle ]
                      [ text (String.fromInt model.arxBalance ++ " ARX / 0 XUSD / 0 ARX:XUSD") ]
                  ]
            , div [ Attr.css listStyle ]
                [ div [ Attr.css listLeftStyle ]
                      [ text "SEIGNORAGE" ]
                , div [ Attr.css listRightStyle ]
                    [ text "0 LUX / 0 NOX" ]
                ]
            , Elements.btn [ onClick (SendJsCommand (Js.Faucet model.address 1000000)) ]
                [ text "FAUCET ARX" ]
            ]
        ]


-- HELPERS


parseBalanceString s =
    case Json.Decode.decodeString Json.Decode.int s of
        Ok amount ->
            amount
        Err _ ->
            0


-- STYLES

containerStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.margin (Css.rem 1) 
    ]


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
    , Css.flexGrow <| Css.int 2
    , Css.padding (Css.rem 1)
    , Css.color Theme.mirage
    , Css.backgroundColor Theme.geyser
    , Fonts.barlowCondensed
    ]

listStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.backgroundColor Theme.white
    , Css.flexGrow <| Css.int 1
    , Css.borderRadius (Css.px 10)
    , Css.marginBottom (Css.px 3)
    ]

listLeftStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.flexGrow <| Css.int 1
    , Css.width <| Css.pct 20
    , Css.backgroundColor Theme.mirage
    , Css.color Theme.geyser
    , Css.padding (Css.rem 1)
    , Css.borderRadius (Css.px 10)
    ]

listRightStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.flexGrow <| Css.int 2
    , Css.width <| Css.pct 20
    , Css.justifyContent Css.right
    , Css.padding (Css.rem 1)
    ]

style =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.width <| Css.pct 100
    , Css.height <| Css.pct 100
    , Css.backgroundColor Theme.havelockBlue
    , Css.color Theme.geyser
    , Fonts.barlowCondensed
    ]
