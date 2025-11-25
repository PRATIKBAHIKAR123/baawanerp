import 'package:flutter/material.dart';

class ExpandableItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool showOpeningBalance;
  final bool showDebit;
  final bool showCredit;
  final Function(Map<String, dynamic>) onItemSelected;

  const ExpandableItem({
    Key? key,
    required this.item,
    required this.showOpeningBalance,
    required this.showDebit,
    required this.showCredit,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _ExpandableItemState createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> {
  void toggleItem(Map<String, dynamic> item) {
    setState(() {
      item['isActive'] = false;
    });
    widget.onItemSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      widget.item['isActive'] = false;
    });
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.item['NAME']),
            leading: widget.item['ISGROUP']
                ? Icon(
                    widget.item['isActive']
                        ? Icons.remove_circle
                        : Icons.add_circle,
                  )
                : Icon(Icons.folder),
            onTap: () => toggleItem(widget.item),
          ),
          if (widget.showOpeningBalance)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Opening Balance: ${widget.item['OPENINGBAL']}'),
            ),
          // if (widget.showDebit)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     child: Text('Debit: ${widget.item['debit']}'),
          //   ),
          // if (widget.showCredit)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     child: Text('Credit: ${widget.item['credit']}'),
          //   ),
          if (widget.item['isActive'] &&
              (widget.item['childNodeData'] as List).isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: (widget.item['childNodeData'] as List)
                    .map((child) => ExpandableItem(
                          item: child,
                          showOpeningBalance: widget.showOpeningBalance,
                          showDebit: widget.showDebit,
                          showCredit: widget.showCredit,
                          onItemSelected: widget.onItemSelected,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
