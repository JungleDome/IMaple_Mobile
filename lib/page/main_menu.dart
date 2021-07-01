import 'package:flutter/material.dart';
import 'package:imaplemobile/page/movie_menu.dart';
import 'package:imaplemobile/utils/imapleManager.dart';
import 'package:imaplemobile/widgets/menu_button.dart';

import '../player.dart';

class MainMenu extends StatefulWidget {
  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  final menuButton = [
    {"Name": "电影", "Type": MovieType.Movie},
    {"Name": "连戏剧", "Type": MovieType.Drama},
    {"Name": "综艺", "Type": MovieType.VarietyShow},
    {"Name": "动漫", "Type": MovieType.Anime}
  ];

  Widget buildMenuButton(int index) {
    return MenuButton(
      onPressed: () {
        print('pressed ${menuButton[index]["Name"]}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieMenu(
              movieType: menuButton[index]["Type"] as MovieType,
            ),
          ),
        );
      },
      text: '${menuButton[index]["Name"]}',
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    var isHorizontal = media.orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: isHorizontal
            ? Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.1,
                                child: MenuButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayer(
                                          streamUrl: '',
                                        ),
                                      ),
                                    );
                                  },
                                  text: '搜索',
                                  icon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.1,
                                child: MenuButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayer(
                                          streamUrl: '',
                                        ),
                                      ),
                                    );
                                  },
                                  text: '观看记录',
                                  icon: Icon(Icons.history),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 2.2,
                                child: MenuButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayer(
                                          streamUrl: '',
                                        ),
                                      ),
                                    );
                                  },
                                  text: '继续观看',
                                  icon: Icon(Icons.play_arrow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: buildMenuButton(0),
                                ),
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: buildMenuButton(1),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: buildMenuButton(2),
                                ),
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: buildMenuButton(3),
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              )
            : Column(
                verticalDirection: VerticalDirection.down,
                //direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.1,
                          child: MenuButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayer(
                                    streamUrl: '',
                                  ),
                                ),
                              );
                            },
                            text: '搜索',
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.1,
                          child: MenuButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayer(
                                    streamUrl: '',
                                  ),
                                ),
                              );
                            },
                            text: '观看记录',
                            icon: Icon(Icons.history),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 2.2,
                          child: MenuButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayer(
                                    streamUrl: '',
                                  ),
                                ),
                              );
                            },
                            text: '继续观看',
                            icon: Icon(Icons.play_arrow),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: buildMenuButton(0),
                  ),
                  Expanded(
                    flex: 1,
                    child: buildMenuButton(1),
                  ),
                  Expanded(
                    flex: 1,
                    child: buildMenuButton(2),
                  ),
                  Expanded(
                    flex: 1,
                    child: buildMenuButton(3),
                  ),
                ],
              ),
      ),
    );
  }
}
