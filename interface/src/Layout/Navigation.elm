module Layout.Navigation exposing (view, css)


import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Styles.Breakpoints as Breakpoints
import Styles.Fonts as Fonts
import Styles.Theme as Theme
import Css exposing (..)
import Css.Global


view accountView =
    ul
    [ class "navigation" ]
    [ viewLink "/account" "ACCOUNT"
    , viewLink "/subsidialis" "SUBSIDIALIS"
    , viewLink "/senatus" "SENATUS"
    , viewLink "/magisterium" "MAGISTERIUM"
    , viewLink "/liquidity" "LIQUIDITY"
    , viewLink "/liquidity" "SWAP"
    , li
          [ class "navigation__item" ]
          [ accountView ]
    ]


viewLink : String -> String -> Html msg
viewLink path content =
    li [ class "navigation__item" ] [ a [ href path ] [ text content ] ]


css =
    [ Css.displayFlex
    , Css.alignItems Css.center
    , Css.justifyContent Css.center
    , Css.Global.descendants
        [ Css.Global.selector ".navigation"
            [ Css.displayFlex
            , Css.alignItems Css.center
            , Css.listStyle Css.none
            , Css.margin Css.zero
            , Css.width <| Css.pct 100
            , Css.Global.descendants
                [ Css.Global.selector ".navigation__item"
                    [ Css.padding <| Css.rem 1
                    , Css.marginLeft <| Css.rem 2
                    , Css.lastOfType
                        [ Css.marginLeft Css.auto
                        , Css.borderRadius (Css.px 100)
                        ]
                    , Breakpoints.small
                        [ Css.padding <| Css.rem 0.3 ]
                    ]
                , Css.Global.selector ".placeholder-rectangle"
                    [ Css.width <| Css.rem 5
                    , Breakpoints.small
                        [ Css.width <| Css.rem 3 ]
                    ]
                ]
            ]
        , Css.Global.selector "a"
            [ color Theme.mirage
            , textDecoration Css.none
            , Fonts.barlowCondensed
            , fontSize (Css.rem 1.5)
            , hover [
                   textDecoration3  Css.underline Css.solid Theme.havelockBlue
              ]
            ]
        , Css.Global.selector ".listElement a"
            [ color Theme.mirage
            , backgroundColor Theme.geyser
            , textDecoration Css.none
            , Fonts.barlowCondensed
            , fontSize (Css.rem 1.25)
            , hover [
                   textDecoration3  Css.underline Css.solid Theme.havelockBlue
              ]
            ]
        ]
    ]    
