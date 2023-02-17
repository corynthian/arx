module Styles.Elements exposing (..)


import Css exposing (..)
import Html.Styled exposing (..)
import Styles.Fonts as Fonts
import Styles.Theme as Theme


btn =
    styled button
        [ margin (px 12)
        , padding (px 12)
        , border (px 0)
        , borderRadius (px 6)
        , Fonts.barlowCondensed
        , color Theme.geyser
        , backgroundColor Theme.mirage
        -- , hover [  ]
        ]


listElement =
    styled li
        [ margin (px 12)
        , padding (px 12)
        , border (px 0)
        , borderRadius (px 32)
        , Fonts.barlowCondensed
        --, backgroundColor Theme.primary
        ]


formStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.backgroundColor Theme.white
    , Css.flexGrow <| Css.int 1
    , Css.borderRadius <| Css.rem 1
    , Css.marginBottom <| Css.px 3
    ]


formLeftStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.flexGrow <| Css.int 1
    , Css.alignItems Css.center
    , Css.justifyContent Css.center
--    , Css.width <| Css.pct 20
    , Css.backgroundColor Theme.mirage
    , Css.color Theme.geyser
    , Css.padding <| Css.rem 1
    , Css.borderRadius4 (Css.px 10) (Css.px 0) (Css.px 0) (Css.px 0)
    ]


formRightStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.flexGrow <| Css.int 3
    , Css.alignItems Css.center
    , Css.justifyContent Css.left
    , Css.backgroundColor Theme.white
--    , Css.width <| Css.pct 20
    , Css.padding <| Css.rem 1
    ]
