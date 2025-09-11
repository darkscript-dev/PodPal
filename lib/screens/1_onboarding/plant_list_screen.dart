import 'package:flutter/material.dart';
import 'package:podpal/widgets/custom_button.dart';

class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({super.key});

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  // Controller for the Autocomplete text field.
  final _plantTypeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const List<String> _plantOptions = <String>[
    'Basil',
    'Mint',
    'Lettuce',
    'Cherry Tomatoes',
    'Cilantro',
    'Parsley',
    'Spinach',
    'chilli',
    'Chives',
    'Oregano',
    'Thyme',
    'Rosemary',
    'Microgreens',
    'Arugula',
    'Kale',
  ];

  // Options for the dropdown
  final List<String> _plantStages = ['Seed', 'Seedling', 'Young Plant', 'Mature Plant'];
  String? _selectedStage;

  @override
  void initState() {
    super.initState();
    _selectedStage = _plantStages.first; // Set default value
  }

  @override
  void dispose() {
    _plantTypeController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (_formKey.currentState!.validate()) {
      // Pass the selected data to the next screen
      Navigator.pushNamed(
        context,
        '/name_plant',
        arguments: {
          'plantType': _plantTypeController.text.trim(),
          'plantStage': _selectedStage!,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'PodPal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's find your\nplant",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                Autocomplete<String>(
                  // This builds the list of suggestions.
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    // If the search field is empty, return the entire list.
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    // Otherwise, filter the list based on the user's input.
                    return _plantOptions.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },

                  // This runs when a user taps on a suggestion.
                  onSelected: (String selection) {
                    debugPrint('You just selected $selection');
                    _plantTypeController.text = selection;
                  },

                  // This builds the text field itself.
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                    // We assign our controller to the one provided by the builder.
                    // This is a bit of a workaround to use our existing controller.
                    // A cleaner way is to just use the `fieldController` directly.
                    // For simplicity, we'll stick with our own.
                    return TextFormField(
                      controller: _plantTypeController, // Use our controller
                      focusNode: fieldFocusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'What are you planting? (e.g., Basil)',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2C2C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter or select a plant type';
                        }
                        return null;
                      },
                    );
                  },

                  // This builds the suggestion list UI.
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 200.0,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option, style: const TextStyle(color: Colors.white)),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Dropdown for Plant Stage
                DropdownButtonFormField<String>(
                  value: _selectedStage,
                  dropdownColor: const Color(0xFF2C2C2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Current Stage',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _plantStages.map((String stage) {
                    return DropdownMenuItem<String>(
                      value: stage,
                      child: Text(stage),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStage = newValue;
                    });
                  },
                ),
                const Spacer(),

                // Next Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomButton(
                    text: 'Next',
                    onPressed: _navigateToNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}