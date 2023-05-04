import '../src/autocomplete.dart';

import 'autocomplete_button.dart';
import 'custom_text_field.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    this.cameraPos,
    this.onAutocompleTapped,
  });

  final CameraPosition? cameraPos;
  final void Function(AutocompleteResult)? onAutocompleTapped;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final CustomTextFieldController _searchController =
      CustomTextFieldController();
  List<AutocompleteResult> _autocompleteResults = <AutocompleteResult>[];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() async {
      var results = await AutocompleteResult.fetch(
        _searchController.text,
        location: widget.cameraPos?.target,
      );

      setState(() => _autocompleteResults = results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 60.0),
      child: TapRegion(
        onTapOutside: (_) => _searchController.unfocus(),
        child: Column(
          children: [
            CustomTextField(
              hintText: "Search",
              unfocusOnTapOutside: false,
              controller: _searchController,
              leading: const Icon(Icons.search_rounded),
              keyboardType: TextInputType.streetAddress,
            ),
            if (_searchController.focused)
              Column(
                children: [
                  SizedBox(
                    height: math.min(_autocompleteResults.length * 58, 58 * 3),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        if (i >= _autocompleteResults.length) return null;

                        return AutocompleteButton(
                          text: Text(_autocompleteResults[i].name),
                          onTap: widget.onAutocompleTapped != null
                              ? () {
                                  _searchController.unfocus();

                                  widget.onAutocompleTapped!(
                                      _autocompleteResults[i]);
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
