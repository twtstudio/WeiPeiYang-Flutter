import 'package:flutter/material.dart';
import '../model/home_model.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:flutter/services.dart';

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cards = GlobalModel().cards;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Container(
      padding: const EdgeInsets.only(top: 65),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 25.0,
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        childAspectRatio: 117 / 86,
        children: _getCardsWidget(cards, context),
      ),
    );
  }

  List<Widget> _getCardsWidget(List<CardBean> cards, BuildContext context) =>
      cards
          .map((e) => generateCard(context, e, textColor: Color(0xff656b80)))
          .toList();
}

/// 此方法在wpy_page中有复用
Widget generateCard(BuildContext context, CardBean bean, {Color textColor}) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, bean.route),
    child: Card(
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            bean.icon,
            color: MyColors.darkGrey,
            size: 25.0,
          ),
          Container(height: 5),
          Center(
            child: Text(bean.label,
                style: TextStyle(
                    color: textColor ?? MyColors.darkGrey,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    ),
  );
}
