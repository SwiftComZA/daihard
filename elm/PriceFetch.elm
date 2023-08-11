module PriceFetch exposing (PriceAndTimestamp, PriceData(..), checkAgainstTime, fetch, getPriceData, priceDataToMaybe)

import CommonTypes exposing (..)
import Currencies
import Dict exposing (Dict)
import Helpers.Decoders.CurrencyRatesDecoder as CurrencyRatesDecoder
import Helpers.Time as TimeHelpers
import Http
import Iso8601
import Json.Decode
import Time


type alias PriceAndTimestamp =
    { price : Float
    , timestamp : Time.Posix
    }


type PriceData
    = Ok Float
    | Outdated


fetch : (Result Http.Error CurrencyRatesDecoder.Root -> msg) -> Cmd msg
fetch msgConstructor =
    Http.request
        { method = "GET"
        , headers = []
        , url = "https://openexchangerates.org/api/latest.json?app_id=e89c9afecc7d4d268f3fe19d83a10414"
        , body = Http.emptyBody
        , expect = Http.expectJson msgConstructor CurrencyRatesDecoder.rootDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


checkAgainstTime : Time.Posix -> PriceAndTimestamp -> PriceData
checkAgainstTime now priceAndTimestamp =
    let
        isStale =
            TimeHelpers.compare
                (TimeHelpers.sub
                    now
                    priceAndTimestamp.timestamp
                )
                (Time.millisToPosix <| 1000 * 60 * 10)
                == GT
    in
    if isStale then
        Outdated

    else
        Ok priceAndTimestamp.price


responseDecoder : Json.Decode.Decoder (List ( Currencies.Symbol, PriceAndTimestamp ))
responseDecoder =
    Json.Decode.dict dataToPriceTupleDecoder
        |> Json.Decode.map Dict.values


dataToPriceTupleDecoder : Json.Decode.Decoder ( Currencies.Symbol, PriceAndTimestamp )
dataToPriceTupleDecoder =
    Json.Decode.map2
        Tuple.pair
        (Json.Decode.field "symbol" Json.Decode.string)
        (Json.Decode.field "quote" <|
            Json.Decode.field "USD" <|
                Json.Decode.map2
                    PriceAndTimestamp
                    (Json.Decode.field "price" Json.Decode.float)
                    (Json.Decode.field "last_updated" Iso8601.decoder)
        )


getPriceData : Currencies.Symbol -> List ( Currencies.Symbol, PriceData ) -> Maybe PriceData
getPriceData symbol prices =
    if symbol == "USD" then
        Just <| Ok 1.0

    else
        prices
            |> List.filter (Tuple.first >> (==) symbol)
            |> List.head
            |> Maybe.map Tuple.second


priceDataToMaybe : PriceData -> Maybe Float
priceDataToMaybe priceData =
    case priceData of
        Ok p ->
            Just p

        _ ->
            Nothing
