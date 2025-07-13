import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_front/global/Common.dart';
import 'package:http/http.dart' as http;
import '../model/Product.dart';
import '../utils/bottomSnackBar.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;
  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  // final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameCtrl.text = widget.product!.name;
      descCtrl.text = widget.product!.description;
      priceCtrl.text = widget.product!.price.toString();
    }
  }

  Future<void> _submit() async {

    if (nameCtrl.text.trim().isEmpty ||
        descCtrl.text.trim().isEmpty ||
        priceCtrl.text.trim().isEmpty) {
      getSnackBar(context, 'Please fill all fields', Colors.orange, 2);
      return;
    }

    setState(() => _isSaving = true);

    final productData = {
      "name": nameCtrl.text,
      "description": descCtrl.text,
      "price": int.tryParse(priceCtrl.text) ?? 0,
    };

    final isEdit = widget.product != null;
    final url = isEdit
        ? Uri.parse("${Common.baseUrl}products/${widget.product!.id}")
        : Uri.parse("${Common.baseUrl}products");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await (isEdit
          ? http.put(url, headers: headers, body: jsonEncode(productData))
          : http.post(url, headers: headers, body: jsonEncode(productData)));

      if (response.statusCode == 200 || response.statusCode == 201) {
        getSnackBar(context, isEdit ? 'Product updated' : 'Product added', Colors.green, 0);
        Navigator.pop(context, true);
      } else {
        setState(() => _isSaving = false);
        getSnackBar(context, 'Failed to ${isEdit ? "Update" : "Add"} product', Colors.red, 1);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint('❌ Submit Error: $e');
      getSnackBar(context, 'Check your Internet Connection', Colors.orange, 2);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "Add Product" : "Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: nameCtrl,
                    cursorColor: Common.secondary,
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: Common.h2,
                      fontWeight: Common.weight2,
                      color: Common.secondary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,         // removes underline
                      enabledBorder: InputBorder.none,  // removes underline when enabled
                      focusedBorder: InputBorder.none,  // removes underline when focused
                      hintText: "Product Name",
                      hintStyle: TextStyle(             // ✅ corrected
                        fontFamily: 'bold',
                        fontSize: Common.h2,
                        fontWeight: Common.weight2,
                        color: Colors.grey,
                      ), // no hint text
                      contentPadding: EdgeInsets.zero,  // remove extra padding
                      isCollapsed: true, // make it tighter
                    ),
                  ),
                ),
              )
          ),

          SizedBox(height: 10,),
          Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                        child: TextField(
                          controller: descCtrl,
                          cursorColor: Common.secondary,
                          style: TextStyle(
                            fontFamily: 'bold',
                            fontSize: Common.h2,
                            fontWeight: Common.weight2,
                            color: Common.secondary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,         // removes underline
                            enabledBorder: InputBorder.none,  // removes underline when enabled
                            focusedBorder: InputBorder.none,  // removes underline when focused
                            hintText: "Description",
                            hintStyle: TextStyle(             // ✅ corrected
                              fontFamily: 'bold',
                              fontSize: Common.h2,
                              fontWeight: Common.weight2,
                              color: Colors.grey,
                            ), // no hint text
                            contentPadding: EdgeInsets.zero,  // remove extra padding
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
            SizedBox(height: 10,),
            Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            cursorColor: Common.secondary,
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: Common.h2,
                              fontWeight: Common.weight2,
                              color: Common.secondary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,         // removes underline
                              enabledBorder: InputBorder.none,  // removes underline when enabled
                              focusedBorder: InputBorder.none,  // removes underline when focused
                              hintText: 'Price',
                              hintStyle: TextStyle(             // ✅ corrected
                                fontFamily: 'bold',
                                fontSize: Common.h2,
                                fontWeight: Common.weight2,
                                color: Colors.grey,
                              ), // no hint text
                              contentPadding: EdgeInsets.zero,  // remove extra padding
                              isCollapsed: true, // make it tighter
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          SizedBox(height: 20,),
          InkWell(
            // onTap: _handleGoogleSignIn,
            onTap: _isSaving ? null : _submit,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Common.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
              _isSaving
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Common.primary),
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: Common.h2,
                      fontWeight: Common.weight2,
                      color: Common.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
