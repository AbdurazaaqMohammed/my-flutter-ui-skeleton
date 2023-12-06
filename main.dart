import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  Color primaryColor = Colors.blue;
  Color accentColor = Colors.purple;
  Color backgroundColor = Colors.black;
  double _fontSize = 32;
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  bool _isRGBEnabled = false;
  bool _autoSave = false;
  bool useImageBG = false;
  String bgImage = '';

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rgb', _isRGBEnabled);
    prefs.setBool('autoSave', _autoSave);
    prefs.setDouble('fontSize', _fontSize);
    prefs.setInt('primaryColor', primaryColor.value);
    prefs.setInt('accentColor', accentColor.value);
    prefs.setInt('backgroundColor', backgroundColor.value);
    prefs.setString('bgImage', bgImage);
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRGBEnabled = prefs.getBool('rgb') ?? _isRGBEnabled;
      _isRGBEnabled = prefs.getBool('autoSave') ?? _autoSave;
      _fontSize = prefs.getDouble('fontSize') ?? _fontSize;
      primaryColor = Color(prefs.getInt('primaryColor') ?? primaryColor.value);
      accentColor = Color(prefs.getInt('primaryColor') ?? accentColor.value);
      backgroundColor =
          Color(prefs.getInt('primaryColor') ?? backgroundColor.value);
      bgImage = prefs.getString('bgImage') ?? bgImage;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    if (_autoSave) _saveSettings();
    _controller.dispose();
    // takeInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI',
      theme: ThemeData(
          scaffoldBackgroundColor: backgroundColor,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: primaryColor),
            bodyText2: TextStyle(color: primaryColor),
            headline1: TextStyle(color: primaryColor),
            headline2: TextStyle(color: primaryColor),
            headline3: TextStyle(color: primaryColor),
            headline4: TextStyle(color: primaryColor),
            headline5: TextStyle(color: primaryColor),
            headline6: TextStyle(color: primaryColor),
            subtitle1: TextStyle(color: primaryColor),
            subtitle2: TextStyle(color: primaryColor),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: getMaterialColor(primaryColor),
            accentColor: accentColor,
          )),
      home: Scaffold(
          appBar: AppBar(),
          drawer: Drawer(
              backgroundColor: Colors.transparent.withOpacity(0.4),
              child: ListView(children: [
                getDrawerOption('Select Font Size', () {
                  _adjustFontSize();
                }),
                getDrawerOption('Select Primary Color', () {
                  _openColorPicker(primaryColor, (Color newColor) {
                    setState(() {
                      primaryColor = newColor;
                    });
                  });
                }),
                getDrawerOption(
                    useImageBG
                        ? 'Select Background Image'
                        : 'Select Background Color', () {
                  useImageBG
                      ? _pickBackgroundImage()
                      : _openColorPicker(backgroundColor, (Color newColor) {
                          setState(() {
                            backgroundColor = newColor;
                          });
                        });
                  ;
                }),
                getDrawerOption('Select Accent Color', () {
                  _openColorPicker(accentColor, (Color newColor) {
                    setState(() {
                      accentColor = newColor;
                    });
                  });
                }),
                getDrawerOption('Toggle RGB Effect', () {
                  setState(() {
                    _isRGBEnabled = !_isRGBEnabled;
                  });
                }),
                getDrawerOption('Toggle BG Image/Background', () {
                  setState(() {
                    useImageBG = !useImageBG;
                  });
                }),
                getDrawerOption(
                    'Toggle Auto Save (currently ' + _autoSave.toString() + ')',
                    () {
                  setState(() {
                    _autoSave = !_autoSave;
                  });
                }),
                getDrawerOption('Save Settings', () {
                  _saveSettings();
                }),
              ])),
          body: Stack(children: [
            if (useImageBG)
              Image.file(
                File(bgImage),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _isRGBEnabled
                      ? getRGBtext('RGB Text')
                      : Text(
                          'Normal Text',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                ],
              ),
            ),
          ])),
    );
  }

  AnimatedBuilder getRGBtext(String text) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Text(text,
            style: TextStyle(color: getRGB(), fontSize: _fontSize));
      },
    );
  }

  MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;
    final int alpha = color.alpha;

    final Map<int, Color> shades = {
      50: Color.fromARGB(alpha, red, green, blue),
      100: Color.fromARGB(alpha, red, green, blue),
      200: Color.fromARGB(alpha, red, green, blue),
      300: Color.fromARGB(alpha, red, green, blue),
      400: Color.fromARGB(alpha, red, green, blue),
      500: Color.fromARGB(alpha, red, green, blue),
      600: Color.fromARGB(alpha, red, green, blue),
      700: Color.fromARGB(alpha, red, green, blue),
      800: Color.fromARGB(alpha, red, green, blue),
      900: Color.fromARGB(alpha, red, green, blue),
    };

    return MaterialColor(color.value, shades);
  }

  void _openColorPicker(Color colorFiSet, void Function(Color) setColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = colorFiSet;
        return AlertDialog(
          title: Text('Pick Custom Color'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setColor(selectedColor);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _adjustFontSize() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double selectedFontSize = _fontSize;
        double maxSliderValue = 512;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Adjust Font Size',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Current Font Size: $selectedFontSize',
                      style: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        inactiveTrackColor: Colors.grey,
                        trackShape: const RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 28.0,
                        ),
                      ),
                      child: Slider.adaptive(
                        value: _fontSize,
                        min: 10,
                        max: maxSliderValue,
                        onChanged: (double value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ListTile getDrawerOption(String text, VoidCallback toDoOnTap) {
    return ListTile(
      title: Text(
        text,
      ),
      onTap: () {
        toDoOnTap();
      },
    );
  }

  void _pickBackgroundImage() async {
    Navigator.pop(context);
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          bgImage = pickedImage.path;
        });
      }
    } catch (e) {}
  }

  Color getRGB() {
    int r = (sin(_controller.value * 2 * pi) * 127.5 + 127.5).toInt();
    int g =
        (sin(_controller.value * 2 * pi + 2 / 3 * pi) * 127.5 + 127.5).toInt();
    int b =
        (sin(_controller.value * 2 * pi + 4 / 3 * pi) * 127.5 + 127.5).toInt();
    return Color.fromARGB(255, r, g, b);
  }
}
