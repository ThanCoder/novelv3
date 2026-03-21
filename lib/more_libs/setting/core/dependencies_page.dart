import 'package:flutter/material.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:yaml/yaml.dart';

class DependenciesPage extends StatelessWidget {
  final dynamic yaml;
  const DependenciesPage({super.key, required this.yaml});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dependencies')),
      body: TScrollableColumn(
        children: [
          Text(
            'Dependencies',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          _dependencies(),
          Text(
            'Dev Dependencies',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          _devDependencies(),
        ],
      ),
    );
  }

  Widget _devDependencies() {
    final devDependencies = yaml['dev_dependencies'];
    return _showList(devDependencies);
  }

  Widget _dependencies() {
    final map = yaml['dependencies'];
    return _showList(map);
  }

  Widget _showList(dynamic mapValue) {
    final depList = (mapValue as YamlMap).keys.toList();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: depList.length,
      itemBuilder: (context, index) => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: depList[index].toString(),
              style: TextStyle(color: Colors.blue),
            ),
            TextSpan(text: ' : ${mapValue[depList[index].toString()]}'),
          ],
        ),
      ),
    );
  }
}
