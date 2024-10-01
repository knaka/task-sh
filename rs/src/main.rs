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
        self.root_command = self.root_command.clone().subcommand(&subcommand);
        self.handler_map.insert(subcommand.get_name().to_string(), handler);
    }
}

include!("subcmds.rs");

static SUBCOMMAND_NAMES: Lazy<Mutex<Vec<String>>> = Lazy::new(|| {
    Mutex::new(vec![])
});

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut main_command = MainCommand::new(Command::new("myapp"));
    register_subcommands(&mut main_command);
    {
        let mut subcommand_names = SUBCOMMAND_NAMES.lock().unwrap();
        for (subcommand_name, _) in main_command.handler_map.iter() {
            subcommand_names.push(subcommand_name.clone());
        }
    }
    main_command.register_subcommand(
        Command::new("list").about("List subcommands"),
        |_matches: &clap::ArgMatches| {
            for subcommand_name in SUBCOMMAND_NAMES.lock().unwrap().iter() {
                println!("{}", subcommand_name);
            }
            Ok(())
        }
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
