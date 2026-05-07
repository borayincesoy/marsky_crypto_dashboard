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
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Fiyat (Düşükten Yükseğe)'),
              onTap: () {
                _sortBy = 'price';
                _sortDirection = 'asc';
                _currentPage = 1;
                _loadCryptos();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Fiyat (Yüksekten Düşüğe)'),
              onTap: () {
                _sortBy = 'price';
                _sortDirection = 'desc';
                _currentPage = 1;
                _loadCryptos();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pazar Hacmi (Düşükten Yükseğe)'),
              onTap: () {
                _sortBy = '24hVolume';
                _sortDirection = 'asc';
                _currentPage = 1;
                _loadCryptos();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pazar Hacmi (Yüksekten Düşüğe)'),
              onTap: () {
                _sortBy = '24hVolume';
                _sortDirection = 'desc';
                _currentPage = 1;
                _loadCryptos();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Değişim Oranı (Düşükten Yükseğe)'),
              onTap: () {
                _sortBy = 'change';
                _sortDirection = 'asc';
                _currentPage = 1;
                _loadCryptos();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Değişim Oranı (Yüksekten Düşüğe)'),
              onTap: () {
                _sortBy = 'change';
                _sortDirection = 'desc';
                _currentPage = 1;
                _loadCryptos();
                Navigator.pop(context);
              },
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
              Tab(text: 'Ana Sayfa'),
              Tab(text: 'Favoriler'),
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
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _showSortOptions,
                    child: const Text('Sıralamayı Değiştir'),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CryptoBloc, CryptoState>(
                    builder: (context, state) {
                      if (state is CryptoLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is CryptoError) {
                        return Center(child: Text('Hata: ${state.message}'));
                      }

                      if (state is CryptoLoaded) {
                        return ListView.builder(
                          itemCount: state.cryptos.length,
                          itemBuilder: (context, index) {
                            final crypto = state.cryptos[index];
                            return CryptoCard(
                              crypto: crypto,
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
                            );
                          },
                        );
                      }

                      return const Center(child: Text('Veri yükleniyor...'));
                    },
                  ),
                ),
                // Pagination Controls
                BlocBuilder<CryptoBloc, CryptoState>(
                  builder: (context, state) {
                    if (state is CryptoLoaded) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                      _currentPage--;
                                      _loadCryptos();
                                    }
                                  : null,
                              child: const Text('Önceki'),
                            ),
                            Text(
                              'Sayfa ${state.currentPage}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: state.currentPage < state.totalPages
                                  ? () {
                                      _currentPage++;
                                      _loadCryptos();
                                    }
                                  : null,
                              child: const Text('Sonraki'),
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
}
