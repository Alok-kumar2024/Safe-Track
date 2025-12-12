import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/customWidgets/custom_TextField.dart';
import 'package:safe_track/presentation/screens/home_screen.dart';
import 'package:safe_track/state/profile_provider.dart';

// someProblem on this page.. will see it later..... have to implement error red border for
// all i know how , but is a bit complex...

class ProfileSetUpScreen extends StatelessWidget {
  const ProfileSetUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8), Color(0xFFF5F3FF)],
          ),
        ),
        child: MainSet(),
      ),
    );
  }
}

class MainSet extends StatefulWidget {
  const MainSet({super.key});

  @override
  State<MainSet> createState() => _MainSetState();
}

class _MainSetState extends State<MainSet> {
  Future<String?>? _saveFuture;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            SizedBox(height: 50),
            // Header Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Setup Your Profile",
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Add your details and emergency contacts to stay safe",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ProfileSet(),
            SizedBox(height: 20),
            Contacts(),
            SizedBox(height: 100),
          ],
        ),
        if (_saveFuture != null)
          Center(
            child: FutureBuilder<String?>(
              future: _saveFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.black),
                      Text(
                        "Saving Profile....",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${snapshot.error}')),
                      );

                      setState(() {
                        _saveFuture = null;
                      });
                    });

                    return SizedBox.shrink();
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(snapshot.data!)));

                      setState(() {
                        _saveFuture = null;
                      });
                    });

                    return SizedBox.shrink();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Profile Saved SuccessFully.")),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  });

                  return const SizedBox.shrink();
                }

                return SizedBox.shrink();
              },
            ),
          ),
        // Floating Complete Button
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9333EA),
                  Color(0xFFC026D3),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF9333EA).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Consumer<ProfileProvider>(
              builder: (ctx, prd, _) {
                // final names = prd.getTECNames();
                // final numbers = prd.getTECNumber();
                // final userName = prd.getName();
                // final userEmail = prd.getEmail();

                return ElevatedButton(
                  onPressed: () async {
                    // print('Button pressed - starting test write');
                    // try {
                    //   await FirebaseFirestore.instance.collection('debug_test').add({'ts': DateTime.now().toIso8601String()});
                    //   print('Test write success');
                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Test write success')));
                    // } on FirebaseException catch (e) {
                    //   print('TEST FirebaseException: code=${e.code} message=${e.message}');
                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.code}')));
                    // } catch (e, st) {
                    //   print('TEST Unknown error: $e\n$st');
                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unknown error')));
                    // }

                    // Validation and save logic
                    setState(() {
                      _saveFuture = prd.saveProfileData();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Complete Setup",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileSet extends StatelessWidget {
  const ProfileSet({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Personal Information",
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              "Full Name",
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomTextField(
                hint: "Enter your full name",
                hintColor: Color(0xFF9CA3AF),
                radius: 12,
                filled: true,
                fW: FontWeight.normal,
                filledColor: Color(0xFFF9FAFB),
                paddingHorizontal: 16,
                enabledColorBorder: Color(0xFFE5E7EB),
                focusedColorBorder: Color(0xFF9333EA),
                tec: context.watch<ProfileProvider>().getName(),
              ),
            ),
            SizedBox(height: 20),
            // Email Field
            Text(
              "Email Address (Optional)",
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomTextField(
                hint: "your.email@example.com",
                hintColor: Color(0xFF9CA3AF),
                radius: 12,
                fW: FontWeight.normal,
                filled: true,
                filledColor: Color(0xFFF9FAFB),
                paddingHorizontal: 16,
                enabledColorBorder: Color(0xFFE5E7EB),
                focusedColorBorder: Color(0xFF9333EA),
                tec: context.watch<ProfileProvider>().getEmail(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyContacts extends StatefulWidget {
  const EmergencyContacts({super.key, required this.index});

  final int index;

  @override
  State<EmergencyContacts> createState() => _EmergencyContacts();
}

class _EmergencyContacts extends State<EmergencyContacts> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    // final controllerNames = context.watch<ProfileProvider>().getTECNames();
    // final controllerNumbers = context.watch<ProfileProvider>().getTECNumber();

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: _isVisible
            ? Container(
                margin: EdgeInsets.only(bottom: 12, left: 4, right: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFAF5FF),
                      Color(0xFFF3E8FF).withOpacity(0.5),
                    ],
                  ),
                  border: Border.all(
                    color: Color(0xFFE9D5FF).withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF9333EA).withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Number Badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF9333EA), Color(0xFFC026D3)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${widget.index + 1}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Input Fields
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomTextField(
                                hint: "Contact name",
                                hintColor: Color(0xFF9CA3AF),
                                radius: 10,
                                filled: true,
                                filledColor: Colors.white,
                                tec: context
                                    .watch<ProfileProvider>()
                                    .getTECNames()[widget.index],
                                fW: FontWeight.w500,
                                paddingHorizontal: 5,
                                enabledColorBorder: Colors.white,
                                focusedColorBorder: Color(0xFF9333EA),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomTextField(
                                hint: "Phone number",
                                hintColor: Color(0xFF9CA3AF),
                                radius: 10,
                                filled: true,
                                fW: FontWeight.w500,
                                filledColor: Colors.white,
                                tec: context
                                    .watch<ProfileProvider>()
                                    .getTECNumber()[widget.index],
                                keyboard: TextInputType.phone,
                                paddingHorizontal: 5,
                                enabledColorBorder: Color(0xFFE5E7EB),
                                focusedColorBorder: Color(0xFF9333EA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Delete Button
                      // Container(
                      //   width: 35,
                      //   height: 35,
                      //   margin: EdgeInsets.only(top: 4),
                      //   decoration: BoxDecoration(
                      //     color: Color(0xFFFEE2E2),
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Consumer<ProfileProvider>(),
                      // ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              _isVisible = false;
                              int idx = widget.index;
                              setState(() {});
                              Future.delayed(Duration(milliseconds: 300), () {
                                if (mounted) {
                                  context
                                      .read<ProfileProvider>()
                                      .updateRemoveTEC(idx);
                                  setState(() {});
                                }
                              });
                            },
                            icon: SvgPicture.asset(
                              'assets/images/delete.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                Color(0xFFEF4444),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _Contacts();
}

class _Contacts extends State<Contacts> {
  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().updateAddTEC(
        TextEditingController(),
        TextEditingController(),
      );
      context.read<ProfileProvider>().updateAddTEC(
        TextEditingController(),
        TextEditingController(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // final controllerNames = context.watch<ProfileProvider>().getTECNames();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 5),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.contact_emergency,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emergency Contacts",
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Consumer<ProfileProvider>(
                            builder: (ctx, provider, _) {
                              return Text(
                                "${provider.getTECNames().length} contact${provider.getTECNames().length != 1 ? 's' : ''}",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Add Contact Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF3E8FF), Color(0xFFFAE8FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE9D5FF), width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.read<ProfileProvider>().updateAddTEC(
                          TextEditingController(),
                          TextEditingController(),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF9333EA),
                              size: 18,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "Add",
                              style: TextStyle(
                                color: Color(0xFF9333EA),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
              ],
            ),
            SizedBox(height: 10),
            // Contacts List or Empty State
            Consumer<ProfileProvider>(
              builder: (_, provider, _) {
                final names = provider.getTECNames();
                return names.isEmpty
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.contact_phone_outlined,
                              size: 48,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No Emergency Contacts",
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Add at least one emergency contact",
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: names.length,
                        itemBuilder: (context, index) {
                          return EmergencyContacts(
                            key: ValueKey(names[index].hashCode),
                            index: index,
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
