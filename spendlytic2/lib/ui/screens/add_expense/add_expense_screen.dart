import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Import Image Picker

// Logic
import '../../../logic/transaction_cubit/transaction_cubit.dart';

// Services
import '../../../services/gemini_service.dart'; // ✅ Import Service

// Core & Models
import '../../../core/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../core/app_text_styles.dart';

// Local Widgets
import 'widgets/compact_category_dropdown.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _ExpenseRow {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  CategoryModel category = CategoryModel.list[0];

  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
  }
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final List<_ExpenseRow> _rows = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker(); // ✅ Image Picker Instance

  @override
  void initState() {
    super.initState();
    _addNewRow();
  }

  @override
  void dispose() {
    for (var row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addNewRow() {
    setState(() {
      _rows.add(_ExpenseRow());
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows[index].dispose();
        _rows.removeAt(index);
      });
    } else {
      _rows[0].titleCtrl.clear();
      _rows[0].amountCtrl.clear();
      setState(() {
        _rows[0].category = CategoryModel.list[0];
      });
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var row in _rows) {
      final val = double.tryParse(row.amountCtrl.text) ?? 0;
      total += val;
    }
    return total;
  }

  Future<void> _saveAll() async {
    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      if (row.titleCtrl.text.isEmpty || row.amountCtrl.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Row #${i + 1} is empty.")));
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      for (var row in _rows) {
        final title = row.titleCtrl.text.trim();
        final amount = double.parse(row.amountCtrl.text.trim());

        context.read<TransactionCubit>().addTransaction(
          title: title,
          amount: amount,
          category: row.category.name,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          for (var row in _rows) {
            row.dispose();
          }
          _rows.clear();
          _addNewRow();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transactions saved!"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
      );
    }
  }

  // --- 📸 REAL AI SCANNER ---
  Future<void> _handleScan(ImageSource source) async {
    try {
      // 1. Pick Image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Resize to speed up upload
        imageQuality: 80,
      );

      if (image == null) return; // User cancelled

      // 2. Show Loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.darkPurple),
                  SizedBox(height: 16),
                  Text("Analyzing..."),
                ],
              ),
            ),
          ),
        ),
      );

      // 3. Convert to Bytes & Call Service
      final bytes = await image.readAsBytes();
      final items = await GeminiService().scanReceipt(bytes);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No items detected. Try a clearer photo."),
          ),
        );
        return;
      }

      // 4. Populate UI
      setState(() {
        // Clear first empty row if it exists
        if (_rows.length == 1 && _rows[0].titleCtrl.text.isEmpty) {
          _rows[0].dispose();
          _rows.clear();
        }

        for (var item in items) {
          final row = _ExpenseRow();
          row.titleCtrl.text = item['title'].toString();
          row.amountCtrl.text = item['amount'].toString();
          row.category = CategoryModel.fromName(item['category'].toString());
          _rows.add(row);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✨ ${items.length} items extracted!"),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading if error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Scan Error: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Show Bottom Sheet to pick Camera or Gallery
  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.darkPurple,
              ),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(ctx);
                _handleScan(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.darkIndigo,
              ),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(ctx);
                _handleScan(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Batch Entry"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.document_scanner_outlined,
            color: AppColors.darkPurple,
          ),
          onPressed: _showScanOptions, // ✅ Triggers Real Scan
          tooltip: "Scan Receipt",
        ),
      ),
      body: Column(
        children: [
          // --- SCROLLABLE LIST OF ROWS ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length + 1,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _rows.length) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: _addNewRow,
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.darkPurple,
                      ),
                      label: const Text(
                        "Add Another Item",
                        style: TextStyle(
                          color: AppColors.darkPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  );
                }

                final row = _rows[index];
                return Dismissible(
                  key: ValueKey(row),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeRow(index),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkPurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: row.titleCtrl,
                                decoration: const InputDecoration(
                                  hintText: "Item Name",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () => _removeRow(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: row.amountCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  prefixText: "RM ",
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkPurple,
                                    fontSize: 14,
                                  ),
                                  hintText: "0.00",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkPurple,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Expanded(
                              flex: 3,
                              child: CompactCategoryDropdown(
                                selectedCategory: row.category,
                                onChanged: (newCat) {
                                  setState(() => row.category = newCat);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- FOOTER ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${_rows.length} Items", style: AppTextStyles.label),
                      Text(
                        currency.format(_calculateTotal()),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkIndigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.mainGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkPurple.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "SAVE TRANSACTIONS",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
