import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/artist.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import 'list_item.dart';

const artistsUrl = '/me/top/artists?time_range=';

class TopArtistsList extends StatefulWidget {
  final String timeRange;
  final User? user;
  const TopArtistsList({Key? key, this.timeRange = 'short_term', this.user}) : super(key: key);

  @override
  _TopArtistsListState createState() => _TopArtistsListState();
}

class _TopArtistsListState extends State<TopArtistsList> {
  final ArtistsNotifier _artists = ArtistsNotifier([]);

  @override
  void initState() {
    super.initState();
    getTopArtists(widget.timeRange);
  }

  @override
  void didUpdateWidget(covariant TopArtistsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeRange != widget.timeRange) {
      _artists.changeData([]);
      getTopArtists(widget.timeRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(children: [
          const Text(
            'Top Artists',
            style: TextStyle(fontSize: 24),
          ),
          ValueListenableBuilder<List<Artist>>(
            builder: (BuildContext context, List<Artist> value, Widget? child) {
              return value.isEmpty ? _buildSkeletonArtists() : _buildArtists(value);
            },
            valueListenable: _artists,
          )
        ]));
  }

  void getTopArtists(String timeRange) async {
    var token = widget.user != null ? widget.user!.token : await SecureStorage.getToken();
    var url = dotenv.env['NODE_ENV'] == 'development' ? dotenv.env['DEV_URL'] : dotenv.env['PROD_URL'];
    var timerangeUrl = url! + artistsUrl + timeRange;
    var res = await http.get(Uri.parse(timerangeUrl), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final json = jsonDecode(res.body);
    final parsed = json.cast<Map<String, dynamic>>();
    final artists = parsed.map<Artist>((json) => Artist.fromJson(json)).toList();
    _artists.changeData(artists);
  }

  Widget _buildArtists(List<Artist> artists) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: artists.length,
        itemBuilder: (context, i) {
          // if (i.isOdd) return const Divider();
          // final index = i ~/ 2;
          var name = artists[i].name;
          var cover = artists[i].image;
          return _buildArtistRow(name, cover);
        });
  }

  Widget _buildArtistRow(String name, String cover) {
    return ListItem(
      img: CircleAvatar(
        maxRadius: 28,
        backgroundImage: NetworkImage(cover),
      ),
      title: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          name,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSkeletonArtists() {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: 10,
        itemBuilder: (context, i) {
          // if (i.isOdd) return Divider(color: Colors.grey[600]);
          return _buildSkeletonArtistRow();
        });
  }

  Widget _buildSkeletonArtistRow() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: ListItem(
          img: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              )),
          title: Container(
            height: 20,
            width: 180,
            decoration:
                BoxDecoration(color: Colors.grey[800], borderRadius: const BorderRadius.all(Radius.circular(2))),
          ),
        ));
  }
}

class ArtistsNotifier extends ValueNotifier<List<Artist>> {
  ArtistsNotifier(List<Artist> value) : super(value);

  void changeData(List<Artist> artists) {
    value = artists;
    notifyListeners();
  }
}
