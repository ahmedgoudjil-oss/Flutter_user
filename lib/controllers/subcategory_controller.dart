import 'package:cloudinary_public/cloudinary_public.dart';

import 'package:http/http.dart' as http;
import 'package:untitled/globale_variables.dart';

import 'dart:convert';

import 'package:untitled/models/category.dart';
import 'package:untitled/models/subcategory.dart';
import 'package:untitled/services/shared_preferences_service.dart';

class SubcategoryController {
  Future<List<Subcategory>> getSubCategoriesByCategoryName(String categoryName)async{
    try {
      // Check cache first
      String? cachedData = SharedPreferencesService.getSubCategories(categoryName);
      if (cachedData != null && !SharedPreferencesService.isDataStale('subcategories_$categoryName', 2)) {
        final List<dynamic> data = jsonDecode(cachedData);
        if (data.isNotEmpty) {
          return data
              .map((subcategory) => Subcategory.fromJson(subcategory))
              .toList();
        } else {
          return [];
        }
      }
      
       http.Response response =await http.get(Uri.parse("$uri/api/category/$categoryName/subcategories"),
      headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        );
        if (response.statusCode == 200) {
  final List<dynamic> data = jsonDecode(response.body);

  if (data.isNotEmpty) {
    // Cache the data
    await SharedPreferencesService.saveDataWithTimestamp('subcategories_$categoryName', jsonEncode(data));
    
    return data
        .map((subcategory) => Subcategory.fromJson(subcategory))
        .toList();
  } else {
    return [];
  }
} else if (response.statusCode == 404) {
  return[];
} else {
  return [];
}

    } catch (e) {
      return[];
    }

  }
}
