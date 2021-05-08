import 'package:flutter/material.dart';

import './commons.dart';

Widget buildLeftChildDrawer({
  @required double edge,
  @required Function(String page) routePageCallBack,
  @required BuildContext context,
  @required bool reverse,
}) {
  return Material(
    child: Container(
      decoration: backgroundDecoration(),
      child: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  child: Center(
                    child: Container(
                      height: edge * 0.3,
                      width: edge * 0.3,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/eagle_image.gif'),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Divider(),
                buildDrawerButtonItem(
                  reverse: true,
                  item: 'Home',
                  callback: (page) => routePageCallBack(page),
                  context: context,
                  icon: Icons.home,
                  page: '/',
                ),
                Divider(),
                buildDrawerButtonItem(
                  reverse: true,
                  item: 'Salvos',
                  callback: (page) => routePageCallBack(page),
                  context: context,
                  icon: Icons.save,
                  page: '/saved',
                ),
                Divider(),
                buildDrawerButtonItem(
                  reverse: true,
                  item: 'Configurações',
                  callback: (page) => routePageCallBack(page),
                  context: context,
                  icon: Icons.delete,
                  page: '/setup',
                ),
                Divider(),
                buildDrawerButtonItem(
                  reverse: true,
                  item: 'Lixeira',
                  callback: (page) => routePageCallBack(page),
                  context: context,
                  icon: Icons.delete,
                  page: '/trash',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}