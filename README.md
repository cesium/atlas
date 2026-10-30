[contributing]: CONTRIBUTING.md
[code_of_conduct]: CODE_OF_CONDUCT.md
[license]: LICENSE
[ci-style-status]: https://github.com/cesium/atlas/actions/workflows/style.yml/badge.svg
[ci-style-workflow]: https://github.com/cesium/atlas/actions/workflows/style.yml

# Atlas

[![CI Style][ci-style-status]][ci-style-workflow]

Atlas is the backend used by [Pombo](https://pombo.di.uminho.pt/), CeSIUM's platform for LEI students at UMinho. Built with [Elixir](https://elixir-lang.org/) and [Phoenix Framework](https://www.phoenixframework.org/), it acts as the primary data source and central API for the entire platform.

It is responsible for storing and managing university courses, shifts, student enrollments, shift exchanges, and schedules, as well as integrating with Kepler for schedule generation and Telescopium for cross-checking classroom and timetable data.

## How it fits in Pombo

Pombo is made of four repositories:

- [Astra](https://github.com/cesium/astra): frontend
- **Atlas**: backend
- [Kepler](https://github.com/cesium/kepler): schedule generation
- [Telescopium](https://github.com/cesium/telescopium): scraper used to update and cross-check data

## 🤝 Contributing

When contributing to this repository, please first discuss the change you wish
to make via discussions, issue, email, or any other method with the owners of
this repository before making a change.

Please note we have a [Code of Conduct][code_of_conduct], please follow it
in all your interactions with the project.

We have a [Contributing Guide][contributing] to help you getting started.

## 📝 License

<img src=".github/brand/cesium-DARK.svg#gh-light-mode-only" width="300">
<img src=".github/brand/cesium-LIGHT.svg#gh-dark-mode-only" width="300">

Copyright (c) 2026, CeSIUM.

This project is licensed under the MIT License - see the [LICENSE][license]
file for details.