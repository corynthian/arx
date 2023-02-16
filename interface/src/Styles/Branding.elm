module Styles.Branding exposing (logo)


import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href, src)
import Css exposing (..)


logo =
    img [ src "/static/arx_brand.png"
        , css
            [ display inlineBlock
            , width (px 80)
            , height (px 80)
            , padding (rem 0.5)
            --, border3 (px 1) solid (rgb 120 120 120)
            --, borderRadius (px 5)
            ]
        ]
        []
