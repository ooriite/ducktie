import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/time_block.dart';

class TimeBlocksPage extends StatefulWidget {
  @override
  _TimeBlocksPageState createState() => _TimeBlocksPageState();
}

class _TimeBlocksPageState extends State<TimeBlocksPage> {
  final supabase = Supabase.instance.client;
  List<TimeBlock> _timeBlocks = [];
  bool _allowOverlap = false;

  @override
  void initState() {
    super.initState();
    _loadTimeBlocks();
    _setupRealtime();
  }

  Future<void> _loadTimeBlocks() async {
    final response = await supabase
        .from('time_blocks')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('start_time')
        .order('position');
    
    setState(() {
      _timeBlocks = response.map((json) => TimeBlock.fromJson(json)).toList();
    });
  }

  void _setupRealtime() {
    supabase
        .channel('time_blocks')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'time_blocks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: supabase.auth.currentUser!.id,
          ),
          callback: (payload) => _loadTimeBlocks(),
        )
        .subscribe();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
  if (newIndex > oldIndex) newIndex--;
  
  final movedBlock = _timeBlocks.removeAt(oldIndex);
  
  TimeBlock updatedBlock;
  
  if (!_allowOverlap) {
    // No-overlap mode: adjust times based on new position
    final newStartTime = newIndex > 0 
        ? _timeBlocks[newIndex - 1].endTime
        : DateTime.now().add(Duration(hours: 9)); // Default 9AM
    
    updatedBlock = TimeBlock(
      id: movedBlock.id,
      userId: movedBlock.userId,
      title: movedBlock.title,
      startTime: newStartTime,
      endTime: newStartTime.add(Duration(hours: 1)),
      notes: movedBlock.notes,
      isShared: movedBlock.isShared,
      position: newIndex,
    );
  } else {
    updatedBlock = TimeBlock(
      id: movedBlock.id,
      userId: movedBlock.userId,
      title: movedBlock.title,
      startTime: movedBlock.startTime,
      endTime: movedBlock.endTime,
      notes: movedBlock.notes,
      isShared: movedBlock.isShared,
      position: newIndex,
    );
  }
  
  _timeBlocks.insert(newIndex, updatedBlock);
  
  // Update Supabase
  await supabase.from('time_blocks').update({
    'start_time': updatedBlock.startTime.toIso8601String(),
    'end_time': updatedBlock.endTime.toIso8601String(),
    'position': newIndex,
  }).eq('id', updatedBlock.id);
  
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Allow overlapping blocks'),
            value: _allowOverlap,
            onChanged: (value) => setState(() => _allowOverlap = value),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: _onReorder,
              children: _timeBlocks.map((block) {
                return ListTile(
                  key: ValueKey(block.id),
                  title: Text(block.title),
                  subtitle: Text(
                    '${_formatTime(block.startTime)} - ${_formatTime(block.endTime)}'
                  ),
                  trailing: Icon(Icons.drag_handle),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBlockDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showAddBlockDialog() {
    // Add dialog for new blocks (implement later)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add block dialog - coming in next step!')),
    );
  }
}
