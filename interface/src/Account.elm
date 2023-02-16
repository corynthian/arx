module Account exposing (..)

import Api
import Css
import Css.Global
import Generated.Api.Data as Data
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Js.Data
import Json.Decode
import Styles.Elements as Elements
import Styles.Fonts as Fonts
import Styles.Theme as Theme


-- INIT    


type alias Model =
    { arxAccount : Maybe Js.Data.ArxAccount
    , arxBalance : Int
    }


default arxAccount =
    { arxAccount = arxAccount
    , arxBalance = 0
    }


init arxAccount =
    ( default arxAccount, Cmd.none )


-- UPDATE


type Msg
    = ArxCoin (Data.MoveResource Data.CoinStore)
    | Error String


matchResult f r =
    case r of
        Ok result ->
            f result
        Err err ->
            Error (Debug.toString err)


updateCredential credential model =
    case credential.arxAccount of
        Nothing ->
            ( model, Cmd.none )
        Just arxAccount ->
            ( { model | arxAccount = Just arxAccount }
            , Api.getAccountArxCoinResource (matchResult ArxCoin) arxAccount.accountAddress.hexString
            )


update msg model =
    case msg of 
        ArxCoin coinStore ->
            ( { model | arxBalance = parseBalanceString coinStore.data.coin.value }, Cmd.none )
        Error err ->
            let _ = Debug.log "account-error" err in
            ( model, Cmd.none )

-- VIEW


view model =
    div []
        [ div [ Attr.css containerStyle ]
          [ div [ Attr.css leftStyle ] [ ]
          , div [ Attr.css middleStyle ]
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
                  , Elements.btn [ ] --onClick (SendJsCommand (Js.Faucet address 10)) ]
                      [ text "FAUCET ARX" ]
                  ]
              ]
          , div [ Attr.css rightStyle ] [ ]
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


leftStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.margin (Css.rem 1)
    , Css.width (Css.pct 10)
    ]


middleStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.margin (Css.rem 1)
    , Css.width (Css.pct 33)
    ]


rightStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 3
    , Css.margin (Css.rem 1)
    , Css.width (Css.pct 10)
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
