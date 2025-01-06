import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment() async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(10, "usd");
      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Asif Afroj Shayon",
        ),
      );
      await _processPayment();
    } catch (e) {
      log("$e");
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': _calculateAmount(amount),
        'currency': currency
      };
      var response = await dio.post("https://api.stripe.com/v1/payment_intents",
          data: data,
          options: Options(contentType: Headers.formUrlEncodedContentType, headers: {
            "Authorization": "Bearer $secretkey",
            "Content-Type": "application/x-www-form-urlencoded"
          }));
      if (response.data != null && response.data is Map && response.data.containsKey('client_secret')) {
        log(response.data.toString());
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      log("$e");
      return null;
    }
  }


  String _calculateAmount(int amount) {
    final calculateamount = amount * 100;
    return calculateamount.toString();
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      log("$e");
    }
  }
}

final String publishkey =
    "pk_test_51QeE4NRwXRJ1klvENpC6nMDu3XZube1vWl2Im8I7HqgJsrnJa8YUxRF1S3iM5ScRcsP4Ru7EQWEJMPlEeDqwGSGH00o3BRgYcG";
final String secretkey =
    "sk_test_51QeE4NRwXRJ1klvEBqKgRFZyflVtrBZUx7V3sO7wt3d6uMZQhtG6V0v8oYOedm8IZC388ZSTPBR58pZ975xtO0mJ00fo57DsnL";
