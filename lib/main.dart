import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

enum City {
  tokyo,
  osaka,
  nagoya,
}

typedef Weather = String;
Future<Weather> getWeather(City city) async {
  return Future.delayed(
      const Duration(seconds: 1),
      () => {
            City.tokyo: 'sunny',
            City.osaka: 'rainy',
            City.nagoya: 'cloudy',
          }[city]!);
}

final currentCityProvider = StateProvider<City?>((ref) => null);

final weatherProvider = FutureProvider.autoDispose<Weather>((ref) async {
  final city = ref.watch(currentCityProvider);
  if (city == null) {
    return 'Unknown Weather';
  }
  return getWeather(city);
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Example3(),
    );
  }
}

class Example3 extends ConsumerWidget {
  const Example3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 3'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: City.values.length,
                itemBuilder: (context, index) {
                  final city = City.values[index];
                  return ListTile(
                    title: Text(
                      city.toString(),
                      style: blackTextStyle,
                    ),
                    onTap: () {
                      ref.read(currentCityProvider.notifier).state = city;
                    },
                    trailing:
                        ref.watch(currentCityProvider.notifier).state == city
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : null,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            currentWeather.when(
              data: (data) {
                return Text(data,style: blackTextStyle,);
              },
              error: (_, __) {
                return const Text(
                  'Error',
                  style: blackTextStyle,
                );
              },
              loading: () {
                return const CircularProgressIndicator();
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

const blackTextStyle = TextStyle(color: Colors.black, fontSize: 20.0);
