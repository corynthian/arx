module Subsidialis.AddCoins exposing (..)


import Css
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Layout.Centered as Centered
import Styles.Elements as Elements
import Styles.Fonts as Fonts
import Styles.Theme as Theme


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
    Centered.formView
        [ div [ Attr.css containerHeaderStyle ]
              [ text "ADD COINS" ]
        , div [ Attr.css containerBodyStyle ]
            [ div [ Attr.css Elements.formStyle ]
              [ div [ Attr.css Elements.formLeftStyle ]
                [ text "AMOUNT" ]
              , div [ Attr.css Elements.formRightStyle ]
                [ input [ Attr.css inputStyle ] []
                , Elements.btn [] [ text "MAX" ]
                ]
              ]
            , Elements.btn [ ] [ text "ADD" ]
            ]
        ]


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
