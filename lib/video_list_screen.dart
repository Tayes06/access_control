import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage de la date
import 'video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final DatabaseReference _videoRef =
      FirebaseDatabase.instance.ref().child('videos');
  List<Map<String, dynamic>> _videoList = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() {
    _videoRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final videos = data.entries.map((entry) {
        return {
          'filename': entry.value['filename'],
          'timestamp': entry.value['timestamp'],
        };
      }).toList();

      // Trier les vidéos par timestamp décroissant (du plus récent au plus ancien)
      videos.sort((a, b) {
        return b['timestamp'].compareTo(a['timestamp']);
      });

      setState(() {
        _videoList = videos;
      });
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      // Convertir la chaîne en DateTime (format : dd-MM-yyyy HH:mm:ss)
      final DateTime parsedDate =
          DateFormat('dd-MM-yyyy HH:mm:ss').parse(timestamp);

      // Retourner la date formatée (exemple : 04 janvier 2025)
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(parsedDate);
    } catch (e) {
      // Retourner une valeur par défaut en cas d'erreur
      return "Date invalide";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrements Vidéos'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _videoList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _videoList.length,
              itemBuilder: (context, index) {
                final video = _videoList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const Icon(
                      Icons.video_library,
                      color: Colors.blueAccent,
                      size: 40,
                    ),
                    title: Text(
                      video['filename'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Enregistré le ${_formatTimestamp(video['timestamp'])}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.green,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(url: video['filename']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
