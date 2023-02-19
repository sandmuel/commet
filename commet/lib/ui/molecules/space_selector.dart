import 'dart:async';

import 'package:commet/client/client.dart';
import 'package:commet/config/style/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../atoms/space_icon.dart';

class SpaceSelector extends StatefulWidget {
  SpaceSelector(this.spaces, {super.key, this.onSelected, this.onSpaceInsert});
  Stream<int>? onSpaceInsert;
  List<Space> spaces;
  @override
  State<SpaceSelector> createState() => _SpaceSelectorState();
  void Function(int index)? onSelected;
}

class _SpaceSelectorState extends State<SpaceSelector> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _count = 0;

  late StreamSubscription<int>? onInsertListener;

  @override
  void initState() {
    onInsertListener = widget.onSpaceInsert?.listen((index) {
      _listKey.currentState?.insertItem(index);
      _count++;
    });

    _count = widget.spaces.length;
    super.initState();
  }

  @override
  void dispose() {
    onInsertListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).extension<ExtraColors>()!.surfaceExtraLow,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: SizedBox(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _count,
            itemBuilder: (context, i, animation) => ScaleTransition(
              scale: animation,
              child: SpaceIcon(widget.spaces[i], onTap: () => widget.onSelected?.call(i)),
            ),
          ),
        ),
      ),
    );
  }
}
