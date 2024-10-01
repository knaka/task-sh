mod subcmd_hello;

use clap::{Command};
use std::collections::HashMap;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut command = Command::new("myapp");
    let mut command_map: HashMap<&str, fn(&clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>>> = HashMap::new();

    command = subcmd_hello::register(command, &mut command_map);

    let matches = command.get_matches();
    if let Some((subcommand_name, args)) = matches.subcommand() {
        if let Some(handler) = command_map.get(subcommand_name) {
            return handler(args);
        } else {
            eprintln!("Unknown subcommand: {}", subcommand_name);
        }
    }
    Ok(())
}
