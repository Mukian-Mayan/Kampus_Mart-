// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor: AppTheme.deepBlue,
        title: const Text(
          'Our Story',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoBox(
                title: 'How It Started',
                content:
                    'This app was born out of a simple idea: to help freshers easily find what they need on campus — books, gadgets, supplies — from trusted finalists who already have these items.',
              ),
              const SizedBox(height: 16),
              InfoBox(
                title: 'Connecting Buyers and Sellers',
                content:
                    'Freshers can browse listings, chat with sellers (finalists), and get the best deals from people they can trust within their campus community.',
              ),
              const SizedBox(height: 16),
              InfoBox(
                title: 'Empowering Students',
                content:
                    'Finalists get a safe, easy way to sell what they no longer need. Freshers get affordable supplies. It\'s a win-win that keeps resources circulating on campus!',
              ),
              const SizedBox(height: 16),
              InfoBox(
                title: 'Our Mission',
                content:
                    'Our mission is to make campus life easier, more sustainable, and connected by bringing students together through a simple, reliable marketplace.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const InfoBox({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
