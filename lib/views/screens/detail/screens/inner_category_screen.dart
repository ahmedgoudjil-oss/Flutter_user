//hadi tafichi bnv ta3 ki nthamou 3la category man home

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/controllers/subcategory_controller.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/models/subcategory.dart';
import 'package:untitled/views/screens/detail/screens/widgets/inner_banner_widget.dart';
import 'package:untitled/views/screens/detail/screens/widgets/inner_category_content_widget.dart';
import 'package:untitled/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:untitled/views/screens/nav_screens/account_screen.dart';
import 'package:untitled/views/screens/nav_screens/cart_screen.dart';
import 'package:untitled/views/screens/nav_screens/category_screen.dart';
import 'package:untitled/views/screens/nav_screens/favorite_screen.dart';
import 'package:untitled/views/screens/nav_screens/stores_screen.dart';

class InnerCategoryScreen extends StatefulWidget {
  final Category category;

  const InnerCategoryScreen({super.key, required this.category});

  @override
  State<InnerCategoryScreen> createState() => _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryScreen> {
  late Future<List <Subcategory>> _subCategories;
  final SubcategoryController _subcategoryController = SubcategoryController();
  int pageIndex=0;
  @override
  void initState() {
    super.initState();
   _subCategories = _subcategoryController.getSubCategoriesByCategoryName(widget.category.name);
  }
  @override
  Widget build(BuildContext context) {
    
  final List<Widget> pages = [
    InnerCategoryContentWidget(category: widget.category),
    FavoriteScreen(),
    CategoryScreen(),
    StoresScreen(),
    CartScreen(),
    AccountScreen(),
  ];
    return Scaffold(
      
       bottomNavigationBar: BottomNavigationBar(
      selectedItemColor: Colors.purple,

       useLegacyColorScheme: true,
         selectedFontSize: 15,
         unselectedFontSize: 15,
         unselectedItemColor: Colors.grey,
         currentIndex:pageIndex ,
        onTap: (value){
           setState(() {
             pageIndex=value;
           });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/icons/home.png",width: 25,),
            label: "home"
          ),
          
          BottomNavigationBarItem(

              icon: Image.asset("assets/icons/love.png",width: 25,),
              label: "Favorite"
          ),
          BottomNavigationBarItem(

              icon: Icon(Icons.category),
              label: "Category"
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/icons/mart.png",width: 25,),
              label: "Stores"
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/icons/cart.png",width: 25,),
              label: "Cart"
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/icons/user.png",width: 25,),
              label: "Account"
          ),
    ]),
      body: pages[pageIndex],
     
        
      );
    
  }
}
