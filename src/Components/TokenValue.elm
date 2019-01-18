module TokenValue exposing (TokenValue, empty, getString, numDecimals, renderToString, toBigInt, updateViaBigInt, updateViaString)

import BigInt exposing (BigInt)



-- Exposed


type TokenValue
    = TokenValue
        { numDecimals : Int
        , string : String
        }


numDecimals : TokenValue -> Int
numDecimals tokens =
    case tokens of
        TokenValue tokens ->
            tokens.numDecimals


getString : TokenValue -> String
getString tokens =
    case tokens of
        TokenValue tokens ->
            tokens.string


toBigInt : TokenValue -> Maybe BigInt
toBigInt tokens =
    stringToEvmValue (numDecimals tokens) (getString tokens)


empty : Int -> TokenValue
empty numDecimals =
    TokenValue
        { numDecimals = numDecimals
        , string = ""
        }


renderToString : Maybe Int -> TokenValue -> Maybe String
renderToString maxDigitsAfterDecimal tokens =
    case toBigInt tokens of
        Nothing ->
            Nothing

        Just evmValue ->
            Just
                (case maxDigitsAfterDecimal of
                    Nothing ->
                        evmValueToString (numDecimals tokens) evmValue

                    Just maxDigits ->
                        evmValueToTruncatedString (numDecimals tokens) maxDigits evmValue
                )


updateViaString : TokenValue -> String -> TokenValue
updateViaString (TokenValue originalTokens) newString =
    TokenValue
        { numDecimals = originalTokens.numDecimals
        , string = newString
        }


updateViaBigInt : TokenValue -> BigInt -> TokenValue
updateViaBigInt (TokenValue tokens) newBigIntValue =
    let
        newString =
            evmValueToString tokens.numDecimals newBigIntValue
    in
    TokenValue { tokens | string = newString }



-- Internal


stringToEvmValue : Int -> String -> Maybe BigInt
stringToEvmValue numDecimals amountString =
    let
        ( newString, numDigitsMoved ) =
            pullAnyFirstDecimalOffToRight amountString

        numDigitsLeftToMove =
            numDecimals - numDigitsMoved

        maybeBigIntAmount =
            BigInt.fromString newString
    in
    if numDigitsLeftToMove < 0 then
        Nothing

    else
        case maybeBigIntAmount of
            Nothing ->
                Nothing

            Just bigIntAmount ->
                let
                    evmValue =
                        BigInt.mul bigIntAmount (BigInt.pow (BigInt.fromInt 10) (BigInt.fromInt numDigitsLeftToMove))
                in
                Just evmValue


pullAnyFirstDecimalOffToRight : String -> ( String, Int )
pullAnyFirstDecimalOffToRight numString =
    let
        maybeDecimalPosition =
            List.head (String.indexes "." numString)
    in
    case maybeDecimalPosition of
        Nothing ->
            ( numString, 0 )

        Just decimalPos ->
            let
                numDigitsMoved =
                    (String.length numString - 1) - decimalPos

                newString =
                    String.left decimalPos numString
                        ++ String.dropLeft (decimalPos + 1) numString
            in
            ( newString, numDigitsMoved )


evmValueToTruncatedString : Int -> Int -> BigInt -> String
evmValueToTruncatedString numDecimals maxDigitsAfterDecimal evmValue =
    let
        untruncatedString =
            evmValueToString numDecimals evmValue

        maybeDecimalPos =
            List.head (String.indexes "." untruncatedString)
    in
    case maybeDecimalPos of
        Nothing ->
            untruncatedString

        Just decimalPos ->
            if maxDigitsAfterDecimal == 0 then
                String.left decimalPos untruncatedString

            else
                String.left (decimalPos + 1 + maxDigitsAfterDecimal) untruncatedString


evmValueToString : Int -> BigInt -> String
evmValueToString numDecimals evmValue =
    let
        zeroPaddedString =
            evmValue
                |> BigInt.toString
                |> String.padLeft numDecimals '0'

        withDecimalString =
            String.dropRight numDecimals zeroPaddedString
                ++ "."
                ++ String.right numDecimals zeroPaddedString
    in
    removeUnnecessaryZerosAndDots withDecimalString


removeUnnecessaryZerosAndDots : String -> String
removeUnnecessaryZerosAndDots numString =
    if String.endsWith "." numString then
        String.slice 0 -1 numString

    else if String.endsWith "0" numString then
        removeUnnecessaryZerosAndDots (String.slice 0 -1 numString)

    else
        numString
