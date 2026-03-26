import 'dart:convert';


import 'package:http/http.dart' as http;

import '../globale_variables.dart';
import '../models/banner_model.dart';
import '../models/vendor.dart';
import '../services/manage_http_response.dart';
import '../services/shared_preferences_service.dart';

class VendorController {



  //fetch vendors
  Future < List <Vendor> > loadVendors ()async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getVendors();
      if (cachedData != null && !SharedPreferencesService.isDataStale('vendors', 2)) {
        List<dynamic> data = jsonDecode(cachedData);
        List<Vendor> vendors = data.map((vendor) => Vendor.fromJson(vendor)).toList();
        return vendors;
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/vendors"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        List<dynamic> data= jsonDecode(response.body);
        List<Vendor> vendors=     data.map((vendor)=> Vendor.fromJson(vendor)).toList();
        
        // Cache the data
        await SharedPreferencesService.saveDataWithTimestamp('vendors', jsonEncode(data));
        
        return vendors;
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load vendors");
      }
    }catch(e){
      throw Exception("Error loading vendors: $e");
    }

  }
}