import '../src/autocomplete.dart';
import 'autocomplete_button.dart';

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
  final TextEditingController _searchController = TextEditingController();
  List<AutocompleteResult> _autocompleteResults = <AutocompleteResult>[];

  bool showAutocomplete = false;

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

  void unfocus() {
    showAutocomplete = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 60.0),
      child: TapRegion(
        onTapOutside: (_) => unfocus(),
        child: Column(
          children: [
            Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.search_rounded),
                trailing: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.cancel_rounded),
                        onPressed: () => _searchController.clear(),
                      ),
                title: TextField(
                  autocorrect: false,
                  controller: _searchController,
                  keyboardType: TextInputType.streetAddress,
                  onTap: () => showAutocomplete = true,
                  onSubmitted: (_) => unfocus(),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (showAutocomplete)
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
                                  unfocus();

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
