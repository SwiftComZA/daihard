module Marketplace.State exposing (init, runCmdDown, subscriptions, update)

import Array exposing (Array)
import BigInt exposing (BigInt)
import ChainCmd exposing (ChainCmd)
import CmdDown
import CmdUp
import CommonTypes exposing (..)
import Config
import Contracts.Types as CTypes
import Contracts.Wrappers
import Currencies exposing (Price)
import Dict
import Eth.Sentry.Event as EventSentry exposing (EventSentry)
import Eth.Types exposing (Address)
import Filters.State as Filters
import Filters.Types as Filters
import Flip exposing (flip)
import Helpers.BigInt as BigIntHelpers
import Helpers.Eth as EthHelpers
import Helpers.Time as TimeHelpers
import Marketplace.Types exposing (..)
import PaymentMethods exposing (PaymentMethod)
import PriceFetch
import Routing
import String.Extra
import Time
import TokenValue exposing (TokenValue)
import TradeCache.State as TradeCache
import TradeCache.Types as TradeCache exposing (TradeCache)
import TradeTable.State as TradeTable
import TradeTable.Types as TradeTable
import UserNotice as UN
import Utils
import Wallet


init : Wallet.State -> ( Model, Cmd Msg )
init wallet =
    ( { wallet = wallet
      , tradeTable =
            TradeTable.init
                ( TradeTable.Expires, TradeTable.Ascending )
      , inputs = initialInputs
      , errors = noErrors
      , showCurrencyDropdown = False
      , filters =
            Filters.init
                [ Filters.offerType True True
                , Filters.phases True False False False
                ]
      , filterFunc = baseFilterFunc
      , now = Time.millisToPosix 0
      , prices = []
      }
        |> applyInputs
    , PriceFetch.fetch PricesFetched
    )


initialInputs : SearchInputs
initialInputs =
    { minDai = ""
    , maxDai = ""
    , fiatType = ""
    , paymentMethod = ""
    , paymentMethodTerms = []
    }


update : Msg -> Model -> UpdateResult
update msg prevModel =
    case msg of
        UpdateNow time ->
            justModelUpdate
                { prevModel | now = time }

        Refresh ->
            UpdateResult
                prevModel
                (PriceFetch.fetch PricesFetched)
                ChainCmd.none
                []

        PricesFetched fetchResult ->
            case fetchResult of
                Ok pricesAndTimestamps ->
                    let
                        newPrices : List ( Currencies.Symbol, PriceFetch.PriceData )
                        newPrices =
                            [ ( "AUD", PriceFetch.Ok pricesAndTimestamps.rates.aUD )
                            , ( "CLP", PriceFetch.Ok pricesAndTimestamps.rates.cLP )
                            , ( "EUR", PriceFetch.Ok pricesAndTimestamps.rates.eUR )
                            , ( "IDR", PriceFetch.Ok pricesAndTimestamps.rates.iDR )
                            , ( "KRW", PriceFetch.Ok pricesAndTimestamps.rates.kRW )
                            , ( "NZD", PriceFetch.Ok pricesAndTimestamps.rates.nZD )
                            , ( "RUB", PriceFetch.Ok pricesAndTimestamps.rates.rUB )
                            , ( "TRY", PriceFetch.Ok pricesAndTimestamps.rates.tRY )
                            , ( "BRL", PriceFetch.Ok pricesAndTimestamps.rates.bRL )
                            , ( "CNY", PriceFetch.Ok pricesAndTimestamps.rates.cNY )
                            , ( "GBP", PriceFetch.Ok pricesAndTimestamps.rates.gBP )
                            , ( "ILS", PriceFetch.Ok pricesAndTimestamps.rates.iLS )
                            , ( "MXN", PriceFetch.Ok pricesAndTimestamps.rates.mXN )
                            , ( "PHP", PriceFetch.Ok pricesAndTimestamps.rates.pHP )
                            , ( "SEK", PriceFetch.Ok pricesAndTimestamps.rates.sEK )
                            , ( "TWD", PriceFetch.Ok pricesAndTimestamps.rates.tWD )
                            , ( "CAD", PriceFetch.Ok pricesAndTimestamps.rates.cAD )
                            , ( "CZK", PriceFetch.Ok pricesAndTimestamps.rates.cZK )
                            , ( "HKD", PriceFetch.Ok pricesAndTimestamps.rates.hKD )
                            , ( "INR", PriceFetch.Ok pricesAndTimestamps.rates.iNR )
                            , ( "MYR", PriceFetch.Ok pricesAndTimestamps.rates.mYR )
                            , ( "PKR", PriceFetch.Ok pricesAndTimestamps.rates.pKR )
                            , ( "SGD", PriceFetch.Ok pricesAndTimestamps.rates.sGD )
                            , ( "USD", PriceFetch.Ok pricesAndTimestamps.rates.uSD )
                            , ( "CHF", PriceFetch.Ok pricesAndTimestamps.rates.cHF )
                            , ( "DKK", PriceFetch.Ok pricesAndTimestamps.rates.dKK )
                            , ( "HUF", PriceFetch.Ok pricesAndTimestamps.rates.hUF )
                            , ( "JPY", PriceFetch.Ok pricesAndTimestamps.rates.jPY )
                            , ( "NOK", PriceFetch.Ok pricesAndTimestamps.rates.nOK )
                            , ( "PLN", PriceFetch.Ok pricesAndTimestamps.rates.pLN )
                            , ( "THB", PriceFetch.Ok pricesAndTimestamps.rates.tHB )
                            , ( "ZAR", PriceFetch.Ok pricesAndTimestamps.rates.zAR )
                            , ( "VND", PriceFetch.Ok pricesAndTimestamps.rates.vND )
                            , ( "ZWL", PriceFetch.Ok pricesAndTimestamps.rates.zWL )
                            ]
                    in
                    justModelUpdate
                        { prevModel | prices = newPrices }

                Err httpErr ->
                    justModelUpdate prevModel

        MinDaiChanged input ->
            justModelUpdate
                { prevModel | inputs = prevModel.inputs |> updateMinDaiInput (Utils.filterPositiveNumericInput input) }

        MaxDaiChanged input ->
            justModelUpdate
                { prevModel | inputs = prevModel.inputs |> updateMaxDaiInput (Utils.filterPositiveNumericInput input) }

        FiatTypeInputChanged input ->
            justModelUpdate
                { prevModel | inputs = prevModel.inputs |> updateFiatTypeInput (String.toUpper input) }

        FiatTypeSelected input ->
            UpdateResult
                ({ prevModel
                    | inputs = prevModel.inputs |> updateFiatTypeInput input
                    , showCurrencyDropdown = False
                 }
                    |> applyInputs
                )
                Cmd.none
                ChainCmd.none
                [ CmdUp.gTag "fiat type changed" "input" input 0 ]

        ShowCurrencyDropdown flag ->
            let
                oldInputs =
                    prevModel.inputs
            in
            justModelUpdate
                { prevModel
                    | showCurrencyDropdown = flag
                    , inputs =
                        prevModel.inputs
                            |> updateFiatTypeInput ""
                }

        FiatTypeLostFocus ->
            justModelUpdate
                { prevModel | showCurrencyDropdown = False }

        PaymentMethodInputChanged input ->
            justModelUpdate
                { prevModel | inputs = prevModel.inputs |> updatePaymentMethodInput input }

        AddSearchTerm ->
            UpdateResult
                (prevModel |> addPaymentInputTerm)
                Cmd.none
                ChainCmd.none
                [ CmdUp.gTag "search term added" "input" prevModel.inputs.paymentMethod 0 ]

        RemoveTerm term ->
            justModelUpdate
                (prevModel |> removePaymentInputTerm term)

        ApplyInputs ->
            UpdateResult
                (prevModel |> applyInputs)
                Cmd.none
                ChainCmd.none
                []

        ResetSearch ->
            justModelUpdate
                (prevModel |> resetSearch)

        FiltersMsg filtersMsg ->
            let
                ( newFilters, cmdUps ) =
                    prevModel.filters |> Filters.update filtersMsg
            in
            UpdateResult
                ({ prevModel
                    | filters =
                        newFilters
                 }
                    |> applyInputs
                )
                Cmd.none
                ChainCmd.none
                (List.map
                    (CmdUp.map FiltersMsg)
                    cmdUps
                )

        TradeTableMsg tradeTableMsg ->
            let
                ttUpdateResult =
                    prevModel.tradeTable
                        |> TradeTable.update tradeTableMsg
            in
            UpdateResult
                { prevModel
                    | tradeTable = ttUpdateResult.model
                }
                (Cmd.map TradeTableMsg ttUpdateResult.cmd)
                (ChainCmd.map TradeTableMsg ttUpdateResult.chainCmd)
                (List.map (CmdUp.map TradeTableMsg) ttUpdateResult.cmdUps)

        NoOp ->
            justModelUpdate prevModel

        CmdUp cmdUp ->
            UpdateResult
                prevModel
                Cmd.none
                ChainCmd.none
                [ cmdUp ]


runCmdDown : CmdDown.CmdDown -> Model -> UpdateResult
runCmdDown cmdDown prevModel =
    case cmdDown of
        CmdDown.UpdateWallet wallet ->
            justModelUpdate { prevModel | wallet = wallet }

        CmdDown.CloseAnyDropdownsOrModals ->
            prevModel
                |> update (ShowCurrencyDropdown False)


addPaymentInputTerm : Model -> Model
addPaymentInputTerm model =
    if model.inputs.paymentMethod == "" then
        model

    else
        let
            searchTerm =
                model.inputs.paymentMethod

            newSearchTerms =
                List.append
                    model.inputs.paymentMethodTerms
                    [ searchTerm ]
        in
        { model
            | inputs =
                model.inputs
                    |> updatePaymentMethodInput ""
                    |> updatePaymentMethodTerms newSearchTerms
        }
            |> applyInputs


removePaymentInputTerm : String -> Model -> Model
removePaymentInputTerm term model =
    let
        newTermList =
            model.inputs.paymentMethodTerms
                |> List.filter ((/=) term)
    in
    { model | inputs = model.inputs |> updatePaymentMethodTerms newTermList }
        |> applyInputs


applyInputs : Model -> Model
applyInputs prevModel =
    let
        model =
            prevModel |> addPaymentInputTerm
    in
    case inputsToQuery model.inputs of
        Err errors ->
            { prevModel | errors = errors }

        Ok query ->
            let
                searchTest time trade =
                    case query.paymentMethodTerms of
                        [] ->
                            True

                        terms ->
                            testTextMatch terms trade.terms.paymentMethods

                daiTest trade =
                    (case query.dai.min of
                        Nothing ->
                            True

                        Just min ->
                            TokenValue.compare trade.parameters.tradeAmount min /= LT
                    )
                        && (case query.dai.max of
                                Nothing ->
                                    True

                                Just max ->
                                    TokenValue.compare trade.parameters.tradeAmount max /= GT
                           )

                fiatTest trade =
                    case query.fiatSymbol of
                        Nothing ->
                            True

                        Just symbol ->
                            trade.terms.price.symbol == symbol

                newFilterFunc now trade =
                    baseFilterFunc now trade
                        && searchTest now trade
                        && daiTest trade
                        && fiatTest trade
                        && Filters.filterTrade model.filters trade
            in
            { model
                | filterFunc = newFilterFunc
            }


inputsToQuery : SearchInputs -> Result Errors Query
inputsToQuery inputs =
    Result.map2
        (\minDai maxDai ->
            { dai =
                { min = minDai
                , max = maxDai
                }
            , fiatSymbol =
                String.Extra.nonEmpty inputs.fiatType
            , paymentMethodTerms =
                inputs.paymentMethodTerms
            }
        )
        (interpretDaiAmount inputs.minDai
            |> Result.mapError (\e -> { noErrors | minDai = Just e })
        )
        (interpretDaiAmount inputs.maxDai
            |> Result.mapError (\e -> { noErrors | maxDai = Just e })
        )


interpretDaiAmount : String -> Result String (Maybe TokenValue)
interpretDaiAmount input =
    if input == "" then
        Ok Nothing

    else
        case TokenValue.fromString input of
            Nothing ->
                Err "I can't interpret this number"

            Just value ->
                Ok <| Just value


interpretFiatAmount : String -> Result String (Maybe BigInt)
interpretFiatAmount input =
    if input == "" then
        Ok Nothing

    else
        case BigInt.fromString input of
            Nothing ->
                Err "I don't understand this number."

            Just value ->
                Ok <| Just value


resetSearch : Model -> Model
resetSearch model =
    { model
        | filterFunc = baseFilterFunc
        , inputs = initialInputs
    }
        |> applyInputs


baseFilterFunc : Time.Posix -> CTypes.FullTradeInfo -> Bool
baseFilterFunc now trade =
    TimeHelpers.compare trade.derived.phaseEndTime now == GT


testTextMatch : List String -> List PaymentMethod -> Bool
testTextMatch terms paymentMethods =
    let
        searchForAllTerms searchable =
            terms
                |> List.all
                    (\term ->
                        String.contains
                            (String.toLower term)
                            (String.toLower searchable)
                    )
    in
    paymentMethods
        |> List.any
            (\method ->
                searchForAllTerms method.info
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 500 UpdateNow
        , Time.every 500000 (always Refresh)
        ]
