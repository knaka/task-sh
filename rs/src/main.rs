// mod subcmd_goodbye;
mod subcmd_hello;
// mod subcmd_list;

use clap::{Command};
use once_cell::sync::Lazy;
use std::collections::HashMap;
use std::sync::Mutex;

type CommandHandler = fn(&clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>>;

struct MainCommand {
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

    fn register(&mut self, name: &'static str, subcommand: Command, handler: CommandHandler) {
        self.root = self.root.clone().subcommand(subcommand);
        self.map.insert(name, handler);
    }
}

static ROOT_COMMAND: Lazy<Mutex<MainCommand>> = Lazy::new(|| {
    let root_command = Command::new("myapp")
        .about("My super CLI app")
        .version("0.1.0");
    Mutex::new(MainCommand::new(root_command))
});

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let main_command = ROOT_COMMAND.lock().unwrap();
    let mut root_command = main_command.root.clone();
    let matches = root_command.clone().get_matches();
    if matches.subcommand().is_none() {
        root_command.print_help()?;
        std::process::exit(0);
    }
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
