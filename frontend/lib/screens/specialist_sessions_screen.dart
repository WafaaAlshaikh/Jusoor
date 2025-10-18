import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpecialistSessionsScreen extends StatefulWidget {
  @override
  _SpecialistSessionsScreenState createState() => _SpecialistSessionsScreenState();
}

class _SpecialistSessionsScreenState extends State<SpecialistSessionsScreen> with SingleTickerProviderStateMixin {
  final List<Session> _sessions = [];
  List<Session> _filteredSessions = [];

  // Filter variables
  String _selectedStatus = 'All';
  String _selectedSessionType = 'All';
  String _selectedDiagnosis = 'All';
  DateTime? _selectedDate;
  String _searchQuery = '';

  // New state variables
  bool _isGridView = false;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Beautiful Purple Color Scheme
  final Color _primaryColor = Color(0xFF6B46C1); // Deep Purple
  final Color _secondaryColor = Color(0xFF9F7AEA); // Light Purple
  final Color _accentColor = Color(0xFFED64A6); // Pink accent
  final Color _backgroundColor = Color(0xFFF7FAFC); // Light background
  final Color _cardColor = Colors.white;
  final Color _textColor = Color(0xFF2D3748);
  final Color _successColor = Color(0xFF48BB78); // Green
  final Color _warningColor = Color(0xFFED8936); // Orange
  final Color _errorColor = Color(0xFFF56565); // Red

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
  }

  void _loadSessions() {
    // Mock data with enhanced information
    setState(() {
      _sessions.addAll([
        Session(
          sessionId: '1',
          child: Child(
            childId: '1',
            fullName: 'John Smith',
            diagnosis: 'ASD',
            age: 8,
            photo: 'assets/child1.jpg',
          ),
          institution: Institution(
            institutionId: '1',
            name: 'Main Therapy Center',
            address: '123 Therapy St, City',
          ),
          date: DateTime.now(),
          time: '10:00 AM',
          duration: 60,
          price: 100.0,
          sessionType: 'Online',
          status: 'Scheduled',
          notes: 'Focus on communication skills and social interaction. Continue with PECS training.',
          rating: 4,
          progress: 75,
          objectives: ['Improve eye contact', 'Enhance verbal communication'],
          materials: ['PECS cards', 'Social stories'],
        ),
        Session(
          sessionId: '2',
          child: Child(
            childId: '2',
            fullName: 'Emma Wilson',
            diagnosis: 'ADHD',
            age: 10,
            photo: 'assets/child2.jpg',
          ),
          institution: Institution(
            institutionId: '2',
            name: 'Children Care Center',
            address: '456 Care Ave, Town',
          ),
          date: DateTime.now().add(Duration(days: 1)),
          time: '02:30 PM',
          duration: 45,
          price: 85.0,
          sessionType: 'Onsite',
          status: 'Completed',
          notes: 'Excellent progress with attention tasks. Responding well to positive reinforcement.',
          rating: 5,
          progress: 60,
          objectives: ['Increase focus duration', 'Reduce impulsivity'],
          materials: ['Timer', 'Reward chart'],
        ),
        Session(
          sessionId: '3',
          child: Child(
            childId: '3',
            fullName: 'Michael Brown',
            diagnosis: 'Down Syndrome',
            age: 6,
            photo: 'assets/child3.jpg',
          ),
          institution: Institution(
            institutionId: '1',
            name: 'Main Therapy Center',
            address: '123 Therapy St, City',
          ),
          date: DateTime.now().add(Duration(days: 2)),
          time: '11:15 AM',
          duration: 90,
          price: 120.0,
          sessionType: 'Online',
          status: 'Scheduled',
          notes: 'Physical therapy session focusing on gross motor skills and coordination.',
          rating: 0,
          progress: 40,
          objectives: ['Improve balance', 'Strengthen core muscles'],
          materials: ['Balance board', 'Therapy ball'],
        ),
        Session(
          sessionId: '4',
          child: Child(
            childId: '4',
            fullName: 'Sophia Garcia',
            diagnosis: 'Speech & Language Disorder',
            age: 7,
            photo: 'assets/child4.jpg',
          ),
          institution: Institution(
            institutionId: '3',
            name: 'Speech Therapy Hub',
            address: '789 Language Blvd, Village',
          ),
          date: DateTime.now().subtract(Duration(days: 1)),
          time: '09:00 AM',
          duration: 50,
          price: 95.0,
          sessionType: 'Online',
          status: 'Completed',
          notes: 'Good progress with articulation. Continue practicing /r/ and /s/ sounds.',
          rating: 4,
          progress: 70,
          objectives: ['Improve articulation', 'Expand vocabulary'],
          materials: ['Mirror', 'Articulation cards'],
        ),
      ]);
      _filteredSessions = _sessions;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredSessions = _sessions.where((session) {
        bool statusMatch = _selectedStatus == 'All' || session.status == _selectedStatus;
        bool typeMatch = _selectedSessionType == 'All' || session.sessionType == _selectedSessionType;
        bool diagnosisMatch = _selectedDiagnosis == 'All' || session.child.diagnosis == _selectedDiagnosis;
        bool dateMatch = _selectedDate == null || DateUtils.isSameDay(session.date, _selectedDate);
        bool searchMatch = _searchQuery.isEmpty ||
            session.child.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            session.institution.name.toLowerCase().contains(_searchQuery.toLowerCase());

        return statusMatch && typeMatch && diagnosisMatch && dateMatch && searchMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('My Sessions', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        )),
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showAdvancedFilterDialog,
            tooltip: 'Filters',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'analytics') _showAnalytics();
              if (value == 'export') _exportSessions();
              if (value == 'settings') _showSettings();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: _primaryColor),
                    SizedBox(width: 8),
                    Text('View Analytics'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: _primaryColor),
                    SizedBox(width: 8),
                    Text('Export Sessions'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: _primaryColor),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Stats Cards
          _buildQuickStats(),

          // Search and Tabs
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar with enhanced design
                Container(
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search sessions, children, or institutions...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: _primaryColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                SizedBox(height: 12),
                // Enhanced Tabs
                Container(
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                      ),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: _textColor,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(icon: Icon(Icons.upcoming), text: 'Upcoming'),
                      Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
                      Tab(icon: Icon(Icons.all_inclusive), text: 'All'),
                    ],
                    onTap: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                        _applyTabFilter();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Active Filters
          _buildActiveFiltersChips(),

          // Content
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSessionDialog,
        child: Icon(Icons.add, size: 28),
        backgroundColor: _primaryColor,
        elevation: 4,
      ),
    );
  }

  Widget _buildQuickStats() {
    final upcoming = _sessions.where((s) => s.status == 'Scheduled').length;
    final completed = _sessions.where((s) => s.status == 'Completed').length;
    final revenue = _sessions.where((s) => s.status == 'Completed').fold(0.0, (sum, session) => sum + session.price);

    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Upcoming',
              '$upcoming',
              Icons.upcoming,
              _primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              '$completed',
              Icons.check_circle,
              _successColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenue',
              '\$${revenue.toStringAsFixed(0)}',
              Icons.attach_money,
              _accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];

    if (_selectedStatus != 'All') {
      chips.add(_buildFilterChip('Status: $_selectedStatus', () {
        setState(() => _selectedStatus = 'All');
        _applyFilters();
      }));
    }

    if (_selectedSessionType != 'All') {
      chips.add(_buildFilterChip('Type: $_selectedSessionType', () {
        setState(() => _selectedSessionType = 'All');
        _applyFilters();
      }));
    }

    if (_selectedDiagnosis != 'All') {
      chips.add(_buildFilterChip('Diagnosis: $_selectedDiagnosis', () {
        setState(() => _selectedDiagnosis = 'All');
        _applyFilters();
      }));
    }

    if (_selectedDate != null) {
      chips.add(_buildFilterChip('Date: ${DateFormat('MMM d').format(_selectedDate!)}', () {
        setState(() => _selectedDate = null);
        _applyFilters();
      }));
    }

    return chips.isEmpty ? SizedBox() : Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: TextStyle(color: _primaryColor)),
      backgroundColor: _primaryColor.withOpacity(0.1),
      deleteIcon: Icon(Icons.close, size: 16, color: _primaryColor),
      onDeleted: onDeleted,
    );
  }

  Widget _buildListView() {
    return _filteredSessions.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(_filteredSessions[index]);
      },
    );
  }

  Widget _buildGridView() {
    return _filteredSessions.isEmpty
        ? _buildEmptyState()
        : GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      padding: EdgeInsets.all(16),
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionGridCard(_filteredSessions[index]);
      },
    );
  }

  Widget _buildSessionCard(Session session) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showSessionDetails(session),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with child info and status
                Row(
                  children: [
                    // Child Avatar with initial
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          session.child.fullName[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.child.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          Text(
                            '${session.child.age} years • ${session.child.diagnosis}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSessionTypeChip(session.sessionType),
                    SizedBox(width: 8),
                    _buildStatusChip(session.status),
                  ],
                ),
                SizedBox(height: 12),

                // Institution and timing
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: _primaryColor),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.institution.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Date and time
                Row(
                  children: [
                    _buildDetailItem(Icons.calendar_today,
                        DateFormat('MMM d, yyyy').format(session.date)),
                    _buildDetailItem(Icons.access_time, session.time),
                    _buildDetailItem(Icons.timer, '${session.duration} min'),
                  ],
                ),
                SizedBox(height: 8),

                // Progress and Rating
                if (session.status == 'Completed') ...[
                  Row(
                    children: [
                      _buildRatingStars(session.rating),
                      Spacer(),
                      _buildProgressIndicator(session.progress),
                    ],
                  ),
                  SizedBox(height: 8),
                ],

                // Notes preview
                if (session.notes.isNotEmpty) ...[
                  Text(
                    session.notes.length > 100
                        ? '${session.notes.substring(0, 100)}...'
                        : session.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                ],

                // Price and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${session.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        if (session.sessionType == 'Online' && session.status == 'Scheduled')
                          IconButton(
                            icon: Icon(Icons.video_call, color: _primaryColor, size: 20),
                            onPressed: () => _joinVideoCall(session),
                            tooltip: 'Join Video Call',
                          ),
                        IconButton(
                          icon: Icon(Icons.edit, color: _primaryColor, size: 20),
                          onPressed: () => _editSession(session),
                          tooltip: 'Edit Session',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: _errorColor, size: 20),
                          onPressed: () => _deleteSession(session),
                          tooltip: 'Delete Session',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionGridCard(Session session) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showSessionDetails(session),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          session.child.fullName[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    _buildStatusChip(session.status),
                  ],
                ),
                SizedBox(height: 8),

                // Child info
                Text(
                  session.child.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session.child.diagnosis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 8),

                // Date and time
                Text(
                  DateFormat('MMM d').format(session.date),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  session.time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Spacer(),

                // Price and quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${session.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        fontSize: 14,
                      ),
                    ),
                    if (session.sessionType == 'Online' && session.status == 'Scheduled')
                      Icon(Icons.video_call, color: _primaryColor, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTypeChip(String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: type == 'Online' ? _accentColor.withOpacity(0.1) : _secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: type == 'Online' ? _accentColor : _secondaryColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == 'Online' ? Icons.video_call : Icons.business,
            size: 12,
            color: type == 'Online' ? _accentColor : _secondaryColor,
          ),
          SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: type == 'Online' ? _accentColor : _secondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Scheduled':
        color = _warningColor;
        icon = Icons.access_time;
        break;
      case 'Completed':
        color = _successColor;
        icon = Icons.check_circle;
        break;
      case 'Cancelled':
        color = _errorColor;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 2),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _primaryColor),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        size: 14,
        color: Colors.amber,
      )),
    );
  }

  Widget _buildProgressIndicator(int progress) {
    return Container(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$progress%',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          SizedBox(height: 2),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                Container(
                  width: progress.toDouble(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_note, size: 60, color: _primaryColor),
          ),
          SizedBox(height: 24),
          Text(
            'No sessions found',
            style: TextStyle(
              fontSize: 20,
              color: _textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Schedule your first session to get started with your therapy appointments',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddSessionDialog,
            icon: Icon(Icons.add),
            label: Text('Schedule New Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _applyTabFilter() {
    switch (_selectedTabIndex) {
      case 0: // Upcoming
        setState(() {
          _selectedStatus = 'Scheduled';
        });
        break;
      case 1: // Completed
        setState(() {
          _selectedStatus = 'Completed';
        });
        break;
      case 2: // All
        setState(() {
          _selectedStatus = 'All';
        });
        break;
    }
    _applyFilters();
  }

  // Placeholder methods for features
  void _showAdvancedFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Advanced Filters', style: TextStyle(color: _primaryColor)),
        content: Text('Advanced filtering options will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session Details', style: TextStyle(color: _primaryColor)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Child: ${session.child.fullName}', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Diagnosis: ${session.child.diagnosis}'),
              Text('Date: ${DateFormat('MMM d, yyyy').format(session.date)}'),
              Text('Time: ${session.time}'),
              Text('Duration: ${session.duration} minutes'),
              Text('Price: \$${session.price}'),
              Text('Type: ${session.sessionType}'),
              Text('Status: ${session.status}'),
              if (session.notes.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(session.notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  void _joinVideoCall(Session session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining video call with ${session.child.fullName}'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  void _showAnalytics() {
    // Analytics implementation
  }

  void _exportSessions() {
    // Export implementation
  }

  void _showSettings() {
    // Settings implementation
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Session', style: TextStyle(color: _primaryColor)),
        content: Text('Session creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('New session created successfully!'),
                  backgroundColor: _successColor,
                ),
              );
            },
            child: Text('Create Session'),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
          ),
        ],
      ),
    );
  }

  void _editSession(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Session', style: TextStyle(color: _primaryColor)),
        content: Text('Session editing form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Session updated successfully!'),
                  backgroundColor: _successColor,
                ),
              );
            },
            child: Text('Save Changes'),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
          ),
        ],
      ),
    );
  }

  void _deleteSession(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Session', style: TextStyle(color: _errorColor)),
        content: Text('Are you sure you want to delete this session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textColor)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sessions.removeWhere((s) => s.sessionId == session.sessionId);
                _filteredSessions.removeWhere((s) => s.sessionId == session.sessionId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Session deleted successfully'),
                  backgroundColor: _errorColor,
                ),
              );
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor),
          ),
        ],
      ),
    );
  }
}

// Enhanced Data Models
class Session {
  final String sessionId;
  final Child child;
  final Institution institution;
  final DateTime date;
  final String time;
  final int duration;
  final double price;
  final String sessionType;
  final String status;
  final String notes;
  final int rating;
  final int progress;
  final List<String> objectives;
  final List<String> materials;

  Session({
    required this.sessionId,
    required this.child,
    required this.institution,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.sessionType,
    required this.status,
    this.notes = '',
    this.rating = 0,
    this.progress = 0,
    this.objectives = const [],
    this.materials = const [],
  });
}

class Child {
  final String childId;
  final String fullName;
  final String diagnosis;
  final int age;
  final String photo;

  Child({
    required this.childId,
    required this.fullName,
    required this.diagnosis,
    required this.age,
    required this.photo,
  });
}

class Institution {
  final String institutionId;
  final String name;
  final String address;

  Institution({
    required this.institutionId,
    required this.name,
    required this.address,
  });
}