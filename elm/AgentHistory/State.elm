module AgentHistory.State exposing (init, runCmdDown, subscriptions, update)

import AgentHistory.Types exposing (..)
import Array exposing (Array)
import BigInt exposing (BigInt)
import ChainCmd exposing (ChainCmd)
import CmdDown
import CmdUp
import CommonTypes exposing (..)
import Config exposing (..)
import Contracts.Generated.DAIHardTrade as DHT
import Contracts.Types as CTypes
import Contracts.Wrappers
import Currencies exposing (Price)
import Eth
import Eth.Sentry.Event as EventSentry exposing (EventSentry)
import Eth.Types exposing (Address)
import Filters.State as Filters
import Filters.Types as Filter
import Flip exposing (flip)
import Helpers.BigInt as BigIntHelpers
import Helpers.Eth as EthHelpers
import Helpers.Time as TimeHelpers
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
import Wallet


init : Wallet.State -> Address -> ( Model, Cmd Msg )
init wallet agentAddress =
    ( { wallet = wallet
      , agentAddress = agentAddress
      , filters =
            Filters.init
                [ Filter.phases True True True False
                , Filter.offerType True True
                , Filter.role agentAddress True True
                ]
      , tradeTable =
            TradeTable.init
                ( TradeTable.Phase, TradeTable.Ascending )
      , now = Time.millisToPosix 0
      , prices = []
      }
    , Cmd.none
    )


update : Msg -> Model -> UpdateResult
update msg prevModel =
    case msg of
        Poke address ->
            let
                txParams =
                    DHT.poke
                        address
                        |> Eth.toSend

                customSend =
                    { onMined = Nothing
                    , onSign = Nothing
                    , onBroadcast = Nothing
                    }

                chainCmd =
                    ChainCmd.custom
                        customSend
                        txParams
            in
            UpdateResult
                prevModel
                Cmd.none
                chainCmd
                []

        TradeClicked tradeRef ->
            UpdateResult
                prevModel
                Cmd.none
                ChainCmd.none
                [ CmdUp.GotoRoute (Routing.Trade tradeRef) ]

        FiltersMsg filtersMsg ->
            let
                ( newFilters, cmdUps ) =
                    prevModel.filters |> Filters.update filtersMsg
            in
            UpdateResult
                { prevModel
                    | filters =
                        newFilters
                }
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

        UpdateNow time ->
            justModelUpdate
                { prevModel | now = time }

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

        Refresh ->
            UpdateResult
                prevModel
                (PriceFetch.fetch PricesFetched)
                ChainCmd.none
                []

        NoOp ->
            justModelUpdate prevModel


runCmdDown : CmdDown.CmdDown -> Model -> UpdateResult
runCmdDown cmdDown prevModel =
    case cmdDown of
        CmdDown.UpdateWallet wallet ->
            justModelUpdate { prevModel | wallet = wallet }

        CmdDown.CloseAnyDropdownsOrModals ->
            justModelUpdate prevModel


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 500 UpdateNow
        , Time.every 500000 (always Refresh)
        ]
