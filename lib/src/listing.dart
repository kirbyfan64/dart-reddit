part of reddit;


/**
 *
 * The filters included in a Listing are "after", "before", "count", "limit", "show".
 */
class Listing extends FilterableQuery implements Stream<ListingResult> {
  static const List<String> _LISTING_FILTERS = const ["after", "before", "count", "limit", "show"];

  StreamController _controller;

  Listing._(Reddit reddit, String resource, Map params, [Iterable<String> extraFilters = const []])
      : super._(reddit, resource, params, []..addAll(_LISTING_FILTERS)..addAll(extraFilters)) {
    _controller = new StreamController(onListen: fetch);
  }

  Listing after(fullname) {
    if (params.containsKey("before")) {
      throw new StateError("It is not possible to specify both the after and before filter.");
    }
    fullname = new Fullname.cast(fullname);
    params["after"] = fullname;
    return this;
  }

  Listing before(fullname) {
    if (params.containsKey("after")) {
      throw new StateError("It is not possible to specify both the after and before filter.");
    }
    fullname = new Fullname.cast(fullname);
    params["before"] = fullname;
    return this;
  }

  Listing count([int count = 0]) {
    params["count"] = count;
    return this;
  }

  Listing limit([int limit = 25]) {
    params["limit"] = limit;
    return this;
  }

  Listing show() {
    params["show"] = "all";
    return this;
  }

  @override
  Future<ListingResult> fetch() {
    return super.fetch().then((Map result) {
      if(result.containsKey("data")) {
        params["after"] = result["data"]["after"];
        params["before"] = result["data"]["before"];
      }
      ListingResult res = new ListingResult(result, this);
      _controller.add(res);
      return res;
    });
  }

  @override
  noSuchMethod(Invocation inv) {
    if (reflectClass(Stream).instanceMembers.containsKey(inv.memberName) || inv.memberName == const Symbol("listen")) {
      return reflect(_controller.stream).delegate(inv);
    } else {
      return super.noSuchMethod(inv);
    }
  }
}


/**
 * This class is a LinkedHashMap containing data on a Listing stream.
 *
 * You can use it just like the result of [Query.fetch].
 *
 * The method [fetchMore] allows to request the next batch of data.
 */
class ListingResult implements HashMap {
  HashMap _result;
  Listing _listing;

  ListingResult(Map this._result, Listing this._listing);

  dynamic operator[](Object key) => _result[key];
  void operator[]=(dynamic key, dynamic value) => _result[key] = value;

  void addAll(Map other) => _result.addAll(other);
  void clear() => _result.clear();
  bool containsKey(Object key) => _result.containsKey(key);
  bool containsValue(Object value) => _result.containsValue(value);
  void forEach(void f(dynamic key, dynamic value)) => _result.forEach(f);
  dynamic putIfAbsent(dynamic key, dynamic ifAbsent()) =>
    _result.putIfAbsent(key, ifAbsent);
  dynamic remove(Object key) => _result.remove(key);
  String toString() => _result.toString();

  bool get isEmpty => _result.isEmpty;
  bool get isNotEmpty => _result.isNotEmpty;
  Iterable<dynamic> get keys => _result.keys;
  int get length => _result.length;
  Iterable<dynamic> get values => _result.values;

  Future<ListingResult> fetchMore() => _listing.fetch();

}
