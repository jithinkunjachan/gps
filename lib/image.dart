// lib/native_add.dart
import 'dart:ffi';
import 'dart:io';

import 'image_bindings_generated.dart';

Pointer<Int8> imageConverts(Pointer<Int8> a) => _bindings.imageConverts(a);

const String _libName = 'native_add';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libsum.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final NativeAdd2Bindings _bindings = NativeAdd2Bindings(_dylib);
