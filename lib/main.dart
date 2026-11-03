
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consulta CEP',
      home: const ConsultaCepPage(),
    );
  }
}

class ConsultaCepPage extends StatefulWidget {
  const ConsultaCepPage({super.key});

  @override
  State<ConsultaCepPage> createState() => _ConsultaCepPageState();
}

class _ConsultaCepPageState extends State<ConsultaCepPage> {
  final TextEditingController cepController = TextEditingController();

  String rua = '';
  String bairro = '';
  String cidade = '';
  String estado = '';
  String mensagem = '';

  bool carregando = false;

  Future<void> consultarCep() async {
    String cep = cepController.text.trim().replaceAll('-', '');

    if (!RegExp(r'^\d{8}$').hasMatch(cep)) {
      setState(() {
        mensagem = 'Digite um CEP válido com 8 números.';
        rua = '';
        bairro = '';
        cidade = '';
        estado = '';
      });
      return;
    }

    setState(() {
      carregando = true;
      mensagem = '';
      rua = '';
      bairro = '';
      cidade = '';
      estado = '';
    });

    try {
      final url = Uri.parse(
        'https://viacep.com.br/ws/$cep/json/',
      );

      final resposta = await http.get(url);

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        if (dados['erro'] == true) {
          setState(() {
            mensagem = 'CEP não encontrado.';
          });
        } else {
          setState(() {
            rua = dados['logradouro'] ?? '';
            bairro = dados['bairro'] ?? '';
            cidade = dados['localidade'] ?? '';
            estado = dados['uf'] ?? '';
            mensagem = 'Consulta realizada com sucesso!';
          });
        }
      } else {
        setState(() {
          mensagem = 'Erro ao consultar o CEP.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensagem = 'Erro de conexão ou resposta inválida.';
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de CEP'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.location_on,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              'Consultar Endereço',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: cepController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                hintText: 'Ex: 01001000',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: carregando ? null : consultarCep,
              child: const Text('Consultar CEP'),
            ),

            const SizedBox(height: 20),

            if (carregando)
              const Center(
                child: CircularProgressIndicator(),
              ),

            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            if (cidade.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rua: $rua'),
                      const SizedBox(height: 10),
                      Text('Bairro: $bairro'),
                      const SizedBox(height: 10),
                      Text('Cidade: $cidade'),
                      const SizedBox(height: 10),
                      Text('Estado: $estado'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
