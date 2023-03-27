# Projet-compilation

Le code présenté correspond à un compilateur pour un sous-ensemble du langage Java. 
Le langage implémenté contient les fonctionnalités suivantes :

Déclaration de variables de type int
Affectation de valeurs à des variables
Lecture et écriture de valeurs sur l'entrée/sortie standard
Opérations arithmétiques sur les entiers (+, -, *, /)
Structures de contrôle : boucle "repeter tantque" et blocs d'instructions.

Le compilateur est implémenté en utilisant la bibliothèque ANTLR, qui fournit un générateur de code pour les analyseurs lexicaux et syntaxiques. 
Le compilateur est écrit en Java et utilise une table des symboles pour stocker les informations sur les variables déclarées dans le programme en entrée.

Le compilateur est implémenté en plusieurs étapes : l'analyse lexicale, l'analyse syntaxique, l'analyse sémantique et la génération de code.
L'analyse lexicale permet de reconnaître les différents lexèmes du langage (mots clés, opérateurs, identifiants, nombres, etc.).
L'analyse syntaxique permet de construire l'arbre de syntaxe abstraite correspondant au programme en entrée.
L'analyse sémantique permet de vérifier la conformité du programme aux règles du langage et de construire une table des symboles. 
Enfin, la génération de code permet de produire le code objet correspondant au programme en entrée.

Le code présenté contient des règles de grammaire pour chaque constructeur du langage.
Les règles de grammaire sont écrites en utilisant la syntaxe BNF (Backus-Naur Form), qui est une notation formelle pour décrire la syntaxe d'un langage de programmation.
Chaque règle de grammaire correspond à un constructeur du langage et est implémentée en utilisant du code Java qui génère du code objet correspondant à la règle.
