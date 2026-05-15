import 'package:flutter/material.dart';
import 'package:garbage_collection_system/Api/userController.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';
import 'package:garbage_collection_system/custom_widgets/inputfield.dart';
import 'package:garbage_collection_system/custom_widgets/card.dart';

class RateCompany extends StatefulWidget {
  const RateCompany({super.key});

  @override
  State<RateCompany> createState() => _RateCompanyState();
}

class _RateCompanyState extends State<RateCompany> {
  static const Color appColor = Color(0xFF99C13D);
  static const Color backgroundColor = Color(0xFFF7F9F5);

  int selectedRating = 0;
  bool isSubmitting = false;

  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  String getRatingText() {
    if (selectedRating == 1) return "Poor";
    if (selectedRating == 2) return "Fair";
    if (selectedRating == 3) return "Good";
    if (selectedRating == 4) return "Very Good";
    if (selectedRating == 5) return "Excellent";
    return "Tap stars to rate";
  }

 Future<void> submitRating() async {
  if (selectedRating == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a rating first"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isSubmitting = true;
  });

  try {
    final review = reviewController.text.trim();

    final data = await UserApi().rateCompany(
      rating: selectedRating,
      review: review,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data["message"] ?? "Rating submitted successfully"),
        backgroundColor: appColor,
      ),
    );

    setState(() {
      selectedRating = 0;
      reviewController.clear();
    });
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll("Exception: ", "")),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
    }
  }
}

  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final bool isSelected = starValue <= selectedRating;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = starValue;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_border_rounded,
              size: 42,
              color: isSelected ? appColor : Colors.black26,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: appColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Rate Company",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 18),

            // ✅ How was your service container replaced with CustomCard
            CustomCard(
              title: "How was your service?",
              subtitle:
                  "Your feedback helps improve garbage collection service.",
              icon: Icons.star_rate_rounded,
              onTap: () {},
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.black.withOpacity(0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Rate Your Company",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    getRatingText(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),

                  buildStarRating(),

                  const SizedBox(height: 24),

                  CustomInput(
                    label: "Write your feedback",
                    controller: reviewController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    maxLength: 500,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: isSubmitting
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                        : CustomButton(
                            text: "Submit Rating",
                            icon: Icons.send_rounded,
                            onPressed: submitRating,
                            backgroundColor: appColor,
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.black54,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Please rate only after using the company service.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}