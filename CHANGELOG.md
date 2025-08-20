# Changelog
## [1.4.0] - 2025-08-20

* Minor release: API is backwards compatible; updated package metadata and documentation
* Bumped version to 1.4.0

## [1.3.35] - 2025-08-20

* Bumped package version to 1.3.35
* Packaging fixes: ensured test helpers are not exported from the public API and updated metadata for pub.dev validation

## [1.3.33] - 2024-12-21

* Improved architecture diagram layout and visual balance
* Centered all components horizontally and vertically for better presentation
* Removed redundant legend and key components sections for cleaner design
* Enhanced diagram clarity by removing specific example labels (Counter, Settings)

## [1.3.32] - 2024-12-21

* Updated package icon configuration for pub.dev display
* Refined screenshots configuration with logo and architecture diagram
* Added funding support information

## [1.3.31] - 2024-12-21

* Updated documentation with corrected API examples
* Fixed BoundWidget usage examples to match actual implementation
* Improved code clarity and removed deprecated references

## 1.3.29

* Fixed incorrect parameter name in README examples: `binderBuilder` → `binder`
* Corrected BoundWidget usage examples to match actual API

## 1.3.28

* Updated architecture diagram to demonstrate "One Widget → One Binder" principle
* Enhanced visual representation with proper widget-to-binder relationships
* Improved diagram layout and text positioning for better clarity

## 1.3.27

* Added comprehensive architecture diagram showing Flutter FBI component interactions
* Enhanced README with detailed visual representation of Feature-Binder-Interface pattern
* Improved documentation with architecture flow diagrams and component relationships

## 1.3.26

* Added official package icon for pub.dev sidebar display

## 1.3.25

* Added comprehensive code examples for Feature Binder and Multi-Feature patterns in README
* Enhanced documentation with complete working examples showing Events, States, Features, Binders, and UI components
* Improved developer experience with copy-paste ready code examples

## 1.3.24

* Added Flutter FBI logo and improved README design with badges and centered layout
* Updated installation instructions to reflect current version

## 1.3.23

* Added platform support for all Flutter platforms (Android, iOS, Linux, macOS, Web, Windows)
* Added dart3-compatible tag for Dart 3 compatibility indication

## 1.3.22

* Added comprehensive documentation for uiStatePreprocessor in Binder Layer
* Enhanced README with detailed explanation of state preprocessing functionality

## 1.3.21

* Updated installation instructions in README.md to reflect current version

## 1.3.20

* Fixed widget creation anti-patterns: replaced widget-building methods with private widget classes
* Made all FeatureState fields non-nullable except error fields
* Moved fallback value logic from UI to Binder stateTransformer methods  
* Replaced direct feature references with getFeature<T>() in MultiFeatureBinder
* Improved architecture diagrams with proper data flow visualization
* Enhanced examples with better Flutter best practices

## 1.3.10

* Added comprehensive example project demonstrating all features of the library
* Improved documentation and README

## 1.3.0

* Added support for multiple features with MultiFeatureBinder
* Added side effect handling to Feature class

## 1.2.0

* Added FeatureBinder and BaseFeature for business logic separation
* Improved stability and fixed memory leaks

## 1.1.0

* Added SimpleBinder for basic UI state management
* Added bound widgets that handle lifecycle management

## 1.0.0

* Initial release with core architecture components
* Support for reactive state management with RxDart
