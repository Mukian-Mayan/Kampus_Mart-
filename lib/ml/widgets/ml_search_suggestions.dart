import 'package:flutter/material.dart';
import '../services/enhanced_product_service.dart';
import '../../Theme/app_theme.dart';

class MLSearchSuggestions extends StatefulWidget {
  final Function(String) onSuggestionSelected;
  final String partialQuery;
  final int maxSuggestions;
  final bool showSuggestions;

  const MLSearchSuggestions({
    super.key,
    required this.onSuggestionSelected,
    required this.partialQuery,
    this.maxSuggestions = 5,
    this.showSuggestions = true,
  });

  @override
  State<MLSearchSuggestions> createState() => _MLSearchSuggestionsState();
}

class _MLSearchSuggestionsState extends State<MLSearchSuggestions> {
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.partialQuery.isNotEmpty) {
      _loadSuggestions();
    }
  }

  @override
  void didUpdateWidget(MLSearchSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.partialQuery != oldWidget.partialQuery) {
      if (widget.partialQuery.isNotEmpty) {
        _loadSuggestions();
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _loadSuggestions() async {
    if (widget.partialQuery.length < 2) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await EnhancedProductService.getSearchSuggestions(
        partialQuery: widget.partialQuery,
        limit: widget.maxSuggestions,
      );

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showSuggestions || widget.partialQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading suggestions...'),
                ],
              ),
            )
          else if (_suggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Text(
                    'No suggestions found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._suggestions.map((suggestion) => _buildSuggestionTile(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(String suggestion) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSuggestionSelected(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 18,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    children: _buildHighlightedText(suggestion),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_upward,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String suggestion) {
    final spans = <TextSpan>[];
    final query = widget.partialQuery.toLowerCase();
    final suggestionLower = suggestion.toLowerCase();
    
    int start = 0;
    int index = suggestionLower.indexOf(query);
    
    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: suggestion.substring(start, index),
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: suggestion.substring(index, index + query.length),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryOrange,
        ),
      ));
      
      start = index + query.length;
      index = suggestionLower.indexOf(query, start);
    }
    
    // Add remaining text
    if (start < suggestion.length) {
      spans.add(TextSpan(
        text: suggestion.substring(start),
      ));
    }
    
    return spans;
  }
} 