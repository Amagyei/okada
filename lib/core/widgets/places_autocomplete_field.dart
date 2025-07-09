import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:okada/data/services/places_service.dart';

class PlacesAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration? inputDecoration;
  final Function(PlaceDetails) onPlaceSelected;
  final List<String>? countries;
  final int debounceTime;
  final Widget Function(BuildContext, int, PlaceSuggestion)? itemBuilder;

  const PlacesAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onPlaceSelected,
    this.inputDecoration,
    this.countries,
    this.debounceTime = 400,
    this.itemBuilder,
  });

  @override
  State<PlacesAutocompleteField> createState() => _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState extends State<PlacesAutocompleteField> {
  final PlacesService _placesService = PlacesService();
  final Uuid _uuid = const Uuid();
  String? _sessionToken;
  List<PlaceSuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus && widget.controller.text.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () {
      if (widget.controller.text.isNotEmpty) {
        _fetchSuggestions();
      } else {
        setState(() {
          _suggestions = [];
        });
        _removeOverlay();
      }
    });
  }

  Future<void> _fetchSuggestions() async {
    if (widget.controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await _placesService.getAutocomplete(
        widget.controller.text,
        _sessionToken!,
        components: widget.countries?.map((country) => 'country:$country').join('|') ?? 'country:gh',
      );

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });

        if (_suggestions.isNotEmpty && widget.focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching suggestions: $e');
    }
  }

  void _showOverlay() {
    _removeOverlay();

    if (_suggestions.isEmpty && !_isLoading) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return widget.itemBuilder?.call(context, index, suggestion) ??
                            _defaultItemBuilder(context, suggestion);
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _defaultItemBuilder(BuildContext context, PlaceSuggestion suggestion) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          widget.controller.text = suggestion.description;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: suggestion.description.length),
          );
          
          // Fetch place details
          final details = await _placesService.getPlaceDetails(suggestion.placeId, _sessionToken!);
          if (details != null) {
            widget.onPlaceSelected(details);
          }
          
          widget.focusNode.unfocus();
          _removeOverlay();
          
          // Generate new session token for next search
          _sessionToken = _uuid.v4();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.description,
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: widget.inputDecoration,
        onTap: () {
          if (widget.controller.text.isNotEmpty && _suggestions.isNotEmpty) {
            _showOverlay();
          }
        },
      ),
    );
  }
} 