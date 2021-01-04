abstract class CounterEvent {
  final int amount;

  CounterEvent(this.amount);
}

class CounterIncrementEvent extends CounterEvent {
  CounterIncrementEvent([int amount = 1]) : super(amount);
}

class CounterDecrementEvent extends CounterEvent {
  CounterDecrementEvent([int amount = 1]) : super(amount);
}
