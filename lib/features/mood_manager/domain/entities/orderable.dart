import 'package:equatable/equatable.dart';

class Orderable<T> extends Equatable {
  T child;
  int index;
  Orderable(this.child, this.index);
  @override
  List<Object> get props => [child];

  static List<Orderable> getOrderedList(List children) {
    return children.map((e) => Orderable(e, children.indexOf(e))).toList();
  }
}
