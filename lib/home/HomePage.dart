import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../SignInAndUp.dart';
import '../global/Common.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/Product.dart';
import '../utils/bottomSnackBar.dart';
import '../utils/show_exit_dialog.dart';
import 'AddEditProductPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Product> _products = [];
  bool _isLoading = true;


  void showStyledPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    // bool showSettingsButton = true,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding: EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 24),
        actionsPadding: EdgeInsets.only(right: 16, bottom: 16),
        title: Text(
          title,
          style: TextStyle(fontWeight: Common.weight2, fontFamily: 'bold', fontSize: 18, color: Common.primary),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(message, style: TextStyle(fontWeight: Common.weight2, fontFamily: 'bold', fontSize: Common.h2, color: Common.primary)),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Common.primary,
              side: BorderSide(color: Common.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text("Close", style: TextStyle(color: Common.secondary, fontFamily: 'bold',fontSize: Common.h2, fontWeight: Common.weight2)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadProducts(); // ⬅️ ADD THIS

  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(Common.baseUrl + 'products'),
        headers: {
          'Authorization': 'Bearer $token', // 🔐 Add token to header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load products');

      }
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      setState(() => _isLoading = false);
      getSnackBar(context, 'Check your Internet Connection', Colors.orange, 2);
    }
  }




  @override
  void dispose() { // Cancel timer when widget is disposed
    super.dispose();
  }

  Future<bool> logout() async {
    final screenWidth = MediaQuery.of(context).size.width;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Common.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titlePadding: const EdgeInsets.only(
          top: 20,
          left: 24,
          right: 24,
          bottom: 15,
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        title: Text(
          "Logout",
          style: TextStyle(
            fontWeight: Common.weight,
            color: Common.primary,
            fontSize: Common.title,
          ),
        ),
        content: SizedBox(
          width: screenWidth * 0.9,
          child: Text(
            "Are you sure you want to Logout?",
            style: TextStyle(
              color: Common.primary,
              fontWeight: Common.weight,
              fontSize: Common.h2,
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Common.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Common.primary,
                fontWeight: Common.weight,
                fontSize: Common.h2,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Common.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "Logout",
              style: TextStyle(
                color: Common.secondary,
                fontWeight: Common.weight,
                fontSize: Common.h2,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // ✅ Clears all keys including token

      // Optional: Navigate to login/signup screen after logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInAndUp()),
            (route) => false,
      );
    }

    return shouldExit ?? false;
  }


  Future<void> deleteProduct(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(Common.baseUrl + "products/$id");
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        getSnackBar(context, 'Product deleted successfully', Colors.green, 2);
        _loadProducts();
        setState(() {
          _isLoading = false;
        });
      } else {
        getSnackBar(context, 'Delete failed', Colors.red, 2);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      getSnackBar(context, 'Check your Internet Connection', Colors.orange, 2);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> updateProduct(Product product, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(Common.baseUrl + "products/${product.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
        }),
      );

      if (response.statusCode == 200) {
        getSnackBar(context, 'Product updated successfully', Colors.green, 2);
        return true;
      } else {
        getSnackBar(context, 'Update failed', Colors.red, 2);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      getSnackBar(context, 'Check your Internet Connection', Colors.orange, 2);
      return false;
    }
  }



  // int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/home.svg',
                  width: 25,
                  height: 25,
                  color: Common.primary,
                ),
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap:
                  () async => {
                    // setState(() {
                    //   _isLoading = true;
                    // }),
                    logout()
                  },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  'assets/Icons/logout.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
          title: Text(
            'Home',
            style: TextStyle(fontSize: Common.title, fontFamily: Common.family),
          ),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 8),
            child: Column(
              children: [
                SizedBox(height: 5),
                Expanded(
                  child: _isLoading
                      ? ListView.builder(
                    itemCount: 10,
                    itemBuilder: (_, __) => ProductCardShimmer(),
                  )
                      : RefreshIndicator(
                    onRefresh: () async{
                      _loadProducts();
                    },
                    color: Common.primary,
                    backgroundColor: Common.secondary,
                    child: _products.isEmpty
                        ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * .8, // 👈 center relative to screen
                          alignment: Alignment.center,
                          child: Lottie.asset(
                            'assets/animation/empty2.json',
                            height: 200,
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      itemCount: _products.length + 1, // 👈 extra item for bottom spacing
                      itemBuilder: (ctx, index) {
                        if (index == _products.length) {
                          return const SizedBox(height: 100); // 👈 padding for FAB space
                        }
                        final product = _products[index];
                        return Slidable(
                          key: ValueKey(product.id),
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditProductPage(product: product),
                                    ),
                                  );
                                  if (result == true) _loadProducts();
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  final confirm = await showDeleteConfirmationDialog(context);
                                  if (confirm == true) {
                                    await deleteProduct(product.id);
                                    setState(() => _products.removeAt(index));
                                  }
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          child: ProductCard(
                            product: product,
                          ),
                        );
                      },
                    )
                  ),
                )

              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditProductPage()),
            );
            if (result == true) {
              setState(() => _isLoading = true);
              _loadProducts(); // refresh product list
            }
          },
          backgroundColor: Common.secondary,
          icon: SvgPicture.asset(
            'assets/Icons/add.svg',
            width: 18,
            height: 18,
            color: Common.primary,
          ),
          label: Text(
            'Add Product',
            style: TextStyle(
              color: Common.primary,
              fontFamily: 'bold',
              fontWeight: Common.weight2,
              fontSize: Common.h3,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

      ),
    );
  }

}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Common.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Shimmer.fromColors(
          baseColor: Common.primary,
          highlightColor: Colors.grey.shade300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row shimmer
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Common.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 14,
                      color: Common.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description shimmer
              Container(
                height: 10,
                width: double.infinity,
                color: Common.secondary,
              ),
              const SizedBox(height: 6),
              Container(
                height: 10,
                width: double.infinity,
                color: Common.secondary,
              ),
              const SizedBox(height: 10),

              // Price shimmer
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 80,
                  height: 12,
                  color: Colors.blue.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Common.primary,
      elevation: 5,
      child: Shimmer.fromColors(
        highlightColor: Colors.grey.shade300,
        baseColor: Common.primary,
        // baseColor: Common.secondary,
        // highlightColor: Common.primary,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100,
                  height: 10,
                  color: Common.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 24, height: 24, color: Common.secondary),
                  const SizedBox(width: 16),
                  Container(width: 60, height: 10, color: Common.secondary),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Common.secondary,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Common.secondary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 24, height: 24, color: Common.secondary),
                  const SizedBox(width: 16),
                  Container(width: 60, height: 10, color: Common.secondary),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 10,
                color: Common.secondary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(height: 10, color: Common.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(height: 10, color: Common.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(width: 60, height: 24, color: Common.secondary),
                  const SizedBox(width: 16),
                  Container(width: 60, height: 24, color: Common.secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product,});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Common.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 3,),
                          Image.asset('assets/Icons/box.png', width: 20, height: 20,),
                        ],
                      ),
                      SizedBox(width: 10,),
                      Expanded( child: Text(product.name, style: TextStyle(color: Common.secondary, fontSize: 18, fontFamily: 'bold', fontWeight: FontWeight.bold,))),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded( child: Text(product.description, style: TextStyle(color: Common.light, fontSize: Common.h3, fontFamily: 'bold', fontWeight: FontWeight.bold,))),
                    ],
                  ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Expanded(flex:2, child: Text("Product Description", textAlign: TextAlign.start, style: TextStyle(color: Common.secondary, fontSize: Common.h1, fontFamily: 'bold', fontWeight: FontWeight.bold))),
                  //     Expanded(flex:2, child: Text(product.description, textAlign: TextAlign.end, style: TextStyle(color: Common.secondary, fontSize: Common.h1, fontFamily: 'bold', fontWeight: FontWeight.bold,))),
                  //   ],
                  // ),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded( child: Text('Rs. ${product.price}', textAlign: TextAlign.end, style: TextStyle(color: Colors.blue, fontSize: Common.h2, fontFamily: 'bold', fontWeight: Common.weight2,))),
                    ],
                  ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Expanded(flex:2, child: Text("Product Price", textAlign: TextAlign.start, style: TextStyle(color: Common.secondary, fontSize: Common.h1, fontFamily: 'bold', fontWeight: FontWeight.bold))),
                  //     Expanded(flex:2, child: Text('Rs. ${product.price}', textAlign: TextAlign.end, style: TextStyle(color: Common.secondary, fontSize: Common.h1, fontFamily: 'bold', fontWeight: FontWeight.bold,))),
                  //   ],
                  // ),
                  // SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




