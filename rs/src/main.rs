use clap::{Command};
use std::collections::HashMap;

type CommandHandler = fn(&clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>>;

pub struct MainCommand {
    root: Command,
    map: HashMap<&'static str, CommandHandler>,
}

impl MainCommand {
    fn new(root_command: Command) -> Self {
        Self {
            root: root_command,
            map: HashMap::new(),
        }
    }

    fn register_subcommand(&mut self, name: &'static str, subcommand: Command, handler: CommandHandler) {
        self.root = self.root.clone().subcommand(subcommand);
        self.map.insert(name, handler);
    }
}

include!("subcmds.rs");

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut main_command = MainCommand::new(
        Command::new(""),
    );
    register_subcommands(&mut main_command);
    let mut root_command = main_command.root.clone();
    if std::env::args().count() == 1 {
        root_command.print_help()?;
        std::process::exit(0);
    }
    let matches = root_command.get_matches();
    if let Some((subcommand_name, subcommand_matches)) = matches.subcommand() {
        let handler = main_command.map.get(subcommand_name);
        if let Some(handler) = handler {
            return handler(subcommand_matches);
        } else {
            eprintln!("Unknown subcommand: {}", subcommand_name);
        }
    }
    Ok(())
}
