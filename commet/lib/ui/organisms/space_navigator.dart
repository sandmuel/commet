import 'package:commet/ui/molecules/space_selector.dart';
import 'package:commet/ui/molecules/space_viewer.dart';
import 'package:flutter/material.dart';

import '../../client/client.dart';
import '../../utils/union.dart';

class SpaceNavigator extends StatefulWidget {
  SpaceNavigator(this.spaces, {super.key});
  Union<Space> spaces;
  final double width = 70;

  @override
  State<SpaceNavigator> createState() => _SpaceNavigatorState();
}

class _SpaceNavigatorState extends State<SpaceNavigator> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: widget.width,
        child: SpaceSelector(
          widget.spaces,
          width: widget.width,
          onSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
      Container(child: SpaceViewer(widget.spaces.getItems()[selectedIndex]))
    ]);
  }
}