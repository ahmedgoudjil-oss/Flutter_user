//hadi tafichi header ta3 ki nthamou 3la category man home
import 'package:flutter/material.dart';
import 'dart:ui';

class InnerHeaderWidget extends StatelessWidget {
  const InnerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      child: Stack(
        children: [
          // خلفية الهيدر مع تدرج فاتح وزوايا دائرية وظل خفيف
          ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
            child: Container(
              width: screenWidth,
              height: 148,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF3F4F8),
                    Color(0xFFE9EAF6),
                    Color(0xFFDDE6F6),
                    Color(0xFFFAF7FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7F53AC).withOpacity(0.10),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // طبقة زجاجية شفافة مع تأثير blur وحدود خفيفة
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: screenWidth,
                        height: 148,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
                          border: Border.all(color: Color(0xFF5EACEA).withOpacity(0.08), width: 1.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // زر الرجوع + عنوان
          Positioned(
            left: screenWidth * 0.02,
            bottom: 28,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Color(0xFF5EACEA),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xFF5EACEA).withOpacity(0.16), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                
              ],
            ),
          ),
          // مربع البحث بنفس ستايل الهوم مع ظل أقوى
          Positioned(
            left: screenWidth * 0.17,
            bottom: 21,
            child: Material(
              elevation: 14,
              shadowColor: Color(0xFF5EACEA).withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 48,
                width: screenWidth * 0.5,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    hintText: "Search in category...",
                    hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF5EACEA)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/icons/searc1.png", width: 22, height: 22, color: Color(0xFF5EACEA)),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/icons/cam.png", width: 22, height: 22, color: Color(0xFF647DEE)),
                    ),
                    fillColor: Colors.white.withOpacity(0.96),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Color(0xFF5EACEA).withOpacity(0.14)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Color(0xFF5EACEA), width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // أيقونة الجرس مع ظل أقوى وحجم أكبر
          Positioned(
            right: screenWidth * 0.18,
            bottom: 28,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {},
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0xFF5EACEA).withOpacity(0.14), blurRadius: 12)],
                  ),
                  child: Center(
                    child: Image.asset('assets/icons/bell.png', width: 22, height: 22, color: Color(0xFF5EACEA)),
                  ),
                ),
              ),
            ),
          ),
          // أيقونة الرسائل مع ظل أقوى وحجم أكبر
          Positioned(
            right: screenWidth * 0.05,
            bottom: 28,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {},
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0xFF647DEE).withOpacity(0.14), blurRadius: 12)],
                  ),
                  child: Center(
                    child: Image.asset('assets/icons/message.png', width: 22, height: 22, color: Color(0xFF647DEE)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
