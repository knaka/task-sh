# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4bfdf93-false}" && return 0; sourced_4bfdf93=true

: "${wrangler_toml_path:=$PROJECT_DIR/wrangler.toml}"

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  run_node_modules_bin wrangler bin/wrangler.js "$@"
}

subcmd_cf__name() { # Show the name of the Cloudflare project.
  subcmd_yq --exit-status eval ".name" "$wrangler_toml_path"
}

subcmd_cf__typegen() { # Generate TypeScript types for the Cloudflare project.
  subcmd_wrangler types
}
