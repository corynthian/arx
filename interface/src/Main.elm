module Main exposing (..)


import Account
import Browser
import Browser.Navigation as Nav
import Credential
import Css exposing (..)
import Css.Global
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Html.Styled.Events exposing (onClick)
import Styles.Branding as Branding
import Styles.Fonts as Fonts
import Styles.Theme as Theme
import Subsidialis
import Subsidialis.AddCoins
import Layout.Navigation as Navigation
import Json.Encode
import Json.Decode
import Url
import Js


-- MAIN


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , credential : Credential.Model
    , account : Account.Model
    , subsidialis : Subsidialis.Model
    , responses : List String
    }


default url key credential =
    { url = url
    , key = key
    , credential = credential
    , account = Account.default credential.arxAccountObject
    , subsidialis = Subsidialis.default
    , responses = []
    }


init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
    let ( credential, credentialMsg ) = Credential.init in
    let ( model, cmdMsg ) = initWithUrl (default url key credential) url in
    ( model
    , Cmd.batch
          [ Cmd.map CredentialMsg credentialMsg
          , cmdMsg
          ]
    )


initWithUrl model url =
    case url.path of
        "/subsidialis" ->
            let (subModel, subCmd) = Subsidialis.init in
            ( { model | url = url, subsidialis = subModel }, Cmd.map SubsidialisMsg subCmd )
        "/subsidialis/add_coins" ->
            let (subModel, subCmd) = Subsidialis.AddCoins.init in
            let subsidialis = model.subsidialis in
            ( { model | url = url, subsidialis = { subsidialis | addCoins = subModel } }
            , Cmd.map SubsidialisMsg subCmd
            )
        _ ->
            let (subModel, subCmd) = Account.init model.credential.arxAccountObject in
            ( { model | url = url, account = subModel }, Cmd.map AccountMsg subCmd )


-- UPDATE


type Msg =
    LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | CredentialMsg Credential.Msg
  | AccountMsg Account.Msg
  | SubsidialisMsg Subsidialis.Msg
  | ReceiveJsResult Json.Decode.Value


updateCredentials subMsg model =
    let ( credential, cmdMsg ) = Credential.update subMsg model.credential in
    let ( account, accountMsg ) = Account.updateCredential credential model.account in
    let ( addCoins, addCoinsMsg )
            = Subsidialis.AddCoins.updateArxAccount credential.arxAccountObject model.subsidialis.addCoins
    in
    let subsidialis = model.subsidialis in
    ( { model | credential = credential, account = account, subsidialis = { subsidialis | addCoins = addCoins } }
    , Cmd.batch
          [ Cmd.map CredentialMsg cmdMsg
          , Cmd.map AccountMsg accountMsg
          , Cmd.map SubsidialisMsg (Cmd.map Subsidialis.AddCoinsMsg addCoinsMsg)
          ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )
                Browser.External href ->
                    ( model, Nav.load href )
        UrlChanged url ->
            initWithUrl model url
        CredentialMsg subMsg ->
            let _ = Debug.log "main" "updating credentials" in
            updateCredentials subMsg model
        AccountMsg subMsg ->
            let ( subModel, cmdMsg ) = Account.update subMsg model.account in
            ( { model | account = subModel }, Cmd.map AccountMsg cmdMsg )
        SubsidialisMsg subMsg ->
            let ( subModel, cmdMsg ) = Subsidialis.update subMsg model.subsidialis in
            ( { model | subsidialis = subModel }, Cmd.map SubsidialisMsg cmdMsg )
        ReceiveJsResult res ->
            case Js.decodeResult res of
                Js.Fetched maybeAccount ->
                    updateCredentials (Credential.Fetched maybeAccount) model
                Js.Account account ->
                    updateCredentials (Credential.ArxAccountObject account) model
                Js.Hashes hashes ->
                    let ( subModel, cmdMsg ) = Account.update (Account.Hashes hashes) model.account in
                    ( { model | account = subModel }, Cmd.map AccountMsg cmdMsg )
                Js.TxnHash hash ->
                    ( model, Cmd.none )
                Js.Error errorString ->
                    ( { model | responses = model.responses ++ [ errorString ] }, Cmd.none )


-- VIEW


loadView model =
    case model.url.path of
        "/" ->
            map AccountMsg (Account.view model.account)
        "/account" ->
            map AccountMsg (Account.view model.account)
        "/subsidialis" ->
            Subsidialis.view model.subsidialis.data
        "/subsidialis/add_coins" ->
            map SubsidialisMsg
                (map Subsidialis.AddCoinsMsg (Subsidialis.AddCoins.view model.subsidialis.addCoins))
        _ ->
            div []
                [ text "Responses"
                , ul [] (List.map (\msg -> li [] [ text msg ]) model.responses)
                ]


view : Model -> Browser.Document Msg
view model =
    { title = "ARX"
    , body = 
        [ toUnstyled (div [ css style ]
            [ header []
                  [ Branding.logo
                  , div [
                       css [
                        Css.flexGrow <| Css.int 1
                       , Css.displayFlex
                       , Css.width <| Css.pct 5
                       ]
                      ] []
                  , div
                        [ css ([
                           Css.flexGrow <| Css.int 2
                         , Css.width <| Css.pct 85
                          ] ++ Navigation.css)
                        ]
                        [ Navigation.view (map CredentialMsg (Credential.view model.credential)) ]
                  ]
            , main_
                  []
                  [ Credential.navigation
                  , loadView model
                  ]
            ])
        ]
    }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Js.receiveResult ReceiveJsResult


-- STYLES


style =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.width <| Css.pct 100
    , Css.height <| Css.pct 100
    , Css.backgroundColor Theme.havelockBlue
    , Css.Global.descendants
        [ Css.Global.selector "> header"
            [ Css.displayFlex
            , Css.alignItems Css.center
            , Css.backgroundColor Theme.geyser
--            , Css.borderBottom3 (Css.px 1) Css.solid Theme.secondary 
            ]
        , Css.Global.selector "main"
            [ Css.width <| Css.pct 100
            --, Css.padding <| Css.rem 1
            , Css.overflow Css.auto
            , Css.Global.descendants
                [ Css.Global.selector ".credentialNavigation"
                      [ Css.width <| Css.pct 100
                      , Css.height <| Css.px 40
                      , Css.backgroundColor Theme.mirage
--                      , Css.borderBottom3 (Css.px 4) Css.solid Theme.secondaryMonochromatic
                      ]
                , Css.Global.selector "> div"
                    [ Css.marginBottom <| Css.rem 1 ]
                ]
            ]
        ]
    ]
        
