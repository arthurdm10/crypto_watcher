import 'package:crypto_watcher/components/loading_indicator.dart';
import 'package:crypto_watcher/providers/coins.dart';
import 'package:crypto_watcher/services/coincap_api.dart';
import 'package:crypto_watcher/styles/colors.dart' as AppColors;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCoin extends StatefulWidget {
  @override
  _AddCoinState createState() => _AddCoinState();
}

class _AddCoinState extends State<AddCoin> {
  String _searchCoinName;
  DateTime _lastUpdate;
  TextEditingController _inputController;

  @override
  void initState() {
    _lastUpdate = DateTime.now();
    _inputController = TextEditingController();
    _inputController.addListener(_search);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.backgroundLight),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondaryColor),
                ),
                hintText: "Search...",
                hintStyle: TextStyle(color: AppColors.backgroundLight),
                suffix: GestureDetector(
                  onTap: () => _inputController.clear(),
                  child: Icon(Icons.clear, color: AppColors.backgroundLight),
                ),
              ),
              style: TextStyle(color: AppColors.secondaryDark),
            ),
          ),
          SizedBox(height: 25),
          Expanded(
            child: Provider.value(
              value: _searchCoinName,
              child: CoinsList(),
              updateShouldNotify: (prev, cur) => true,
            ),
          )
        ],
      ),
    );
  }

  void _search() {
    final now = DateTime.now();
    final text = _inputController.text;
    if (now.isAfter(_lastUpdate.add(Duration(milliseconds: 300)))) {
      setState(() {
        _searchCoinName = text;
        _lastUpdate = now;
      });
    }
  }
}

class CoinsList extends StatefulWidget {
  CoinsList({Key key}) : super(key: key);

  _CoinsListState createState() => _CoinsListState();
}

enum Status { Loading, Done }

class _CoinsListState extends State<CoinsList> {
  static const int LIMIT = 20;
  Status _status = Status.Loading;

  final _coins = List<Map<String, dynamic>>();
  var _searchResult = List<Map<String, dynamic>>();
  bool _searching = false;

  int _offset = 0;
  int _searchOffset = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), loadCoins);
  }

  void loadCoins() {
    _status = Status.Loading;
    final coinName = Provider.of<String>(context);
    final offset = _searching ? _searchOffset : _offset;

    CoincapApi.assets(searchId: coinName, limit: LIMIT, offset: offset).then((data) {
      setState(() {
        _status = Status.Done;

        if (!_searching) {
          _coins.addAll([...data["data"]]);
        } else {
          _searchResult.addAll([...data["data"]]);
        }
      });
    });
  }

  @override
  void didUpdateWidget(CoinsList oldWidget) {
    final coinName = Provider.of<String>(context);
    _searching = coinName != null && coinName.isNotEmpty;

    _searchOffset = 0;
    _searchResult.clear();

    _offset = _coins.length;
    loadCoins();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_status == Status.Loading) {
      return Center(child: LoadingIndicator());
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: ListView.builder(
        itemCount: _searching ? _searchResult.length : _coins.length + 1,
        itemBuilder: buildCoinItem,
      ),
    );
  }

  bool _handleScroll(scrollInfo) {
    final maxScroll = scrollInfo.metrics.maxScrollExtent;

    if (scrollInfo.metrics.pixels >= maxScroll - (maxScroll * 0.25) &&
        _status != Status.Loading) {
      if (_searching) {
        _searchOffset += LIMIT;
      } else {
        _offset += LIMIT;
      }

      loadCoins();
    }
    return true;
  }

  Widget buildCoinItem(BuildContext context, int index) {
    final coinsProvider = Provider.of<Coins>(context);
    if (index == _coins.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: LoadingIndicator(),
          ),
        ),
      );
    }

    final coin = _searching ? _searchResult[index] : _coins[index];
    final addedCoins = coinsProvider.userCoins;
    final coinSymbol = coin["symbol"];
    final coinName = coin["name"];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundLight,
            width: 0.5,
          ),
        ),
      ),
      child: SwitchListTile(
        onChanged: (add) {
          if (add) {
            // coinsProvider.addCoin(coin["id"]);
            coinsProvider.addCoin(coin);
          } else {
            coinsProvider.removeCoin(coin["id"]);
          }
        },
        activeColor: AppColors.secondaryColor,
        inactiveThumbColor: AppColors.backgroundLight,
        value:
            addedCoins.indexWhere((userCoin) => userCoin["coin_id"] == coin["id"]) !=
                -1,
        title: Text(
          '$coinName',
          style:
              TextStyle(color: AppColors.secondaryDark, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '$coinSymbol',
          style:
              TextStyle(color: AppColors.secondaryDark.withAlpha(200), fontSize: 11),
        ),
        secondary: SizedBox(
          width: 24,
          height: 24,
          child: Image.asset('assets/icons/${coin["symbol"].toLowerCase()}.png'),
        ),
      ),
    );
  }
}
