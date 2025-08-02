import Config

config :atlas, Oban,
  repo: Atlas.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, emails: 5]
