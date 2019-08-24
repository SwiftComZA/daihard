module CryptoSwap.State exposing (init, runCmdDown, subscriptions, update)

import Base58
import BigInt exposing (BigInt)
import ChainCmd exposing (ChainCmd)
import CmdDown
import CmdUp exposing (CmdUp)
import CommonTypes exposing (..)
import Config
import Contracts.Generated.ERC20Token as TokenContract
import Contracts.Types as CTypes
import Contracts.Wrappers
import CryptoSwap.Types exposing (..)
import Dict
import Eth
import Helpers.BigInt as BigIntHelpers
import Helpers.Time as TimeHelpers
import PriceFetch
import Routing
import Time
import TokenValue exposing (TokenValue)
import UserNotice as UN exposing (UserNotice)
import Wallet


init : Wallet.State -> UpdateResult
init wallet =
    { wallet = wallet
    , initiatorRole = Seller
    , amountInInput = ""
    , amountIn = Nothing
    , dhToken =
        Wallet.factory wallet
            |> Maybe.withDefault (Native XDai)
    , foreignCrypto = ZEC
    , marginInput = "2"
    , margin = Nothing
    , amountOut = Nothing
    , receiveAddress = ""
    , showDhTokenDropdown = False
    , showForeignCryptoDropdown = False
    , errors = noErrors
    , txChainStatus = Nothing
    , depositAmount = Nothing
    , allowance = Nothing
    , prices = []
    , now = Time.millisToPosix 0
    }
        |> applyInputs
        |> update Refresh


update : Msg -> Model -> UpdateResult
update msg prevModel =
    case msg of
        UpdateNow time ->
            justModelUpdate
                { prevModel | now = time }

        Refresh ->
            let
                maybeAllowanceCmd =
                    case ( Wallet.userInfo prevModel.wallet, Wallet.factory prevModel.wallet ) of
                        ( Just userInfo, Just (Token tokenType) ) ->
                            Contracts.Wrappers.getAllowanceCmd
                                tokenType
                                userInfo.address
                                (Config.factoryAddress (Token tokenType))
                                (AllowanceFetched tokenType)

                        _ ->
                            Cmd.none

                fetchExchangeRateCmd =
                    PriceFetch.fetch PricesFetched
            in
            UpdateResult
                prevModel
                (Cmd.batch
                    [ maybeAllowanceCmd
                    , fetchExchangeRateCmd
                    ]
                )
                ChainCmd.none
                []

        PricesFetched fetchResult ->
            case fetchResult of
                Ok pricesAndTimestamps ->
                    let
                        newPrices =
                            pricesAndTimestamps
                                |> List.map
                                    (Tuple.mapSecond
                                        (\priceAndTimestamp ->
                                            PriceInfo
                                                priceAndTimestamp.price
                                                (TimeHelpers.compare
                                                    (TimeHelpers.sub
                                                        prevModel.now
                                                        priceAndTimestamp.timestamp
                                                    )
                                                    (Time.millisToPosix <| 1000 * 60 * 6)
                                                    == GT
                                                )
                                        )
                                    )
                    in
                    justModelUpdate
                        { prevModel | prices = newPrices }

                Err httpErr ->
                    UpdateResult
                        prevModel
                        Cmd.none
                        ChainCmd.none
                        [ CmdUp.UserNotice UN.cantFetchPrices ]

        AmountInChanged input ->
            justModelUpdate
                ({ prevModel
                    | amountInInput = input
                 }
                    |> applyInputs
                )

        MarginChanged input ->
            justModelUpdate
                ({ prevModel
                    | marginInput = input
                 }
                    |> applyInputs
                )

        SwapClicked ->
            justModelUpdate
                ({ prevModel
                    | initiatorRole =
                        case prevModel.initiatorRole of
                            Buyer ->
                                Seller

                            Seller ->
                                Buyer
                 }
                    |> applyInputs
                )

        TokenTypeClicked ->
            justModelUpdate
                ({ prevModel
                    | showDhTokenDropdown =
                        not prevModel.showDhTokenDropdown
                 }
                    |> applyInputs
                )

        ChangeTokenType factory ->
            justModelUpdate
                ({ prevModel
                    | dhToken = factory
                    , showDhTokenDropdown = False
                 }
                    |> applyInputs
                )

        ForeignCryptoTypeClicked ->
            justModelUpdate
                ({ prevModel
                    | showForeignCryptoDropdown =
                        not prevModel.showForeignCryptoDropdown
                 }
                    |> applyInputs
                )

        ChangeForeignCrypto crypto ->
            justModelUpdate
                ({ prevModel
                    | foreignCrypto = crypto
                    , showForeignCryptoDropdown = False
                 }
                    |> applyInputs
                )

        ReceiveAddressChanged input ->
            justModelUpdate
                ({ prevModel
                    | receiveAddress =
                        input
                 }
                    |> applyInputs
                )

        PlaceOrderClicked factoryType userInfo userParameters ->
            let
                createParameters =
                    CTypes.buildCreateParameters userInfo userParameters
            in
            justModelUpdate
                { prevModel
                    | txChainStatus = Just <| Confirm factoryType createParameters
                    , depositAmount =
                        Just <|
                            (CTypes.calculateFullInitialDeposit createParameters
                                |> TokenValue.getEvmValue
                            )
                }

        AbortCreate ->
            UpdateResult
                { prevModel | txChainStatus = Nothing }
                Cmd.none
                ChainCmd.none
                [ CmdUp.gTag "abort" "abort" "create" 0 ]

        ConfirmCreate factoryType createParameters fullDepositAmount ->
            let
                ( txChainStatus, chainCmd ) =
                    case factoryType of
                        Native _ ->
                            initiateCreateCall factoryType createParameters

                        Token tokenType ->
                            let
                                approveChainCmd =
                                    let
                                        txParams =
                                            TokenContract.approve
                                                (Config.tokenContractAddress tokenType)
                                                (Config.factoryAddress factoryType)
                                                fullDepositAmount
                                                |> Eth.toSend

                                        customSend =
                                            { onMined = Nothing
                                            , onSign = Just (ApproveSigned tokenType createParameters)
                                            , onBroadcast = Nothing
                                            }
                                    in
                                    ChainCmd.custom customSend txParams
                            in
                            case prevModel.allowance of
                                Just allowance ->
                                    if BigInt.compare allowance fullDepositAmount /= LT then
                                        initiateCreateCall factoryType createParameters

                                    else
                                        ( Just (ApproveNeedsSig tokenType), approveChainCmd )

                                Nothing ->
                                    ( Just (ApproveNeedsSig tokenType), approveChainCmd )
            in
            UpdateResult
                { prevModel | txChainStatus = txChainStatus }
                Cmd.none
                chainCmd
                []

        ApproveSigned tokenType createParameters result ->
            case result of
                Ok txHash ->
                    justModelUpdate { prevModel | txChainStatus = Just <| ApproveMining tokenType createParameters txHash }

                Err s ->
                    UpdateResult
                        { prevModel | txChainStatus = Nothing }
                        Cmd.none
                        ChainCmd.none
                        [ CmdUp.UserNotice <| UN.web3SigError "appove" s ]

        AllowanceFetched tokenType fetchResult ->
            case fetchResult of
                Ok allowance ->
                    let
                        newModel =
                            { prevModel
                                | allowance = Just allowance
                            }
                    in
                    case ( newModel.txChainStatus, newModel.depositAmount ) of
                        ( Just (ApproveMining _ createParameters _), Just depositAmount ) ->
                            if BigInt.compare allowance depositAmount /= LT then
                                let
                                    ( txChainStatus, chainCmd ) =
                                        initiateCreateCall (Token tokenType) createParameters
                                in
                                UpdateResult
                                    { newModel | txChainStatus = txChainStatus }
                                    Cmd.none
                                    chainCmd
                                    []

                            else
                                justModelUpdate newModel

                        _ ->
                            justModelUpdate newModel

                Err httpError ->
                    UpdateResult
                        prevModel
                        Cmd.none
                        ChainCmd.none
                        [ CmdUp.UserNotice <| UN.web3FetchError "allowance" httpError ]

        CreateSigned factoryType result ->
            case result of
                Ok txHash ->
                    justModelUpdate { prevModel | txChainStatus = Just <| CreateMining factoryType txHash }

                Err s ->
                    UpdateResult
                        { prevModel | txChainStatus = Nothing }
                        Cmd.none
                        ChainCmd.none
                        [ CmdUp.UserNotice <| UN.web3SigError "create" s ]

        CreateMined factoryType (Err s) ->
            UpdateResult
                prevModel
                Cmd.none
                ChainCmd.none
                [ CmdUp.UserNotice <| UN.web3MiningError "create" s ]

        CreateMined factory (Ok txReceipt) ->
            let
                maybeId =
                    CTypes.txReceiptToCreatedTradeSellId factory txReceipt
                        |> Result.toMaybe
                        |> Maybe.andThen BigIntHelpers.toInt
            in
            case maybeId of
                Just id ->
                    UpdateResult
                        prevModel
                        Cmd.none
                        ChainCmd.none
                        [ CmdUp.GotoRoute (Routing.Trade factory id) ]

                Nothing ->
                    UpdateResult
                        prevModel
                        Cmd.none
                        ChainCmd.none
                        [ CmdUp.UserNotice <|
                            UN.unexpectedError "Error getting the ID of the created offer. Check the \"My Trades\" page for your open offer." txReceipt
                        ]

        CmdUp cmdUp ->
            UpdateResult
                prevModel
                Cmd.none
                ChainCmd.none
                [ cmdUp ]

        NoOp ->
            justModelUpdate
                prevModel


runCmdDown : CmdDown.CmdDown -> Model -> UpdateResult
runCmdDown cmdDown prevModel =
    case cmdDown of
        CmdDown.UpdateWallet wallet ->
            UpdateResult
                { prevModel | wallet = wallet }
                (case ( Wallet.userInfo wallet, Wallet.factory wallet ) of
                    ( Just uInfo, Just (Token tokenType) ) ->
                        Contracts.Wrappers.getAllowanceCmd
                            tokenType
                            uInfo.address
                            (Config.factoryAddress (Token tokenType))
                            (AllowanceFetched tokenType)

                    _ ->
                        Cmd.none
                )
                ChainCmd.none
                []

        CmdDown.CloseAnyDropdownsOrModals ->
            justModelUpdate
                { prevModel
                    | showDhTokenDropdown = False
                    , showForeignCryptoDropdown = False
                }


applyInputs : Model -> Model
applyInputs prevModel =
    let
        ( maybeAmountIn, amountInError ) =
            case interpretAmountIn prevModel.amountInInput of
                Ok (Just amountIn_) ->
                    ( Just amountIn_, Nothing )

                Ok Nothing ->
                    ( Nothing, Nothing )

                Err errStr ->
                    ( Nothing, Just errStr )

        ( maybeMargin, marginError ) =
            case interpretMargin prevModel.marginInput of
                Ok (Just margin_) ->
                    ( Just margin_, Nothing )

                Ok Nothing ->
                    ( Nothing, Nothing )

                Err errStr ->
                    ( Nothing, Just errStr )

        maybeAmountOut =
            Maybe.map3
                (\amountIn margin priceInfo ->
                    case prevModel.initiatorRole of
                        Buyer ->
                            let
                                equivalentDai =
                                    amountIn * priceInfo.price

                                equivalentDaiMinusMargin =
                                    equivalentDai - (equivalentDai * margin)
                            in
                            equivalentDaiMinusMargin

                        Seller ->
                            let
                                tradeAmountAfterDevFee =
                                    amountIn - (amountIn / 101)

                                equivalentForeignCrypto =
                                    tradeAmountAfterDevFee / priceInfo.price
                            in
                            equivalentForeignCrypto - (equivalentForeignCrypto * margin)
                )
                maybeAmountIn
                maybeMargin
                (foreignCryptoPriceInfo prevModel prevModel.foreignCrypto)
    in
    { prevModel
        | amountIn = maybeAmountIn
        , margin = maybeMargin
        , amountOut = maybeAmountOut
        , errors =
            { amountIn = amountInError
            , margin = marginError
            }
    }


interpretAmountIn : String -> Result String (Maybe Float)
interpretAmountIn input =
    if input == "" then
        Ok Nothing

    else
        case String.toFloat input of
            Just value ->
                Ok (Just value)

            Nothing ->
                Err "Invalid amount"


interpretMargin : String -> Result String (Maybe Float)
interpretMargin input =
    if input == "" then
        Ok Nothing

    else
        String.toFloat input
            |> Result.fromMaybe "Invalid margin"
            |> Result.map (\percent -> percent / 100.0)
            |> Result.map Just



-- interpretReceiveAddress : ForeignCrypto -> String -> Result String (Maybe String)
-- interpretReceiveAddress crypto input =
--     if input == "" then
--         Ok Nothing
--     else
--         let
--             b58Validate s =
--                 case Base58.decode s of
--                     Ok _ ->
--                         Ok (Just input)
--                     Err _ ->
--                         Err "Invalid address (b58 decode failed)"
--         in
--         case crypto of
--             ZEC ->
--                 b58Validate input
--             XMR ->
--                 if
--                     (String.length input == 106 || String.length input == 95)
--                         && (String.startsWith "4" input || String.startsWith "8" input)
--                 then
--                     Ok (Just input)
--                 else
--                     Err "Invalid address"
--             BTC ->
--                 b58Validate input


initiateCreateCall : FactoryType -> CTypes.CreateParameters -> ( Maybe TxChainStatus, ChainCmd Msg )
initiateCreateCall factoryType parameters =
    let
        txParams =
            Contracts.Wrappers.openTrade
                factoryType
                parameters
                |> Eth.toSend

        customSend =
            { onMined = Just ( CreateMined factoryType, Nothing )
            , onSign = Just (CreateSigned factoryType)
            , onBroadcast = Nothing
            }
    in
    ( Just (CreateNeedsSig factoryType)
    , ChainCmd.custom customSend txParams
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 10000 (always Refresh)
        , Time.every 500 UpdateNow
        ]
