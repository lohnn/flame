import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Animation;
import 'package:flutter_isolates_example/colonists_game.dart';
import 'package:flutter_isolates_example/constants.dart';
import 'package:flutter_isolates_example/objects/colonists_object.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';
import 'package:flutter_isolates_example/standard/pair.dart';
import 'package:flutter_isolates_example/units/actions/movable.dart';

class Worker extends PositionComponent
    with ColonistsObject, HasGameRef<ColonistsGame>, Movable {
  @override
  final double speed;

  Worker(double x, double y, {this.speed = 50}) {
    super.y = y * Constants.tileSize;
    super.x = x * Constants.tileSize;
    height = Constants.tileSize;
    width = Constants.tileSize;

    currentDirection = MoveDirection.idle;
  }

  final double _spriteSize = 72;
  final double _spritePadding = 36 / 2;

  Sprite getSprite(int row, int column) {
    return Sprite(
      Flame.images.fromCache('worker.png'),
      srcPosition: Vector2(
        column * _spriteSize + _spritePadding,
        row * _spriteSize + _spritePadding,
      ),
      srcSize: Vector2.all(72 - _spritePadding * 2),
    );
  }

  late SpriteAnimation _currentAnimation;

  late final Map<MoveDirection, SpriteAnimation> _directionAnimation = {
    MoveDirection.idle: SpriteAnimation.spriteList(
      [getSprite(0, 4)],
      stepTime: 1,
    ),
    MoveDirection.up: SpriteAnimation.spriteList(
      [
        getSprite(0, 0),
        getSprite(1, 0),
        getSprite(2, 0),
        getSprite(3, 0),
        getSprite(4, 0),
      ],
      stepTime: 0.1,
    ),
    MoveDirection.upRight: SpriteAnimation.spriteList(
      [
        getSprite(0, 1),
        getSprite(1, 1),
        getSprite(2, 1),
        getSprite(3, 1),
        getSprite(4, 1),
      ],
      stepTime: 0.1,
    ),
    MoveDirection.right: SpriteAnimation.spriteList(
      [
        getSprite(0, 2),
        getSprite(1, 2),
        getSprite(2, 2),
        getSprite(3, 2),
        getSprite(4, 2),
      ],
      stepTime: 0.1,
    ),
    MoveDirection.downRight: SpriteAnimation.spriteList(
      [
        getSprite(0, 3),
        getSprite(1, 3),
        getSprite(2, 3),
        getSprite(3, 3),
        getSprite(4, 3),
      ],
      stepTime: 0.1,
    ),
    MoveDirection.down: SpriteAnimation.spriteList(
      [
        getSprite(0, 4),
        getSprite(1, 4),
        getSprite(2, 4),
        getSprite(3, 4),
        getSprite(4, 4),
      ],
      stepTime: 0.1,
    ),
  };

  bool _walkingLeft = false;

  @override
  // ignore: avoid_setters_without_getters
  set currentDirection(MoveDirection direction) {
    _walkingLeft = direction.isLeft;
    _currentAnimation = _directionAnimation[
            direction.isLeft ? direction.mirrored : direction] ??
        _directionAnimation.values.first;
  }

  Pair<StaticColonistsObject, List<IntVector2>>? _currentTask;

  bool get isIdle => _currentTask == null;

  @override
  void reachedDestination() => _currentTask = null;

  @override
  void update(double dt) {
    _currentAnimation.update(dt);
    super.update(dt);
  }

  void issueWork(StaticColonistsObject objectToMove, List<IntVector2> path) {
    walkPath(path);
    _currentTask = Pair(objectToMove, path);
  }

  @override
  void render(Canvas canvas) {
    // We want to render from center of component
    canvas.translate(size.x / 2, size.y / 2);
    if (_walkingLeft) {
      canvas.scale(-1, 1);
    } //When moving left
    _currentAnimation.getSprite().render(
          canvas,
          position: Vector2.zero(),
          size: size,
          anchor: Anchor.center,
        );
  }

  @override
  IntVector2 tileSize = const IntVector2(1, 1);
}
