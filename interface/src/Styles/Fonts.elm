module Styles.Fonts exposing (..)


import Css exposing (..)


philosopher : Style
philosopher =
    Css.batch
        [ fontFamilies [ "Philosopher" ]
        , fontSize (px 20)
        , fontWeight normal
        ]


barlowCondensed : Style
barlowCondensed =
    Css.batch
        [ fontFamilies [ "Barlow Condensed" ]
        , fontSize (px 20)
        , fontWeight normal
        ]
        

barlowCondensedBold : Style
barlowCondensedBold =
    Css.batch
        [ fontFamilies [ "Barlow Condensed" ]
        , fontSize (px 20)
        , fontWeight bold
        ]
