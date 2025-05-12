# Event Assistant App

**Autor:** Luiz Gabriel Pagliari Moreira

## Descrição do Aplicativo

O Event Assistant é um aplicativo móvel desenvolvido em Flutter que ajuda na organização de eventos sugerindo cronogramas e atividades com base no tipo do evento e nos detalhes fornecidos pelo usuário. O aplicativo utiliza um Modelo de Linguagem (LLM) através da API OpenAI para fornecer sugestões personalizadas para o planejamento de eventos, tornando o processo mais eficiente e criativo.

## Features

- Criação e gerenciamento de eventos com detalhes como título, descrição, data, local, etc.
- Geração automática de atividades e cronogramas usando IA baseada no tipo de evento
- Sugestões de dicas personalizadas para organização de eventos
- Acompanhamento de atividades com uma checklist
- Interface de usuário intuitiva e moderna seguindo Material Design 3
- Suporte ao modo escuro
- Mecanismo de fallback para quando a API está indisponível

## Tecnologias Utilizadas

- **Flutter (v3.7+)**: Framework UI para desenvolvimento de aplicativos móveis multiplataforma
- **Dart (v3.7+)**: Linguagem de programação
- **Provider (v6.1.2)**: Solução de gerenciamento de estado
- **dart_openai (v5.0.0)**: Cliente da API OpenAI para integração com GPT-3.5
- **Shared Preferences (v2.2.2)**: Armazenamento local para salvar dados dos eventos
- **Flutter DateTime Picker Plus (v2.1.0)**: Para seleção de data e hora
- **Intl (v0.19.0)**: Para formatação de data e hora
- **UUID (v4.3.3)**: Para geração de identificadores únicos

## Instruções de Instalação e Execução

### Pré-requisitos
- Flutter SDK (v3.7.0 ou superior)
- Dart SDK (v3.7.0 ou superior)
- Android Studio / VS Code com plugins Flutter e Dart
- Dispositivo Android (físico ou emulador) ou iOS

### Instalação
1. Clone este repositório:
   ```
   git clone https://github.com/seu-usuario/event_assistant.git
   cd event_assistant
   ```

2. Instale as dependências:
   ```
   flutter pub get
   ```

3. Atualize a chave da API OpenAI em `lib/main.dart` com sua própria chave:
   ```dart
   await LLMService.init('sua-chave-api-openai-aqui');
   ```

4. Execute o aplicativo:
   ```
   flutter run
   ```

### Gerando o APK
Para gerar o APK do aplicativo:
```
flutter build apk --release
```
O APK estará disponível em: `build/app/outputs/flutter-apk/app-release.apk`

## Estrutura do Projeto

- **lib/models/**: Modelos de dados para eventos e atividades
- **lib/providers/**: Gerenciamento de estado usando Provider
- **lib/screens/**: Telas do aplicativo (home, formulário de eventos, detalhes do evento)
- **lib/services/**: Serviços para interação com a API OpenAI
- **lib/utils/**: Utilitários para formatação de data e outras funções
- **lib/widgets/**: Componentes UI reutilizáveis

## Utilização do LLM (GPT-3.5)

O aplicativo Event Assistant utiliza o modelo GPT-3.5 da OpenAI de duas maneiras principais:

1. **Geração de Atividades**: Quando um usuário cria um evento, o aplicativo envia os detalhes do evento (tipo, título, descrição, data, local e número esperado de participantes) para o LLM, que então gera um cronograma detalhado com atividades específicas para aquele tipo de evento. O LLM considera o contexto completo para criar atividades relevantes e cronologicamente coerentes.

2. **Sugestões de Dicas**: O aplicativo também utiliza o LLM para gerar dicas personalizadas para a organização do evento, considerando o tipo de evento, o número de participantes, o local e outros detalhes específicos.

O método de interação com o LLM está implementado na classe `LLMService`, que:
- Formata prompts específicos para cada tipo de solicitação
- Envia os prompts para a API OpenAI usando o modelo gpt-3.5-turbo
- Processa as respostas JSON recebidas
- Implementa um sistema de fallback para quando a API está indisponível ou apresenta falhas

A implementação inclui tratamento de erros robusto e um sistema de geração de dados simulados para garantir que o aplicativo continue funcionando mesmo quando há problemas com a API OpenAI.

## Como o Aplicativo Funciona

1. Os usuários criam um evento fornecendo detalhes como título, descrição, data, local e tipo de evento.
2. O aplicativo envia esses detalhes para a API OpenAI que gera atividades e cronogramas apropriados.
3. Os usuários podem ver as atividades e dicas sugeridas pela IA na tela de detalhes do evento.
4. As atividades podem ser marcadas como concluídas à medida que o planejamento do evento avança.
5. Se a API não estiver disponível, o aplicativo usa um conjunto de atividades e dicas pré-definidas baseadas no tipo de evento.

## Exemplos de Código

### Modelo de Dados (Event e EventActivity)

```dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String eventType;
  final int expectedAttendees;
  final List<EventActivity> activities;
  
  // Construtor e métodos para gerenciar eventos
}

class EventActivity {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  
  // Construtor e métodos para gerenciar atividades
}
```

### Integração com OpenAI (LLMService)

```dart
static Future<List<EventActivity>> generateEventActivities(Event event) async {
  try {
    final prompt = _generatePromptForEventActivities(event);
    
    final chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are an event planning assistant that generates detailed event schedules and activities. Respond with a JSON array of activities."
            )
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, 
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
          ],
        ),
      ],
    );
    
    // Processamento da resposta e conversão para objetos EventActivity
  } catch (e) {
    // Mecanismo de fallback com atividades simuladas
    return _getSimulatedActivities(event);
  }
}
```

## Melhorias Futuras

- Integração com calendário
- Notificações e lembretes
- Acompanhamento de orçamento para eventos
- Gerenciamento de lista de convidados
- Compartilhamento de eventos com outras pessoas
- Suporte offline aprimorado
- Mais tipos de eventos personalizados
