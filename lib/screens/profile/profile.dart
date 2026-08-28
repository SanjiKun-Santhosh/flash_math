import 'package:flash_math/models/user_record.dart';
import 'package:flash_math/screens/loading.dart';
import 'package:flash_math/screens/profile/profile_support.dart';
import 'package:flash_math/screens/template.dart';
import 'package:flash_math/screens/wrapper.dart';
import 'package:flash_math/services/auth.dart';
import 'package:flash_math/shared/authresult.dart';
import 'package:flash_math/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/game_record.dart';
import '../../models/user.dart';
import '../../services/hive_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final Auth _auth = Auth();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textNameController = TextEditingController();
  final TextEditingController _textPasswordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  bool _nameChanged = false;
  bool _emailChanged = false;
  bool _passwordChanged = false;
  bool _isAnonymous = false;
  final RecordBottomSheet recordBottomSheet = RecordBottomSheet();
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@!#%^&*.,:"-=+;$~])',
  );
  final Map<String, GameRecord> _updatedGameRecord =
      Map<String, GameRecord>.from(gameRecordInitialization);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mathUser = context.read<MathUser?>();
      final userRecord = context.read<UserRecord?>();
      if (mathUser != null) {
        context.read<HiveService>().loadProfileImage(mathUser.uid);
        _auth.checkAnonymousUser().then((value) {
          setState(() {
            _isAnonymous = value;
          });
        });
      }
      if (userRecord != null && _textNameController.text.isEmpty) {
        setState(() {
          _textNameController.text = userRecord.name.isEmpty
              ? "Player"
              : userRecord.name;
        });
      }
    });

    if (_textEmailController.text.isEmpty) {
      _auth.getEmail().then((email) {
        setState(() {
          if (mounted) {
            _textEmailController.text = email ?? '';
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _textEmailController.dispose();
    _textNameController.dispose();
    _textPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(HiveService service, String userId) async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) return;
    await service.saveProfileImage(userId, pickedImage.path);
    await service.loadProfileImage(userId);
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isAnonymous) {
        if (_emailChanged || _passwordChanged) {
          await _auth.linkAnonymousWithCredentials(
            _textEmailController.text,
            _textPasswordController.text,
          );
        }
        _auth.checkAnonymousUser().then((value) {
          setState(() {
            _isAnonymous = value;
          });
        });
      } else {
        if (_passwordChanged) {
          await _auth.updatePassword(_textPasswordController.text);
        }
        if (_emailChanged) {
          await _auth.updateEmail(_textEmailController.text);
        }
      }
      if (_nameChanged) {
        await _auth.updateName(_textNameController.text);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mathUser = context.watch<MathUser?>();
    final userRecord = context.watch<UserRecord?>();
    final hiveService = context.watch<HiveService>();
    if (mathUser == null) {
      return Template(child: Loading());
    }

    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _pickImage(hiveService, mathUser.uid),
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.red,
                          backgroundImage: hiveService.profileImage != null
                              ? FileImage(hiveService.profileImage!)
                              : const AssetImage(ImageGallery.profilePicture)
                                    as ImageProvider,
                          child: hiveService.profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: AppDecoration().textDecoration
                                    .copyWith(labelText: "Name"),
                                controller: _textNameController,
                                onChanged: (_) =>
                                    setState(() => _nameChanged = true),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                decoration: AppDecoration().textDecoration
                                    .copyWith(labelText: "Email"),
                                controller: _textEmailController,
                                onChanged: (_) =>
                                    setState(() => _emailChanged = true),
                                validator: (val) {
                                  if (val == null ||
                                      !val.contains('@') ||
                                      !val.contains('.')) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                decoration: AppDecoration().textDecoration
                                    .copyWith(labelText: "New Password"),
                                controller: _textPasswordController,
                                obscuringCharacter: "*",
                                obscureText: !_showPassword,
                                onChanged: (val) {
                                  setState(() {
                                    _passwordChanged = true;
                                  });
                                },
                                validator: (val) {
                                  if (val == null ||
                                      val.isEmpty ||
                                      val == "Password") {
                                    return null;
                                  }
                                  if (!_passwordRegex.hasMatch(val)) {
                                    return ErrorMsg().passwordErrorMsg;
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text("Show password"),
                                  const SizedBox(width: 5),
                                  Checkbox(
                                    value: _showPassword,
                                    onChanged: (val) {
                                      setState(
                                        () => _showPassword = !_showPassword,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      var gameData =
                                          userRecord?.gameRecord ??
                                          gameRecordInitialization;
                                      for (var key in _updatedGameRecord.keys) {
                                        if (gameData[key] == null) {
                                          _updatedGameRecord[key] =
                                              gameTypesInitialisation(key);
                                        } else {
                                          _updatedGameRecord[key] =
                                              gameData[key]!;
                                        }
                                      }
                                      recordBottomSheet
                                          .showCustomModalBottomSheet(
                                            context,
                                            gameRecord: _updatedGameRecord,
                                          );
                                    },
                                    child: const Text("View Record"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      if (_nameChanged ||
                                          _emailChanged ||
                                          _passwordChanged) {
                                        _saveProfileChanges();
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: const Icon(Icons.save_alt_rounded),
                                    label: const Text("Save Changes"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext bottomSheetContext) {
                                          bool isModalLoading = false;
                                          return StatefulBuilder(
                                            builder: (BuildContext modalContext, setModalState) {
                                              return Container(
                                                height: 400,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(20),
                                                    topRight: Radius.circular(20),
                                                  ),
                                                ),
                                                padding: const EdgeInsets.all(30),
                                                child: isModalLoading 
                                                  ? const Center(child: CircularProgressIndicator())
                                                  : Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(height: 20),
                                                    const Text(
                                                      "Are you sure you want to delete your account?",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      "This action is permanent and cannot be undone.",
                                                      style: TextStyle(fontSize: 16),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 40),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            foregroundColor: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            setModalState(() => isModalLoading = true);
                                                            AuthResult<void> result = await _auth.deleteAccount();
                                                            
                                                            if (!mounted) return;
                                                            
                                                            if (result.isSuccess) {
                                                              Navigator.of(this.context).pushAndRemoveUntil(
                                                                MaterialPageRoute(builder: (context) => const Wrapper()),
                                                                (Route<dynamic> route) => false,
                                                              );
                                                            } else {
                                                              setModalState(() => isModalLoading = false);
                                                              if (bottomSheetContext.mounted) {
                                                                Navigator.pop(bottomSheetContext);
                                                              }
                                                              if (mounted) {
                                                                ErrorHandling().showError(
                                                                  this.context,
                                                                  result.errorMsg ?? "An unknown error occurred",
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: const Text("Confirm"),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(modalContext);
                                                          },
                                                          child: const Text("Cancel"),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          );
                                        },
                                      );
                                    },
                                    label: const Text("Delete account"),
                                    icon: const Icon(Icons.delete_forever_rounded),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
