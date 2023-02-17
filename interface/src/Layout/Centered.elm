module Layout.Centered exposing (..)


import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr


-- LAYOUT


view content =
    Html.div []
        [ Html.div [ Attr.css containerStyle ]
          [ Html.div [ Attr.css leftStyle ] [ ]
          , Html.div [ Attr.css middleStyle ]
              content
          , Html.div [ Attr.css rightStyle ] [ ]
          ]
        ]


formView content =
    Html.div []
        [ Html.div [ Attr.css formContainerStyle ]
          [ Html.div [ Attr.css formLeftStyle ] [ ]
          , Html.div [ Attr.css formMiddleStyle ]
              content
          , Html.div [ Attr.css formRightStyle ] [ ]
          ]
        ]


-- STYLE


-- Layout with one central element


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
    ]


middleStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 2
    , Css.margin (Css.rem 1)
    ]


rightStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.margin (Css.rem 1)
    ]


-- Layout with one central element for forms


formContainerStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.row
    , Css.margin (Css.rem 1) 
    ]


formLeftStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 2
    , Css.margin (Css.rem 1)
    ]


formMiddleStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 1
    , Css.margin (Css.rem 1)
    ]


formRightStyle =
    [ Css.displayFlex
    , Css.flexDirection Css.column
    , Css.flexGrow <| Css.int 2
    , Css.margin (Css.rem 1)
    ]
    
