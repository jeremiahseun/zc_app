import 'package:flutter/material.dart';
import 'package:zurichat/constants/app_strings.dart';
import 'package:zurichat/ui/shared/text_styles.dart';
import 'package:stacked/stacked.dart';

import '../home_page_viewmodel.dart';

class CustomDMListTile extends ViewModelWidget<HomePageViewModel> {
  final String? imagelink;
  final String? userName;
  final String name;

  const CustomDMListTile({
    Key? key,
    this.imagelink,
    this.name = statusBackground,
    this.userName,
  }) : super(key: key);

  showProfileDialog(BuildContext context) {
    // set up the AlertDialog
    final alert = AlertDialog(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      content: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("$imagelink"),
            radius: 20.0,
          ),
          const SizedBox(width: 8),
          Text(
            "$userName",
            style: AppTextStyle.darkGreySize12,
          ),
        ],
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context, HomePageViewModel viewModel) {
    return InkWell(
      onTap: () {
        viewModel.navigateToDmUser();
      },
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                    image: AssetImage("$imagelink"), fit: BoxFit.cover)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: () {
              showProfileDialog(context);
            },
            child: Text(
              "$userName",
              style: AppTextStyle.darkGreySize12,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 14,
            height: 14,
            child: Image.asset(name),
          )
        ],
      ),
    );
  }
}
