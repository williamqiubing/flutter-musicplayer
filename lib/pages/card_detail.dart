import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';

class CardDetail extends StatefulWidget {
  int id;
  var album;
  Song song;
  int mode;
  DatabaseClient db;
  CardDetail(this.db, this.song, this.mode);
  @override
  State<StatefulWidget> createState() {
    return new stateCardDetail();
  }
}

class stateCardDetail extends State<CardDetail> {
  List<Song> songs;

  bool isLoading = true;
  var image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAlbum();
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(song.albumArt));
  }

  void initAlbum() async {
    image = widget.song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(widget.song.albumArt));
    if (widget.mode == 0)
      songs = await widget.db.fetchSongsfromAlbum(widget.song.albumId);
    else
      songs = await widget.db.fetchSongsByArtist(widget.song.artist);
    print(songs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: <Widget>[
                new SliverAppBar(
                  expandedHeight: 350.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: new FlexibleSpaceBar(
                    title: widget.mode == 0
                        ? new Text(
                            widget.song.album,
                          )
                        : new Text(widget.song.artist),
                    background: new Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        image != null
                            ? new Image.file(
                                image,
                                fit: BoxFit.cover,
                              )
                            : new Image.asset("images/back.jpg",
                                fit: BoxFit.cover),
                      ],
                    ),
                  ),
                ),
                new SliverList(
                  delegate: new SliverChildListDelegate(<Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Text(
                        widget.song.album,
                        style: new TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Text(
                        widget.song.artist,
                        style: new TextStyle(fontSize: 14.0),
                        maxLines: 1,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 10.0, bottom: 10.0),
                      child: new Text(songs.length.toString() + " songs"),
                    ),
                    new Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: new Text("Songs",
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ))),
                  ]),
                ),
                new SliverList(
                  delegate: new SliverChildBuilderDelegate((builder, i) {
                    return new ListTile(
                      leading: new CircleAvatar(
                        child: getImage(songs[i]) != null
                            ? new Image.file(
                                getImage(songs[i]),
                                height: 120.0,
                                fit: BoxFit.cover,
                              )
                            : new Text(songs[i].title[0].toUpperCase()),
                      ),
                      title: new Text(songs[i].title,
                          maxLines: 1, style: new TextStyle(fontSize: 18.0)),
                      subtitle: new Text(
                        songs[i].artist,
                        maxLines: 1,
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      trailing: new Text(
                          new Duration(milliseconds: songs[i].duration)
                              .toString()
                              .split('.')
                              .first,
                          style: new TextStyle(
                              fontSize: 12.0, color: Colors.grey)),
                      onTap: () {
                        LastPlay.songs = songs;
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) =>
                                new NowPlaying(widget.db, songs, i, 0)));
                      },
                    );
                  }, childCount: songs.length),
                ),
              ],
            ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          LastPlay.songs = songs;
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) =>
                  new NowPlaying(widget.db, LastPlay.songs, 0, 0)));
        },
        child: new Icon(Icons.shuffle),
      ),
    );
  }
}