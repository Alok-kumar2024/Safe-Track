import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/services/shake_services.dart';
import 'package:safe_track/state/home_provider.dart';
import 'package:safe_track/state/profile_provider.dart';
import 'package:safe_track/state/sos_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double topBarHeight = 150.0;

  late ShakeServices _shakeServices;

  @override
  void initState()
  {
    super.initState();

    _shakeServices = ShakeServices();

    WidgetsBinding.instance.addPostFrameCallback((_){
      final homeProvider = context.read<HomeProvider>();

      if(homeProvider.getShakeValue())
        {
          _shakeServices.startShakeListening(() async {
            await context.read<SosProvider>().triggerSos(context);
          });
        }
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: topBarHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView(
              padding: EdgeInsets.only(top: 5),
              children: [
                Sos(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          print("Clicked Safenavigate..");
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: SafeRoutes(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          print("clicked shareLocation......");
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ShareLocation(),
                        ),
                      ),
                    ),
                  ],
                ),
                ShakeDetection(),
                RecentActivities(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: TopBar()),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/shield.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xFF9333EA),
                BlendMode.srcIn,
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined, color: Color(0xFF9333EA)),
            label: "Map",
          ),
        ],
      ),
    );
  }

  @override
  void dispose()
  {
    _shakeServices.stopShakeListening();
    super.dispose();

  }

}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5)),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          //
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                //
                children: [
                  Consumer<ProfileProvider>(
                    builder: (_, prd, _) {
                      return Text(
                        "Hi, ${prd
                            .getName()
                            .text}! 👋",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      );
                    },
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Stay safe, stay connected",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
                //
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () {
                  //Will open settings features.....
                },
                child: CircleAvatar(
                  backgroundColor: Colors.purple.shade50,
                  radius: 30,
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.deepPurple,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sos extends StatelessWidget {
  const Sos({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children: [
                  Consumer<SosProvider>(
                    builder: (ctx, provider, child) {
                      return GestureDetector(
                        // 1. Logic: If sending, disable click (null)
                        onTap: provider.isSending ? null : () async {
                          debugPrint("clicked");

                          // 2. Trigger SOS using 'ctx'
                          bool? result = await provider.triggerSos(ctx);

                          // 3. SAFETY CHECK (Crucial for async code)
                          // If the user closed the screen while SOS was sending, 'ctx' is dead.
                          // We must check if it's still mounted before using it.
                          if (!ctx.mounted) return;

                          // 4. Handle Result
                          if (result == null) return; // Busy/Double click

                          if (result == true) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text("🚨 SOS Sent!"),
                                  backgroundColor: Colors.green,
                                ));
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text("❌ Failed to send SOS."),
                                  backgroundColor: Colors.red,
                                ));
                          }
                        },
                        child: Container(
                          width: 192,
                          height: 192,
                          decoration: BoxDecoration(
                            // 5. VISUAL FEEDBACK: Change color if busy
                            // If you don't do this, the button stays Red but does nothing when tapped.
                            gradient: provider.isSending
                                ? LinearGradient(colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade600
                            ])
                                : const LinearGradient(
                              colors: [
                                Color(0xFFEF4444), // Red
                                Color(0xFFEC4899), // Pink
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              // Remove shadow when disabled to look "flat"
                              provider.isSending
                                  ? const BoxShadow(color: Colors.transparent)
                                  : const BoxShadow(
                                color: Color(0x40EF4444),
                                blurRadius: 40,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),

                          // 6. Show Spinner if sending, otherwise show Icon+Text
                          child: provider.isSending
                              ? const Center(child: CircularProgressIndicator(
                              color: Colors.white))
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.error_outline_outlined,
                                color: Colors.white,
                                size: 80,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "SOS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30),
                  Text(
                    "Tap to send emergency alert",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 60,
              top: 35,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: SvgPicture.asset(
                  'assets/images/shield.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafeRoutes extends StatelessWidget {
  const SafeRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 30,
          bottom: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.shade50,
              ),
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  color: Colors.deepPurple,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Safe Navigation",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Navigate Safely",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareLocation extends StatelessWidget {
  const ShareLocation({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 30,
          bottom: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffc1f6d3),
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.greenAccent.shade700,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Share Location",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Live Tracking",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ShakeDetection extends StatelessWidget {
  const ShakeDetection({super.key});

  final bool isOn = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.pinkAccent.shade400],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(1, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shake Detection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Shake phone to trigger SOS",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Switch(
              value: context.watch<HomeProvider>().getShakeValue(),
              // Use Provider
              activeColor: Colors.green,
              activeTrackColor: Colors.white,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (value) {
                //Will set Later
                final homeProvider = context.read<HomeProvider>();
                final sosProvider = context.read<SosProvider>();

                homeProvider.updateShake(value);

                final homeState =
                context.findAncestorStateOfType<_HomeScreenState>();

                if (homeState == null) return;

                if (value) {
                  homeState._shakeServices.startShakeListening(() async {
                    await sosProvider.triggerSos(context);
                  });
                } else {
                  homeState._shakeServices.stopShakeListening();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Activity",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [ActivitiesCard()],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivitiesCard extends StatelessWidget {
  const ActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Icon(
                      Icons.access_time,
                      color: Colors.deepPurpleAccent.shade400,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 5),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Alert Sent Successfully",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Today at 2:30 PM",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Sector 12, Dwarka, Delhi",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
