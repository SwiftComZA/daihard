module Constants exposing (daiAddress, factoryAddress, networkId, tokenDecimals)

import Eth.Net
import Eth.Types exposing (Address)
import Eth.Utils


type NetSetting
    = Mainnet
    | Kovan


tokenDecimals =
    18


netSetting =
    Kovan


networkId =
    case netSetting of
        Mainnet ->
            Eth.Net.Mainnet

        Kovan ->
            Eth.Net.Kovan


daiAddress =
    case netSetting of
        Mainnet ->
            Eth.Utils.unsafeToAddress "0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359"

        Kovan ->
            Eth.Utils.unsafeToAddress "0xC4375B7De8af5a38a93548eb8453a498222C4fF2"


factoryAddress =
    case netSetting of
        Mainnet ->
            Eth.Utils.unsafeToAddress "0x54382c6528e55b812117c1b54e04d149585e462d"

        Kovan ->
            Eth.Utils.unsafeToAddress "0x02b37f71e1B274570fbb5b26f20D8eA1777Fb65a"
