import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/route_constants.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({
    required this.isEditable,
  });

  final bool isEditable;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserService _userService = UserService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKeyUserInfo = GlobalKey<FormState>();

  DateTime? _selectedDate;
  String? _gender = 'Male';
  File? _profileImage;
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    FocusScope.of(context).unfocus();
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _changeGender(String gender) async {
    setState(() => _gender = gender);
  }

  List<String> buildSearchKeywords(String firstName, String lastName) {
    final keywords = <String>{};

    void addPrefixes(String value) {
      value = value.toLowerCase();
      for (int i = 1; i <= value.length; i++) {
        keywords.add(value.substring(0, i));
      }
    }

    addPrefixes(firstName);
    addPrefixes(lastName);
    addPrefixes('$firstName $lastName');

    return keywords.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup profile",
            style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        leading: widget.isEditable
            ? IconButton(
                icon: Icon(LucideIcons.arrowLeft),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(LucideIcons.user, size: 50, color: Colors.grey)
                          : null,
                      backgroundColor: cardBackgroundColor,
                    ),
                    Positioned(
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 1,
                              offset: Offset(0, 0),
                            ),
                          ],
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          border: Border.all(
                            color: backgroundColor,
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            LucideIcons.camera,
                            color: backgroundColor,
                            size: 19,
                          ),
                          onPressed: _takePicture,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text(
                    "Upload Image",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Form(
                  key: _formKeyUserInfo,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _BuildTextField(
                              label: "First Name",
                              controller: _firstNameController,
                            ),
                          ),
                          const SizedBox(width: defaultPadding),
                          Expanded(
                            child: _BuildTextField(
                              label: "Last Name",
                              controller: _lastNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            validator: (value) => value!.isEmpty
                                ? "Please enter your date of birth"
                                : null,
                            decoration: InputDecoration(
                              hintText: "Date of Birth",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: defaultPadding * 0.75),
                                child: Icon(
                                  LucideIcons.calendar,
                                  size: 24,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withOpacity(0.3),
                                ),
                              ),
                            ),
                            controller: TextEditingController(
                              text: _selectedDate != null
                                  ? DateFormat.yMMMd().format(_selectedDate!)
                                  : '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Text("Gender:",
                        style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: defaultPadding / 2),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: "Male",
                        isSelected: _gender == "Male",
                        icon: LucideIcons.user,
                        onTap: () => _changeGender("Male"),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _GenderOption(
                        label: "Female",
                        isSelected: _gender == "Female",
                        icon: LucideIcons.userCircle,
                        onTap: () => _changeGender("Female"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding * 4),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKeyUserInfo.currentState!.validate() &&
                        _selectedDate != null) {
                      final name = [
                        _firstNameController.text,
                        _lastNameController.text
                      ].join(' ');
                      Map<String, dynamic> user = {
                        "firstName": _firstNameController.text,
                        "lastName": _lastNameController.text,
                        "name": name,
                        "dateOfBirth": _selectedDate,
                        "gender": _gender,
                        'searchKeywords': buildSearchKeywords(
                            _firstNameController.text,
                            _lastNameController.text),
                      };

                      await _userService.updateUserWithJson(user);

                      if (_profileImage != null) {
                        final downloadUrl = await _userService
                            .uploadImageToFirebase(_profileImage!);
                        // Optionally save the URL to Firestore
                        await _userService.saveImageUrlToFirestore(downloadUrl);
                      }

                      Navigator.pushNamed(context, selectSportsScreenRoute);
                    }
                  },
                  child: const Text("Continue"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _BuildTextField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? "Please fill in" : null,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: label,
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: defaultPadding,
          horizontal: defaultPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryMaterialColor.shade900 : cardBackgroundColor,
          border: Border.all(
            color: isSelected ? primaryColor : cardBackgroundColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: whiteColor,
                ),
                const SizedBox(width: defaultPadding / 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: defaultPadding),
            if (isSelected)
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.check, size: 16, color: backgroundColor),
              ),
          ],
        ),
      ),
    );
  }
}
