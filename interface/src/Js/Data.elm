module Js.Data exposing (..)


import Dict
import Json.Decode as D
import Json.Encode as E


-- ArxAccountObject


type alias ArxAccountObject =
    { address : String
    , publicKeyHex : String
    , privateKeyHex : String
    }


arxAccountObjectDecoder : D.Decoder ArxAccountObject
arxAccountObjectDecoder =
    D.map3 ArxAccountObject
        (D.field "address" D.string)
        (D.field "publicKeyHex" D.string)
        (D.field "privateKeyHex" D.string)


encodeArxAccountObject accountObject =
    E.object
        [ ( "address", E.string accountObject.address )
        , ( "publicKeyHex", E.string accountObject.publicKeyHex )
        , ( "privateKeyHex", E.string accountObject.privateKeyHex )
        ]
