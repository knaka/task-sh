use clap::Command;
use std::collections::HashMap;
use std::sync::Mutex;
use once_cell::sync::Lazy;

type SubcommandHandler = fn(&clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>>;

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
        self.root_command = self.root_command.clone().subcommand(subcommand.clone());
        self.handler_map.insert(subcommand.get_name().to_string(), handler);
    }
}

include!("subcmds.rs");

static MAIN_COMMAND: Lazy<Mutex<MainCommand>> = Lazy::new(|| {
    Mutex::new(MainCommand::new(Command::new("myapp")))
});

fn list_subcommands(_matches: &clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    let main_command = MAIN_COMMAND.lock().unwrap();
    for (name, _) in main_command.handler_map.iter() {
        println!("{}", name);
    }
    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    {
        let mut main_command = MAIN_COMMAND.lock().unwrap();
        register_subcommands(&mut main_command);
        main_command.register_subcommand(
            Command::new("list")
                .about("List subcommands")
            ,
            list_subcommands,
        );
    }
    let mut root_command = {
        let main_command = MAIN_COMMAND.lock().unwrap();
        main_command.root_command.clone()
    };
    if std::env::args().count() == 1 {
        root_command.print_help()?;
        std::process::exit(0);
    }
    let matches = root_command.get_matches();
    if let Some((subcommand_name, subcommand_matches)) = matches.subcommand() {
        let handler = {
            let main_command = MAIN_COMMAND.lock().unwrap();
            main_command.handler_map.get(subcommand_name).cloned()
        };
        if let Some(handler) = handler {
            return handler(subcommand_matches);
        } else {
            eprintln!("Unknown subcommand: {}", subcommand_name);
        }
    }
    Ok(())
}
