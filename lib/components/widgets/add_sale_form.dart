// import 'package:dairy_harbor/pages/milk/milk_distribution_sales.dart';
// import 'package:flutter/material.dart';

// class AddSaleForm extends StatefulWidget {
//   final void Function(Sale) onSave;

//   const AddSaleForm({required this.onSave, Key? key}) : super(key: key);

//   @override
//   _AddSaleFormState createState() => _AddSaleFormState();
// }

// class _AddSaleFormState extends State<AddSaleForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _saleAmountController = TextEditingController();
//   final _milkDistributedController = TextEditingController();

//   @override
//   void dispose() {
//     _saleAmountController.dispose();
//     _milkDistributedController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Add Sale'),
//       content: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: _saleAmountController,
//               decoration: const InputDecoration(labelText: 'Sale Amount'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the sale amount';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _milkDistributedController,
//               decoration: const InputDecoration(labelText: 'Milk Distributed (liters)'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter the amount of milk distributed';
//                 }
//                 return null;
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: const Text('Cancel'),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         ElevatedButton(
//           child: const Text('Save'),
//           onPressed: () {
//             if (_formKey.currentState?.validate() ?? false) {
//               final saleAmount = double.tryParse(_saleAmountController.text) ?? 0.0;
//               final milkDistributed = double.tryParse(_milkDistributedController.text) ?? 0.0;
//               final sale = Sale(saleAmount: saleAmount, milkDistributed: milkDistributed);

//               widget.onSave(sale); // Call the callback

//               Navigator.of(context).pop();
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
