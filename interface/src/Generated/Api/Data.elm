module Generated.Api.Data exposing (..)


import Json.Decode
import Json.Encode


-- Guid


type alias GuidAddress =
    { addr : String
    , creationNum : String
    }
        

guidAddressDecoder : Json.Decode.Decoder GuidAddress
guidAddressDecoder =
    Json.Decode.succeed GuidAddress
        |> decode "addr" Json.Decode.string
        |> decode "creation_num" Json.Decode.string


type alias Guid =
    { id : GuidAddress }


guidDecoder : Json.Decode.Decoder Guid
guidDecoder =
    Json.Decode.succeed Guid
        |> decode "id" guidAddressDecoder


-- EventObject


type alias EventObject =
    { counter : String
    , guid : Guid
    }


eventObjectDecoder : Json.Decode.Decoder EventObject
eventObjectDecoder =
    Json.Decode.succeed EventObject
        |> decode "counter" Json.Decode.string
        |> decode "guid" guidDecoder


-- CoinStore


type alias CoinValue =
    { value : String }


coinValueDecoder : Json.Decode.Decoder CoinValue
coinValueDecoder =
    Json.Decode.succeed CoinValue
        |> decode "value" Json.Decode.string


type alias CoinStore =
    { coin : CoinValue
    , depositEvents : EventObject
    , frozen : Bool
    , withdrawEvents : EventObject
    }


coinStoreDecoder : Json.Decode.Decoder CoinStore
coinStoreDecoder =
    Json.Decode.succeed CoinStore
        |> decode "coin" coinValueDecoder
        |> decode "deposit_events" eventObjectDecoder
        |> decode "frozen" Json.Decode.bool
        |> decode "withdraw_events" eventObjectDecoder


-- Solaris


type alias Coin =
    { value : String }


coinDecoder : Json.Decode.Decoder Coin
coinDecoder =
    Json.Decode.succeed Coin
        |> decode "value" Json.Decode.string


type alias Solaris =
    { ownerAddress : String
    , activeLux : Coin
    , pendingActiveLux : Coin
    , activeNox : Coin
    , pendingActiveNox : Coin
    , lockedCoins : Coin
    , pendingUnlockedCoins : Coin
    , unlockedCoins : Coin
    , timeRemaining : String
    }


solarisDecoder : Json.Decode.Decoder Solaris
solarisDecoder =
    Json.Decode.succeed Solaris
        |> decode "owner_address" Json.Decode.string
        |> decode "active_lux" coinDecoder
        |> decode "pending_active_lux" coinDecoder
        |> decode "active_nox" coinDecoder
        |> decode "pending_active_nox" coinDecoder
        |> decode "locked_forma" coinDecoder
        |> decode "pending_unlocked_forma" coinDecoder
        |> decode "unlocked_forma" coinDecoder
        |> decode "time_remaining" Json.Decode.string


-- Subsidialis


type alias Subsidialis =
    { active : List String
    , pendingActive : List String
    , pendingInactive : List String
    , totalActivePower : String
    , totalJoiningPower : String
    }

subsidialisDecoder : Json.Decode.Decoder Subsidialis
subsidialisDecoder =
    Json.Decode.succeed Subsidialis
        |> decode "active" (Json.Decode.list Json.Decode.string)
        |> decode "pending_active" (Json.Decode.list Json.Decode.string)
        |> decode "pending_inactive" (Json.Decode.list Json.Decode.string)
        |> decode "total_active_power" Json.Decode.string
        |> decode "total_joining_power" Json.Decode.string


{-| Account data  A simplified version of the onchain Account resource -}
type alias AccountData =
    { sequenceNumber : String
    , authenticationKey : String
    }


encodeAccountData : AccountData -> Json.Encode.Value
encodeAccountData =
    encodeObject << encodeAccountDataPairs


encodeAccountDataWithTag : ( String, String ) -> AccountData -> Json.Encode.Value
encodeAccountDataWithTag (tagField, tag) model =
    encodeObject (encodeAccountDataPairs model ++ [ encode tagField Json.Encode.string tag ])


encodeAccountDataPairs : AccountData -> List EncodedField
encodeAccountDataPairs model =
    let
        pairs =
            [ encode "sequence_number" Json.Encode.string model.sequenceNumber
            , encode "authentication_key" Json.Encode.string model.authenticationKey
            ]
    in
    pairs


accountDataDecoder : Json.Decode.Decoder AccountData
accountDataDecoder =
    Json.Decode.succeed AccountData
        |> decode "sequence_number" Json.Decode.string 
        |> decode "authentication_key" Json.Decode.string 



{-| Move function -}
type alias MoveFunction =
    { name : String
    , visibility : MoveFunctionVisibility
    , isEntry : Bool
    , genericTypeParams : List (MoveFunctionGenericTypeParam)
    , params : List (String)
    , return : List (String)
    }


moveFunctionDecoder : Json.Decode.Decoder MoveFunction
moveFunctionDecoder =
    Json.Decode.succeed MoveFunction
        |> decode "name" Json.Decode.string 
        |> decode "visibility" moveFunctionVisibilityDecoder 
        |> decode "is_entry" Json.Decode.bool 
        |> decode "generic_type_params" (Json.Decode.list moveFunctionGenericTypeParamDecoder) 
        |> decode "params" (Json.Decode.list Json.Decode.string) 
        |> decode "return" (Json.Decode.list Json.Decode.string) 


{-| Move function generic type param -}
type alias MoveFunctionGenericTypeParam =
    { constraints : List (String) }


{-| Move function visibility -}
type MoveFunctionVisibility
    = MoveFunctionVisibilityPrivate
    | MoveFunctionVisibilityPublic
    | MoveFunctionVisibilityFriend


moveFunctionVisibilityVariants : List MoveFunctionVisibility
moveFunctionVisibilityVariants =
    [ MoveFunctionVisibilityPrivate
    , MoveFunctionVisibilityPublic
    , MoveFunctionVisibilityFriend
    ]


encodeMoveFunction : MoveFunction -> Json.Encode.Value
encodeMoveFunction =
    encodeObject << encodeMoveFunctionPairs


encodeMoveFunctionWithTag : ( String, String ) -> MoveFunction -> Json.Encode.Value
encodeMoveFunctionWithTag (tagField, tag) model =
    encodeObject (encodeMoveFunctionPairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveFunctionPairs : MoveFunction -> List EncodedField
encodeMoveFunctionPairs model =
    let
        pairs =
            [ encode "name" Json.Encode.string model.name
            , encode "visibility" encodeMoveFunctionVisibility model.visibility
            , encode "is_entry" Json.Encode.bool model.isEntry
            , encode "generic_type_params" (Json.Encode.list encodeMoveFunctionGenericTypeParam) model.genericTypeParams
            , encode "params" (Json.Encode.list Json.Encode.string) model.params
            , encode "return" (Json.Encode.list Json.Encode.string) model.return
            ]
    in
    pairs


encodeMoveFunctionGenericTypeParam : MoveFunctionGenericTypeParam -> Json.Encode.Value
encodeMoveFunctionGenericTypeParam =
    encodeObject << encodeMoveFunctionGenericTypeParamPairs


encodeMoveFunctionGenericTypeParamWithTag : ( String, String ) -> MoveFunctionGenericTypeParam -> Json.Encode.Value
encodeMoveFunctionGenericTypeParamWithTag (tagField, tag) model =
    encodeObject (encodeMoveFunctionGenericTypeParamPairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveFunctionGenericTypeParamPairs : MoveFunctionGenericTypeParam -> List EncodedField
encodeMoveFunctionGenericTypeParamPairs model =
    let
        pairs =
            [ encode "constraints" (Json.Encode.list Json.Encode.string) model.constraints
            ]
    in
    pairs


stringFromMoveFunctionVisibility : MoveFunctionVisibility -> String
stringFromMoveFunctionVisibility model =
    case model of
        MoveFunctionVisibilityPrivate ->
            "private"

        MoveFunctionVisibilityPublic ->
            "public"

        MoveFunctionVisibilityFriend ->
            "friend"


encodeMoveFunctionVisibility : MoveFunctionVisibility -> Json.Encode.Value
encodeMoveFunctionVisibility =
    Json.Encode.string << stringFromMoveFunctionVisibility


moveFunctionGenericTypeParamDecoder : Json.Decode.Decoder MoveFunctionGenericTypeParam
moveFunctionGenericTypeParamDecoder =
    Json.Decode.succeed MoveFunctionGenericTypeParam
        |> decode "constraints" (Json.Decode.list Json.Decode.string) 


moveFunctionVisibilityDecoder : Json.Decode.Decoder MoveFunctionVisibility
moveFunctionVisibilityDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                case value of
                    "private" ->
                        Json.Decode.succeed MoveFunctionVisibilityPrivate

                    "public" ->
                        Json.Decode.succeed MoveFunctionVisibilityPublic

                    "friend" ->
                        Json.Decode.succeed MoveFunctionVisibilityFriend

                    other ->
                        Json.Decode.fail <| "Unknown type: " ++ other
            )


{-| A Move module -}
type alias MoveModule =
    { address : String
    , name : String
    , friends : List (String)
    , exposedFunctions : List (MoveFunction)
    , structs : List (MoveStruct)
    }


{-| Move module bytecode along with it's ABI -}
type alias MoveModuleBytecode =
    { bytecode : String
    , abi : Maybe MoveModule
    }


encodeMoveModule : MoveModule -> Json.Encode.Value
encodeMoveModule =
    encodeObject << encodeMoveModulePairs


encodeMoveModuleWithTag : ( String, String ) -> MoveModule -> Json.Encode.Value
encodeMoveModuleWithTag (tagField, tag) model =
    encodeObject (encodeMoveModulePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveModulePairs : MoveModule -> List EncodedField
encodeMoveModulePairs model =
    let
        pairs =
            [ encode "address" Json.Encode.string model.address
            , encode "name" Json.Encode.string model.name
            , encode "friends" (Json.Encode.list Json.Encode.string) model.friends
            , encode "exposed_functions" (Json.Encode.list encodeMoveFunction) model.exposedFunctions
            , encode "structs" (Json.Encode.list encodeMoveStruct) model.structs
            ]
    in
    pairs


encodeMoveModuleBytecode : MoveModuleBytecode -> Json.Encode.Value
encodeMoveModuleBytecode =
    encodeObject << encodeMoveModuleBytecodePairs


encodeMoveModuleBytecodeWithTag : ( String, String ) -> MoveModuleBytecode -> Json.Encode.Value
encodeMoveModuleBytecodeWithTag (tagField, tag) model =
    encodeObject (encodeMoveModuleBytecodePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveModuleBytecodePairs : MoveModuleBytecode -> List EncodedField
encodeMoveModuleBytecodePairs model =
    let
        pairs =
            [ encode "bytecode" Json.Encode.string model.bytecode
            , maybeEncode "abi" encodeMoveModule model.abi
            ]
    in
    pairs


moveModuleDecoder : Json.Decode.Decoder MoveModule
moveModuleDecoder =
    Json.Decode.succeed MoveModule
        |> decode "address" Json.Decode.string 
        |> decode "name" Json.Decode.string 
        |> decode "friends" (Json.Decode.list Json.Decode.string) 
        |> decode "exposed_functions" (Json.Decode.list moveFunctionDecoder) 
        |> decode "structs" (Json.Decode.list moveStructDecoder) 


moveModuleBytecodeDecoder : Json.Decode.Decoder MoveModuleBytecode
moveModuleBytecodeDecoder =
    Json.Decode.succeed MoveModuleBytecode
        |> decode "bytecode" Json.Decode.string 
        |> maybeDecode "abi" moveModuleDecoder Nothing


-- MoveResource

type alias MoveResource object =
    { type_ : String
    , data : object
    }


encodeMoveResource : MoveResource object -> (object -> List EncodedField) -> Json.Encode.Value
encodeMoveResource model toFields =
    encodeObject (encodeMoveResourcePairs model toFields)


encodeMoveResourceWithTag : ( String, String ) -> MoveResource object -> (object -> List EncodedField) -> Json.Encode.Value
encodeMoveResourceWithTag (tagField, tag) model toFields =
    encodeObject (encodeMoveResourcePairs model toFields ++ [ encode tagField Json.Encode.string tag ])


encodeMoveResourcePairs : MoveResource object -> (object -> List EncodedField) -> List EncodedField
encodeMoveResourcePairs model toFields =
    let
        pairs =
            [ encode "type" Json.Encode.string model.type_
            , encode "data" encodeObject (toFields model.data)
            ]
    in
    pairs


moveResourceDecoder : Json.Decode.Decoder object -> Json.Decode.Decoder (MoveResource object)
moveResourceDecoder objectDecoder =
    Json.Decode.succeed MoveResource
        |> decode "type" Json.Decode.string 
        |> decode "data" objectDecoder 


{-| A move struct -}
type alias MoveStruct =
    { name : String
    , isNative : Bool
    , abilities : List (String)
    , genericTypeParams : List (MoveStructGenericTypeParam)
    , fields : List (MoveStructField)
    }


{-| Move struct field -}
type alias MoveStructField =
    { name : String
    , type_ : String
    }


{-| Move generic type param -}
type alias MoveStructGenericTypeParam =
    { constraints : List (String)
    }


encodeMoveStruct : MoveStruct -> Json.Encode.Value
encodeMoveStruct =
    encodeObject << encodeMoveStructPairs


encodeMoveStructWithTag : ( String, String ) -> MoveStruct -> Json.Encode.Value
encodeMoveStructWithTag (tagField, tag) model =
    encodeObject (encodeMoveStructPairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveStructPairs : MoveStruct -> List EncodedField
encodeMoveStructPairs model =
    let
        pairs =
            [ encode "name" Json.Encode.string model.name
            , encode "is_native" Json.Encode.bool model.isNative
            , encode "abilities" (Json.Encode.list Json.Encode.string) model.abilities
            , encode "generic_type_params" (Json.Encode.list encodeMoveStructGenericTypeParam) model.genericTypeParams
            , encode "fields" (Json.Encode.list encodeMoveStructField) model.fields
            ]
    in
    pairs


encodeMoveStructField : MoveStructField -> Json.Encode.Value
encodeMoveStructField =
    encodeObject << encodeMoveStructFieldPairs


encodeMoveStructFieldWithTag : ( String, String ) -> MoveStructField -> Json.Encode.Value
encodeMoveStructFieldWithTag (tagField, tag) model =
    encodeObject (encodeMoveStructFieldPairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveStructFieldPairs : MoveStructField -> List EncodedField
encodeMoveStructFieldPairs model =
    let
        pairs =
            [ encode "name" Json.Encode.string model.name
            , encode "type" Json.Encode.string model.type_
            ]
    in
    pairs


encodeMoveStructGenericTypeParam : MoveStructGenericTypeParam -> Json.Encode.Value
encodeMoveStructGenericTypeParam =
    encodeObject << encodeMoveStructGenericTypeParamPairs


encodeMoveStructGenericTypeParamWithTag : ( String, String ) -> MoveStructGenericTypeParam -> Json.Encode.Value
encodeMoveStructGenericTypeParamWithTag (tagField, tag) model =
    encodeObject (encodeMoveStructGenericTypeParamPairs model ++ [ encode tagField Json.Encode.string tag ])


encodeMoveStructGenericTypeParamPairs : MoveStructGenericTypeParam -> List EncodedField
encodeMoveStructGenericTypeParamPairs model =
    let
        pairs =
            [ encode "constraints" (Json.Encode.list Json.Encode.string) model.constraints
            ]
    in
    pairs


moveStructDecoder : Json.Decode.Decoder MoveStruct
moveStructDecoder =
    Json.Decode.succeed MoveStruct
        |> decode "name" Json.Decode.string 
        |> decode "is_native" Json.Decode.bool 
        |> decode "abilities" (Json.Decode.list Json.Decode.string) 
        |> decode "generic_type_params" (Json.Decode.list moveStructGenericTypeParamDecoder) 
        |> decode "fields" (Json.Decode.list moveStructFieldDecoder) 


moveStructFieldDecoder : Json.Decode.Decoder MoveStructField
moveStructFieldDecoder =
    Json.Decode.succeed MoveStructField
        |> decode "name" Json.Decode.string 
        |> decode "type" Json.Decode.string 


moveStructGenericTypeParamDecoder : Json.Decode.Decoder MoveStructGenericTypeParam
moveStructGenericTypeParamDecoder =
    Json.Decode.succeed MoveStructGenericTypeParam
        |> decode "constraints" (Json.Decode.list Json.Decode.string) 


-- HELPERS


type alias EncodedField =
    Maybe ( String, Json.Encode.Value )


encodeObject : List EncodedField -> Json.Encode.Value
encodeObject =
    Json.Encode.object << List.filterMap identity


encode : String -> (a -> Json.Encode.Value) -> a -> EncodedField
encode key encoder value =
    Just ( key, encoder value )


encodeNullable : String -> (a -> Json.Encode.Value) -> Maybe a -> EncodedField
encodeNullable key encoder value =
    Just ( key, Maybe.withDefault Json.Encode.null (Maybe.map encoder value) )


maybeEncode : String -> (a -> Json.Encode.Value) -> Maybe a -> EncodedField
maybeEncode key encoder =
    Maybe.map (Tuple.pair key << encoder)


maybeEncodeNullable : String -> (a -> Json.Encode.Value) -> Maybe a -> EncodedField
maybeEncodeNullable =
    encodeNullable


decode : String -> Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b
decode key decoder =
    decodeChain (Json.Decode.field key decoder)


decodeLazy : (a -> c) -> String -> Json.Decode.Decoder a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
decodeLazy f key decoder =
    decodeChainLazy f (Json.Decode.field key decoder)


decodeNullable : String -> Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
decodeNullable key decoder =
    decodeChain (maybeField key decoder Nothing)


decodeNullableLazy : (Maybe a -> c) -> String -> Json.Decode.Decoder a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
decodeNullableLazy f key decoder =
    decodeChainLazy f (maybeField key decoder Nothing)


maybeDecode : String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
maybeDecode key decoder fallback =
    -- let's be kind to null-values as well
    decodeChain (maybeField key decoder fallback)


maybeDecodeLazy : (Maybe a -> c) -> String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
maybeDecodeLazy f key decoder fallback =
    -- let's be kind to null-values as well
    decodeChainLazy f (maybeField key decoder fallback)


maybeDecodeNullable : String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
maybeDecodeNullable key decoder fallback =
    decodeChain (maybeField key decoder fallback)


maybeDecodeNullableLazy : (Maybe a -> c) -> String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
maybeDecodeNullableLazy f key decoder fallback =
    decodeChainLazy f (maybeField key decoder fallback)


maybeField : String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (Maybe a)
maybeField key decoder fallback =
    let
        fieldDecoder =
            Json.Decode.field key Json.Decode.value

        valueDecoder =
            Json.Decode.oneOf [ Json.Decode.map Just decoder, Json.Decode.null fallback ]

        decodeRawObject rawObject =
            case Json.Decode.decodeValue fieldDecoder rawObject of
                Ok rawValue ->
                    case Json.Decode.decodeValue valueDecoder rawValue of
                        Ok value ->
                            Json.Decode.succeed value

                        Err error ->
                            Json.Decode.fail (Json.Decode.errorToString error)

                Err _ ->
                    Json.Decode.succeed fallback
    in
    Json.Decode.value
        |> Json.Decode.andThen decodeRawObject


decodeChain : Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b
decodeChain =
    Json.Decode.map2 (|>)


decodeChainLazy : (a -> c) -> Json.Decode.Decoder a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
decodeChainLazy f =
    decodeChain << Json.Decode.map f
