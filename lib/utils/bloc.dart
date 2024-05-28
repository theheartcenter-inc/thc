import 'package:flutter/foundation.dart' show ChangeNotifier, ValueNotifier;
import 'package:provider/provider.dart' show ChangeNotifierProvider;

export 'package:provider/provider.dart' show MultiProvider, ReadContext, WatchContext;

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;
typedef BlocProvider<T extends Bloc?> = ChangeNotifierProvider<T>;
