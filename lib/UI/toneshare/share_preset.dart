import 'package:flutter/material.dart';

class PresetForm extends StatefulWidget {
  @override
  _PresetFormState createState() => _PresetFormState();
}

class _PresetFormState extends State<PresetForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _instrumentOptions = [
    "Electric guitar",
    "Bass guitar",
    "Acoustic guitar",
  ];
  final List<String> _genreOptions = [
    "Rock",
    "Blues",
    "Pop",
    "Other",
  ];
  String _name = "";
  String _description = "";
  String? _instrument;
  String? _genre;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: handle form submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Preset"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Enter preset name",
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter a name";
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Enter preset description",
                ),
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Instrument",
                ),
                value: _instrument,
                items: _instrumentOptions
                    .map((instrument) => DropdownMenuItem(
                          value: instrument,
                          child: Text(instrument),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _instrument = value ?? ""),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Genre",
                ),
                value: _genre,
                items: _genreOptions
                    .map((genre) => DropdownMenuItem(
                          value: genre,
                          child: Text(genre),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _genre = value ?? ""),
              ),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Upload"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
