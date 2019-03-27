import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text/flutter_masked_text.dart';

class card extends StatefulWidget {
  @override
  _card createState() => new _card();
}

Color appColor = Colors.indigo;

class _card extends State<card> {
  final cardNumber = new MaskedTextController(mask: '0000 0000 0000 0000');
  final expireDate = new MaskedTextController(mask: '00/00');
  final cvcNumber = new MaskedTextController(mask: '000');
  final email = TextEditingController();
  final amount = TextEditingController();

  void _simpleAlertBox(String value) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Alert!",
              ),
              content: Text(value),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    "Ok",
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  @override
  createCard() async {
    var month = expireDate.text.split("/")[0];
    var year = expireDate.text.split("/")[1];
    var url = "https://api.stripe.com/v1/tokens";
    var body = {
      "card[number]": cardNumber.text,
      "card[exp_month]": month,
      "card[exp_year]": year,
      "card[cvc]": cvcNumber.text,
    };
    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));

    request.headers[HttpHeaders.CONTENT_TYPE] =
        'application/x-www-form-urlencoded; charset=utf-8';
    request.headers[HttpHeaders.AUTHORIZATION] =
        'Bearer Your Stripe Accoun Secret Key';
    request.bodyFields = body;
    final response1 = await client.send(request);
    final response2 = await response1.stream.bytesToString();
    var test = json.decode(response2);
    var token = test['id'];
    print(test);
    createCustomer(token);
  }

  createCustomer(String token) async {
    var url = "https://api.stripe.com/v1/customers";
    var body = {
      "description": "Customerdetail",
      "source": token,
      "email": email.text
    };
    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));

    request.headers[HttpHeaders.CONTENT_TYPE] =
        'application/x-www-form-urlencoded; charset=utf-8';
    request.headers[HttpHeaders.AUTHORIZATION] =
        'Bearer Your Stripe Accoun Secret Key';
    request.bodyFields = body;
    final response1 = await client.send(request);
    final response2 = await response1.stream.bytesToString();
    var test = json.decode(response2);
    var cust_id = test['id'];
    print(cust_id);
    pay(cust_id);
  }

  pay(String cust_id) async {
    var url = "https://api.stripe.com/v1/charges";
    var body = {
      "amount": amount.text,
      "currency": "INR",
      "customer": cust_id,
      "description": "Testing"
    };
    
    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));

    request.headers[HttpHeaders.CONTENT_TYPE] =
        'application/x-www-form-urlencoded; charset=utf-8';
    request.headers[HttpHeaders.AUTHORIZATION] =
        'Bearer Your Stripe Accoun Secret Key';
    request.bodyFields = body;
    final response1 = await client.send(request);
    final response2 = await response1.stream.bytesToString();
    var test = json.decode(response2);
    if (response1.statusCode == 200) {
      _simpleAlertBox("Payment Successfull");
    } else {
      _simpleAlertBox("Somthing Wrong!");
    }
    print(test);
  }

  final expiredateFocus = FocusNode();
  final cvcFocus = FocusNode();
  final emailFocus = FocusNode();
  final amountFocus = FocusNode();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        backgroundColor: appColor,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            new TextField(
              keyboardType: TextInputType.number,
              controller: cardNumber,
              decoration: new InputDecoration(
                icon: Icon(Icons.credit_card, color: appColor),
                hintText: "4242 4242 4242 4242",
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(expiredateFocus);
              },
            ),
            new TextField(
              focusNode: expiredateFocus,
              keyboardType: TextInputType.number,
              controller: expireDate,
              decoration: new InputDecoration(
                icon: Icon(Icons.date_range, color: appColor),
                hintText: "MM/YY",
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(cvcFocus);
              },
            ),
            new TextField(
              focusNode: cvcFocus,
              keyboardType: TextInputType.number,
              controller: cvcNumber,
              decoration: new InputDecoration(
                icon: Icon(Icons.confirmation_number, color: appColor),
                hintText: "CVC",
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(emailFocus);
              },
            ),
            new TextField(
              focusNode: emailFocus,
              controller: email,
              decoration: new InputDecoration(
                icon: Icon(Icons.email, color: appColor),
                hintText: "abc@gmail.com",
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(amountFocus);
              },
            ),
            new TextField(
              focusNode: amountFocus,
              keyboardType: TextInputType.number,
              controller: amount,
              decoration: new InputDecoration(
                icon: Icon(Icons.attach_money, color: appColor),
                hintText: "amount",
              ),
            ),
            RaisedButton(
              child: Text("Payment"),
              onPressed: () {
                createCard();
              },
            )
          ],
        ),
      ),
    );
  }
}
