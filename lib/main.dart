import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: DemoScreen(),
    ),
  );
}

class DemoScreen extends StatelessWidget {
  DemoScreen({
    super.key,
  });

  final myGame = BoxesSimulation();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Boxes simulation demo'),
      ),
      child: Center(
        child: GameWidget(
          game: myGame,
        ),
      ),
    );
  }
}

class BoxesSimulation extends Forge2DGame {
  BodyComponent? ground;
  BodyComponent? ceiling;
  BodyComponent? rightWall;
  BodyComponent? leftWall;

  BoxesSimulation() : super();

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    Vector2 gameSize = screenToWorld(camera.viewport.effectiveSize);
    recreateWalls(gameSize);
    addAll([
      for (int i = 0; i < 40; i++)
        Obstacle(
          position: Vector2(
            Random().nextDouble() % gameSize.x,
            Random().nextDouble() % gameSize.y,
          ),
        )
    ]);
    accelerometerEvents.listen((event) {
      world.setGravity(Vector2(-event.x, event.y));
    });
  }

  void recreateWalls(Vector2 gameSize) {
    removeAll([
      if (ground != null) ground!,
      if (ceiling != null) ceiling!,
      if (rightWall != null) rightWall!,
      if (leftWall != null) leftWall!,
    ]);

    ground = Ground(gameSize);
    ceiling = Ceiling(gameSize);
    rightWall = RightWall(gameSize);
    leftWall = LeftWall(gameSize);

    add(ground!);
    add(ceiling!);
    add(rightWall!);
    add(leftWall!);
  }

  @override
  Color backgroundColor() => Colors.yellow;
}

class Obstacle extends BodyComponent {
  final Vector2 position;

  Obstacle({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    add(
      SpriteComponent(
        sprite: await gameRef.loadSprite('rect.png'),
        size: Vector2.all(6),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    final vertices = [
      Vector2(-2.5, -3),
      Vector2(2.5, -3),
      Vector2(3, -2.5),
      Vector2(3, 2.5),
      Vector2(2.5, 3),
      Vector2(-2.5, 3),
      Vector2(-3, 2.5),
      Vector2(-3, -2.5),
    ];

    shape.set(vertices);
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3,
      restitution: 0.1,
      density: 10,
    );
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.dynamic,
      gravityScale: Vector2(20, 20),
      angle: 1,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Ground extends BodyComponent {
  final Vector2 gameSize;

  Ground(this.gameSize);

  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set(Vector2(0, gameSize.y), Vector2(gameSize.x, gameSize.y));
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(userData: this, position: Vector2.zero());
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Paint get paint => Paint()..color = Colors.transparent;
}

class Ceiling extends BodyComponent {
  final Vector2 gameSize;

  Ceiling(this.gameSize);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(Vector2(0, 0), Vector2(gameSize.x, 0));
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(userData: this, position: Vector2.zero());
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Paint get paint => Paint()..color = Colors.transparent;
}

class RightWall extends BodyComponent {
  final Vector2 gameSize;

  RightWall(this.gameSize);

  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set(Vector2(gameSize.x, 0), Vector2(gameSize.x, gameSize.y));
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(userData: this, position: Vector2.zero());
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Paint get paint => Paint()..color = Colors.transparent;
}

class LeftWall extends BodyComponent {
  final Vector2 gameSize;

  LeftWall(this.gameSize);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(Vector2(0, 0), Vector2(0, gameSize.y));
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(userData: this, position: Vector2.zero());
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Paint get paint => Paint()..color = Colors.transparent;
}
