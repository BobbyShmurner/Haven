import 'package:haven/src/place.dart';
import 'package:haven/widgets/map.dart';

import 'package:flutter/material.dart';
import 'package:enum_flag/enum_flag.dart';

class MapFilterButton extends StatefulWidget {
  const MapFilterButton({super.key, required this.mapController});

  final MapController mapController;

  @override
  State<MapFilterButton> createState() => _MapFilterButtonState();
}

class _MapFilterButtonState extends State<MapFilterButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mapController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(
            Radius.circular(56),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const CircleAvatar(
          backgroundColor: Colors.pink,
          radius: 56,
          child: Icon(
            Icons.filter_list_rounded,
            color: Colors.white,
          ),
        ),
      ),
      builder: (context, child) => PopupMenuButton(
        position: PopupMenuPosition.under,
        iconSize: 56,
        icon: child,
        itemBuilder: (context) {
          List<PopupMenuEntry<dynamic>> items = PlaceType.values
              .map(
                (place) => PopupMenuItem(
                  child: StatefulBuilder(
                    builder: (context, localSetState) => CheckboxListTile(
                      value: widget.mapController.placeMask.hasFlag(place),
                      onChanged: (newVal) => localSetState(
                        () => widget.mapController.setPlaceFlag(
                          place,
                          newVal ?? false,
                        ),
                      ),
                      title: Text(place.pluralName),
                    ),
                  ),
                ),
              )
              .toList();

          items.add(const PopupMenuItem(child: Divider()));

          items.add(
            PopupMenuItem(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return CheckboxListTile(
                    value: widget.mapController.onlyVerified,
                    onChanged: (newVal) => localSetState(
                      () => widget.mapController.onlyVerified =
                          !widget.mapController.onlyVerified,
                    ),
                    title: const Text("Only Verified"),
                  );
                },
              ),
            ),
          );

          return items;
        },
      ),
    );
  }
}
