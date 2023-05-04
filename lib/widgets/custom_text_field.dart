import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.leading,
    this.onFocus,
    this.onUnfocus,
    this.hintText,
    this.onSubmitted,
    this.keyboardType,
    this.unfocusOnSubmit = true,
    this.unfocusOnTapOutside = true,
    this.controller,
  });

  final CustomTextFieldController? controller;

  final void Function()? onFocus;
  final void Function()? onUnfocus;
  final void Function()? onSubmitted;

  final Widget? leading;
  final String? hintText;
  final bool unfocusOnSubmit;
  final bool unfocusOnTapOutside;
  final TextInputType? keyboardType;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  CustomTextFieldController? _controller;
  CustomTextFieldController get _effectiveController =>
      widget.controller ?? (_controller ??= CustomTextFieldController());

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: widget.unfocusOnTapOutside
          ? (_) => _effectiveController.unfocus()
          : null,
      child: Card(
        child: AnimatedBuilder(
          animation: _effectiveController,
          builder: (context, _) => ListTile(
            dense: true,
            horizontalTitleGap: 0,
            focusNode: _effectiveController.focusNode,
            leading: widget.leading,
            trailing: _effectiveController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.cancel_rounded),
                    onPressed: () => _effectiveController.clear(),
                  ),
            title: TextField(
              autocorrect: false,
              controller: _effectiveController,
              keyboardType: widget.keyboardType,
              onTap: () => () {
                _effectiveController.focus();
                widget.onFocus?.call();
              },
              onSubmitted: (_) => () {
                if (widget.unfocusOnSubmit) _effectiveController.unfocus();
                widget.onSubmitted?.call();
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextFieldController extends TextEditingController {
  CustomTextFieldController({super.text});

  final FocusNode focusNode = FocusNode();

  bool get focused {
    return focusNode.hasFocus;
  }

  void unfocus() {
    if (!focused) return;

    focusNode.unfocus();
    notifyListeners();
  }

  void focus() {
    if (focused) return;

    focusNode.requestFocus();
    notifyListeners();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
