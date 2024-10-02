use clap::Command;
use std::collections::HashMap;

type SubcommandHandler = Box<dyn Fn(&clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>>>;

pub struct MainCommand {
    root_command: Command,
    handler_map: HashMap<String, SubcommandHandler>,
}

impl MainCommand {
    fn new(root_command: Command) -> Self {
        Self {
            root_command,
            handler_map: HashMap::new(),
        }
    }
    fn register_subcommand(&mut self, subcommand: Command, handler: SubcommandHandler) {
        self.root_command = self.root_command.clone().subcommand(&subcommand);
        self.handler_map.insert(subcommand.get_name().to_string(), handler);
    }
}

include!("subcmds.rs");

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut main_command = MainCommand::new(Command::new(""));
    register_subcommands(&mut main_command);
    let subcmd_names: Vec<String> = main_command.handler_map.keys().map(|name| name.clone()).collect();
    main_command.root_command = main_command.root_command.subcommand(
        Command::new("list").about("List subcommand names")
    );
    main_command.register_subcommand(
        Command::new("list").about("List subcommand names"),
        Box::new(move |_matches| {
            for name in &subcmd_names {
                println!("{}", name);
            }
            Ok(())
        })
    );
    if std::env::args().count() == 1 {
        main_command.root_command.print_help()?;
        std::process::exit(0);
    }
    let matches = main_command.root_command.get_matches();
    if let Some((subcommand_name, subcommand_matches)) = matches.subcommand() {
        if let Some(handler) = main_command.handler_map.get(subcommand_name) {
            return handler(subcommand_matches);
        } else {
            eprintln!("Unknown subcommand: {}", subcommand_name);
        }
    }
    Ok(())
}

// use std::sync::{Mutex};
// use once_cell::sync::Lazy;

// static SUBCOMMAND_NAMES: Lazy<Mutex<Vec<String>>> = Lazy::new(|| {
//     Mutex::new(vec![])
// });
