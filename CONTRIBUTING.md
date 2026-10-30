[mise]: https://mise.jdx.dev/

# 🚀 Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes.

## 📥 Prerequisites

The following software is required to be installed on your system:

- [Erlang 27+](https://www.erlang.org/downloads)
- [Elixir 1.18+](https://elixir-lang.org/install.html)
- [PostgreSQL 14+](https://www.postgresql.org/download/) (see
  [this section](#-docker) for setting it up with Docker)

We recommend using [mise][mise] to install and manage all the programming
languages' requirements. The required versions are listed in the
`.tool-versions` file, which mise reads.

If you prefer to use Docker, see the [section below](#-docker).

## 🔧 Setup

First, clone the repository:

```
git clone git@github.com:cesium/atlas.git
cd atlas
```

Then, if you are using mise, install the required tools:

```
mise install
```

Create your environment file and change it as needed:

```
cp .env.dev.sample .env.dev
```

| Variable              | Description                                                             |
| --------------------- | ----------------------------------------------------------------------- |
| `FRONTEND_URL`        | URL of the frontend (defaults to `http://localhost:3000`)               |
| `KEPLER_API_URL`      | URL of the Kepler API (defaults to `http://localhost:8000/api/v1`)      |
| `TELESCOPIUM_API_URL` | URL of the Telescopium API (defaults to `http://localhost:5000/api/v1`) |

Finally, make sure the database is up and running and run the setup script to
get all dependencies configured:

```
bin/setup --local
```

Run this script again if you change the `.env.dev` file.

## 🔨 Development

Start the development server and then you can send requests to
`http://localhost:4000`.

```
bin/server
```

Run the tests.

```
bin/test
```

Lint your code.

```
bin/lint
```

Format your code.

```
bin/format
```

## 🐳 Docker

For data persistence this project uses a PostgreSQL database. You should have
PostgreSQL up and running.

If you want to set up the required database using Docker containers you can
easily do it with [Docker Compose](https://docs.docker.com/compose/install/).

Create the environment file, then create and start the database container. You
should use `linux.yml` if running on Linux and `darwin.yml` if running on macOS.

```
cp .env.dev.sample .env.dev
docker compose -f compose.dev.yaml -f {linux,darwin}.yml up db
```

Start the previously created containers.

```
docker compose -f compose.dev.yaml -f {linux,darwin}.yml start
```

Stop the containers.

```
docker compose -f compose.dev.yaml -f {linux,darwin}.yml stop
```

Destroy the containers and volumes created.

```
docker compose -f compose.dev.yaml -f {linux,darwin}.yml down -v
```

## 🔗 References

You can use these resources to learn more about the technologies this project
uses.

- [Getting Started with Elixir](https://elixir-lang.org/getting-started/introduction.html)
- [Erlang/Elixir Syntax: A Crash Course](https://elixir-lang.org/crash-course.html)
- [Elixir School Course](https://elixirschool.com/en/)
- [Phoenix Guides Overview](https://hexdocs.pm/phoenix/overview.html)
- [Phoenix Documentation](https://hexdocs.pm/phoenix)
- [Ecto Documentation](https://hexdocs.pm/ecto)
