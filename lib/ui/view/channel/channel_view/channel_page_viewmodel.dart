//TODO: remove material import, this is temporary for testing
import 'dart:developer';

import 'package:flutter/material.dart'; //TODO material was only imported for the icons
import 'package:hng/app/app.locator.dart';
import 'package:hng/app/app.router.dart';
import 'package:hng/models/channel_members.dart';
import 'package:hng/models/channel_model.dart';
import 'package:hng/models/user_post.dart';
import 'package:hng/models/user_search_model.dart';
import 'package:hng/package/base/jump_to_request/jump_to_api.dart';
import 'package:hng/package/base/server-request/api/http_api.dart';
import 'package:hng/package/base/server-request/channels/channels_api_service.dart';
import 'package:hng/services/centrifuge_service.dart';
import 'package:hng/services/local_storage_services.dart';

import 'package:hng/utilities/constants.dart';
import 'package:hng/utilities/enums.dart';
import 'package:hng/utilities/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ChannelPageViewModel extends BaseViewModel {
  bool isVisible = false;

  final _navigationService = locator<NavigationService>();
  final _channelsApiService = locator<ChannelsApiService>();
  final _jumpToApiService = locator<JumpToApi>();
  final _coreApiService = HttpApiService(coreBaseUrl);
  final storage = locator<SharedPreferenceLocalStorage>();
  final _centrifugeService = locator<CentrifugeService>();

  final _bottomSheetService = locator<BottomSheetService>();

//TODO This ScrollController will be removed
  ScrollController scrollController = ScrollController();

  bool isLoading = true;
  List<UserSearch> usersInOrg = [];

  List<UserPost>? channelUserMessages = [];

  void onMessageFieldTap() {
    isVisible = true;
    notifyListeners();
  }

  void initialise(String channelId) {
    joinChannel("$channelId");
    fetchMessages("$channelId");

    getChannelSocketId("$channelId");

    listenToNewMessages("$channelId");
  }

  void showThreadOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.threadOptions,
      isScrollControlled: true,
    );
  }

  void onMessageFocusChanged() {
    isVisible = false;
    notifyListeners();
  }

  void joinChannel(String channelId) async {
    var joinedChannel = await _channelsApiService.joinChannel(channelId);
    print(joinedChannel);
  }

  void getChannelSocketId(String channelId) async {
    String channelSockId =
        await _channelsApiService.getChannelSocketId(channelId);

    websocketConnect(channelSockId);
  }

  void fetchMessages(String channelId) async {
    setBusy(true);

    List? channelMessages =
        await _channelsApiService.getChannelMessages(channelId);
    channelUserMessages = [];

    channelMessages.forEach((data) async {
      String userid = data["user_id"];

      // String endpoint = '/users/$userid';

      //final response = await _coreApiService.get(endpoint);

      channelUserMessages!.add(
        UserPost(
            id: data["_id"],
            displayName: userid,
            statusIcon: Icons.looks_6,
            lastSeen: "4 hours ago",
            message: data["content"],
            channelType: ChannelType.public,
            postEmojis: <PostEmojis>[],
            userThreadPosts: <UserThreadPost>[],
            channelName: channelId,
            userImage: "assets/images/chimamanda.png",
            userID: userid),
      );
    });
    isLoading = false;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);

    notifyListeners();
  }

  void sendMessage(String message, String channelId) async {
    String? userId = storage.getString(StorageKeys.currentUserId);
    var channelMessages = await _channelsApiService.sendChannelMessages(
        channelId, "$userId", message);

    notifyListeners();
  }

  void exitPage() {
    _navigationService.back();
  }

  String time() {
    return "${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}";
  }

  navigateToChannelInfoScreen(int numberOfMembers,
      List<ChannelMembermodel> channelMembers, ChannelModel channelDetail) {
    NavigationService().navigateTo(Routes.channelInfoView,
        arguments: ChannelInfoViewArguments(
            numberOfMembers: numberOfMembers,
            channelMembers: channelMembers,
            channelDetail: channelDetail));
  }

  Future navigateToAddPeople() async {
    await _navigationService.navigateTo(Routes.channelAddPeopleView);
  }

  void goBack() {
    NavigationService().back();
  }

  navigateToChannelEdit() {
    _navigationService.navigateTo(Routes.editChannelPageView);
  }

  void websocketConnect(String channelId) async {
    await _centrifugeService.connect();
    await _centrifugeService.subscribe(channelId);
  }

  void listenToNewMessages(String channelId) {
    _centrifugeService.messageStreamController.stream.listen((event) {
      fetchMessages(channelId);
      notifyListeners();
    });
  }
}
