import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:datepicker_dropdown/order_format.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({required this.childWidget,super.key});
   final Widget childWidget; 
  @override
  Widget build(context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
       shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    elevation: 8,
    margin: const EdgeInsets.all(10),
      child: childWidget,
    );
  }
}

class ParkingSpaceField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController? textEditingController;


  const ParkingSpaceField({super.key, required this.label, this.icon,this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      keyboardType: TextInputType.number,  // Set number input type
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}



// class ContainerTextField extends StatefulWidget {
//   const ContainerTextField({super.key});

//   @override
//   MyContainerTextFieldState createState() {
//     return MyContainerTextFieldState();
//   }
// }

// class MyContainerTextFieldState extends State<ContainerTextField> {
//   // Create a global key that uniquely identifies the Form widget
//   // and allows validation of the form.
//   //
//   // Note: This is a GlobalKey<FormState>,
//   // not a GlobalKey<MyCustomFormState>.
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     // Build a Form widget using the _formKey created above.
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//         SizedBox(height: 20),
//         Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child:  TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter some text';
//               }
//               return null;
//             },
//             controller: _controllerAccountHolderName,
//             decoration: const InputDecoration(
//               labelText: 'Account Holder name',
//               border: OutlineInputBorder(),
//             ),)
//           )
//         ],
//       ),
//     );
//   }
// }