import 'package:flutter/material.dart';
import '../../../core/models/document_record.dart';

class FilterChips extends StatelessWidget {
  final FileType? selectedFilter;
  final Function(FileType?) onFilterChanged;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            isSelected: selectedFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'PDFs',
            isSelected: selectedFilter == FileType.pdf,
            onTap: () => onFilterChanged(FileType.pdf),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Images',
            isSelected: selectedFilter == FileType.image,
            onTap: () => onFilterChanged(FileType.image),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Documents',
            isSelected: selectedFilter == FileType.office,
            onTap: () => onFilterChanged(FileType.office),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Text',
            isSelected: selectedFilter == FileType.text,
            onTap: () => onFilterChanged(FileType.text),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Others',
            isSelected: selectedFilter == FileType.other,
            onTap: () => onFilterChanged(FileType.other),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
