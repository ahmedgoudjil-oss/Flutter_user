import 'dart:convert';


import 'package:http/http.dart' as http;

import '../globale_variables.dart';
import '../models/banner_model.dart';

import '../services/shared_preferences_service.dart';

class BannerController {



  //fetch banners
  Future < List <BannerModel> > loadBanners ()async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getBanners();
      if (cachedData != null && !SharedPreferencesService.isDataStale('banners', 2)) {
        List<dynamic> data = jsonDecode(cachedData);
        List<BannerModel> banners = data.map((banner) => BannerModel.fromJson(banner)).toList();
        return banners;
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/banner"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        List<dynamic> data= jsonDecode(response.body);
        List<BannerModel> banners=     data.map((banner)=> BannerModel.fromJson(banner)).toList();
        
        // Cache the data
        await SharedPreferencesService.saveDataWithTimestamp('banners', jsonEncode(data));
        
        return banners;
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load banners");
      }
    }catch(e){
      throw Exception("Error loading banners: $e");
    }

  }
}