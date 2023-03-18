import 'package:commet/ui/molecules/direct_message_list.dart';
import 'package:commet/ui/molecules/timeline_viewer.dart';
import 'package:commet/ui/pages/chat/chat_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:tiamat/tiamat.dart';

import '../../../client/client_manager.dart';
import '../../../client/room.dart';
import '../../../client/space.dart';
import '../../../config/app_config.dart';

import '../../atoms/room_header.dart';
import '../../atoms/space_header.dart';
import '../../molecules/message_input.dart';
import '../../molecules/overlapping_panels.dart';
import '../../molecules/space_viewer.dart';
import '../../molecules/user_list.dart';
import '../../molecules/user_panel.dart';
import '../../organisms/side_navigation_bar.dart';

import 'package:flutter/material.dart' as m;

class MobileChatPageView extends StatefulWidget {
  const MobileChatPageView({required this.state, super.key});
  final ChatPageState state;

  @override
  State<MobileChatPageView> createState() => _MobileChatPageViewState();
}

class _MobileChatPageViewState extends State<MobileChatPageView> {
  late GlobalKey<OverlappingPanelsState> panelsKey;
  late GlobalKey<MessageInputState> messageInput = GlobalKey();
  bool shouldMainIgnoreInput = false;

  @override
  void initState() {
    panelsKey = GlobalKey<OverlappingPanelsState>();
    super.initState();
  }

  @override
  Widget build(BuildContext newContext) {
    return OverlappingPanels(
        key: panelsKey,
        left: navigation(newContext),
        main: shouldMainIgnoreInput
            ? IgnorePointer(
                child: timelineView(),
              )
            : timelineView(),
        onDragStart: () {
          messageInput.currentState?.unfocus();
        },
        onSideChange: (side) {
          setState(() {
            shouldMainIgnoreInput = side != RevealSide.main;
          });
        },
        right: widget.state.selectedRoom != null ? userList() : null);
  }

  Widget navigation(BuildContext newContext) {
    return Row(
      children: [
        SideNavigationBar(
          onHomeSelected: () {
            widget.state.selectHome();
          },
          onSpaceSelected: (index) {
            widget.state.selectSpace(widget.state.clientManager.spaces[index]);
          },
        ),
        if (widget.state.homePageSelected) homePageView(),
        if (widget.state.homePageSelected == false && widget.state.selectedSpace != null) spaceRoomSelector(newContext)
      ],
    );
  }

  Widget userList() {
    if (widget.state.selectedRoom != null) {
      return Tile.low1(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 0, 0),
            child: PeerList(
              widget.state.selectedRoom!.members,
              key: widget.state.selectedRoom!.key,
            ),
          ),
        ),
      );
    }
    return const Placeholder();
  }

  Widget homePageView() {
    return Flexible(
      child: Tile.low1(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
            child: DirectMessageList(
              directMessages: widget.state.clientManager.directMessages,
              onSelected: (index) {
                setState(() {
                  selectRoom(widget.state.clientManager.directMessages[index]);
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget timelineView() {
    if (widget.state.selectedRoom != null) {
      return roomChatView();
    }

    return Container(
      color: m.Colors.red,
      child: const Placeholder(),
    );
  }

  Widget spaceRoomSelector(BuildContext newContext) {
    return Flexible(
      child: Tile.low1(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: s(50), child: SpaceHeader(widget.state.selectedSpace!)),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, s(50), 0),
                child: SpaceViewer(
                  widget.state.selectedSpace!,
                  key: widget.state.selectedSpace!.key,
                  onRoomInsert: widget.state.selectedSpace!.onRoomAdded.stream,
                  onRoomSelected: (index) async {
                    selectRoom(widget.state.selectedSpace!.rooms[index]);
                  },
                ),
              )),
              Tile.low2(
                child: SizedBox(
                  height: s(70),
                  child: UserPanel(
                    displayName: widget.state.selectedSpace!.client.user!.displayName,
                    avatar: widget.state.selectedSpace!.client.user!.avatar,
                    detail: widget.state.selectedSpace!.client.user!.detail,
                    color: widget.state.selectedSpace!.client.user!.color,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget roomChatView() {
    return Tile(
      child: m.Scaffold(
        backgroundColor: m.Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: s(50), child: RoomHeader(widget.state.selectedRoom!)),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: TimelineViewer(
                      key: widget.state.timelines[widget.state.selectedRoom!.identifier],
                      timeline: widget.state.selectedRoom!.timeline!,
                    )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, s(8)),
                      child: MessageInput(
                        key: messageInput,
                        onSendMessage: (message) {
                          widget.state.selectedRoom!.sendMessage(message);
                          return MessageInputSendResult.clearText;
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectRoom(Room room) {
    Future.delayed(const Duration(milliseconds: 125)).then((value) {
      panelsKey.currentState!.reveal(RevealSide.main);
      setState(() {
        shouldMainIgnoreInput = false;
      });
    });

    widget.state.selectRoom(room);
  }
}
