module Styles.Elements exposing (..)


import Css exposing (..)
import Html.Styled exposing (..)
import Styles.Fonts as Fonts
import Styles.Theme as Theme


btn =
    styled button
        [ margin (px 12)
        , color Theme.havelockBlue
        , padding (px 12)
        , border (px 0)
        , borderRadius (px 6)
        , Fonts.barlowCondensed
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
