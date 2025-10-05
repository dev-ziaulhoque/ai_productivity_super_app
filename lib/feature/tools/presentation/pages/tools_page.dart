import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tools_bloc.dart';
import '../../data/datasources/tools_remote_datasource.dart';
import '../../data/repositories/tools_repository_impl.dart';
import '../widgets/image_gen_widget.dart';
import '../widgets/doc_helper_widget.dart';
import '../widgets/voice_widget.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Tools'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.image), text: 'Image Gen'),
              Tab(icon: Icon(Icons.document_scanner), text: 'Doc Helper'),
              Tab(icon: Icon(Icons.mic), text: 'Voice'),
            ],
          ),
        ),
        body: BlocProvider(
          create: (context) => ToolsBloc(
            ToolsRepositoryImpl(remoteDataSource: ToolsRemoteDataSource()),
          ),
          child: TabBarView(
            children: const [
              ImageGenWidget(),
              DocHelperWidget(),
              VoiceWidget(),
            ],
          ),
        ),
      ),
    );
  }
}