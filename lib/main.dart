// ignore_for_file: deprecated_member_use
// https://www.geeksforgeeks.org/flutter-radial-hero-animation/

// Radial Hero Animation
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

//  Radial transformation means turning
// a circular shape into a square shape
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RadialExpansionDemo(),
    ),
  );
}

class Photo extends StatelessWidget {
  const Photo({super.key, required this.photo, this.onTap});

  final String photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // container of the image
    return Material(
      color: Colors.purple.withOpacity(0.25),
      // gestures handled by inkwell
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints size) {
            return Image.asset(
              photo,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {
  // used to wrap the hero
  RadialExpansion({
    super.key,
    required this.minRadius,
    required this.maxRadius,
    this.child,
  })  : clipTween = Tween<double>(
          begin: 2.0 * minRadius,
          end: 2.0 * (maxRadius / math.sqrt2),
        );

  final double minRadius;
  final double maxRadius;
  final Tween<double> clipTween;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints size) {
        final double t =
            (size.biggest.width / 2.0 - minRadius) / (maxRadius - minRadius);
        final double rectClipExtent = clipTween.transform(t);
        return ClipOval(
          child: Center(
            child: SizedBox(
              width: rectClipExtent,
              height: rectClipExtent,
              child: ClipRect(
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RadialExpansionDemo extends StatelessWidget {
  const RadialExpansionDemo({super.key});

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;
  static const opacityCurve = Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

  RectTween _createRectTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  Widget _buildPage(
      BuildContext context, String imageName, String description) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Card(
          elevation: 8.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: kMaxRadius * 2.0,
                height: kMaxRadius * 2.0,
                child: Hero(
                  createRectTween: _createRectTween,
                  tag: imageName,
                  child: RadialExpansion(
                    minRadius: kMinRadius,
                    maxRadius: kMaxRadius,
                    child: Photo(
                      photo: imageName,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 2.0,
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
      BuildContext context, String imageName, String description) {
    return SizedBox(
      width: kMinRadius * 2.0,
      height: kMinRadius * 2.0,
      child: Hero(
        createRectTween: _createRectTween,
        tag: imageName,
        child: RadialExpansion(
          minRadius: kMinRadius,
          maxRadius: kMaxRadius,
          child: Photo(
            photo: imageName,
            onTap: () {
              Navigator.of(context).push(
                // build the destination of the hero
                PageRouteBuilder<void>(
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        return Opacity(
                          opacity: opacityCurve.transform(animation.value),
                          child: _buildPage(context, imageName, description),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // speed of the animation
    timeDilation = 5.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 130, 111, 163),
        centerTitle: true,
        title: const Text('Radial Hero Animation'),
      ),
      body: Container(
        padding: const EdgeInsets.all(40.0),
        alignment: FractionalOffset.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // assets
            _buildHero(context, 'lib/assets/r1.jpg', 'The Kingdom of the Wicked'),
            _buildHero(context, 'lib/assets/r2.jpg', 'Invisible life of Addie LaRue'),
            _buildHero(context, 'lib/assets/r3.jpg', 'The Cruel Prince'),
            _buildHero(context, 'lib/assets/r4.jpg', 'One Dark Window'),
          ],
        ),
      ),
    );
  }
}
