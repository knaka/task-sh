use clap::{Command, ArgMatches};
use crate::SUBCOMMAND_NAMES;

pub fn meta() -> Command {
    Command::new("list")
        .about("List subcommands")
}

pub fn handler(_matches: &ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    for subcommand_name in SUBCOMMAND_NAMES.lock().unwrap().iter() {
        println!("{}", subcommand_name);
    }
    Ok(())
}
