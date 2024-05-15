extension Powers<T extends num> on T {
  T get squared => this * this as T;
  T get cubed => this * this * this as T;
}
