abstract class PaymentMethod {}

class CreditCardPaymentMethod extends PaymentMethod {
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardHolderName;

  CreditCardPaymentMethod({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardHolderName,
  });
}

class PayPalPaymentMethod extends PaymentMethod {}
