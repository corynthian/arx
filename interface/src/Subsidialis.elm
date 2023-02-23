module Subsidialis exposing (..)


import Api
import Css
import Css.Global
import Js
import Js.Data
import Generated.Api.Data as Data
import Html.Styled exposing (..)
import Html.Styled.Attributes as A
import Html.Styled.Events exposing (onClick)
import Styles.Elements as Elements
import Styles.Fonts as Fonts
import Styles.Theme as Theme
import Subsidialis.AddCoins


-- MODEL

type alias Model =
    { arxAccountObject : Maybe Js.Data.ArxAccountObject
    , data : Data.Subsidialis
    , addCoins : Subsidialis.AddCoins.Model
    }


init =
    let ( addCoins, addCoinsMsg ) = Subsidialis.AddCoins.init in
    ( { default | addCoins = addCoins }
    , Cmd.batch
          [ Api.getSubsidialis matchResult
          , Cmd.map AddCoinsMsg addCoinsMsg
          ]
    )


defaultData =
    { active = []
    , pendingActive = []
    , pendingInactive = []
    , totalActivePower = ""
    , totalJoiningPower = ""
    } 


default =
    { arxAccountObject = Nothing
    , data = defaultData
    , addCoins = Subsidialis.AddCoins.default
    }


-- UPDATE


type Msg =
    GetSubsidialis
  | Subsidialis ( Data.MoveResource Data.Subsidialis )
  | JoinSubsidialis
  | AddCoinsMsg Subsidialis.AddCoins.Msg
  | Error String


matchResult r =
    case r of
        Ok result ->
            Subsidialis result
        Err err ->
            Error (Debug.toString err)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSubsidialis ->
            ( model, Api.getSubsidialis matchResult )
        Subsidialis subsidialis ->
            ( { model | data = subsidialis.data }, Cmd.none )
        JoinSubsidialis ->
            case model.arxAccountObject of
                Just arxAccountObject ->
                    let cmd = Js.SubsidialisJoin arxAccountObject in
                    ( model, Js.sendCommand (Js.encodeCommand cmd) )
                Nothing ->
                    let _ = Debug.log "subsidialis" "arxAccountObject was undefined" in
                    ( model, Cmd.none )
        AddCoinsMsg subMsg ->
            let ( subModel, cmdMsg ) = Subsidialis.AddCoins.update subMsg model.addCoins in
            ( { model | addCoins = subModel }, Cmd.map AddCoinsMsg cmdMsg )
        Error err ->
            ( model, Cmd.none )


updateCredential credential model =
    case credential.arxAccountObject of
        Nothing ->
            ( model, Cmd.none )
        Just arxAccountObject ->
            let ( addCoins, addCoinsMsg ) =
                    Subsidialis.AddCoins.updateArxAccountObject arxAccountObject model.addCoins
            in
            ( { model | arxAccountObject = Just arxAccountObject, addCoins = addCoins }
            , Cmd.map AddCoinsMsg addCoinsMsg
            )


-- VIEW


view model =
    div []
        [ div [ A.css containersCss ]
          [ div [ A.css activeContainerCss ]
            [ div [ A.css containerHeaderCss ]
                [ text "ACTIVE" ]
            , div [ A.css containerBodyCss ]
                [ text (Debug.toString model.active) ]
            ]
          , div [ A.css pendingContainerCss ]
              [ div [ A.css containerHeaderCss ]
                  [ text "PENDING" ]
              , div [ A.css containerBodyCss ]
                  [ text (Debug.toString model.pendingActive) ]
              ]
          , div [ A.css leavingContainerCss ]
              [ div [ A.css containerHeaderCss ]
                    [ text "LEAVING" ]
              , div [ A.css containerBodyCss ]
                  [ text (Debug.toString model.pendingInactive) ]
              ]
          ]
        , ul [ A.css css ]
            [ Elements.btn [ onClick JoinSubsidialis ]
                  [ text "BECOME DOMINUS" ]
            , Elements.listElement [ A.class "listElement" ]
                  [ a [ A.href "/subsidialis/add_coins" ] [ text "ADD ARX COINS" ] ]
            , Elements.listElement [ A.class "listElement" ]
                [ a [ A.href "/subsidialis/add_liquidity" ] [ text "ADD ARX:XUSD LIQUIDITY" ] ]
            , Elements.listElement [ A.class "listElement" ]
                [ a [ A.href "/subsidialis/remove_coins" ] [ text "REMOVE ARX COINS" ] ]
            , Elements.listElement [ A.class "listElement" ]
                [ a [ A.href "/subsidialis/remove_liquidity" ] [ text "REMOVE ARX:XUSD LIQUIDITY" ] ]
            , Elements.listElement [ A.class "listElement" ]
                [ a [ A.href "/subsidialis/leave" ] [ text "LEAVE SUBSIDIALIS" ] ]
            ]
        ]


-- STYLES


containersCss =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.margin (Css.rem 1)
    ]
    

activeContainerCss =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.margin (Css.rem 1)
    , Css.width (Css.pct 30)
    , Css.backgroundColor Theme.geyser
    , Css.borderRadius (Css.px 10)
    ]

pendingContainerCss =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 2
    , Css.margin (Css.rem 1)
    , Css.width (Css.pct 30)
    , Css.backgroundColor Theme.geyser
    , Css.borderRadius (Css.px 10)
    ]

leavingContainerCss =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 3
    , Css.margin (Css.rem 1)
    , Css.width (Css.pct 30)
    , Css.backgroundColor Theme.geyser
    , Css.borderRadius (Css.px 10)
    ]

containerHeaderCss =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.padding (Css.rem 1)
    , Css.color Theme.geyser
    , Css.backgroundColor Theme.mirage
    , Css.borderRadius (Css.px 10)
    , Fonts.barlowCondensed
    ]

containerBodyCss =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 2
    , Css.padding (Css.rem 1)
    , Css.borderRadius (Css.px 10)
    , Css.color Theme.mirage
    , Css.width (Css.pct 100)
    , Fonts.barlowCondensed
    ]

css =
    [ Css.displayFlex
    , Css.alignItems Css.center
    , Css.justifyContent Css.center
    , Css.listStyle Css.none
    , Css.Global.descendants
        [ Css.Global.selector ".listElement a"
            [ Css.color Theme.havelockBlue
            , Css.backgroundColor Theme.mirage
            , Css.textDecoration Css.none
            , Fonts.barlowCondensed
            , Css.fontSize (Css.rem 1.25)
            , Css.padding (Css.rem 1)
            , Css.borderRadius (Css.rem 1)
            , Css.hover [
                   Css.textDecoration3  Css.underline Css.solid Theme.mirage
              ]
            ]
        ]
    ]
