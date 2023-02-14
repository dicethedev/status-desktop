import ../../../app_service/service/currency/dto
import ./currency_amount

proc currencyAmountToItem*(amount: float64, format: CurrencyFormatDto) : CurrencyAmount =
  return newCurrencyAmount(
      amount,
      format.symbol,
      int(format.displayDecimals),
      format.stripTrailingZeroes
    )
