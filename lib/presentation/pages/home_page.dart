import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/crypto_bloc.dart';
import '../bloc/crypto_event.dart';
import '../bloc/crypto_state.dart';
import 'login_page.dart';
import 'favorites_page.dart';
import 'crypto_detail_page.dart';
import '../widgets/crypto_card.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  String? _sortBy;
  String? _sortDirection;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCryptos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCryptos() {
    const pageSize = 20;
    context.read<CryptoBloc>().add(
      FetchCryptosRequested(
        offset: (_currentPage - 1) * pageSize,
        limit: pageSize,
        orderBy: _sortBy,
        orderDirection: _sortDirection,
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  String _getSortLabel(String value) {
    switch (value) {
      case 'marketCap':
        return 'Market Cap';
      case '24hVolume':
        return '24h Volume';
      case 'price':
        return 'Price';
      case 'change':
        return 'Change';
      case 'listedAt':
        return 'Newest Listed';
      default:
        return 'Market Rank';
    }
  }

  void _showSortOptions() {
    final List<Map<String, String?>> sortOptions = [
      {'label': 'Market Rank', 'value': null},
      {'label': 'Market Cap', 'value': 'marketCap'},
      {'label': '24h Volume', 'value': '24hVolume'},
      {'label': 'Price', 'value': 'price'},
      {'label': 'Change Rate', 'value': 'change'},
      {'label': 'Listing Date', 'value': 'listedAt'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sortOptions.map((option) {
              final isSelected = _sortBy == option['value'];
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                ),
                title: Text(
                  option['label']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                  ),
                ),
                trailing: isSelected && _sortBy != null
                    ? Icon(
                        _sortDirection == 'desc'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 18,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    if (option['value'] == null) {
                      _sortBy = null;
                      _sortDirection = null;
                    } else if (_sortBy == option['value']) {
                      _sortDirection = _sortDirection == 'desc' ? 'asc' : 'desc';
                    } else {
                      _sortBy = option['value'];
                      _sortDirection = 'desc';
                    }
                    _currentPage = 1;
                  });
                  _loadCryptos();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPagePicker(int totalPages) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Go to Page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 50, // Limit to 50 pages for UX
                itemBuilder: (context, index) {
                  final page = index + 1;
                  final isSelected = _currentPage == page;
                  return InkWell(
                    onTap: () {
                      _currentPage = page;
                      _loadCryptos();
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        page.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginPage.routeName,
            (route) => false,
          );
        }

        if (state is AuthFailure) {
          _showErrorDialog(context, state.title, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marsky Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Home'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Home Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showSortOptions,
                          icon: const Icon(Icons.sort, size: 18),
                          label: Text(
                            'Sort: ${_sortBy != null ? _getSortLabel(_sortBy!) : 'Market Rank'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1C1E),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CryptoBloc, CryptoState>(
                    builder: (context, state) {
                      if (state is CryptoLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is CryptoError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                                const SizedBox(height: 16),
                                Text(
                                  state.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _loadCryptos,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is CryptoLoaded) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            _loadCryptos();
                          },
                          child: ListView.builder(
                            itemCount: state.cryptos.length,
                            itemBuilder: (context, index) {
                            final crypto = state.cryptos[index];
                            return CryptoCard(
                              crypto: crypto,
                              displayIndex: (state.currentPage - 1) * 20 + index + 1,
                              onFavoriteTap: () {
                                if (crypto.isFavorite) {
                                  context.read<CryptoBloc>().add(
                                    RemoveFavoriteRequested(crypto.id),
                                  );
                                } else {
                                  context.read<CryptoBloc>().add(
                                    AddFavoriteRequested(crypto.id),
                                  );
                                }
                              },
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.black.withValues(alpha: 0.5),
                                  builder: (context) =>
                                      CryptoDetailPage(crypto: crypto),
                                );
                              },
                            );
                          },
                        ),
                        );
                      }

                      return const Center(child: Text('Loading data...'));
                    },
                  ),
                ),
                // Pagination Controls
                BlocBuilder<CryptoBloc, CryptoState>(
                  builder: (context, state) {
                    if (state is CryptoLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, -2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                      _currentPage--;
                                      _loadCryptos();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            TextButton.icon(
                              onPressed: () => _showPagePicker(state.totalPages),
                              icon: const Icon(Icons.pages, size: 18),
                              label: Text(
                                'Page ${state.currentPage}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: state.currentPage < state.totalPages
                                  ? () {
                                      _currentPage++;
                                      _loadCryptos();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            // Favorites Tab
            const FavoritesPage(),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
