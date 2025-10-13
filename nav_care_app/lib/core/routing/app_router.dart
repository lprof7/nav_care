import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/features/authentication/signin/view/signin_page.dart';
import '../../presentation/features/example/view/example_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const SigninPage()),
    GoRoute(path: '/signin', builder: (ctx, st) => const SigninPage()),
  ],
);
