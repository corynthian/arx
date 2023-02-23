port module Js exposing (..)


import Js.Data
import Json.Encode
import Json.Decode


-- PORTS


port sendCommand : Json.Encode.Value -> Cmd msg
port receiveResult : (Json.Decode.Value -> msg) -> Sub msg


-- MODEL


type alias Model =
    { }


-- UPDATE


type Command =
  -- Asks JS to retrieve an account from local storage
    FetchAccount
  -- Asks JS to generate a new random account
  | GenerateAccount
  -- Asks JS to mint new coins on local / testnet to designated account
  | Faucet String Int
  | GetSolaris Js.Data.ArxAccountObject
  -- Asks JS to request to join an account to the subsidialis
  | SubsidialisJoin Js.Data.ArxAccountObject
  -- Asks JS to request to add coins to a subsidialis
  | SubsidialisAddCoins Js.Data.ArxAccountObject Int


type Result =
    Fetched (Maybe Js.Data.ArxAccountObject)
  | Account Js.Data.ArxAccountObject
  | Hashes (List String)
  | TxnHash String
  | Error String


-- HELPERS


encodeCommand : Command -> Json.Encode.Value
encodeCommand cmd =
    case cmd of
        FetchAccount ->
            Json.Encode.object [ ("commandType", Json.Encode.string "fetchAccount") ]
        GenerateAccount ->
            Json.Encode.object [ ("commandType", Json.Encode.string "generateAccount") ]
        Faucet address amount ->
            Json.Encode.object
                [ ("commandType", Json.Encode.string "faucetArxCoin")
                , ("address", Json.Encode.string address)
                , ("amount", Json.Encode.int amount)
                ]
        GetSolaris arxAccount ->
            Json.Encode.object
                [ ("commandType", Json.Encode.string "getSolaris")
                , ("account", Js.Data.encodeArxAccountObject arxAccount)
                ]
        SubsidialisJoin arxAccount ->
            Json.Encode.object
                [ ("commandType", Json.Encode.string "subsidialisJoin")
                , ("account", Js.Data.encodeArxAccountObject arxAccount)
                ]
        SubsidialisAddCoins arxAccount amount ->
            Json.Encode.object
                [ ("commandType", Json.Encode.string "subsidialisAddCoins")
                , ("account", Js.Data.encodeArxAccountObject arxAccount)
                , ("amount", Json.Encode.int amount)
                ]


fetchedDecoder : Json.Decode.Decoder Result
fetchedDecoder =
    Json.Decode.map Fetched
        (Json.Decode.field "account" (Json.Decode.maybe Js.Data.arxAccountObjectDecoder))


accountDecoder : Json.Decode.Decoder Result
accountDecoder =
    Json.Decode.map Account (Json.Decode.field "account" Js.Data.arxAccountObjectDecoder)


hashesDecoder : Json.Decode.Decoder Result
hashesDecoder =
    Json.Decode.map Hashes (Json.Decode.field "hashes" (Json.Decode.list Json.Decode.string))


hashDecoder =
    Json.Decode.map TxnHash (Json.Decode.field "hash" Json.Decode.string)


decodeResult res =
    case Json.Decode.decodeValue (Json.Decode.field "resultType" Json.Decode.string) res of
        Ok resultType ->
            case resultType of
                "fetched" ->
                    case Json.Decode.decodeValue fetchedDecoder res of
                        Ok fetched ->
                            fetched
                        Err err ->
                            Error (Json.Decode.errorToString err)
                "account" ->
                    case Json.Decode.decodeValue accountDecoder res of
                        Ok account ->
                            account
                        Err err ->
                            Error (Json.Decode.errorToString err)
                "hashes" ->
                    case Json.Decode.decodeValue hashesDecoder res of
                        Ok hashes ->
                            hashes
                        Err err ->
                            Error (Json.Decode.errorToString err)
                "hash" ->
                    case Json.Decode.decodeValue hashDecoder res of
                        Ok hash ->
                            hash
                        Err err ->
                            Error (Json.Decode.errorToString err)
                _ ->
                    Error "Unsupported result type"
        Err err ->
            Error (Json.Decode.errorToString err)
