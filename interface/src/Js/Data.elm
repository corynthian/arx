module Js.Data exposing (..)


import Json.Decode as D


-- ArxAccount


type alias SigningKey =
    { publicKey : List (String, Int)
    , secretKey : List (String, Int)
    }


type alias AccountAddress =
    { hexString : String }


type alias ArxAccount =
    { signingKey : SigningKey
    , accountAddress : AccountAddress
    }


arxAccountDecoder : D.Decoder ArxAccount
arxAccountDecoder =
    D.map2 ArxAccount
        (D.field "signingKey" signingKeyDecoder)
        (D.field "accountAddress" accountAddressDecoder)


signingKeyDecoder : D.Decoder SigningKey
signingKeyDecoder =
    D.map2 SigningKey
        (D.field "publicKey" (D.keyValuePairs D.int))
        (D.field "secretKey" (D.keyValuePairs D.int))


accountAddressDecoder : D.Decoder AccountAddress
accountAddressDecoder =
    D.map AccountAddress
        (D.field "hexString" D.string)
