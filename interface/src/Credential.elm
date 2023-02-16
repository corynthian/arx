module Credential exposing (..)


import Css
import Css.Global
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
    { arxAccount : Maybe Js.Data.ArxAccount }


init : (Model, Cmd Msg)
init =
    ( { arxAccount = Nothing }, Js.sendCommand (Js.encodeCommand Js.FetchAccount) )


-- UPDATE


type Msg =
    SendJsCommand Js.Command
  | Fetched (Maybe Js.Data.ArxAccount)
  | ArxAccount Js.Data.ArxAccount
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
        Fetched maybeArxAccount ->
            case maybeArxAccount of
                Just arxAccount ->
                    ( { model | arxAccount = Just arxAccount }, Cmd.none )
                Nothing ->
                    ( model, Js.sendCommand (Js.encodeCommand Js.GenerateAccount) )
        ArxAccount arxAccount ->
            ( { model | arxAccount = Just arxAccount }, Cmd.none )
        Error err ->
            let _ = Debug.log "credential-error" err in
            ( model, Cmd.none )


-- VIEW


renderAddress address =
    let start = String.slice 0 2 address in
    let end = String.slice 2 20 (String.toUpper address) in
    start ++ end ++ "..."


view model =
    case model.arxAccount of
        Just arxAccount ->
            let address = arxAccount.accountAddress.hexString in
            div [ A.css [ Css.color Theme.havelockBlue ] ]
                [ Elements.listElement [ A.class "listElement" ]
                      [ a [ A.href "/account" ] [ text (renderAddress address) ] ]
                ]
        Nothing ->
            Elements.btn [ onClick (SendJsCommand Js.GenerateAccount) ]
                [ text "GENERATE ACCOUNT" ]


navigation =
    div [ A.css style ]
        [ ul
          [ A.class "credentialNavigation" ]
          [ li
            [ A.class "credentialNavigation__item" ]
            [ text "1 ARX = 1.000 XUSD" ]
          , li
            [ A.class "credentialNavigation__item"
            , A.css [ Css.color Theme.ochre ]
            ]
            [ text "DISCONNECTED" ]
          ]
        ]


-- STYLES


style =
    [ Css.displayFlex
    , Css.alignItems Css.center
    , Css.justifyContent Css.center
    , Css.Global.descendants
        [ Css.Global.selector ".credentialNavigation"
            [ Css.displayFlex
            , Css.alignItems Css.center
            , Css.listStyle Css.none
            , Css.margin Css.zero
            , Css.Global.descendants
                [ Css.Global.selector ".credentialNavigation__item"
                    [ Css.padding <| Css.rem 1
                    , Css.lastOfType
                        [ Css.marginLeft Css.auto
                        , Css.color Theme.ochre
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
