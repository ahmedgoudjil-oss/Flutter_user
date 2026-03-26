//bach nhatou fi cloudinary

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/globale_variables.dart';

import 'dart:convert';

import 'package:untitled/models/category.dart';
import 'package:untitled/services/manage_http_response.dart';
import 'package:untitled/services/shared_preferences_service.dart';




class CategoryController {
  
  Future < List <Category> > loadCategories ()async{
    try{
      // Check cache first
      String? cachedData = SharedPreferencesService.getCategories();
      if (cachedData != null && !SharedPreferencesService.isDataStale('categories', 2)) {
        final List<dynamic> data = jsonDecode(cachedData);
        List<Category> categories = data.map((category) => Category.fromJson(category)).toList();
        return categories;
      }
      
      // send http get request
      http.Response response =await http.get(Uri.parse("$uri/api/categories"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },

      );
      if(response.statusCode==200){
        final List<dynamic> data= jsonDecode(response.body);
        List<Category> categories =     data.map((category)=> Category.fromJson(category)).toList();
        
        // Cache the data
        await SharedPreferencesService.saveDataWithTimestamp('categories', jsonEncode(data));
        
        return categories;
      } else if(response.statusCode==404){
        return [];
      } else{
        throw Exception("Failed to load categories");
      }
    }catch(e){
      throw Exception("Error loading categories: $e");
    }

  }
}