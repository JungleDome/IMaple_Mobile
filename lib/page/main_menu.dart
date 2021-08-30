import 'package:flutter/material.dart';
import 'package:imaplemobile/model/movie_storage.dart';
import 'package:imaplemobile/page/movie_menu.dart';
import 'package:imaplemobile/page/search_page.dart';
import 'package:imaplemobile/page/video_player.dart';
import 'package:imaplemobile/utils/imaple_manager.dart';
import 'package:imaplemobile/widgets/menu_button.dart';

import 'movie_details.dart';

class MainMenu extends StatefulWidget {
  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  final menuButton = [
    {"Name": "电影", "Type": MovieType.Movie, "Color": Colors.purple},
    {"Name": "连续剧", "Type": MovieType.Drama, "Color": Colors.pink},
    {"Name": "综艺", "Type": MovieType.VarietyShow, "Color": Colors.indigo},
    {"Name": "动漫", "Type": MovieType.Anime, "Color": Colors.deepOrange}
  ];

  Widget buildMenuButton(int index) {
    return MenuButton(
      onPressed: () {
        //print('pressed ${menuButton[index]["Name"]}');
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
      boxColor: menuButton[index]["Color"] as Color,
    );
  }

  Widget buildResumeLastPlayButton(Orientation orientation) {
    var baseButton = MenuButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetail(
              movieUrl: MovieStorage.instance.lastPlayDetailUrl!,
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayer(
              streamUrl: MovieStorage.instance.lastPlayPlayUrl!,
              playAtMillisecondDuration: MovieStorage.instance.lastPlayDuration!,
            ),
          ),
        );
      },
      text: '继续观看',
      subText: MovieStorage.instance.lastPlayName ?? '',
      icon: Icon(Icons.play_arrow),
      boxColor: Colors.green,
    );

    return Visibility(
      visible: MovieStorage.instance.lastPlayName != null,
      child: orientation == Orientation.portrait
          ? Expanded(
              child: AspectRatio(
                aspectRatio: 2.2,
                child: baseButton,
              ),
            )
          : Expanded(
              flex: 3,
              child: baseButton,
            ),
    );
  }

  Widget buildSearchButton(Orientation orientation) {
    var baseButton = MenuButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ),
        );
      },
      text: '搜索',
      icon: Icon(Icons.search),
      boxColor: Colors.blue,
    );

    return orientation == Orientation.portrait
        ? Expanded(
            child: AspectRatio(
              aspectRatio: 1.1,
              child: baseButton,
            ),
          )
        : Expanded(
            flex: 1,
            child: baseButton,
          );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    var isHorizontal = media.orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: media.size.height - media.padding.top - media.padding.bottom,
          width: media.size.width - media.padding.left - media.padding.right,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: isHorizontal
              ? Container(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            buildResumeLastPlayButton(Orientation.landscape),
                            buildSearchButton(Orientation.landscape),
                            // MenuButton(
                            //       //   onPressed: () {
                            //       //     // Navigator.push(
                            //       //     //   context,
                            //       //     //   MaterialPageRoute(
                            //       //     //     builder: (context) => MainMenu(
                            //       //     //       streamUrl: '',
                            //       //     //     ),
                            //       //     //   ),
                            //       //     // );
                            //       //   },
                            //       //   text: '别按我 😖!',
                            //       //   //icon: Icon(Icons.history),
                            //       // ),
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: [
                            Expanded(
                              child: buildMenuButton(0),
                            ),
                            Expanded(
                              child: buildMenuButton(1),
                            ),
                            Expanded(
                              child: buildMenuButton(2),
                            ),
                            Expanded(
                              child: buildMenuButton(3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  verticalDirection: VerticalDirection.down,
                  //direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        buildSearchButton(Orientation.portrait),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.1,
                            child: MenuButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => VideoPlayer(
                                //       streamUrl: '',
                                //     ),
                                //   ),
                                // );
                              },
                              text: '别按我 😖!',
                              //icon: Icon(Icons.history),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildResumeLastPlayButton(Orientation.portrait),
                      ],
                    ),
                    Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: buildMenuButton(0),
                            ),
                            Expanded(
                              child: buildMenuButton(1),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: buildMenuButton(2),
                            ),
                            Expanded(
                              child: buildMenuButton(3),
                            ),
                          ],
                        )),
                  ],
                ),
        ),
      ),
    );
  }
}
