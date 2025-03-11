# Documentation du Projet EMA API

Bienvenue dans la documentation du projet EMA API (Exploration de Micro-Aventures). Cette documentation est destinée aux développeurs qui travaillent sur le projet.

## Structure de la documentation

La documentation du projet est organisée comme suit :

1. **[Guide de développement](DEVELOPMENT.md)** - Un guide complet pour les développeurs qui travaillent sur le projet, incluant l'architecture, la configuration, les modèles, les API, etc.

2. **[Documentation technique](TECHNICAL.md)** - Une documentation technique détaillée sur l'architecture, les modèles de données, les API, l'intégration avec l'IA, etc.

3. **Documentation de code** - Générée automatiquement à partir des commentaires YARD dans le code source.

## Génération de la documentation

### Documentation de code avec YARD

Pour générer la documentation de code avec YARD, exécutez la commande suivante :

```bash
bundle exec yard
```

La documentation générée sera disponible dans le répertoire `doc/yard`.

### Visualisation de la documentation

Pour visualiser la documentation générée, ouvrez le fichier `doc/yard/index.html` dans votre navigateur.

## Contribution à la documentation

### Commentaires YARD

Pour contribuer à la documentation de code, utilisez les commentaires YARD dans vos fichiers Ruby. Voici un exemple :

```ruby
# @author Votre Nom
# @since 0.1.0
#
# Description de la classe ou du module
#
# @example
#   # Exemple d'utilisation
class MaClasse
  # Description de la méthode
  #
  # @param param1 [Type] Description du paramètre
  # @return [Type] Description de la valeur de retour
  def ma_methode(param1)
    # ...
  end
end
```

### Documentation Markdown

Pour contribuer à la documentation Markdown, modifiez les fichiers dans le répertoire `docs/`.

## Ressources

- [Guide YARD](https://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
- [Syntaxe Markdown](https://www.markdownguide.org/basic-syntax/)
- [Rails Guides](https://guides.rubyonrails.org/)
