// branchPageBloc.dart
import 'package:flutter/material.dart';
import 'package:inventory_app/bloc/bloc.base.dart';
import 'package:inventory_app/modelss/branch.models.dart';
import 'package:inventory_app/serviecs/login.services.dart';
import 'package:inventory_app/serviecs/reposiory.services.dart';
import 'package:invo_models/invo_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

class branchPageBloc implements BlocBase {
  final Property<List<Branch>> branches = Property([]);
  final Property<String> _selectedBranch = Property("");

  late Repository _repository;

  branchPageBloc() {
    _initializeRepository();
    loadData();
  }

  void _initializeRepository() {
    if (!GetIt.instance.isRegistered<Repository>()) {
      _repository = Repository();
      GetIt.instance.registerSingleton<Repository>(_repository);
    } else {
      _repository = GetIt.instance.get<Repository>();
    }
  }

  Stream<String> get selectedBranchStream => _selectedBranch.stream;

  void selectBranch(String branch) {
    _selectedBranch.sink(branch);
  }

  void dispose() {
    _selectedBranch.dispose();
    branches.dispose();
  }

  Future<bool> loadData() async {
    await _repository.load(); // Always load data from repository
    branches.sink(_repository.branches);
    return true;
  }

  // Call this method to refresh data when entering the branch page
  Future<void> refreshData() async {
    await loadData();
  }
}