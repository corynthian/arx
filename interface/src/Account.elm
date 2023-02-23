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
    , luxActiveBalance : Int
    , luxPendingBalance : Int
    , noxActiveBalance : Int
    , noxPendingBalance : Int
    , arxLockedBalance : Int
    , arxPendingUnlockedBalance : Int
    , arxUnlockedBalance : Int
    , address : String
    }


default arxAccountObject =
    { arxAccountObject = arxAccountObject
    , arxBalance = 0
    , luxActiveBalance = 0
    , luxPendingBalance = 0
    , noxActiveBalance = 0
    , noxPendingBalance = 0
    , arxLockedBalance = 0
    , arxPendingUnlockedBalance = 0
    , arxUnlockedBalance = 0
    , address = ""
    }


init arxAccountObject =
    ( default arxAccountObject, Cmd.none )


-- UPDATE


type Msg
    = SendJsCommand Js.Command
    | Hashes (List String)
    | ArxSolaris (Data.MoveResource Data.Solaris)
    | ArxCoin (Data.MoveResource Data.CoinStore)
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
            let getSolaris = Js.GetSolaris arxAccountObject in
            ( { model | arxAccountObject = Just arxAccountObject, address = address }
            , Cmd.batch [
                Api.getAccountArxCoinResource (matchResult ArxCoin) address
              , Api.getArxSolaris (matchResult ArxSolaris) address
                     -- , Js.sendCommand (Js.encodeCommand getSolaris)
              ]
            )


update msg model =
    case msg of 
        SendJsCommand cmd ->
            ( model, Js.sendCommand (Js.encodeCommand cmd) )
        Hashes _ ->
            ( model, Api.getAccountArxCoinResource (matchResult ArxCoin) model.address )
        ArxSolaris solaris ->
            let _ = Debug.log "account-solaris" solaris in
            ( { model | luxActiveBalance = parseBalanceString solaris.data.activeLux.value
              , luxPendingBalance = parseBalanceString solaris.data.pendingActiveLux.value
              , noxActiveBalance = parseBalanceString solaris.data.activeNox.value
              , noxPendingBalance = parseBalanceString solaris.data.pendingActiveNox.value
              }
            , Cmd.none )
        ArxCoin coinStore ->
            let _ = Debug.log "account-arx" coinStore.data.coin.value in
            ( { model | arxBalance = parseBalanceString coinStore.data.coin.value }, Cmd.none )
        Error err ->
            let _ = Debug.log "account-error" err in
            ( model, Cmd.none )

-- VIEW


printArxCoins balance =
    String.fromFloat ((toFloat balance) / 100000000.0)


printSeignorage model =
    let activeLux = String.fromFloat ((toFloat model.luxActiveBalance) / 100000000.0) in
    let pendingLux = String.fromFloat ((toFloat model.luxPendingBalance) / 100000000.0) in
    let activeNox = String.fromFloat ((toFloat model.noxActiveBalance) / 100000000.0) in
    let pendingNox = String.fromFloat ((toFloat model.noxPendingBalance) / 100000000.0) in
    activeLux ++ " LUX (active) / " ++ pendingLux ++ " LUX (pending) / "
        ++ activeNox ++ " NOX (active) / " ++ pendingNox ++ " NOX (pending)"

view model =
    Centered.view
        [ div [ Attr.css containerHeaderStyle ]
              [ text "ACCOUNT" ]
        , div [ Attr.css containerBodyStyle ]
            [ div [ Attr.css listStyle ]
                  [ div [ Attr.css listLeftStyle ]
                        [ text "COINS" ]
                  , div [ Attr.css listRightStyle ]
                      [ text (printArxCoins model.arxBalance ++ " ARX / 0 XUSD / 0 ARX:XUSD") ]
                  ]
            , div [ Attr.css listStyle ]
                [ div [ Attr.css listLeftStyle ]
                      [ text "SEIGNORAGE" ]
                , div [ Attr.css listRightStyle ]
                    [ text (printSeignorage model) ]
                ]
            , Elements.btn [ onClick (SendJsCommand (Js.Faucet model.address 10000000)) ]
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
