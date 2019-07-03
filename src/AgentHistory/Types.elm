module AgentHistory.Types exposing (Model, Msg(..), UpdateResult)

import AppCmd exposing (AppCmd)
import Array exposing (Array)
import BigInt exposing (BigInt)
import CommonTypes exposing (..)
import Contracts.Types as CTypes
import Dict exposing (Dict)
import Eth.Sentry.Event as EventSentry exposing (EventSentry)
import Eth.Types exposing (Address)
import FiatValue exposing (FiatValue)
import Helpers.ChainCmd as ChainCmd exposing (ChainCmd)
import Helpers.Eth as EthHelpers exposing (Web3Context)
import Http
import Json.Decode
import PaymentMethods exposing (PaymentMethod)
import Routing
import String.Extra
import Time
import TokenValue exposing (TokenValue)
import TradeCache.Types as TradeCache exposing (TradeCache)


type alias Model =
    { web3Context : Web3Context
    , agentAddress : Address
    , agentRole : BuyerOrSeller
    , userInfo : Maybe UserInfo
    , viewPhase : CTypes.Phase
    }


type Msg
    = ViewUserRoleChanged BuyerOrSeller
    | ViewPhaseChanged CTypes.Phase
    | Poke Address
    | TradeClicked Int
    | NoOp


type alias UpdateResult =
    { model : Model
    , cmd : Cmd Msg
    , chainCmd : ChainCmd Msg
    , appCmds : List AppCmd
    }