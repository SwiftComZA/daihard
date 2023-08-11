module Helpers.Decoders.CurrencyRatesDecoder exposing (..)

import Json.Decode
import Json.Encode



-- Required packages:
-- * elm/json


type alias Root =
    { base : String
    , disclaimer : String
    , license : String
    , rates : RootRates
    , timestamp : Int
    }


type alias RootRates =
    { aED : Float
    , aFN : Float
    , aLL : Float
    , aMD : Float
    , aNG : Float
    , aOA : Float
    , aRS : Float
    , aUD : Float
    , aWG : Float
    , aZN : Float
    , bAM : Float
    , bBD : Float
    , bDT : Float
    , bGN : Float
    , bHD : Float
    , bIF : Float
    , bMD : Float
    , bND : Float
    , bOB : Float
    , bRL : Float
    , bSD : Float
    , bTC : Float
    , bTN : Float
    , bWP : Float
    , bYN : Float
    , bZD : Float
    , cAD : Float
    , cDF : Float
    , cHF : Float
    , cLF : Float
    , cLP : Float
    , cNH : Float
    , cNY : Float
    , cOP : Float
    , cRC : Float
    , cUC : Float
    , cUP : Float
    , cVE : Float
    , cZK : Float
    , dJF : Float
    , dKK : Float
    , dOP : Float
    , dZD : Float
    , eGP : Float
    , eRN : Float
    , eTB : Float
    , eUR : Float
    , fJD : Float
    , fKP : Float
    , gBP : Float
    , gEL : Float
    , gGP : Float
    , gHS : Float
    , gIP : Float
    , gMD : Float
    , gNF : Float
    , gTQ : Float
    , gYD : Float
    , hKD : Float
    , hNL : Float
    , hRK : Float
    , hTG : Float
    , hUF : Float
    , iDR : Float
    , iLS : Float
    , iMP : Float
    , iNR : Float
    , iQD : Float
    , iRR : Float
    , iSK : Float
    , jEP : Float
    , jMD : Float
    , jOD : Float
    , jPY : Float
    , kES : Float
    , kGS : Float
    , kHR : Float
    , kMF : Float
    , kPW : Float
    , kRW : Float
    , kWD : Float
    , kYD : Float
    , kZT : Float
    , lAK : Float
    , lBP : Float
    , lKR : Float
    , lRD : Float
    , lSL : Float
    , lYD : Float
    , mAD : Float
    , mDL : Float
    , mGA : Float
    , mKD : Float
    , mMK : Float
    , mNT : Float
    , mOP : Float
    , mRU : Float
    , mUR : Float
    , mVR : Float
    , mWK : Float
    , mXN : Float
    , mYR : Float
    , mZN : Float
    , nAD : Float
    , nGN : Float
    , nIO : Float
    , nOK : Float
    , nPR : Float
    , nZD : Float
    , oMR : Float
    , pAB : Float
    , pEN : Float
    , pGK : Float
    , pHP : Float
    , pKR : Float
    , pLN : Float
    , pYG : Float
    , qAR : Float
    , rON : Float
    , rSD : Float
    , rUB : Float
    , rWF : Float
    , sAR : Float
    , sBD : Float
    , sCR : Float
    , sDG : Float
    , sEK : Float
    , sGD : Float
    , sHP : Float
    , sLL : Float
    , sOS : Float
    , sRD : Float
    , sSP : Float
    , sTD : Float
    , sTN : Float
    , sVC : Float
    , sYP : Float
    , sZL : Float
    , tHB : Float
    , tJS : Float
    , tMT : Float
    , tND : Float
    , tOP : Float
    , tRY : Float
    , tTD : Float
    , tWD : Float
    , tZS : Float
    , uAH : Float
    , uGX : Float
    , uSD : Float
    , uYU : Float
    , uZS : Float
    , vES : Float
    , vND : Float
    , vUV : Float
    , wST : Float
    , xAF : Float
    , xAG : Float
    , xAU : Float
    , xCD : Float
    , xDR : Float
    , xOF : Float
    , xPD : Float
    , xPF : Float
    , xPT : Float
    , yER : Float
    , zAR : Float
    , zMW : Float
    , zWL : Float
    }


rootDecoder : Json.Decode.Decoder Root
rootDecoder =
    Json.Decode.map5 Root
        (Json.Decode.field "base" Json.Decode.string)
        (Json.Decode.field "disclaimer" Json.Decode.string)
        (Json.Decode.field "license" Json.Decode.string)
        (Json.Decode.field "rates" rootRatesDecoder)
        (Json.Decode.field "timestamp" Json.Decode.int)


rootRatesDecoder : Json.Decode.Decoder RootRates
rootRatesDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 RootRates
                (Json.Decode.field "AED" Json.Decode.float)
                (Json.Decode.field "AFN" Json.Decode.float)
                (Json.Decode.field "ALL" Json.Decode.float)
                (Json.Decode.field "AMD" Json.Decode.float)
                (Json.Decode.field "ANG" Json.Decode.float)
                (Json.Decode.field "AOA" Json.Decode.float)
                (Json.Decode.field "ARS" Json.Decode.float)
                (Json.Decode.field "AUD" Json.Decode.float)

        fieldSet1 =
            Json.Decode.map8 (<|)
                fieldSet0
                (Json.Decode.field "AWG" Json.Decode.float)
                (Json.Decode.field "AZN" Json.Decode.float)
                (Json.Decode.field "BAM" Json.Decode.float)
                (Json.Decode.field "BBD" Json.Decode.float)
                (Json.Decode.field "BDT" Json.Decode.float)
                (Json.Decode.field "BGN" Json.Decode.float)
                (Json.Decode.field "BHD" Json.Decode.float)

        fieldSet2 =
            Json.Decode.map8 (<|)
                fieldSet1
                (Json.Decode.field "BIF" Json.Decode.float)
                (Json.Decode.field "BMD" Json.Decode.float)
                (Json.Decode.field "BND" Json.Decode.float)
                (Json.Decode.field "BOB" Json.Decode.float)
                (Json.Decode.field "BRL" Json.Decode.float)
                (Json.Decode.field "BSD" Json.Decode.float)
                (Json.Decode.field "BTC" Json.Decode.float)

        fieldSet3 =
            Json.Decode.map8 (<|)
                fieldSet2
                (Json.Decode.field "BTN" Json.Decode.float)
                (Json.Decode.field "BWP" Json.Decode.float)
                (Json.Decode.field "BYN" Json.Decode.float)
                (Json.Decode.field "BZD" Json.Decode.float)
                (Json.Decode.field "CAD" Json.Decode.float)
                (Json.Decode.field "CDF" Json.Decode.float)
                (Json.Decode.field "CHF" Json.Decode.float)

        fieldSet4 =
            Json.Decode.map8 (<|)
                fieldSet3
                (Json.Decode.field "CLF" Json.Decode.float)
                (Json.Decode.field "CLP" Json.Decode.float)
                (Json.Decode.field "CNH" Json.Decode.float)
                (Json.Decode.field "CNY" Json.Decode.float)
                (Json.Decode.field "COP" Json.Decode.float)
                (Json.Decode.field "CRC" Json.Decode.float)
                (Json.Decode.field "CUC" Json.Decode.float)

        fieldSet5 =
            Json.Decode.map8 (<|)
                fieldSet4
                (Json.Decode.field "CUP" Json.Decode.float)
                (Json.Decode.field "CVE" Json.Decode.float)
                (Json.Decode.field "CZK" Json.Decode.float)
                (Json.Decode.field "DJF" Json.Decode.float)
                (Json.Decode.field "DKK" Json.Decode.float)
                (Json.Decode.field "DOP" Json.Decode.float)
                (Json.Decode.field "DZD" Json.Decode.float)

        fieldSet6 =
            Json.Decode.map8 (<|)
                fieldSet5
                (Json.Decode.field "EGP" Json.Decode.float)
                (Json.Decode.field "ERN" Json.Decode.float)
                (Json.Decode.field "ETB" Json.Decode.float)
                (Json.Decode.field "EUR" Json.Decode.float)
                (Json.Decode.field "FJD" Json.Decode.float)
                (Json.Decode.field "FKP" Json.Decode.float)
                (Json.Decode.field "GBP" Json.Decode.float)

        fieldSet7 =
            Json.Decode.map8 (<|)
                fieldSet6
                (Json.Decode.field "GEL" Json.Decode.float)
                (Json.Decode.field "GGP" Json.Decode.float)
                (Json.Decode.field "GHS" Json.Decode.float)
                (Json.Decode.field "GIP" Json.Decode.float)
                (Json.Decode.field "GMD" Json.Decode.float)
                (Json.Decode.field "GNF" Json.Decode.float)
                (Json.Decode.field "GTQ" Json.Decode.float)

        fieldSet8 =
            Json.Decode.map8 (<|)
                fieldSet7
                (Json.Decode.field "GYD" Json.Decode.float)
                (Json.Decode.field "HKD" Json.Decode.float)
                (Json.Decode.field "HNL" Json.Decode.float)
                (Json.Decode.field "HRK" Json.Decode.float)
                (Json.Decode.field "HTG" Json.Decode.float)
                (Json.Decode.field "HUF" Json.Decode.float)
                (Json.Decode.field "IDR" Json.Decode.float)

        fieldSet9 =
            Json.Decode.map8 (<|)
                fieldSet8
                (Json.Decode.field "ILS" Json.Decode.float)
                (Json.Decode.field "IMP" Json.Decode.float)
                (Json.Decode.field "INR" Json.Decode.float)
                (Json.Decode.field "IQD" Json.Decode.float)
                (Json.Decode.field "IRR" Json.Decode.float)
                (Json.Decode.field "ISK" Json.Decode.float)
                (Json.Decode.field "JEP" Json.Decode.float)

        fieldSet10 =
            Json.Decode.map8 (<|)
                fieldSet9
                (Json.Decode.field "JMD" Json.Decode.float)
                (Json.Decode.field "JOD" Json.Decode.float)
                (Json.Decode.field "JPY" Json.Decode.float)
                (Json.Decode.field "KES" Json.Decode.float)
                (Json.Decode.field "KGS" Json.Decode.float)
                (Json.Decode.field "KHR" Json.Decode.float)
                (Json.Decode.field "KMF" Json.Decode.float)

        fieldSet11 =
            Json.Decode.map8 (<|)
                fieldSet10
                (Json.Decode.field "KPW" Json.Decode.float)
                (Json.Decode.field "KRW" Json.Decode.float)
                (Json.Decode.field "KWD" Json.Decode.float)
                (Json.Decode.field "KYD" Json.Decode.float)
                (Json.Decode.field "KZT" Json.Decode.float)
                (Json.Decode.field "LAK" Json.Decode.float)
                (Json.Decode.field "LBP" Json.Decode.float)

        fieldSet12 =
            Json.Decode.map8 (<|)
                fieldSet11
                (Json.Decode.field "LKR" Json.Decode.float)
                (Json.Decode.field "LRD" Json.Decode.float)
                (Json.Decode.field "LSL" Json.Decode.float)
                (Json.Decode.field "LYD" Json.Decode.float)
                (Json.Decode.field "MAD" Json.Decode.float)
                (Json.Decode.field "MDL" Json.Decode.float)
                (Json.Decode.field "MGA" Json.Decode.float)

        fieldSet13 =
            Json.Decode.map8 (<|)
                fieldSet12
                (Json.Decode.field "MKD" Json.Decode.float)
                (Json.Decode.field "MMK" Json.Decode.float)
                (Json.Decode.field "MNT" Json.Decode.float)
                (Json.Decode.field "MOP" Json.Decode.float)
                (Json.Decode.field "MRU" Json.Decode.float)
                (Json.Decode.field "MUR" Json.Decode.float)
                (Json.Decode.field "MVR" Json.Decode.float)

        fieldSet14 =
            Json.Decode.map8 (<|)
                fieldSet13
                (Json.Decode.field "MWK" Json.Decode.float)
                (Json.Decode.field "MXN" Json.Decode.float)
                (Json.Decode.field "MYR" Json.Decode.float)
                (Json.Decode.field "MZN" Json.Decode.float)
                (Json.Decode.field "NAD" Json.Decode.float)
                (Json.Decode.field "NGN" Json.Decode.float)
                (Json.Decode.field "NIO" Json.Decode.float)

        fieldSet15 =
            Json.Decode.map8 (<|)
                fieldSet14
                (Json.Decode.field "NOK" Json.Decode.float)
                (Json.Decode.field "NPR" Json.Decode.float)
                (Json.Decode.field "NZD" Json.Decode.float)
                (Json.Decode.field "OMR" Json.Decode.float)
                (Json.Decode.field "PAB" Json.Decode.float)
                (Json.Decode.field "PEN" Json.Decode.float)
                (Json.Decode.field "PGK" Json.Decode.float)

        fieldSet16 =
            Json.Decode.map8 (<|)
                fieldSet15
                (Json.Decode.field "PHP" Json.Decode.float)
                (Json.Decode.field "PKR" Json.Decode.float)
                (Json.Decode.field "PLN" Json.Decode.float)
                (Json.Decode.field "PYG" Json.Decode.float)
                (Json.Decode.field "QAR" Json.Decode.float)
                (Json.Decode.field "RON" Json.Decode.float)
                (Json.Decode.field "RSD" Json.Decode.float)

        fieldSet17 =
            Json.Decode.map8 (<|)
                fieldSet16
                (Json.Decode.field "RUB" Json.Decode.float)
                (Json.Decode.field "RWF" Json.Decode.float)
                (Json.Decode.field "SAR" Json.Decode.float)
                (Json.Decode.field "SBD" Json.Decode.float)
                (Json.Decode.field "SCR" Json.Decode.float)
                (Json.Decode.field "SDG" Json.Decode.float)
                (Json.Decode.field "SEK" Json.Decode.float)

        fieldSet18 =
            Json.Decode.map8 (<|)
                fieldSet17
                (Json.Decode.field "SGD" Json.Decode.float)
                (Json.Decode.field "SHP" Json.Decode.float)
                (Json.Decode.field "SLL" Json.Decode.float)
                (Json.Decode.field "SOS" Json.Decode.float)
                (Json.Decode.field "SRD" Json.Decode.float)
                (Json.Decode.field "SSP" Json.Decode.float)
                (Json.Decode.field "STD" Json.Decode.float)

        fieldSet19 =
            Json.Decode.map8 (<|)
                fieldSet18
                (Json.Decode.field "STN" Json.Decode.float)
                (Json.Decode.field "SVC" Json.Decode.float)
                (Json.Decode.field "SYP" Json.Decode.float)
                (Json.Decode.field "SZL" Json.Decode.float)
                (Json.Decode.field "THB" Json.Decode.float)
                (Json.Decode.field "TJS" Json.Decode.float)
                (Json.Decode.field "TMT" Json.Decode.float)

        fieldSet20 =
            Json.Decode.map8 (<|)
                fieldSet19
                (Json.Decode.field "TND" Json.Decode.float)
                (Json.Decode.field "TOP" Json.Decode.float)
                (Json.Decode.field "TRY" Json.Decode.float)
                (Json.Decode.field "TTD" Json.Decode.float)
                (Json.Decode.field "TWD" Json.Decode.float)
                (Json.Decode.field "TZS" Json.Decode.float)
                (Json.Decode.field "UAH" Json.Decode.float)

        fieldSet21 =
            Json.Decode.map8 (<|)
                fieldSet20
                (Json.Decode.field "UGX" Json.Decode.float)
                (Json.Decode.field "USD" Json.Decode.float)
                (Json.Decode.field "UYU" Json.Decode.float)
                (Json.Decode.field "UZS" Json.Decode.float)
                (Json.Decode.field "VES" Json.Decode.float)
                (Json.Decode.field "VND" Json.Decode.float)
                (Json.Decode.field "VUV" Json.Decode.float)

        fieldSet22 =
            Json.Decode.map8 (<|)
                fieldSet21
                (Json.Decode.field "WST" Json.Decode.float)
                (Json.Decode.field "XAF" Json.Decode.float)
                (Json.Decode.field "XAG" Json.Decode.float)
                (Json.Decode.field "XAU" Json.Decode.float)
                (Json.Decode.field "XCD" Json.Decode.float)
                (Json.Decode.field "XDR" Json.Decode.float)
                (Json.Decode.field "XOF" Json.Decode.float)
    in
    Json.Decode.map8 (<|)
        fieldSet22
        (Json.Decode.field "XPD" Json.Decode.float)
        (Json.Decode.field "XPF" Json.Decode.float)
        (Json.Decode.field "XPT" Json.Decode.float)
        (Json.Decode.field "YER" Json.Decode.float)
        (Json.Decode.field "ZAR" Json.Decode.float)
        (Json.Decode.field "ZMW" Json.Decode.float)
        (Json.Decode.field "ZWL" Json.Decode.float)


encodedRoot : Root -> Json.Encode.Value
encodedRoot root =
    Json.Encode.object
        [ ( "base", Json.Encode.string root.base )
        , ( "disclaimer", Json.Encode.string root.disclaimer )
        , ( "license", Json.Encode.string root.license )
        , ( "rates", encodedRootRates root.rates )
        , ( "timestamp", Json.Encode.int root.timestamp )
        ]


encodedRootRates : RootRates -> Json.Encode.Value
encodedRootRates rootRates =
    Json.Encode.object
        [ ( "AED", Json.Encode.float rootRates.aED )
        , ( "AFN", Json.Encode.float rootRates.aFN )
        , ( "ALL", Json.Encode.float rootRates.aLL )
        , ( "AMD", Json.Encode.float rootRates.aMD )
        , ( "ANG", Json.Encode.float rootRates.aNG )
        , ( "AOA", Json.Encode.float rootRates.aOA )
        , ( "ARS", Json.Encode.float rootRates.aRS )
        , ( "AUD", Json.Encode.float rootRates.aUD )
        , ( "AWG", Json.Encode.float rootRates.aWG )
        , ( "AZN", Json.Encode.float rootRates.aZN )
        , ( "BAM", Json.Encode.float rootRates.bAM )
        , ( "BBD", Json.Encode.float rootRates.bBD )
        , ( "BDT", Json.Encode.float rootRates.bDT )
        , ( "BGN", Json.Encode.float rootRates.bGN )
        , ( "BHD", Json.Encode.float rootRates.bHD )
        , ( "BIF", Json.Encode.float rootRates.bIF )
        , ( "BMD", Json.Encode.float rootRates.bMD )
        , ( "BND", Json.Encode.float rootRates.bND )
        , ( "BOB", Json.Encode.float rootRates.bOB )
        , ( "BRL", Json.Encode.float rootRates.bRL )
        , ( "BSD", Json.Encode.float rootRates.bSD )
        , ( "BTC", Json.Encode.float rootRates.bTC )
        , ( "BTN", Json.Encode.float rootRates.bTN )
        , ( "BWP", Json.Encode.float rootRates.bWP )
        , ( "BYN", Json.Encode.float rootRates.bYN )
        , ( "BZD", Json.Encode.float rootRates.bZD )
        , ( "CAD", Json.Encode.float rootRates.cAD )
        , ( "CDF", Json.Encode.float rootRates.cDF )
        , ( "CHF", Json.Encode.float rootRates.cHF )
        , ( "CLF", Json.Encode.float rootRates.cLF )
        , ( "CLP", Json.Encode.float rootRates.cLP )
        , ( "CNH", Json.Encode.float rootRates.cNH )
        , ( "CNY", Json.Encode.float rootRates.cNY )
        , ( "COP", Json.Encode.float rootRates.cOP )
        , ( "CRC", Json.Encode.float rootRates.cRC )
        , ( "CUC", Json.Encode.float rootRates.cUC )
        , ( "CUP", Json.Encode.float rootRates.cUP )
        , ( "CVE", Json.Encode.float rootRates.cVE )
        , ( "CZK", Json.Encode.float rootRates.cZK )
        , ( "DJF", Json.Encode.float rootRates.dJF )
        , ( "DKK", Json.Encode.float rootRates.dKK )
        , ( "DOP", Json.Encode.float rootRates.dOP )
        , ( "DZD", Json.Encode.float rootRates.dZD )
        , ( "EGP", Json.Encode.float rootRates.eGP )
        , ( "ERN", Json.Encode.float rootRates.eRN )
        , ( "ETB", Json.Encode.float rootRates.eTB )
        , ( "EUR", Json.Encode.float rootRates.eUR )
        , ( "FJD", Json.Encode.float rootRates.fJD )
        , ( "FKP", Json.Encode.float rootRates.fKP )
        , ( "GBP", Json.Encode.float rootRates.gBP )
        , ( "GEL", Json.Encode.float rootRates.gEL )
        , ( "GGP", Json.Encode.float rootRates.gGP )
        , ( "GHS", Json.Encode.float rootRates.gHS )
        , ( "GIP", Json.Encode.float rootRates.gIP )
        , ( "GMD", Json.Encode.float rootRates.gMD )
        , ( "GNF", Json.Encode.float rootRates.gNF )
        , ( "GTQ", Json.Encode.float rootRates.gTQ )
        , ( "GYD", Json.Encode.float rootRates.gYD )
        , ( "HKD", Json.Encode.float rootRates.hKD )
        , ( "HNL", Json.Encode.float rootRates.hNL )
        , ( "HRK", Json.Encode.float rootRates.hRK )
        , ( "HTG", Json.Encode.float rootRates.hTG )
        , ( "HUF", Json.Encode.float rootRates.hUF )
        , ( "IDR", Json.Encode.float rootRates.iDR )
        , ( "ILS", Json.Encode.float rootRates.iLS )
        , ( "IMP", Json.Encode.float rootRates.iMP )
        , ( "INR", Json.Encode.float rootRates.iNR )
        , ( "IQD", Json.Encode.float rootRates.iQD )
        , ( "IRR", Json.Encode.float rootRates.iRR )
        , ( "ISK", Json.Encode.float rootRates.iSK )
        , ( "JEP", Json.Encode.float rootRates.jEP )
        , ( "JMD", Json.Encode.float rootRates.jMD )
        , ( "JOD", Json.Encode.float rootRates.jOD )
        , ( "JPY", Json.Encode.float rootRates.jPY )
        , ( "KES", Json.Encode.float rootRates.kES )
        , ( "KGS", Json.Encode.float rootRates.kGS )
        , ( "KHR", Json.Encode.float rootRates.kHR )
        , ( "KMF", Json.Encode.float rootRates.kMF )
        , ( "KPW", Json.Encode.float rootRates.kPW )
        , ( "KRW", Json.Encode.float rootRates.kRW )
        , ( "KWD", Json.Encode.float rootRates.kWD )
        , ( "KYD", Json.Encode.float rootRates.kYD )
        , ( "KZT", Json.Encode.float rootRates.kZT )
        , ( "LAK", Json.Encode.float rootRates.lAK )
        , ( "LBP", Json.Encode.float rootRates.lBP )
        , ( "LKR", Json.Encode.float rootRates.lKR )
        , ( "LRD", Json.Encode.float rootRates.lRD )
        , ( "LSL", Json.Encode.float rootRates.lSL )
        , ( "LYD", Json.Encode.float rootRates.lYD )
        , ( "MAD", Json.Encode.float rootRates.mAD )
        , ( "MDL", Json.Encode.float rootRates.mDL )
        , ( "MGA", Json.Encode.float rootRates.mGA )
        , ( "MKD", Json.Encode.float rootRates.mKD )
        , ( "MMK", Json.Encode.float rootRates.mMK )
        , ( "MNT", Json.Encode.float rootRates.mNT )
        , ( "MOP", Json.Encode.float rootRates.mOP )
        , ( "MRU", Json.Encode.float rootRates.mRU )
        , ( "MUR", Json.Encode.float rootRates.mUR )
        , ( "MVR", Json.Encode.float rootRates.mVR )
        , ( "MWK", Json.Encode.float rootRates.mWK )
        , ( "MXN", Json.Encode.float rootRates.mXN )
        , ( "MYR", Json.Encode.float rootRates.mYR )
        , ( "MZN", Json.Encode.float rootRates.mZN )
        , ( "NAD", Json.Encode.float rootRates.nAD )
        , ( "NGN", Json.Encode.float rootRates.nGN )
        , ( "NIO", Json.Encode.float rootRates.nIO )
        , ( "NOK", Json.Encode.float rootRates.nOK )
        , ( "NPR", Json.Encode.float rootRates.nPR )
        , ( "NZD", Json.Encode.float rootRates.nZD )
        , ( "OMR", Json.Encode.float rootRates.oMR )
        , ( "PAB", Json.Encode.float rootRates.pAB )
        , ( "PEN", Json.Encode.float rootRates.pEN )
        , ( "PGK", Json.Encode.float rootRates.pGK )
        , ( "PHP", Json.Encode.float rootRates.pHP )
        , ( "PKR", Json.Encode.float rootRates.pKR )
        , ( "PLN", Json.Encode.float rootRates.pLN )
        , ( "PYG", Json.Encode.float rootRates.pYG )
        , ( "QAR", Json.Encode.float rootRates.qAR )
        , ( "RON", Json.Encode.float rootRates.rON )
        , ( "RSD", Json.Encode.float rootRates.rSD )
        , ( "RUB", Json.Encode.float rootRates.rUB )
        , ( "RWF", Json.Encode.float rootRates.rWF )
        , ( "SAR", Json.Encode.float rootRates.sAR )
        , ( "SBD", Json.Encode.float rootRates.sBD )
        , ( "SCR", Json.Encode.float rootRates.sCR )
        , ( "SDG", Json.Encode.float rootRates.sDG )
        , ( "SEK", Json.Encode.float rootRates.sEK )
        , ( "SGD", Json.Encode.float rootRates.sGD )
        , ( "SHP", Json.Encode.float rootRates.sHP )
        , ( "SLL", Json.Encode.float rootRates.sLL )
        , ( "SOS", Json.Encode.float rootRates.sOS )
        , ( "SRD", Json.Encode.float rootRates.sRD )
        , ( "SSP", Json.Encode.float rootRates.sSP )
        , ( "STD", Json.Encode.float rootRates.sTD )
        , ( "STN", Json.Encode.float rootRates.sTN )
        , ( "SVC", Json.Encode.float rootRates.sVC )
        , ( "SYP", Json.Encode.float rootRates.sYP )
        , ( "SZL", Json.Encode.float rootRates.sZL )
        , ( "THB", Json.Encode.float rootRates.tHB )
        , ( "TJS", Json.Encode.float rootRates.tJS )
        , ( "TMT", Json.Encode.float rootRates.tMT )
        , ( "TND", Json.Encode.float rootRates.tND )
        , ( "TOP", Json.Encode.float rootRates.tOP )
        , ( "TRY", Json.Encode.float rootRates.tRY )
        , ( "TTD", Json.Encode.float rootRates.tTD )
        , ( "TWD", Json.Encode.float rootRates.tWD )
        , ( "TZS", Json.Encode.float rootRates.tZS )
        , ( "UAH", Json.Encode.float rootRates.uAH )
        , ( "UGX", Json.Encode.float rootRates.uGX )
        , ( "USD", Json.Encode.float rootRates.uSD )
        , ( "UYU", Json.Encode.float rootRates.uYU )
        , ( "UZS", Json.Encode.float rootRates.uZS )
        , ( "VES", Json.Encode.float rootRates.vES )
        , ( "VND", Json.Encode.float rootRates.vND )
        , ( "VUV", Json.Encode.float rootRates.vUV )
        , ( "WST", Json.Encode.float rootRates.wST )
        , ( "XAF", Json.Encode.float rootRates.xAF )
        , ( "XAG", Json.Encode.float rootRates.xAG )
        , ( "XAU", Json.Encode.float rootRates.xAU )
        , ( "XCD", Json.Encode.float rootRates.xCD )
        , ( "XDR", Json.Encode.float rootRates.xDR )
        , ( "XOF", Json.Encode.float rootRates.xOF )
        , ( "XPD", Json.Encode.float rootRates.xPD )
        , ( "XPF", Json.Encode.float rootRates.xPF )
        , ( "XPT", Json.Encode.float rootRates.xPT )
        , ( "YER", Json.Encode.float rootRates.yER )
        , ( "ZAR", Json.Encode.float rootRates.zAR )
        , ( "ZMW", Json.Encode.float rootRates.zMW )
        , ( "ZWL", Json.Encode.float rootRates.zWL )
        ]
