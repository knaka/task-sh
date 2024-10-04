use clap::Command;
use std::collections::HashMap;

type SubcommandHandler = Box<dyn Fn(&clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>>>;

pub struct App {
    main_command: Command,
    handler_map: HashMap<String, SubcommandHandler>,
}

impl App {
    fn new(main_command: Command) -> Self {
        Self {
            main_command,
            handler_map: HashMap::new(),
        }
    }
    fn register_subcommand(&mut self, subcommand: Command, handler: SubcommandHandler) {
        // Cannot move self.main_command because self is borrowed as mutable.
        self.main_command = self.main_command.clone().subcommand(&subcommand);
        self.handler_map.insert(subcommand.get_name().to_string(), handler);
    }
}

include!("subcmds.rs");

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut app = App::new(Command::new(""));
    register_subcommands(&mut app);
    let subcmd_names = app.handler_map.keys()
        .map(|subcmd_name| String::from(subcmd_name)).collect::<Vec<String>>();
    app.register_subcommand(
        Command::new("list").about("List subcommand names"),
        Box::new(move |_matches| {
            for subcmd_name in &subcmd_names {
                println!("{}", subcmd_name);
            }
            Ok(())
        })
    );
    if std::env::args().count() <= 1 {
        app.main_command.print_help()?;
        std::process::exit(0);
    }
    let matches = app.main_command.get_matches();
    let (subcommand_name, subcommand_matches) = matches.subcommand().unwrap();
    return app.handler_map.get(subcommand_name).unwrap()(subcommand_matches);
}
