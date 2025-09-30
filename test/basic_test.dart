import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Tests', () {
    test('should perform basic arithmetic correctly', () {
      // Arrange
      const a = 5;
      const b = 3;

      // Act
      final sum = a + b;
      final product = a * b;

      // Assert
      expect(sum, 8);
      expect(product, 15);
    });

    test('should handle string operations correctly', () {
      // Arrange
      const firstName = 'John';
      const lastName = 'Doe';

      // Act
      final fullName = '$firstName $lastName';

      // Assert
      expect(fullName, 'John Doe');
      expect(fullName.length, 8);
    });

    test('should work with lists correctly', () {
      // Arrange
      final numbers = [1, 2, 3, 4, 5];

      // Act
      final sum = numbers.fold<int>(0, (sum, number) => sum + number);
      final doubled = numbers.map((n) => n * 2).toList();

      // Assert
      expect(sum, 15);
      expect(doubled, [2, 4, 6, 8, 10]);
      expect(numbers.length, 5);
    });
  });
}