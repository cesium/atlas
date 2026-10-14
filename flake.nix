{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      pg = pkgs.postgresql_16;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          beamMinimal27Packages.elixir_1_18
          inotify-tools
          pg
        ];

        shellHook = ''
          export PGDATA="$PWD/.direnv/db"
          export HOST_COMMON="-h 127.0.0.1 -p 5432"
          export ATLAS_API_URL="http://localhost:4000"
          export FRONTEND_URL="http://localhost:3000"
          export PGHOST="/tmp"

          # Clean up any legacy socket file left inside PGDATA
          rm -f "$PGDATA"/.s.PGSQL.* 2>/dev/null

          if [ ! -d "$PGDATA" ]; then
            ${pg}/bin/initdb --auth=trust -U postgres "$PGDATA" > /dev/null
          fi

          if ! ${pg}/bin/pg_ctl status -D "$PGDATA" > /dev/null 2>&1; then
            ${pg}/bin/pg_ctl start \
              -D "$PGDATA" \
              -l "$PGDATA/postgres.log" \
              -o "-k /tmp -p 5432"
          fi

          trap "${pg}/bin/pg_ctl stop -D '$PGDATA' -m fast" EXIT
        '';
      };
    };
}