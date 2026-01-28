enum Semester {
  spring(label: '前期'),
  fall(label: '後期');

  const Semester({required this.label});

  final String label;

  int get number {
    switch (this) {
      case Semester.spring:
        return 10;
      case Semester.fall:
        return 20;
    }
  }
}
