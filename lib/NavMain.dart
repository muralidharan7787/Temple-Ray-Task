
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'global/Common.dart';
import 'home/HomePage.dart';

class NavMain extends StatefulWidget {
  final int initialIndex; // <-- new
  const NavMain({super.key, this.initialIndex = 0}); // default to Home
  // const NavMain({super.key});

  @override
  State<NavMain> createState() => _NavMainState();
}

class _NavMainState extends State<NavMain> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // <-- initialize with passed index
  }

  List pages = [
    // HistoryPage(),
    // Center(child: Text('data'),)
    HomePage(),
    // DashboardPage(),
    // SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Common.secondary,
      ),
      child: SafeArea(
        bottom: true,
        child: Scaffold(

          body: pages[_currentIndex],

          bottomNavigationBar: Container(
            // height: 50,
            // width: double.infinity,
            decoration: BoxDecoration(
              // color: Colors.black,
              borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12),),
            ),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30),),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: _currentIndex==0 ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          _currentIndex==0 ? SizedBox(height: 10,) : SizedBox(height: 0,),
                          SvgPicture.asset('assets/Icons/home.svg', width: 22, height: 22, color: Common.primary),
                          if(_currentIndex == 0)...[
                            SizedBox(height: 5,),
                            Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                          ]

                        ],
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   child: GestureDetector(
                //     onTap: (){
                //       setState(() {
                //         _currentIndex = 1;
                //       });
                //     },
                //     child: Container(
                //       height: 50,
                //       decoration: BoxDecoration(
                //         color: Colors.black,
                //       ),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisAlignment: _currentIndex==1? MainAxisAlignment.start : MainAxisAlignment.center,
                //         children: [
                //           _currentIndex==1 ? SizedBox(height: 10,) : SizedBox(height: 0,),
                //           SvgPicture.asset('assets/Icons/truck.svg', width: 22, height: 22, color: Common.primary),
                //           if(_currentIndex == 1)...[
                //             SizedBox(height: 5,),
                //             Container(height: 2, width: 22, decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(2)),)
                //           ]
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // In your bottom navigation bar widget:

              ],
            ),
          ),

        ),
      ),
    );
  }
}
