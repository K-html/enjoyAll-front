import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp_recording.wav';

    try {
      await _recorder.startRecorder(
        toFile: tempPath,
        codec: Codec.pcm16WAV, // PCM Wave 형식으로 녹음
      );

      setState(() {
        _isRecording = true;
        _filePath = tempPath;
      });
    } catch (e) {
      print('Recorder error: $e');
      // 오류 처리
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();

    setState(() {
      _isRecording = false;
    });

    if (_filePath != null) {
      _sendRecording(_filePath!);
    }
  }

  Future<void> _sendRecording(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://175.45.205.178/chat'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        Navigator.pop(context, responseData); // 응답 데이터를 전달
      } else {
        Navigator.pop(context, '녹음 전송에 실패했습니다.');
      }
    } catch (e) {
      Navigator.pop(context, '오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '음성 녹음',
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontSize: 22,
            fontFamily: 'GmarketSansTTFMedium',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 50,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              SizedBox(height: 20),
              Text(
                _isRecording ? '녹음 중...' : '녹음을 시작하려면 버튼을 누르세요',
                style: TextStyle(
                  color: Color(0xFF595858),
                  fontSize: 18,
                  fontFamily: 'GmarketSansTTFBold',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
