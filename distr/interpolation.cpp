#include <iostream>
#include <format>
#include <vector>
#include <cmath>
#include <numeric>
#include <cfloat>
#include <cstdio>

// Структура для представления точки данных
struct Point {
    double x;
    double y;
};

// Метод Гаусса для решения СЛУ (Ax = B)
std::vector<double> solveLinearSystem(std::vector<std::vector<double>>& A, std::vector<double>& B) {
    int n = B.size();
    for (int i = 0; i < n; ++i) {
        // Поиск максимального элемента в столбце для устойчивости
        int maxRow = i;
        for (int k = i + 1; k < n; ++k) {
            if (std::abs(A[k][i]) > std::abs(A[maxRow][i])) {
                maxRow = k;
            }
        }
        std::swap(A[i], A[maxRow]);
        std::swap(B[i], B[maxRow]);

        // Прямой ход
        for (int k = i + 1; k < n; ++k) {
            double c = -A[k][i] / A[i][i];
            for (int j = i; j < n; ++j) {
                if (i == j) {
                    A[k][j] = 0;
                } else {
                    A[k][j] += c * A[i][j];
                }
            }
            B[k] += c * B[i];
        }
    }

    // Обратный ход
    std::vector<double> X(n);
    for (int i = n - 1; i >= 0; --i) {
        X[i] = B[i] / A[i][i];
        for (int k = i - 1; k >= 0; --k) {
            B[k] -= A[k][i] * X[i];
        }
    }
    return X;
}

// Класс гармонического интерполятора
class HarmonicInterpolator {
private:
    double omega;            // Базовая частота
    std::vector<double> coeffs; // Коэффициенты [a0, a1, b1, a2, b2, ...]
    int numHarmonics;        // Число гармоник (M)

public:
    // Инициализация и расчет коэффициентов
    void fit(const std::vector<Point>& points, int M, double period) {
        numHarmonics = M;
        omega = 2.0 * M_PI / period;
        
        int numCoeffs = 1 + 2 * M; // a0 + M косинусов + M синусов
        int N = points.size();

        // Матрицы для системы нормальных уравнений МНК
        std::vector<std::vector<double>> A(numCoeffs, std::vector<double>(numCoeffs, 0.0));
        std::vector<double> B(numCoeffs, 0.0);

        // Функция для вычисления j-го базисного полинома в точке x
        auto getBasis = [&](double x, int j) {
            if (j == 0) return 1.0;
            int harmonic = (j + 1) / 2;
            if (j % 2 != 0) {
                return std::cos(harmonic * omega * x);
            } else {
                return std::sin(harmonic * omega * x);
            }
        };

        // Составление матрицы СЛУ по методу наименьших квадратов
        for (int i = 0; i < numCoeffs; ++i) {
            for (int j = 0; j < numCoeffs; ++j) {
                double sum = 0.0;
                for (const auto& p : points) {
					// std::cout << sum << "\n";
                    sum += getBasis(p.x, i) * getBasis(p.x, j);
                }
                A[i][j] = sum;
            }
            double sumY = 0.0;
            for (const auto& p : points) {
                sumY += p.y * getBasis(p.x, i);
            }
            B[i] = sumY;
        }

        // Решаем систему и получаем коэффициенты
        coeffs = solveLinearSystem(A, B);
    }

    // Вычисление значения в произвольной точке x
    double evaluate(double x) const {
        double result = coeffs[0]; // Смещение a0
        for (int k = 1; k <= numHarmonics; ++k) {
            double a_k = coeffs[2 * k - 1];
            double b_k = coeffs[2 * k];
            result += a_k * std::cos(k * omega * x) + b_k * std::sin(k * omega * x);
        }
        return result;
    }

    // Вывод полученных коэффициентов
    void printCoefficients() const {
        std::printf("%.8f\n", coeffs[0]);
        for (int k = 1; k <= numHarmonics; ++k) {
            printf("%.8f\n", coeffs[2 * k - 1]);
			printf("%.8f\n", coeffs[2 * k]);
        }
    }
};

int main() {
    // Входные точки (например, зашумленный синус)
    std::vector<Point> points;
    

    double period; // Ожидаемый период функции
    int M;           // Количество используемых гармоник (переменное число)
    int l;
    
    std::cin >> period;
    std::cin >> M;
    
    std::cin >> l;
    
    for (int i = 1 ; i <= l ; i++) {
		float x, y;
		std::cin >> x;
		std::cin >> y;
		Point p = {x, y};
		points.push_back(p);
	}

    HarmonicInterpolator interpolator;
    interpolator.fit(points, M, period);

//    std::cout << "--- Вычисленные коэффициенты Фурье ---" << std::endl;
    interpolator.printCoefficients();


    return 0;
}
