import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class GenerateBagsScreen extends StatefulWidget {
  const GenerateBagsScreen({super.key});

  @override
  State<GenerateBagsScreen> createState() => _GenerateBagsScreenState();
}

class _GenerateBagsScreenState extends State<GenerateBagsScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String bagType = "Recyclable";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Bags"),
        backgroundColor: const Color(0xFF99C13D),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              CustomInput(
                label: "User ID",
                controller: userIdController,
                keyboardType: TextInputType.number,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Enter User ID";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomInput(
                label: "Quantity of Bags",
                controller: quantityController,
                keyboardType: TextInputType.number,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Enter Quantity";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: bagType,
                items: const [
                  DropdownMenuItem(
                    value: "Recyclable",
                    child: Text("Recyclable"),
                  ),
                  DropdownMenuItem(
                    value: "Non-Recyclable",
                    child: Text("Non-Recyclable"),
                  ),
                ],
                onChanged: (value){
                  setState(() {
                    bagType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Bag Type",
                  filled: true,
                  fillColor: const Color(0xFFD0E5FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              CustomInput(
                label: "Weight Limit",
                controller: weightController,
                keyboardType: TextInputType.number,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Enter Weight Limit";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              CustomButton(
                text: "Generate Bags",
                onPressed: (){
                  if(_formKey.currentState!.validate()){
                    print("Form Valid");
                  }
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}