module Api exposing (..)

import Generated.Api
import Generated.Api.Data as Data
import Generated.Api.Request.Accounts as Accounts

import Http


localNetworkUrl = "http://localhost:8080/v1" 


-- API


getAccountArxCoinResource matchResult address =
    send localNetworkUrl matchResult 
        (Accounts.getAccountResource address "0x1::coin::CoinStore<0x1::arx_coin::ArxCoin>" Nothing Data.coinStoreDecoder)


getAccountXUSDCoinResource matchResult address =
    send localNetworkUrl matchResult 
        (Accounts.getAccountResource address "0x1::coin::CoinStore<0x1::xusd_coin::XUSDCoin>" Nothing Data.coinStoreDecoder)


getAccounLuxCoinResource matchResult address =
    send localNetworkUrl matchResult 
        (Accounts.getAccountResource address "0x1::coin::CoinStore<0x1::lux_coin::LuxCoin>" Nothing Data.coinStoreDecoder)
    

getAccountNoxCoinResource matchResult address =
    send localNetworkUrl matchResult 
        (Accounts.getAccountResource address "0x1::coin::CoinStore<0x1::nox_coin::NoxCoin>" Nothing Data.coinStoreDecoder)
    

getSubsidialis matchResult =
    send localNetworkUrl matchResult
        (Accounts.getAccountResource "0x1" "0x1::subsidialis::Subsidialis" Nothing Data.subsidialisDecoder)


-- getSenatus matchResult =
--     send "http://localhost:8080/v1" matchResult
--         (Accounts.getAccountResource "0x1" "0x1::senatus::Senatus" Nothing)
    

-- HELPER


send : String -> (Result Http.Error a -> msg) -> Generated.Api.Request a -> Cmd msg
send basePath toMsg request =
    request
        |> Generated.Api.withBasePath basePath
        |> Generated.Api.send toMsg
    
