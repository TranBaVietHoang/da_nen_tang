import 'dart:io';  // Import để sử dụng File class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';  // Import Firebase Storage
import 'package:image_picker/image_picker.dart';  // Import Image Picker

class ProductForm extends StatefulWidget {
  final String? productId;  
  final String? productName;
  final String? productCategory;
  final double? productPrice;
  final String? imageUrl;

  ProductForm({
    this.productId,
    this.productName,
    this.productCategory,
    this.productPrice,
    this.imageUrl,
  });

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String _productName;
  late String _productCategory;
  late double _productPrice;
  String? _imageUrl; // Biến để lưu URL của ảnh

  @override
  void initState() {
    super.initState();
    _productName = widget.productName ?? '';
    _productCategory = widget.productCategory ?? '';
    _productPrice = widget.productPrice ?? 0.0;
    _imageUrl = widget.imageUrl;  // Nếu đã có ảnh từ trước (chỉnh sửa sản phẩm), hiển thị luôn
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload ảnh lên Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.png');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrl = url;  // Lưu URL của ảnh
      });
    }
  }

  Future<void> _addOrUpdateProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productData = {
        'name': _productName,
        'category': _productCategory,
        'price': _productPrice,
        'image_url': _imageUrl,  // Thêm URL ảnh vào dữ liệu sản phẩm
      };

      if (widget.productId != null) {
        // Cập nhật sản phẩm
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);
      } else {
        // Thêm sản phẩm mới
        await FirebaseFirestore.instance.collection('products').add(productData);
      }

      Navigator.pop(context);  // Quay lại màn hình danh sách sản phẩm
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _productName,
                decoration: const InputDecoration(labelText: 'Product Name'),
                onSaved: (value) => _productName = value!,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a product name';
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productCategory,
                decoration: const InputDecoration(labelText: 'Product Category'),
                onSaved: (value) => _productCategory = value!,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a category';
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productPrice.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _productPrice = double.parse(value!),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a price';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                ),  // Hiển thị ảnh đã chọn
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addOrUpdateProduct,
                child: Text(widget.productId != null ? 'Update Product' : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
