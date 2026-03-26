import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse ({
  required http.Response response,
  required BuildContext context, //the context is to show on snackbar
  required VoidCallback
       onSuccess, //the callback to execute on a successfull
}){
  switch(response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, json.decode(response.body)['msg']);
      break;

    case 500:
      showSnackBar(context, json.decode(response.body)['error']);
      break;

    case 201:
      onSuccess();
      break;

  }


}
void showSnackBar(BuildContext context, String title){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 237, 246, 237),
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Expanded(child: Text(title,style: GoogleFonts.quicksand(color: Colors.black,fontSize: 18),)),
        ],
      ),
    ),
  );
}