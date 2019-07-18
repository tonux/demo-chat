# Project Title
Mini-chat with Erlang
## Context

Réaliser l’application suivante :Minimal chat application erlang qui accepte des connexions TCP entrantes (en utilisant telnet par exemple) chaque session doit permettre d'envoyer vers les autres sessions chaque ligne de texte terminée par la touche entrée. Par exemple 
* 1. lancement du programme erlang sur le port 4000
* 2. deux terminaux lancent "telnet localhost 4000"
* 3. quand on entre dans un terminal "bonjour", "bonjour" est envoyé vers l'autre terminal
* 4. un troisième telnet se connecte la phrase tapée se répercute sur les autres terminaux
* 4. quand un terminal se déconnecte la phrase "déconnection de votre interlocuteur" est envoyé aux autres terminaux
* 5. chaque session utilise un nom "friendly" pour savoir qui a tapé quoi (et qui se déconnecte)

### Prerequisites

* Erlang (SMP,ASYNC_THREADS,HIPE) (BEAM) emulator version 10.4.4

### Installing

```
https://medium.com/erlang-central/erlang-quick-install-9c5dcaa5b634
```

## Deployment

* open terminal
* erl
* c(demo_chat).
* demo_chat:run().

## - Run client
* open terminal
* telnet localhost 4000

## Authors

* **Tonux SAMB** - 
