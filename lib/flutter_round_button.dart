import 'dart:async';

import 'package:flutter/material.dart';

/// States that your button can assume via the controller
// ignore: public_member_api_docs
enum ButtonState { idle, loading, success, error }

/// Initalize class
class RoundedLoadingButton extends StatefulWidget {
  /// Button controller, now required
  final RoundedLoadingButtonController controller;

  /// The callback that is called when
  /// the button is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// The button's label
  final Widget child;

  /// The primary color of the button
  final Color? color;

  /// The vertical extent of the button.
  final double height;

  /// The horiztonal extent of the button.
  final double width;

  /// The size of the CircularProgressIndicator
  final double loaderSize;

  /// The stroke width of the CircularProgressIndicator
  final double loaderStrokeWidth;

  /// Whether to trigger the animation on the tap event
  final bool animateOnTap;

  /// The color of the static icons
  final Color valueColor;

  /// reset the animation after specified duration,
  /// use resetDuration parameter to set Duration, defaults to 15 seconds
  final bool resetAfterDuration;

  /// The curve of the shrink animation
  final Curve curve;

  /// The radius of the button border
  final double borderRadius;

  /// The duration of the button animation
  final Duration duration;

  /// The elevation of the raised button
  final double elevation;

  /// Duration after which reset the button
  final Duration resetDuration;

  /// The color of the button when it is in the error state
  final Color? errorColor;

  /// The color of the button when it is in the success state
  final Color? successColor;

  /// The color of the button when it is disabled
  final Color? disabledColor;

  /// The icon for the success state
  final IconData successIcon;

  /// The icon for the failed state
  final IconData failedIcon;

  /// The success and failed animation curve
  final Curve completionCurve;

  /// The duration of the success and failed animation
  final Duration completionDuration;

  Duration get _borderDuration {
    return Duration(milliseconds: (duration.inMilliseconds / 2).round());
  }

  final Text? childText;

  /// initalize constructor
  const RoundedLoadingButton({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.child,
    this.color = Colors.lightBlue,
    this.height = 50,
    this.width = 300,
    this.loaderSize = 25.0,
    this.loaderStrokeWidth = 2.0,
    this.animateOnTap = false,
    this.valueColor = Colors.white,
    this.borderRadius = 20,
    this.elevation = 2,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCirc,
    this.errorColor = Colors.red,
    this.successColor,
    this.resetDuration = const Duration(seconds: 2),
    this.resetAfterDuration = false,
    this.successIcon = Icons.check,
    this.failedIcon = Icons.close,
    this.completionCurve = Curves.elasticOut,
    this.completionDuration = const Duration(seconds: 1),
    this.disabledColor,
    this.childText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RoundedLoadingButtonState();
}

class RoundedLoadingButtonState extends State<RoundedLoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _borderController;
  late AnimationController _checkButtonController;

  late Animation _squeezeAnimation;
  late Animation _bounceAnimation;
  late Animation _borderAnimation;
  bool isChildVisible = true;
  ButtonState buttonState = ButtonState.idle;

  StreamController<ButtonState> controller =
      StreamController<ButtonState>.broadcast();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: StreamBuilder<ButtonState>(
        initialData: ButtonState.idle,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          if (snapshot.data == ButtonState.error) {
            return buildFail();
          }
          if (snapshot.data == ButtonState.success) {
            return buildSuccess();
          }
          return buildButton();
        },
        stream: controller.stream,
      ),
    );
  }

  Widget buildSuccess() {
    final theme = Theme.of(context);
    return Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: widget.successColor ?? theme.primaryColor,
        borderRadius:
            BorderRadius.all(Radius.circular(_bounceAnimation.value / 2)),
      ),
      width: _bounceAnimation.value,
      height: _bounceAnimation.value,
      child: _bounceAnimation.value > 20
          ? Icon(
              widget.successIcon,
              color: widget.valueColor,
            )
          : null,
    );
  }

  Widget buildFail() {
    return Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: widget.errorColor,
        borderRadius:
            BorderRadius.all(Radius.circular(_bounceAnimation.value / 2)),
      ),
      width: _bounceAnimation.value,
      height: _bounceAnimation.value,
      child: _bounceAnimation.value > 20
          ? Icon(
              widget.failedIcon,
              color: widget.valueColor,
            )
          : null,
    );
  }

  Widget buildLoader() {
    return SizedBox(
      height: widget.loaderSize,
      width: widget.loaderSize,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
        strokeWidth: widget.loaderStrokeWidth,
      ),
    );
  }

  Widget buildButton() {
    return ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: _borderAnimation.value),
      disabledColor: widget.disabledColor,
      padding: EdgeInsets.zero,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(_squeezeAnimation.value, widget.height),
          backgroundColor: widget.color,
          disabledForegroundColor: widget.disabledColor?.withOpacity(0.38),
          disabledBackgroundColor: widget.disabledColor?.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          elevation: widget.elevation,
        ),
        onPressed: widget.onPressed == null ? null : _btnPressed,
        child: buttonState == ButtonState.loading
            ? buildLoader()
            : AnimatedOpacity(
                opacity: isChildVisible ? 1 : 0,
                duration: widget.duration,
                child: isChildVisible ? widget.child : const SizedBox.shrink(),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _buttonController =
        AnimationController(duration: widget.duration, vsync: this);

    _checkButtonController =
        AnimationController(duration: widget.completionDuration, vsync: this);

    _borderController =
        AnimationController(duration: widget._borderDuration, vsync: this);

    _bounceAnimation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(
        parent: _checkButtonController,
        curve: widget.completionCurve,
      ),
    );
    _bounceAnimation.addListener(() {
      setState(() {});
    });

    _squeezeAnimation =
        Tween<double>(begin: widget.width, end: widget.height).animate(
      CurvedAnimation(parent: _buttonController, curve: widget.curve),
    );

    _squeezeAnimation.addListener(() {
      setState(() {});
    });

    _squeezeAnimation.addStatusListener((state) {
      if (state == AnimationStatus.completed && widget.animateOnTap) {
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      }
    });

    _borderAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(widget.borderRadius),
      end: BorderRadius.circular(widget.height),
    ).animate(_borderController);

    _borderAnimation.addListener(() {
      setState(() {});
    });

    // There is probably a better way of doing this...
    controller.stream.listen((event) {
      if (!mounted) return;
      widget.controller.sink.add(event);
    });

    widget.controller._addListeners(_start, _stop, _success, _error, _reset);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _checkButtonController.dispose();
    _borderController.dispose();
    controller.sink.close();
    super.dispose();
  }

  void _btnPressed() async {
    if (widget.animateOnTap) {
      _start();
    } else {
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    }
  }

  void _start() {
    if (!mounted) return;
    isChildVisible = false;
    buttonState = ButtonState.loading;
    controller.sink.add(ButtonState.loading);
    _borderController.forward();
    _buttonController.forward();
  }

  void _stop() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      isChildVisible = true;
    });
    buttonState = ButtonState.idle;
    controller.sink.add(ButtonState.idle);
    _buttonController.reverse();
    _borderController.reverse();
  }

  void _success() {
    if (!mounted) return;
    buttonState = ButtonState.success;
    controller.sink.add(ButtonState.success);
    _checkButtonController.forward();
  }

  void _error() {
    if (!mounted) return;
    buttonState = ButtonState.error;
    controller.sink.add(ButtonState.error);
    _checkButtonController.forward();
  }

  void _reset() async {
    if (widget.resetAfterDuration) await Future.delayed(widget.resetDuration);
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      isChildVisible = true;
    });
    controller.sink.add(ButtonState.idle);
    buttonState = ButtonState.idle;
    _buttonController.reverse();
    _borderController.reverse();
    _checkButtonController.reset();
  }
}

/// Options that can be chosen by the controller
/// each will perform a unique animation
class RoundedLoadingButtonController {
  VoidCallback? _startListener;
  VoidCallback? _stopListener;
  VoidCallback? _successListener;
  VoidCallback? _errorListener;
  VoidCallback? _resetListener;

  void _addListeners(
    VoidCallback startListener,
    VoidCallback stopListener,
    VoidCallback successListener,
    VoidCallback errorListener,
    VoidCallback resetListener,
  ) {
    _startListener = startListener;
    _stopListener = stopListener;
    _successListener = successListener;
    _errorListener = errorListener;
    _resetListener = resetListener;
  }

  StreamController<ButtonState> controller =
      StreamController<ButtonState>.broadcast();

  /// A read-only stream of the button state
  Stream<ButtonState> get stateStream => controller.stream;

  StreamSink<ButtonState> get sink => controller.sink;

  /// Gets the current state
  // ButtonState? get currentState => _state.value;

  /// Notify listeners to start the loading animation
  void start() {
    if (_startListener != null) _startListener!();
  }

  /// Notify listeners to start the stop animation
  void stop() {
    if (_stopListener != null) _stopListener!();
  }

  /// Notify listeners to start the success animation
  void success() {
    if (_successListener != null) {
      _successListener!();
    }
  }

  /// Notify listeners to start the error animation
  void error() {
    if (_errorListener != null) _errorListener!();
  }

  /// Notify listeners to start the reset animation
  void reset() {
    if (_resetListener != null) _resetListener!();
  }
}
